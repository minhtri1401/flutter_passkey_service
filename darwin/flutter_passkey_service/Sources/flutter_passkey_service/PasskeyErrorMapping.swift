import AuthenticationServices
import Foundation

// MARK: - Pigeon wrapping

/// Wraps a PasskeyException in the PigeonError shape Dart unwraps into PasskeyException.
func pigeonError(_ exception: PasskeyException) -> PigeonError {
    PigeonError(code: "PASSKEY_ERROR", message: exception.message, details: exception)
}

// MARK: - Entry point

/// Maps any error from ASAuthorizationController to a typed PasskeyException.
/// - Parameter preferImmediatelyAvailableCredentials: whether the assertion was performed with
///   that option; used only to word the "no credentials" message.
func convertAuthorizationError(_ error: Error, preferImmediatelyAvailableCredentials: Bool) -> PasskeyException {
    if let asError = error as? ASAuthorizationError {
        return convertASAuthorizationError(asError, preferImmediatelyAvailableCredentials: preferImmediatelyAvailableCredentials)
    }
    return convertNSError(error as NSError)
}

// MARK: - ASAuthorizationError

@available(iOS 13.0, macOS 10.15, *)
func convertASAuthorizationError(_ error: ASAuthorizationError, preferImmediatelyAvailableCredentials: Bool) -> PasskeyException {
    let nsError = error as NSError

    switch error.code {
    case .unknown:
        return PasskeyException(
            errorType: .unknownError,
            message: error.localizedDescription,
            details: "Unknown authorization error"
        )

    case .canceled:
        // With .preferImmediatelyAvailableCredentials and no local passkey, the system reports
        // .canceled without showing UI. The flag alone cannot distinguish that from a real cancel
        // (the sheet still appears when credentials exist), so inspect the error text chain too.
        if errorChainContains(nsError, "no credentials") {
            return PasskeyException(
                errorType: .noCredentialsAvailable,
                message: preferImmediatelyAvailableCredentials
                    ? "No passkey available on this device"
                    : "No credentials available for login",
                details: error.localizedDescription
            )
        }
        return PasskeyException(
            errorType: .userCancelled,
            message: "User cancelled the operation",
            details: error.localizedDescription
        )

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

    case .notInteractive:
        return PasskeyException(
            errorType: .notHandled,
            message: "Request could not be shown to the user",
            details: error.localizedDescription
        )

    case .failed:
        if errorChainContains(nsError, "not associated with domain") || errorChainContains(nsError, "associated domain") {
            return PasskeyException(
                errorType: .domainNotAssociated,
                message: "Domain not associated with app",
                details: error.localizedDescription
            )
        }
        return PasskeyException(
            errorType: .failed,
            message: "Operation failed",
            details: error.localizedDescription
        )

    default:
        if #available(iOS 18.0, macOS 15.0, *), error.code == .matchedExcludedCredential {
            return PasskeyException(
                errorType: .excludeCredentialsMatch,
                message: "A passkey for this account already exists on this device",
                details: error.localizedDescription
            )
        }
        return PasskeyException(
            errorType: .unknownError,
            message: error.localizedDescription,
            details: "Unhandled authorization error code \(nsError.code)"
        )
    }
}

/// Case-insensitively searches the error's description, failure reason, debug description and
/// up to four levels of NSUnderlyingErrorKey for `needle`.
private func errorChainContains(_ error: NSError, _ needle: String) -> Bool {
    var current: NSError? = error
    var depth = 0
    while let e = current, depth < 5 {
        let haystacks: [String] = [
            e.localizedDescription,
            e.localizedFailureReason ?? "",
            (e.userInfo[NSDebugDescriptionErrorKey] as? String) ?? ""
        ]
        if haystacks.contains(where: { $0.range(of: needle, options: .caseInsensitive) != nil }) {
            return true
        }
        current = e.userInfo[NSUnderlyingErrorKey] as? NSError
        depth += 1
    }
    return false
}

// MARK: - Other NSErrors

func convertNSError(_ error: NSError) -> PasskeyException {
    // iOS 16/17 report an excluded-credential match through WebKit's error domain.
    if error.domain == "WKErrorDomain" && error.code == 8 {
        return PasskeyException(
            errorType: .excludeCredentialsMatch,
            message: "A passkey for this account already exists on this device",
            details: error.localizedDescription
        )
    }
    return PasskeyException(
        errorType: .wkErrorDomain,
        message: error.localizedDescription,
        details: "Unhandled error: \(error.domain) \(error.code)"
    )
}

// MARK: - Plugin-internal errors

public enum CustomErrors: Error {
    case decodingChallenge
    case unexpectedAuthorizationResponse
    case unknown
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
