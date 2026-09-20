#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

public class FlutterPasskeyServicePlugin: NSObject, FlutterPlugin {
    private var passkeyHostApi: Any?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterPasskeyServicePlugin()
        instance.setupPigeonApi(with: registrar)
    }

    private func setupPigeonApi(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let messenger = registrar.messenger()
        #elseif os(macOS)
        let messenger = registrar.messenger
        #endif

        if #available(iOS 16.0, macOS 13.0, *) {
            let api = PasskeyHostApiImpl()
            passkeyHostApi = api
            PasskeyHostApiSetup.setUp(binaryMessenger: messenger, api: api)
        } else {
            // Passkeys need iOS 16 / macOS 13. Registering nil makes Dart calls fail
            // with a channel error instead of crashing.
            PasskeyHostApiSetup.setUp(binaryMessenger: messenger, api: nil)
        }
    }
}
