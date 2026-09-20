import AuthenticationServices
import LocalAuthentication
import Foundation

@available(iOS 16.0, macOS 13.0, *)
class RegisterController: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public var completion: ((Result<CreatePasskeyResponseData, Error>) -> Void)?
    private let window: ASPresentationAnchor
    private let username: String
    private var authorizationController: ASAuthorizationController? = nil
    
    init(window: ASPresentationAnchor, username: String, completion: @escaping ((Result<CreatePasskeyResponseData, Error>) -> Void)) {
        self.completion = completion
        self.window = window
        self.username = username
    }
    
    func run(request: ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest) {
        authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController?.delegate = self
        authorizationController?.presentationContextProvider = self
        authorizationController?.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let r as ASAuthorizationPublicKeyCredentialRegistration:
            var prfOutput: PrfExtensionOutput? = nil
            if #available(iOS 18.0, macOS 15.0, *),
               let platformReg = r as? ASAuthorizationPlatformPublicKeyCredentialRegistration,
               let prfResult = platformReg.prf {
                var results: [String?: String?]? = nil
                if let first = prfResult.first {
                    results = ["first": first.withUnsafeBytes { Data($0) }.toBase64URL()]
                    if let second = prfResult.second {
                        results?["second"] = second.withUnsafeBytes { Data($0) }.toBase64URL()
                    }
                }
                prfOutput = PrfExtensionOutput(enabled: prfResult.isSupported, results: results)
            }

            var largeBlobOutput: LargeBlobExtensionRegistrationOutput? = nil
            if #available(iOS 17.0, macOS 14.0, *),
               let platformReg = r as? ASAuthorizationPlatformPublicKeyCredentialRegistration,
               let largeBlobResult = platformReg.largeBlob {
                largeBlobOutput = LargeBlobExtensionRegistrationOutput(supported: largeBlobResult.isSupported)
            }

            let response = CreatePasskeyResponseData(
                rawId: r.credentialID.toBase64URL(),
                authenticatorAttachment: "platform",
                type: "public-key",
                id: r.credentialID.toBase64URL(),
                response: CreatePasskeyResponse(
                    clientDataJSON: r.rawClientDataJSON.toBase64URL(),
                    attestationObject: r.rawAttestationObject?.toBase64URL() ?? "",
                    // Apple passkeys are synced via iCloud Keychain, so they are reachable both
                    // locally and through the hybrid (cross-device) transport.
                    transports: ["internal", "hybrid"],
                    authenticatorData: nil,   // not exposed separately by AuthenticationServices
                    publicKeyAlgorithm: -7,   // Apple platform authenticators only produce ES256
                    publicKey: nil            // not exposed separately by AuthenticationServices
                ),
                clientExtensionResults: CreatePasskeyExtension(
                    credProps: nil,
                    prf: prfOutput,
                    largeBlob: largeBlobOutput
                ),
                username: username
            )
            completion?(.success(response))
            break
        default:
            let error = PasskeyException(
                errorType: .unexpectedAuthorizationResponse,
                message: "Unexpected authorization response type",
                details: "Expected ASAuthorizationPublicKeyCredentialRegistration"
            )
            completion?(.failure(pigeonError(error)))
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let passkeyError = convertAuthorizationError(error, preferImmediatelyAvailableCredentials: false)
        completion?(.failure(pigeonError(passkeyError)))
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(macOS)
        self.window.makeKeyAndOrderFront(nil)
        #endif
        return self.window
    }
}
