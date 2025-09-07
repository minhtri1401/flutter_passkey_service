
import AuthenticationServices

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


@available(iOS 16.0, *)
class PasskeyAuthServiceImpl: PasskeyAuthService {
    let lock: NSLock = NSLock();
    private let window: ASPresentationAnchor
    private var registerController: RegisterController? = nil
    private var authenController: AuthenticateController? = nil
    
    init(window: ASPresentationAnchor) {
        self.window = window
    }
    
    func authenticate(request: AuthGenerateOptionResponseData, completion: @escaping (Result<GetPasskeyAuthenticationResponseData, Error>) -> Void) {
        guard let decodedChallenge = Data.fromBase64Url(request.challenge) else {
            let error = convertCustomError(.decodingChallenge)
            completion(.failure(PigeonError(code: "PASSKEY_ERROR", message: error.message, details: error)))
            return
        }

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: request.rpId)
        let credentialRequest = platformProvider.createCredentialAssertionRequest(
            challenge: decodedChallenge
        )
                
        credentialRequest.allowedCredentials = parseCredentials(credentialIDs: request.allowCredentials.map { e in e.id })
                
        authenController = AuthenticateController(window: self.window, completion: completion)
        authenController?.run(request: credentialRequest, preferImmediatelyAvailableCredentials: false)
        
    }
    
    func register(option: RegisterGenerateOptionData, completion: @escaping (Result<CreatePasskeyResponseData, Error>) -> Void) {
        guard let decodedChallenge = Data.fromBase64Url(option.challenge) else {
            let error = convertCustomError(.decodingChallenge)
            completion(.failure(PigeonError(code: "PASSKEY_ERROR", message: error.message, details: error)))
            return
        }
        
        let userId = option.user.id
        guard let data = userId.data(using: .utf8) else {
            let error = convertCustomError(.decodingChallenge)
            completion(.failure(PigeonError(code: "PASSKEY_ERROR", message: error.message, details: error)))
            return
        }
        
        guard let decodedUserId = Data.fromBase64(data.base64EncodedString()) else {
            let error = convertCustomError(.decodingChallenge)
            completion(.failure(PigeonError(code: "PASSKEY_ERROR", message: error.message, details: error)))
            return
        }
        
        
        let rp = option.rp.id
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rp)
        let request = platformProvider.createCredentialRegistrationRequest(
            challenge: decodedChallenge,
            name: option.user.name,
            userID: decodedUserId
        )

        if #available(iOS 17.4, *) {
            request.excludedCredentials = parseCredentials(credentialIDs: option.excludeCredentials.map{ e in e.id })
        }

        registerController = RegisterController(window: self.window, completion: completion)
        registerController?.run(request: request)
    }
    
    private func parseCredentials(credentialIDs: [String]) -> [ASAuthorizationPlatformPublicKeyCredentialDescriptor] {
        return credentialIDs.compactMap {
            if let credentialId = Data.fromBase64Url($0) {
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor.init(credentialID: credentialId)
            } else {
                return nil
            }
        }
    }
}

