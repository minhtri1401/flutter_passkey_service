import AuthenticationServices
import LocalAuthentication
import Foundation
import Flutter

@available(iOS 16.0, *)
class AuthenticateController: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public var completion: ((Result<GetPasskeyAuthenticationResponseData, Error>) -> Void)?
    private let window: ASPresentationAnchor
    private var authorizationController: ASAuthorizationController? = nil
    
    init(window: ASPresentationAnchor, completion: @escaping ((Result<GetPasskeyAuthenticationResponseData, Error>)  -> Void)) {
        self.completion = completion
        self.window = window
    }
    
    func run(request: ASAuthorizationPlatformPublicKeyCredentialAssertionRequest, preferImmediatelyAvailableCredentials: Bool) {
        authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController?.delegate = self
        authorizationController?.presentationContextProvider = self
        
        if preferImmediatelyAvailableCredentials {
            // If credentials are available, presents a modal sign-in sheet.
            // If there are no locally saved credentials, no UI appears and
            // the system passes ASAuthorizationError.Code.canceled to call
            // `AccountManager.authorizationController(controller:didCompleteWithError:)`.
            authorizationController?.performRequests(options: .preferImmediatelyAvailableCredentials)
        } else {
            // If credentials are available, presents a modal sign-in sheet.
            // If there are no locally saved credentials, the system presents a QR code to allow signing in with a
            // passkey from a nearby device.
            authorizationController?.performRequests()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let r as ASAuthorizationPublicKeyCredentialAssertion:
            var prfOutput: PrfExtensionOutput? = nil
            if #available(iOS 18.0, *) {
                if let platformAssertion = r as? ASAuthorizationPlatformPublicKeyCredentialAssertion, let prfResult = platformAssertion.prf {
                    prfOutput = PrfExtensionOutput(enabled: nil, results: [:])
                    prfOutput?.results?["first"] = prfResult.first.withUnsafeBytes { Data($0) }.toBase64URL()
                    if let second = prfResult.second {
                        prfOutput?.results?["second"] = second.withUnsafeBytes { Data($0) }.toBase64URL()
                    }
                }
            }

            var largeBlobOutput: LargeBlobExtensionAuthOutput? = nil
            if #available(iOS 17.0, *) {
                if let platformAssertion = r as? ASAuthorizationPlatformPublicKeyCredentialAssertion,
                   let largeBlobResult = platformAssertion.largeBlob {
                    switch largeBlobResult.result {
                    case .read(data: let data):
                        let blobData: FlutterStandardTypedData? = data.map { FlutterStandardTypedData(bytes: $0) }
                        largeBlobOutput = LargeBlobExtensionAuthOutput(
                            blob: blobData,
                            written: nil
                        )
                    case .write(success: let success):
                        largeBlobOutput = LargeBlobExtensionAuthOutput(
                            blob: nil,
                            written: success
                        )
                    @unknown default:
                        break
                    }
                }
            }

            let response = GetPasskeyAuthenticationResponseData(
                authenticatorAttachment: "platform", id: r.credentialID.toBase64URL(),
                rawId: r.credentialID.toBase64URL(),
                response: GetPasskeyAuthenticationResponse(
                    clientDataJSON: r.rawClientDataJSON.toBase64URL(),
                    authenticatorData: r.rawAuthenticatorData.toBase64URL(),
                    signature: r.signature.toBase64URL(),
                    userHandle: r.userID?.toBase64URL()
                ),
                type: "public-key",
                clientExtensionResults: AuthPasskeyExtensionResult(appid: nil, prf: prfOutput, largeBlob: largeBlobOutput),
                username: ""
            )
            completion?(.success(response))
            break
        default:
            let passkeyError = PasskeyException(
                errorType: .unexpectedAuthorizationResponse,
                message: "Unexpected authorization response type",
                details: "Expected ASAuthorizationPublicKeyCredentialAssertion"
            )
            completion?(.failure(PigeonError(code: "PASSKEY_ERROR", message: passkeyError.message, details: passkeyError)))
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let err = error as? ASAuthorizationError {
            let passkeyError = convertASAuthorizationError(err)
            completion?(.failure(PigeonError(code: "PASSKEY_ERROR", message: passkeyError.message, details: passkeyError)))
        } else {
            let nsError = error as NSError
            let passkeyError = convertNSError(nsError)
            completion?(.failure(PigeonError(code: "PASSKEY_ERROR", message: passkeyError.message, details: passkeyError)))
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.window
    }
}

