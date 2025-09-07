import Foundation
import UIKit
import AuthenticationServices

@available(iOS 16.0, *)
class PasskeyHostApiImpl: NSObject, PasskeyHostApi {
    private var passkeyService: PasskeyAuthService?
    
    override init() {
        super.init()
    }
    
    private func getOrCreatePasskeyService() -> PasskeyAuthService? {
        if passkeyService == nil {
            // Get the main window for presentation context
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
                return nil
            }
            
            passkeyService = PasskeyAuthServiceImpl(window: window)
        }
        return passkeyService
    }
    
    func register(options: RegisterGenerateOptionData, completion: @escaping (Result<CreatePasskeyResponseData, Error>) -> Void) {
        guard let service = getOrCreatePasskeyService() else {
            let error = PasskeyException(
                errorType: .systemError,
                message: "Unable to initialize passkey service",
                details: "No key window found for presentation"
            )
            completion(.failure(PigeonError(code: "PASSKEY_ERROR", message: error.message, details: error)))
            return
        }
        
        service.register(option: options, completion: completion)
    }
    
    func authenticate(request: AuthGenerateOptionResponseData, completion: @escaping (Result<GetPasskeyAuthenticationResponseData, Error>) -> Void) {
        guard let service = getOrCreatePasskeyService() else {
            let error = PasskeyException(
                errorType: .systemError,
                message: "Unable to initialize passkey service",
                details: "No key window found for presentation"
            )
            completion(.failure(PigeonError(code: "PASSKEY_ERROR", message: error.message, details: error)))
            return
        }
        
        service.authenticate(request: request, completion: completion)
    }
}

