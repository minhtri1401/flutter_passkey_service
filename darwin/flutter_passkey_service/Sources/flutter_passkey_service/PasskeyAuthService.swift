
import AuthenticationServices
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

/**
 A protocol that defines passkey-based authentication and registration services.

 Implementations of this protocol should handle the necessary steps for both user authentication and registration using passkey challenges.
 */
protocol PasskeyAuthService {
    /**
     Authenticates a user using a passkey.

     This method initiates the authentication process by using the provided request options to generate and verify a passkey challenge. The result is returned asynchronously through the completion handler.

     - Parameter request: An instance of `AuthGenerateOptionResponseData` that contains the challenge and options required for authentication.
     - Parameter completion: A closure executed once authentication is complete. It provides a `Result` which, on success, contains a `GetPasskeyAuthenticationResponseData` with the authentication details, or on failure, an `Error` describing what went wrong.
     */
    func authenticate(request: AuthGenerateOptionResponseData, completion: @escaping (Result<GetPasskeyAuthenticationResponseData, Error>) -> Void)
    
    /**
     Registers a user using a passkey.

     This method initiates the registration process by processing the registration option data to generate and verify a registration challenge. The result is delivered asynchronously via the completion handler.

     - Parameter option: An instance of `RegisterGenerateOptionData` that contains the registration options and challenge details.
     - Parameter completion: A closure executed after registration completes. It provides a `Result` which, on success, includes a `CreatePasskeyResponseData` with the registration details, or on failure, an `Error` indicating the problem encountered.
     */
    func register(option: RegisterGenerateOptionData, completion: @escaping (Result<CreatePasskeyResponseData, Error>) -> Void)
}


@available(iOS 16.0, macOS 13.0, *)
class PasskeyAuthServiceImpl: PasskeyAuthService {
    private let window: ASPresentationAnchor
    private var registerController: RegisterController? = nil
    private var authenController: AuthenticateController? = nil
    /// True while an ASAuthorizationController sheet is up. Pigeon calls arrive on the main
    /// thread, so a plain Bool is sufficient.
    private var operationInFlight = false

    init(window: ASPresentationAnchor) {
        self.window = window
    }

    // MARK: PasskeyAuthService

    func authenticate(request: AuthGenerateOptionResponseData, completion: @escaping (Result<GetPasskeyAuthenticationResponseData, Error>) -> Void) {
        guard beginOperation() else {
            completion(.failure(pigeonError(operationInProgressError())))
            return
        }
        let finish = wrapCompletion(completion)

        guard let challenge = Data.fromBase64Url(request.challenge) else {
            finish(.failure(pigeonError(convertCustomError(.decodingChallenge))))
            return
        }

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: request.rpId)
        let assertion = provider.createCredentialAssertionRequest(challenge: challenge)
        assertion.allowedCredentials = parseCredentials(credentialIDs: request.allowCredentials.map { $0.id })
        if let uv = userVerificationPreference(from: request.userVerification) {
            assertion.userVerificationPreference = uv
        }
        applyPrfAssertionInput(request.extensions?.prf, to: assertion)
        applyLargeBlobAssertionInput(request.extensions?.largeBlob, to: assertion)

        let preferImmediate = request.preferImmediatelyAvailableCredentials ?? false
        authenController = AuthenticateController(
            window: window,
            preferImmediatelyAvailableCredentials: preferImmediate,
            completion: finish
        )
        authenController?.run(request: assertion)
    }

    func register(option: RegisterGenerateOptionData, completion: @escaping (Result<CreatePasskeyResponseData, Error>) -> Void) {
        guard beginOperation() else {
            completion(.failure(pigeonError(operationInProgressError())))
            return
        }
        let finish = wrapCompletion(completion)

        guard let challenge = Data.fromBase64Url(option.challenge) else {
            finish(.failure(pigeonError(convertCustomError(.decodingChallenge))))
            return
        }

        // WebAuthn JSON carries user.id as base64url bytes. Android's Credential Manager decodes
        // it the same way, so both platforms now produce the same user handle.
        guard let userID = Data.fromBase64Url(option.user.id), !userID.isEmpty else {
            finish(.failure(pigeonError(PasskeyException(
                errorType: .invalidFormat,
                message: "user.id must be base64url-encoded",
                details: "WebAuthn user.id is the base64url encoding of the user handle bytes; received \"\(option.user.id)\""
            ))))
            return
        }

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: option.rp.id)
        let request = provider.createCredentialRegistrationRequest(
            challenge: challenge,
            name: option.user.name,
            userID: userID
        )
        if !option.user.displayName.isEmpty {
            request.displayName = option.user.displayName
        }
        if let uv = userVerificationPreference(from: option.authenticatorSelection?.userVerification) {
            request.userVerificationPreference = uv
        }
        if let kind = attestationKind(from: option.attestation) {
            request.attestationPreference = kind
        }
        if #available(iOS 17.4, macOS 13.5, *) {
            request.excludedCredentials = parseCredentials(credentialIDs: option.excludeCredentials.map { $0.id })
        }
        applyPrfRegistrationInput(option.extensions.prf, to: request)
        applyLargeBlobRegistrationInput(option.extensions.largeBlob, to: request)

        registerController = RegisterController(window: window, username: option.user.name, completion: finish)
        registerController?.run(request: request)
    }

    // MARK: In-flight guard

    private func beginOperation() -> Bool {
        if operationInFlight { return false }
        operationInFlight = true
        return true
    }

    private func wrapCompletion<T>(_ completion: @escaping (Result<T, Error>) -> Void) -> (Result<T, Error>) -> Void {
        return { [weak self] result in
            self?.operationInFlight = false
            completion(result)
        }
    }

    private func operationInProgressError() -> PasskeyException {
        PasskeyException(
            errorType: .operationNotSupported,
            message: "A passkey operation is already in progress",
            details: "Wait for the pending register/authenticate call to complete before starting another"
        )
    }

    // MARK: Extension inputs

    @available(iOS 18.0, macOS 15.0, *)
    private func prfInputValues(from eval: [String?: String?]) -> ASAuthorizationPublicKeyCredentialPRFAssertionInput.InputValues? {
        guard let firstStr = eval["first"] as? String, let salt1 = Data.fromBase64Url(firstStr) else {
            return nil
        }
        var salt2: Data? = nil
        if let secondStr = eval["second"] as? String {
            salt2 = Data.fromBase64Url(secondStr)
        }
        return ASAuthorizationPublicKeyCredentialPRFAssertionInput.InputValues(saltInput1: salt1, saltInput2: salt2)
    }

    private func applyPrfAssertionInput(_ prf: PrfExtensionInput?, to request: ASAuthorizationPlatformPublicKeyCredentialAssertionRequest) {
        guard #available(iOS 18.0, macOS 15.0, *), let eval = prf?.eval, let values = prfInputValues(from: eval) else {
            return
        }
        request.prf = .inputValues(values)
    }

    private func applyPrfRegistrationInput(_ prf: PrfExtensionInput?, to request: ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest) {
        guard #available(iOS 18.0, macOS 15.0, *), let prf = prf else {
            return
        }
        if let eval = prf.eval, let values = prfInputValues(from: eval) {
            // Evaluate salts at creation time; results come back in clientExtensionResults.prf.results.
            request.prf = .inputValues(values)
        } else {
            request.prf = .checkForSupport
        }
    }

    private func applyLargeBlobAssertionInput(_ input: LargeBlobExtensionAuthInput?, to request: ASAuthorizationPlatformPublicKeyCredentialAssertionRequest) {
        guard #available(iOS 17.0, macOS 14.0, *), let input = input else {
            return
        }
        if input.read == true {
            request.largeBlob = .read
        } else if let write = input.write {
            request.largeBlob = .write(write.data)
        }
    }

    private func applyLargeBlobRegistrationInput(_ input: LargeBlobExtensionRegistrationInput?, to request: ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest) {
        guard #available(iOS 17.0, macOS 14.0, *), let input = input else {
            return
        }
        request.largeBlob = input.support == "required" ? .supportRequired : .supportPreferred
    }

    private func parseCredentials(credentialIDs: [String]) -> [ASAuthorizationPlatformPublicKeyCredentialDescriptor] {
        credentialIDs.compactMap { id in
            Data.fromBase64Url(id).map { ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: $0) }
        }
    }
}

