import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_passkey_service_platform_interface.dart';

/// An implementation of [FlutterPasskeyServicePlatform] that uses method channels.
class MethodChannelFlutterPasskeyService extends FlutterPasskeyServicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_passkey_service');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
