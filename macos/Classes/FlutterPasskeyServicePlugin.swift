import FlutterMacOS
import AppKit

public class FlutterPasskeyServicePlugin: NSObject, FlutterPlugin {
    private var passkeyHostApi: Any?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterPasskeyServicePlugin()
        instance.setupPigeonApi(with: registrar)
    }

    private func setupPigeonApi(with registrar: FlutterPluginRegistrar) {
        if #available(macOS 13.0, *) {
            passkeyHostApi = PasskeyHostApiImpl()
            PasskeyHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: passkeyHostApi as? PasskeyHostApi)
        } else {
            // For macOS versions below 13.0, passkeys are not available
            PasskeyHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: nil)
        }
    }
}
