import AuthenticationServices
import LocalAuthentication
import Foundation

@available(iOS 16.0, *)
class RegisterController: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public var completion: ((Result<CreatePasskeyResponseData, Error>) -> Void)?
    private let window: ASPresentationAnchor
    private var authorizationController: ASAuthorizationController? = nil
    
    init(window: ASPresentationAnchor, completion: @escaping ((Result<CreatePasskeyResponseData, Error>) -> Void)) {
        self.completion = completion
        self.window = window
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
            let response = CreatePasskeyResponseData(
                rawId: r.credentialID.toBase64URL(),
                authenticatorAttachment: "platform",
                type: "public-key",
                id: r.credentialID.toBase64URL(),
                response: CreatePasskeyResponse(
                    clientDataJSON: r.rawClientDataJSON.toBase64URL(),
                    attestationObject: r.rawAttestationObject?.toBase64URL() ?? "",
                    transports: ["internal"],
                    authenticatorData: "", // iOS doesn't provide this separately
                    publicKeyAlgorithm: -7, // ES256
                    publicKey: "" // iOS doesn't provide this separately
                ),
                clientExtensionResults: CreatePasskeyExtension(
                    credProps: nil,
                    prf: nil
                ),
                username: "username"
            )
            completion?(.success(response))
            break
        default:
            let error = PasskeyException(
                errorType: .unexpectedAuthorizationResponse,
                message: "Unexpected authorization response type",
                details: "Expected ASAuthorizationPublicKeyCredentialRegistration"
            )
            completion?(.failure(PigeonError(code: "PASSKEY_ERROR", message: error.message, details: error)))
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

// MARK: - Error Conversion Functions
@available(iOS 13.0, *)
func convertASAuthorizationError(_ error: ASAuthorizationError) -> PasskeyException {
    switch error.code {
    case .unknown:
        return PasskeyException(
            errorType: .unknownError,
            message: error.localizedDescription,
            details: "Unknown authorization error"
        )
    case .canceled:
        if error.localizedDescription.contains("No credentials available for login.") {
            return PasskeyException(
                errorType: .noCredentialsAvailable,
                message: "No credentials available for login",
                details: error.localizedDescription
            )
        } else {
            return PasskeyException(
                errorType: .userCancelled,
                message: "User cancelled the operation",
                details: error.localizedDescription
            )
        }
    case .invalidResponse:
        return PasskeyException(
            errorType: .invalidResponse,
            message: "Invalid response received",
            details: error.localizedDescription
        )
    case .notHandled:
        return PasskeyException(
            errorType: .notHandled,
            message: "Request not handled",
            details: error.localizedDescription
        )
    case .failed:
        if error.localizedDescription.contains("is not associated with domain") {
            return PasskeyException(
                errorType: .domainNotAssociated,
                message: "Domain not associated with app",
                details: error.localizedDescription
            )
        } else {
            return PasskeyException(
                errorType: .failed,
                message: "Operation failed",
                details: error.localizedDescription
            )
        }
    default:
        return PasskeyException(
            errorType: .unknownError,
            message: error.localizedDescription,
            details: "Unhandled authorization error code"
        )
    }
}

func convertNSError(_ error: NSError) -> PasskeyException {
    if error.domain == "WKErrorDomain" && error.code == 8 {
        return PasskeyException(
            errorType: .excludeCredentialsMatch,
            message: "Excluded credentials match",
            details: error.localizedDescription
        )
    } else {
        return PasskeyException(
            errorType: .wkErrorDomain,
            message: error.localizedDescription,
            details: "iOS unhandled error: \(error.domain)"
        )
    }
}

func convertCustomError(_ error: CustomErrors) -> PasskeyException {
    switch error {
    case .decodingChallenge:
        return PasskeyException(
            errorType: .decodingChallenge,
            message: "Failed to decode challenge",
            details: "Challenge data could not be decoded"
        )
    case .unexpectedAuthorizationResponse:
        return PasskeyException(
            errorType: .unexpectedAuthorizationResponse,
            message: "Unexpected authorization response",
            details: "Received unexpected response type"
        )
    case .unknown:
        return PasskeyException(
            errorType: .unknownError,
            message: "Unknown custom error",
            details: "An unknown custom error occurred"
        )
    }
}

// MARK: - Custom Errors Enum
public enum CustomErrors: Error {
    case decodingChallenge
    case unexpectedAuthorizationResponse
    case unknown
}
