import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_passkey_service/flutter_passkey_service_platform_interface.dart';
import 'package:flutter_passkey_service/flutter_passkey_service_method_channel.dart';
import 'package:flutter_passkey_service/flutter_passkey_service.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPasskeyServicePlatform
    with MockPlatformInterfaceMixin
    implements FlutterPasskeyServicePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}


void main() {
  final FlutterPasskeyServicePlatform initialPlatform =
      FlutterPasskeyServicePlatform.instance;

  test('$MethodChannelFlutterPasskeyService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPasskeyService>());
  });

  group('FlutterPasskeyService Base Options Creation', () {
    test('createRegistrationOptions creates valid defaults', () {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: 'test-challenge',
        rpName: 'Test RP',
        rpId: 'test.com',
        userId: 'user-123',
        username: 'testuser',
      );

      // Verify required
      expect(options.challenge, 'test-challenge');
      expect(options.rp.name, 'Test RP');
      expect(options.rp.id, 'test.com');
      expect(options.user.id, 'user-123');
      expect(options.user.name, 'testuser');
      // Verify displayName falls back to username if empty
      expect(options.user.displayName, 'testuser');
      
      // Verify defaults
      expect(options.timeout, 60000);
      expect(options.attestation, 'none');
      expect(options.pubKeyCredParams.length, 2);
      expect(options.pubKeyCredParams.first.alg, -7);
      expect(options.excludeCredentials, isEmpty);
      expect(options.authenticatorSelection.authenticatorAttachment, 'platform');
      expect(options.authenticatorSelection.residentKey, 'preferred');
      expect(options.extensions.credProps, true);
      expect(options.hints, isNull);
    });

    test('createAuthenticationOptions creates valid defaults', () {
      final options = FlutterPasskeyService.createAuthenticationOptions(
        challenge: 'auth-challenge',
        rpId: 'test.com',
      );

      expect(options.challenge, 'auth-challenge');
      expect(options.rpId, 'test.com');
      
      // Verify defaults
      expect(options.timeout, 60000);
      expect(options.userVerification, 'required');
      expect(options.allowCredentials, isEmpty);
      expect(options.hints, isNull);
      expect(options.extensions, isNull);
    });

    test('createRegistrationOptions with enableLargeBlob creates largeBlob extension', () {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: 'test-challenge',
        rpName: 'Test RP',
        rpId: 'test.com',
        userId: 'user-123',
        username: 'testuser',
        enableLargeBlob: true,
      );

      expect(options.extensions.largeBlob, isNotNull);
      expect(options.extensions.largeBlob!.support, 'preferred');
    });

    test('createRegistrationOptions without enableLargeBlob has null largeBlob', () {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: 'test-challenge',
        rpName: 'Test RP',
        rpId: 'test.com',
        userId: 'user-123',
        username: 'testuser',
      );

      expect(options.extensions.largeBlob, isNull);
    });

    test('createAuthenticationOptions with largeBlobRead creates read extension', () {
      final options = FlutterPasskeyService.createAuthenticationOptions(
        challenge: 'auth-challenge',
        rpId: 'test.com',
        largeBlobRead: true,
      );

      expect(options.extensions, isNotNull);
      expect(options.extensions!.largeBlob, isNotNull);
      expect(options.extensions!.largeBlob!.read, true);
      expect(options.extensions!.largeBlob!.write, isNull);
    });

    test('createAuthenticationOptions with largeBlobWrite creates write extension', () {
      final writeData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final options = FlutterPasskeyService.createAuthenticationOptions(
        challenge: 'auth-challenge',
        rpId: 'test.com',
        largeBlobWrite: writeData,
      );

      expect(options.extensions, isNotNull);
      expect(options.extensions!.largeBlob, isNotNull);
      expect(options.extensions!.largeBlob!.read, isNull);
      expect(options.extensions!.largeBlob!.write, writeData);
    });

    test('createAuthenticationOptions formats allowedCredentialIds properly', () {
      final options = FlutterPasskeyService.createAuthenticationOptions(
        challenge: 'auth-challenge',
        rpId: 'test.com',
        allowedCredentialIds: ['cred-1', 'cred-2'],
      );

      expect(options.allowCredentials.length, 2);
      expect(options.allowCredentials[0].id, 'cred-1');
      expect(options.allowCredentials[0].type, 'public-key');
      expect(options.allowCredentials[1].id, 'cred-2');
    });
  });

  group('FlutterPasskeyService JSON parsing', () {
    test('createRegistrationOptionsFromJson parses all fields including hints and attestationFormats', () {
      final json = {
        "challenge": "base64url-challenge",
        "rp": {"name": "My App", "id": "example.com"},
        "user": {"id": "user-123", "name": "user@example.com", "displayName": "John Doe"},
        "pubKeyCredParams": [{"alg": -7, "type": "public-key"}],
        "timeout": 120000,
        "attestation": "direct",
        "hints": ["client-device", "hybrid"],
        "attestationFormats": ["packed", "none"],
        "extensions": {"credProps": false},
        "excludeCredentials": [
          {"id": "test-cred-id", "type": "public-key", "transports": ["usb"]}
        ],
        "authenticatorSelection": {
          "residentKey": "required",
          "userVerification": "preferred",
          "requireResidentKey": true,
          "authenticatorAttachment": "cross-platform"
        }
      };

      final options = FlutterPasskeyService.createRegistrationOptionsFromJson(json);

      expect(options.challenge, "base64url-challenge");
      expect(options.rp.id, "example.com");
      expect(options.user.displayName, "John Doe");
      expect(options.timeout, 120000);
      expect(options.attestation, "direct");
      expect(options.hints, ["client-device", "hybrid"]);
      expect(options.attestationFormats, ["packed", "none"]);
      expect(options.extensions.credProps, false);
      expect(options.excludeCredentials.length, 1);
      expect(options.excludeCredentials.first.transports, ["usb"]);
      expect(options.authenticatorSelection.residentKey, "required");
      expect(options.authenticatorSelection.authenticatorAttachment, "cross-platform");

      // Verify toJson serialization respects all fields
      final toJsonResult = options.toJson();
      expect(toJsonResult['hints'], ["client-device", "hybrid"]);
      expect(toJsonResult['attestationFormats'], ["packed", "none"]);
      expect(toJsonResult['timeout'], 120000);
      expect(toJsonResult['authenticatorSelection']['residentKey'], 'required');
    });

    test('createRegistrationOptionsFromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        "challenge": "base64url-challenge",
        "rp": {"name": "My App", "id": "example.com"},
        "user": {"id": "user-123", "name": "user@example.com"}
      };

      final options = FlutterPasskeyService.createRegistrationOptionsFromJson(minimalJson);

      expect(options.user.displayName, '');
      expect(options.timeout, 60000); // Default wrapper timeout
      expect(options.attestation, 'none'); // Default
      expect(options.hints, isNull);
      expect(options.attestationFormats, isNull);
      expect(options.excludeCredentials, isEmpty);
      expect(options.pubKeyCredParams.length, 2); // Default algorithms fallbacks
      expect(options.extensions.credProps, true); // Default
      expect(options.authenticatorSelection.authenticatorAttachment, 'platform'); // Default config
      
      final toJsonResult = options.toJson();
      expect(toJsonResult.containsKey('hints'), false);
      expect(toJsonResult.containsKey('attestationFormats'), false);
    });

    test('createAuthenticationOptionsFromJson parses all fields including hints and extensions', () {
      final json = {
        "challenge": "base64url-challenge",
        "rpId": "example.com",
        "allowCredentials": [
          {"id": "credential-id", "type": "public-key", "transports": ["internal"]}
        ],
        "timeout": 60000,
        "userVerification": "preferred",
        "hints": ["security-key"],
        "extensions": {"appid": true}
      };

      final options = FlutterPasskeyService.createAuthenticationOptionsFromJson(json);

      expect(options.challenge, "base64url-challenge");
      expect(options.rpId, "example.com");
      expect(options.userVerification, "preferred");
      expect(options.allowCredentials.length, 1);
      expect(options.allowCredentials.first.id, "credential-id");
      expect(options.hints, ["security-key"]);
      expect(options.extensions?.appid, true);

      // Verify toJson serialization
      final toJsonResult = options.toJson();
      expect(toJsonResult['hints'], ["security-key"]);
      expect(toJsonResult['extensions']['appid'], true);
    });

    test('createAuthenticationOptionsFromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        "challenge": "auth-challenge",
        "rpId": "example.com"
      };

      final options = FlutterPasskeyService.createAuthenticationOptionsFromJson(minimalJson);

      expect(options.timeout, 60000);
      expect(options.userVerification, 'required');
      expect(options.allowCredentials, isEmpty);
      expect(options.hints, isNull);
      expect(options.extensions, isNull);

      final toJsonResult = options.toJson();
      expect(toJsonResult.containsKey('hints'), false);
      expect(toJsonResult.containsKey('extensions'), false);
    });

    test('createRegistrationOptionsFromJsonString parses accurately', () {
      const jsonString = '{"challenge":"test","rp":{"name":"App","id":"app.com"},"user":{"id":"id","name":"n"}}';
      final options = FlutterPasskeyService.createRegistrationOptionsFromJsonString(jsonString);
      
      expect(options.challenge, "test");
      expect(options.rp.id, "app.com");
    });
    
    test('createAuthenticationOptionsFromJsonString parses accurately', () {
      const jsonString = '{"challenge":"testAuth","rpId":"app.com"}';
      final options = FlutterPasskeyService.createAuthenticationOptionsFromJsonString(jsonString);
      
      expect(options.challenge, "testAuth");
      expect(options.rpId, "app.com");
    });
    test('createAuthenticationOptionsFromJson parses all PRF extension data', () {
      final json = {
        "challenge": "auth-challenge",
        "rpId": "example.com",
        "extensions": {
          "prf": {
            "eval": {
              "first": "c2FsdDEyMzQ1Njc4OTA=",
              "second": "c2FsdDk4NzY1NDMyMTA="
            }
          }
        }
      };

      final options = FlutterPasskeyService.createAuthenticationOptionsFromJson(json);

      expect(options.extensions?.prf?.eval?['first'], "c2FsdDEyMzQ1Njc4OTA=");
      expect(options.extensions?.prf?.eval?['second'], "c2FsdDk4NzY1NDMyMTA=");

      final toJsonResult = options.toJson();
      expect(toJsonResult['extensions']['prf']['eval']['first'], "c2FsdDEyMzQ1Njc4OTA=");
    });

    test('createRegistrationOptionsFromJson parses largeBlob extension', () {
      final json = {
        "challenge": "reg-challenge",
        "rp": {"name": "My App", "id": "example.com"},
        "user": {"id": "user-123", "name": "user@example.com"},
        "extensions": {
          "largeBlob": {"support": "required"}
        }
      };

      final options = FlutterPasskeyService.createRegistrationOptionsFromJson(json);

      expect(options.extensions.largeBlob, isNotNull);
      expect(options.extensions.largeBlob!.support, 'required');

      final toJsonResult = options.toJson();
      expect(toJsonResult['extensions']['largeBlob']['support'], 'required');
    });

    test('createRegistrationOptionsFromJson handles largeBlob with default support', () {
      final json = {
        "challenge": "reg-challenge",
        "rp": {"name": "My App", "id": "example.com"},
        "user": {"id": "user-123", "name": "user@example.com"},
        "extensions": {
          "largeBlob": {}
        }
      };

      final options = FlutterPasskeyService.createRegistrationOptionsFromJson(json);

      expect(options.extensions.largeBlob, isNotNull);
      expect(options.extensions.largeBlob!.support, 'preferred');
    });

    test('createAuthenticationOptionsFromJson parses largeBlob read', () {
      final json = {
        "challenge": "auth-challenge",
        "rpId": "example.com",
        "extensions": {
          "largeBlob": {"read": true}
        }
      };

      final options = FlutterPasskeyService.createAuthenticationOptionsFromJson(json);

      expect(options.extensions?.largeBlob, isNotNull);
      expect(options.extensions!.largeBlob!.read, true);
      expect(options.extensions!.largeBlob!.write, isNull);

      final toJsonResult = options.toJson();
      expect(toJsonResult['extensions']['largeBlob']['read'], true);
    });

    test('createAuthenticationOptionsFromJson parses largeBlob write with base64 data', () {
      final json = {
        "challenge": "auth-challenge",
        "rpId": "example.com",
        "extensions": {
          "largeBlob": {"write": "AQIDBAU="}  // base64url of [1,2,3,4,5]
        }
      };

      final options = FlutterPasskeyService.createAuthenticationOptionsFromJson(json);

      expect(options.extensions?.largeBlob, isNotNull);
      expect(options.extensions!.largeBlob!.write, isNotNull);
      expect(options.extensions!.largeBlob!.write, Uint8List.fromList([1, 2, 3, 4, 5]));
    });

    test('createAuthenticationOptionsFromJson without largeBlob has null largeBlob', () {
      final json = {
        "challenge": "auth-challenge",
        "rpId": "example.com",
        "extensions": {
          "appid": true
        }
      };

      final options = FlutterPasskeyService.createAuthenticationOptionsFromJson(json);

      expect(options.extensions?.largeBlob, isNull);
      expect(options.extensions?.appid, true);
    });

    test('largeBlob toJson serialization round-trips correctly', () {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: 'test',
        rpName: 'App',
        rpId: 'app.com',
        userId: 'u1',
        username: 'user',
        enableLargeBlob: true,
        enablePrf: true,
      );

      final json = options.toJson();
      expect(json['extensions']['largeBlob']['support'], 'preferred');
      expect(json['extensions']['prf'], {});
      expect(json['extensions']['credProps'], true);
    });

    test('createAuthenticationOptions with prfEval creates PRF extension', () {
      final options = FlutterPasskeyService.createAuthenticationOptions(
        challenge: 'auth-challenge',
        rpId: 'test.com',
        prfEval: {'first': 'c2FsdDE=', 'second': 'c2FsdDI='},
      );

      expect(options.extensions, isNotNull);
      expect(options.extensions!.prf, isNotNull);
      expect(options.extensions!.prf!.eval!['first'], 'c2FsdDE=');
      expect(options.extensions!.prf!.eval!['second'], 'c2FsdDI=');
    });

    test('createAuthenticationOptions with both prfEval and largeBlobRead', () {
      final options = FlutterPasskeyService.createAuthenticationOptions(
        challenge: 'auth-challenge',
        rpId: 'test.com',
        prfEval: {'first': 'c2FsdDE='},
        largeBlobRead: true,
      );

      expect(options.extensions, isNotNull);
      expect(options.extensions!.prf, isNotNull);
      expect(options.extensions!.prf!.eval!['first'], 'c2FsdDE=');
      expect(options.extensions!.largeBlob, isNotNull);
      expect(options.extensions!.largeBlob!.read, true);
    });

    test('createRegistrationOptionsFromJson handles PRF enabling creation', () {
      final json = {
        "challenge": "reg-challenge",
        "rp": {"name": "My App", "id": "example.com"},
        "user": {"id": "user-123", "name": "user@example.com"},
        "extensions": {
          "prf": {} // empty prf map enables it in registration according to webauthn specs
        }
      };

      final options = FlutterPasskeyService.createRegistrationOptionsFromJson(json);

      expect(options.extensions.prf, isNotNull);
      expect(options.extensions.prf?.eval, isNull);

      final toJsonResult = options.toJson();
      expect(toJsonResult['extensions']['prf'], {});
    });
  });
}
