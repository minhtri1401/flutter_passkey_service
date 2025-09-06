import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_passkey_service/flutter_passkey_service.dart';
import 'package:flutter_passkey_service/flutter_passkey_service_platform_interface.dart';
import 'package:flutter_passkey_service/flutter_passkey_service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPasskeyServicePlatform
    with MockPlatformInterfaceMixin
    implements FlutterPasskeyServicePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterPasskeyServicePlatform initialPlatform = FlutterPasskeyServicePlatform.instance;

  test('$MethodChannelFlutterPasskeyService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPasskeyService>());
  });

  test('getPlatformVersion', () async {
    FlutterPasskeyService flutterPasskeyServicePlugin = FlutterPasskeyService();
    MockFlutterPasskeyServicePlatform fakePlatform = MockFlutterPasskeyServicePlatform();
    FlutterPasskeyServicePlatform.instance = fakePlatform;

    expect(await flutterPasskeyServicePlugin.getPlatformVersion(), '42');
  });
}
