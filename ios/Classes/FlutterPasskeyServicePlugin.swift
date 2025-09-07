import Flutter
import UIKit

public class FlutterPasskeyServicePlugin: NSObject, FlutterPlugin {
    private var passkeyHostApi: Any?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterPasskeyServicePlugin()
        instance.setupPigeonApi(with: registrar)
    }
    
    private func setupPigeonApi(with registrar: FlutterPluginRegistrar) {
        if #available(iOS 16.0, *) {
            passkeyHostApi = PasskeyHostApiImpl()
            PasskeyHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: passkeyHostApi as? PasskeyHostApi)
        } else {
            // For iOS versions below 16.0, passkeys are not available
            PasskeyHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
        }
    }
}
