
import 'flutter_passkey_service_platform_interface.dart';

class FlutterPasskeyService {
  Future<String?> getPlatformVersion() {
    return FlutterPasskeyServicePlatform.instance.getPlatformVersion();
  }
}
