import Foundation
import AuthenticationServices
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@available(iOS 16.0, macOS 13.0, *)
class PasskeyHostApiImpl: NSObject, PasskeyHostApi {
    private var passkeyService: PasskeyAuthService?

    override init() {
        super.init()
    }

    /// Returns the key window to anchor the system passkey sheet to, or nil if none is key.
    private func findPresentationAnchor() -> ASPresentationAnchor? {
        #if os(iOS)
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        #elseif os(macOS)
        return NSApplication.shared.windows.first { $0.isKeyWindow }
        #endif
    }

    private func getOrCreatePasskeyService() -> PasskeyAuthService? {
        if passkeyService == nil {
            guard let window = findPresentationAnchor() else {
                return nil
            }
            passkeyService = PasskeyAuthServiceImpl(window: window)
        }
        return passkeyService
    }

    private func noWindowError() -> PigeonError {
        #if os(iOS)
        let platform = "iOS"
        #else
        let platform = "macOS"
        #endif
        let error = PasskeyException(
            errorType: .systemError,
            message: "Unable to initialize passkey service",
            details: "No key window found for presentation on \(platform)"
        )
        return pigeonError(error)
    }

    func register(options: RegisterGenerateOptionData, completion: @escaping (Result<CreatePasskeyResponseData, Error>) -> Void) {
        guard let service = getOrCreatePasskeyService() else {
            completion(.failure(noWindowError()))
            return
        }
        service.register(option: options, completion: completion)
    }

    func authenticate(request: AuthGenerateOptionResponseData, completion: @escaping (Result<GetPasskeyAuthenticationResponseData, Error>) -> Void) {
        guard let service = getOrCreatePasskeyService() else {
            completion(.failure(noWindowError()))
            return
        }
        service.authenticate(request: request, completion: completion)
    }
}
