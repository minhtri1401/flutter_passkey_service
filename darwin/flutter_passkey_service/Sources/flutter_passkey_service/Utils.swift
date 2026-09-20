import Foundation
import AuthenticationServices

// MARK: - Data Extensions for Base64URL encoding/decoding
extension Data {
    /// Converts a Base64URL encoded string to Data
    /// Base64URL is like Base64 but uses '-' and '_' instead of '+' and '/' and omits padding
    static func fromBase64Url(_ base64Url: String) -> Data? {
        var base64 = base64Url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        return Data(base64Encoded: base64)
    }
    
    /// Converts a standard Base64 encoded string to Data
    static func fromBase64(_ base64: String) -> Data? {
        return Data(base64Encoded: base64)
    }
    
    /// Converts Data to Base64URL encoded string
    /// Base64URL is like Base64 but uses '-' and '_' instead of '+' and '/' and omits padding
    func toBase64URL() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: - WebAuthn string → AuthenticationServices enum mapping

/// Maps a WebAuthn `userVerification` string to the platform preference.
/// Returns nil for unknown values so the caller leaves the platform default in place.
@available(iOS 16.0, macOS 13.0, *)
func userVerificationPreference(from raw: String?) -> ASAuthorizationPublicKeyCredentialUserVerificationPreference? {
    switch raw {
    case "required": return .required
    case "preferred": return .preferred
    case "discouraged": return .discouraged
    default: return nil
    }
}

/// Maps a WebAuthn `attestation` string to the platform attestation kind.
/// Returns nil for unknown values so the caller leaves the platform default in place.
@available(iOS 16.0, macOS 13.0, *)
func attestationKind(from raw: String?) -> ASAuthorizationPublicKeyCredentialAttestationKind? {
    switch raw {
    case "none": return ASAuthorizationPublicKeyCredentialAttestationKind.none
    case "indirect": return .indirect
    case "direct": return .direct
    case "enterprise": return .enterprise
    default: return nil
    }
}
