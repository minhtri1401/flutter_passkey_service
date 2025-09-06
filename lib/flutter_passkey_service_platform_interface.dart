import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_passkey_service_method_channel.dart';

abstract class FlutterPasskeyServicePlatform extends PlatformInterface {
  /// Constructs a FlutterPasskeyServicePlatform.
  FlutterPasskeyServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterPasskeyServicePlatform _instance = MethodChannelFlutterPasskeyService();

  /// The default instance of [FlutterPasskeyServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterPasskeyService].
  static FlutterPasskeyServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterPasskeyServicePlatform] when
  /// they register themselves.
  static set instance(FlutterPasskeyServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
