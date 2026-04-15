
import AuthenticationServices
import FlutterMacOS

/**
 A protocol that defines passkey-based authentication and registration services.

 Implementations of this protocol should handle the necessary steps for both user authentication and registration using passkey challenges.
 */
protocol PasskeyAuthService {
    /**
     Authenticates a user using a passkey.

     - Parameter request: An instance of `AuthGenerateOptionResponseData` that contains the challenge and options required for authentication.
     - Parameter completion: A closure executed once authentication is complete.
     */
    func authenticate(request: AuthGenerateOptionResponseData, completion: @escaping (Result<GetPasskeyAuthenticationResponseData, Error>) -> Void)

    /**
     Registers a user using a passkey.

     - Parameter option: An instance of `RegisterGenerateOptionData` that contains the registration options and challenge details.
     - Parameter completion: A closure executed after registration completes.
     */
    func register(option: RegisterGenerateOptionData, completion: @escaping (Result<CreatePasskeyResponseData, Error>) -> Void)
}


@available(macOS 13.0, *)
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

        if #available(macOS 15.0, *) {
            if let prfEval = request.extensions?.prf?.eval {
                if let firstSaltStr = prfEval["first"] as? String, let salt1 = Data.fromBase64Url(firstSaltStr) {
                    var salt2: Data? = nil
                    if let secondSaltStr = prfEval["second"] as? String {
                        salt2 = Data.fromBase64Url(secondSaltStr)
                    }
                    let inputValues = ASAuthorizationPublicKeyCredentialPRFAssertionInput.InputValues(saltInput1: salt1, saltInput2: salt2)
                    let prfInput = ASAuthorizationPublicKeyCredentialPRFAssertionInput.inputValues(inputValues)
                    credentialRequest.prf = prfInput
                }
            }
        }

        if #available(macOS 14.0, *) {
            if let largeBlobInput = request.extensions?.largeBlob {
                if largeBlobInput.read == true {
                    credentialRequest.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobAssertionInput.read
                } else if let writeData = largeBlobInput.write {
                    credentialRequest.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobAssertionInput.write(writeData.data)
                }
            }
        }

        authenController = AuthenticateController(window: self.window, completion: completion)
        authenController?.run(request: credentialRequest, preferImmediatelyAvailableCredentials: request.preferImmediatelyAvailableCredentials ?? false)

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

        if #available(macOS 14.4, *) {
            request.excludedCredentials = parseCredentials(credentialIDs: option.excludeCredentials.map{ e in e.id })
        }

        if #available(macOS 15.0, *) {
            if option.extensions.prf != nil {
                let prfInput = ASAuthorizationPublicKeyCredentialPRFRegistrationInput.checkForSupport
                request.prf = prfInput
            }
        }

        if #available(macOS 14.0, *) {
            if let largeBlobInput = option.extensions.largeBlob {
                if largeBlobInput.support == "required" {
                    request.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobRegistrationInput.supportRequired
                } else {
                    request.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobRegistrationInput.supportPreferred
                }
            }
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
