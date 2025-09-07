import Foundation

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
