# Flutter Passkey Service

[![pub package](https://img.shields.io/pub/v/flutter_passkey_service.svg)](https://pub.dev/packages/flutter_passkey_service)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter plugin that provides seamless integration with **Passkeys** (WebAuthn) for both iOS and Android platforms. Enable passwordless authentication in your Flutter applications using biometric authentication, device PINs, or security keys.

## ✨ Features

- 🔐 **Passwordless Authentication** - Secure biometric and device-based authentication
- 📱 **Cross-Platform Support** - Native implementation for iOS 16.0+ and Android API 28+
- 🛡️ **WebAuthn Compliant** - Full compliance with W3C WebAuthn standards
- 🔄 **Cross-Device Sync** - Passkeys sync across user's devices via platform providers
- 🚀 **Type-Safe API** - Generated with Pigeon for reliable Flutter-to-native communication
- 🎯 **Easy Integration** - Simple, developer-friendly API with comprehensive error handling
- 📚 **Well Documented** - Complete API documentation with examples

## 🚀 Quick Start

### Installation

Add `flutter_passkey_service` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_passkey_service: ^0.0.1
```

Run the following command:

```bash
flutter pub get
```

### Platform Setup

#### iOS Setup

1. **Minimum Requirements**: iOS 16.0+

2. **Add Capability**: In Xcode, add "Associated Domains" capability
   - Open your project in Xcode
   - Select your target → "Signing & Capabilities"
   - Click "+" and add "Associated Domains"

3. **Configure Domain**: Add your domain with `webcredentials` prefix:
   ```
   webcredentials:yourdomain.com
   ```

4. **Domain Verification**: Create an `apple-app-site-association` file on your server:
   ```json
   {
     "webcredentials": {
       "apps": ["TEAMID.com.yourcompany.yourapp"]
     }
   }
   ```
   - Host at: `https://yourdomain.com/.well-known/apple-app-site-association`
   - **No file extension** required
   - Content-Type: `application/json`
   - **Verification Tool**: [Apple App Site Association Validator](https://developer.apple.com/help/app-store-connect/configure-app-store-connect/verify-domain-ownership)

#### Android Setup

1. **Minimum Requirements**: Android API 28+ (Android 9.0)

2. **Add Dependencies**: The plugin automatically includes required dependencies

3. **Configure Digital Asset Links**: Create an `assetlinks.json` file:
   ```json
   [{
     "relation": ["delegate_permission/common.handle_all_urls"],
     "target": {
       "namespace": "android_app",
       "package_name": "com.yourcompany.yourapp",
       "sha256_cert_fingerprints": ["SHA256_FINGERPRINT_OF_YOUR_APP"]
     }
   }]
   ```

4. **Host Asset Links File**:
   - Upload to: `https://yourdomain.com/.well-known/assetlinks.json`
   - Content-Type: `application/json`
   - Must be accessible via HTTPS

5. **Get SHA256 Fingerprint**:
   ```bash
   # For debug keystore
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # For release keystore
   keytool -list -v -keystore /path/to/your/keystore.jks -alias your_key_alias
   ```

6. **Verification Tools**:
   - [Google Digital Asset Links Tester](https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://yourdomain.com&relation=delegate_permission/common.handle_all_urls)
   - [Android Asset Links Testing Tool](https://developers.google.com/digital-asset-links/tools/generator)

### Basic Usage

```dart
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

class PasskeyAuth {
  
  // Register a new passkey
  Future<void> registerPasskey() async {
    try {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: 'your-server-challenge',
        rpName: 'Your App Name',
        rpId: 'yourdomain.com',
        userId: 'user-123',
        username: 'user@example.com',
        displayName: 'John Doe',
      );
      
      final response = await FlutterPasskeyService.register(options);
      
      // Send response to your server for verification
      print('Registration successful: ${response.id}');
      
    } on PasskeyException catch (e) {
      print('Registration failed: ${e.message}');
    }
  }
  
  // Authenticate with existing passkey
  Future<void> authenticateWithPasskey() async {
    try {
      final request = FlutterPasskeyService.createAuthenticationOptions(
        challenge: 'your-server-challenge',
        rpId: 'yourdomain.com',
      );
      
      final response = await FlutterPasskeyService.authenticate(request);
      
      // Send response to your server for verification
      print('Authentication successful: ${response.id}');
      
    } on PasskeyException catch (e) {
      print('Authentication failed: ${e.message}');
    }
  }
}
```

## 📚 Comprehensive Guide

### Domain Verification Setup

Proper domain verification is **essential** for passkey functionality. Both platforms require your app to be associated with your web domain.

#### iOS Domain Verification (Apple App Site Association)

1. **Create the Association File**:
   ```json
   {
     "webcredentials": {
       "apps": [
         "TEAMID.com.yourcompany.yourapp",
         "TEAMID.com.yourcompany.yourapp.staging"
       ]
     }
   }
   ```

2. **Host the File**:
   - URL: `https://yourdomain.com/.well-known/apple-app-site-association`
   - **Important**: No `.json` file extension!
   - Content-Type: `application/json`
   - Must be served over HTTPS
   - Must return HTTP 200 status

3. **Find Your Team ID**:
   - Go to [Apple Developer Account](https://developer.apple.com/account/)
   - Navigate to "Membership" section
   - Copy your Team ID (10-character string)

4. **Verify Association**:
   ```bash
   # Test your association file
   curl -v https://yourdomain.com/.well-known/apple-app-site-association
   ```
   - Use [Apple's Validator](https://developer.apple.com/help/app-store-connect/configure-app-store-connect/verify-domain-ownership)

#### Android Domain Verification (Digital Asset Links)

1. **Get Your App's SHA256 Fingerprint**:
   ```bash
   # Debug keystore (for development)
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA256
   
   # Release keystore (for production)
   keytool -list -v -keystore /path/to/release-key.keystore -alias release-key-alias | grep SHA256
   
   # From APK file
   keytool -printcert -jarfile app-release.apk | grep SHA256
   ```

2. **Create Asset Links File**:
   ```json
   [
     {
       "relation": ["delegate_permission/common.handle_all_urls"],
       "target": {
         "namespace": "android_app",
         "package_name": "com.yourcompany.yourapp",
         "sha256_cert_fingerprints": [
           "AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78"
         ]
       }
     }
   ]
   ```

3. **Host the File**:
   - URL: `https://yourdomain.com/.well-known/assetlinks.json`
   - Content-Type: `application/json`
   - Must be served over HTTPS
   - Must return HTTP 200 status

4. **Verify Asset Links**:
   ```bash
   # Test your asset links file
   curl -v https://yourdomain.com/.well-known/assetlinks.json
   ```
   - Use [Google's Tester](https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://yourdomain.com&relation=delegate_permission/common.handle_all_urls)
   - Use [Asset Links Generator](https://developers.google.com/digital-asset-links/tools/generator)

#### Common Domain Verification Issues

| Issue | Solution |
|-------|----------|
| **File not found (404)** | Ensure files are in `/.well-known/` directory |
| **HTTPS required** | Both files must be served over HTTPS only |
| **Wrong content-type** | Set `Content-Type: application/json` |
| **Invalid JSON** | Validate JSON syntax |
| **Wrong package name** | Must match your app's package identifier exactly |
| **Case sensitivity** | Package names and fingerprints are case-sensitive |
| **Caching issues** | Clear CDN/server cache after updating files |

#### Testing Domain Verification

```dart
// Test domain association in your Flutter app
void testDomainVerification() async {
  try {
    // This will fail if domain verification is not set up correctly
    final request = FlutterPasskeyService.createAuthenticationOptions(
      challenge: 'test-challenge',
      rpId: 'yourdomain.com', // Must match your verified domain
    );
    
    print('Domain verification appears to be working');
  } catch (e) {
    print('Domain verification issue: $e');
  }
}
```

### Registration Flow

The passkey registration process involves creating a new credential for the user:

```dart
Future<CreatePasskeyResponseData> registerUser({
  required String username,
  required String userId,
  required String challenge,
}) async {
  // 1. Create registration options
  final options = RegisterGenerateOptionData(
    challenge: challenge, // Base64URL encoded challenge from server
    rp: RegisterGenerateOptionRp(
      name: 'Your App Name',
      id: 'yourdomain.com',
    ),
    user: RegisterGenerateOptionUser(
      id: userId, // Unique user identifier
      name: username,
      displayName: 'Display Name',
    ),
    pubKeyCredParams: [
      RegisterGenerateOptionPublicKeyParams(alg: -7, type: 'public-key'), // ES256
      RegisterGenerateOptionPublicKeyParams(alg: -257, type: 'public-key'), // RS256
    ],
    timeout: 60000,
    attestation: 'none',
    excludeCredentials: [], // Previously registered credentials to exclude
    authenticatorSelection: RegisterGenerateOptionAuthenticatorSelection(
      residentKey: 'preferred',
      userVerification: 'required',
      requireResidentKey: false,
      authenticatorAttachment: 'platform',
    ),
    extensions: RegisterGenerateOptionExtension(credProps: true),
  );
  
  // 2. Perform registration
  final response = await FlutterPasskeyService.register(options);
  
  // 3. Send to server for verification and storage
  // response contains: id, rawId, type, authenticatorAttachment, 
  // response (attestationObject, clientDataJSON), clientExtensionResults
  
  return response;
}
```

### Authentication Flow

Authenticate users with their existing passkeys:

```dart
Future<GetPasskeyAuthenticationResponseData> authenticateUser({
  required String challenge,
  List<String>? allowedCredentialIds,
}) async {
  // 1. Create authentication request
  final request = AuthGenerateOptionResponseData(
    rpId: 'yourdomain.com',
    challenge: challenge, // Base64URL encoded challenge from server
    allowCredentials: allowedCredentialIds?.map((id) => 
      AuthGenerateOptionAllowCredential(
        id: id,
        type: 'public-key',
        transports: ['internal', 'hybrid'],
      )
    ).toList() ?? [],
    timeout: 60000,
    userVerification: 'required',
  );
  
  // 2. Perform authentication
  final response = await FlutterPasskeyService.authenticate(request);
  
  // 3. Send to server for verification
  // response contains: id, rawId, type, authenticatorAttachment,
  // response (clientDataJSON, authenticatorData, signature, userHandle)
  
  return response;
}
```

### Error Handling

The plugin provides comprehensive error handling through `PasskeyException`:

```dart
try {
  await FlutterPasskeyService.register(options);
} on PasskeyException catch (e) {
  switch (e.errorType) {
    case PasskeyErrorType.userCancelled:
      showMessage('User cancelled the operation');
      break;
    case PasskeyErrorType.noCredentialsAvailable:
      showMessage('No passkeys available for this account');
      break;
    case PasskeyErrorType.invalidParameters:
      showMessage('Invalid request parameters');
      break;
    case PasskeyErrorType.platformNotSupported:
      showMessage('Passkeys not supported on this device');
      break;
    default:
      showMessage('Authentication failed: ${e.message}');
  }
}
```

### Available Error Types

| Error Type | Description |
|------------|-------------|
| `invalidParameters` | Invalid or missing parameters |
| `userCancelled` | User cancelled the operation |
| `userTimeout` | Operation timed out |
| `noCredentialsAvailable` | No credentials available for authentication |
| `credentialNotFound` | Specified credential not found |
| `platformNotSupported` | Platform doesn't support passkeys |
| `domainNotAssociated` | Domain not associated with app |
| `invalidResponse` | Invalid response received |
| `systemError` | System-level error occurred |
| `networkError` | Network-related error |
| `unknownError` | Unknown error occurred |

## 🏗️ Advanced Configuration

### Custom Registration Options

```dart
final customOptions = RegisterGenerateOptionData(
  challenge: challenge,
  rp: RegisterGenerateOptionRp(name: 'App', id: 'domain.com'),
  user: RegisterGenerateOptionUser(id: 'user', name: 'username', displayName: 'User'),
  pubKeyCredParams: [
    RegisterGenerateOptionPublicKeyParams(alg: -7, type: 'public-key'),
  ],
  timeout: 120000, // 2 minutes
  attestation: 'direct', // Request attestation
  excludeCredentials: [
    RegisterGenerateOptionExcludeCredential(
      id: 'existing-credential-id',
      type: 'public-key',
      transports: ['internal'],
    ),
  ],
  authenticatorSelection: RegisterGenerateOptionAuthenticatorSelection(
    residentKey: 'required', // Force resident key
    userVerification: 'preferred',
    requireResidentKey: true,
    authenticatorAttachment: 'cross-platform', // Allow external authenticators
  ),
  extensions: RegisterGenerateOptionExtension(credProps: true),
);
```

### Server Integration

#### Challenge Generation
```dart
// Generate a cryptographically secure challenge on your server
String generateChallenge() {
  final bytes = List<int>.generate(32, (i) => Random.secure().nextInt(256));
  return base64Url.encode(bytes);
}
```

#### Verification
```dart
// Verify registration response on server
bool verifyRegistration(CreatePasskeyResponseData response, String challenge) {
  // 1. Decode and verify clientDataJSON
  // 2. Verify challenge matches
  // 3. Verify origin matches your domain
  // 4. Parse and verify attestationObject
  // 5. Store credential for future authentication
  return true; // Simplified
}

// Verify authentication response on server
bool verifyAuthentication(GetPasskeyAuthenticationResponseData response, String challenge) {
  // 1. Decode and verify clientDataJSON
  // 2. Verify challenge matches
  // 3. Verify origin matches your domain
  // 4. Verify signature using stored public key
  // 5. Update credential sign count
  return true; // Simplified
}
```

## 🔧 Platform Requirements

### iOS
- **Minimum Version**: iOS 16.0+
- **Frameworks**: AuthenticationServices
- **Capabilities**: Associated Domains
- **Features**: Touch ID, Face ID, Device Passcode support

### Android
- **Minimum Version**: Android 9.0 (API 28)+
- **Dependencies**: Credential Manager API
- **Features**: Biometric authentication, Device PIN support
- **Requirements**: Google Play Services

## 🧪 Testing

### Unit Testing
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

void main() {
  group('FlutterPasskeyService', () {
    test('createRegistrationOptions returns valid options', () {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: 'test-challenge',
        rpName: 'Test App',
        rpId: 'test.com',
        userId: 'user-123',
        username: 'test@example.com',
      );
      
      expect(options.challenge, 'test-challenge');
      expect(options.rp.name, 'Test App');
      expect(options.user.id, 'user-123');
    });
  });
}
```

### Integration Testing
```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Passkey Integration Tests', () {
    testWidgets('registration flow', (tester) async {
      // Test complete registration flow
      // Note: Requires physical device and user interaction
    });
  });
}
```

## 🔐 Security Considerations

1. **Challenge Generation**: Always generate challenges server-side using cryptographically secure methods
2. **Origin Verification**: Verify the origin in clientDataJSON matches your domain
3. **Timeout Handling**: Implement appropriate timeouts for user operations
4. **Error Messages**: Avoid exposing sensitive information in error messages
5. **Credential Storage**: Store public keys and metadata securely on your server
6. **Sign Count**: Track and validate signature counter to prevent replay attacks

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code of Conduct
- Development setup
- Pull request process
- Issue reporting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [API Reference](https://pub.dev/documentation/flutter_passkey_service)
- **Issues**: [GitHub Issues](https://github.com/minhtri1401/flutter_passkey_service/issues)
- **Discussions**: [GitHub Discussions](https://github.com/minhtri1401/flutter_passkey_service/discussions)

## 🔗 Resources

### WebAuthn & Passkeys
- [WebAuthn Specification](https://w3c.github.io/webauthn/)
- [Passkeys Overview](https://developers.google.com/identity/passkeys)
- [Passkeys.dev](https://passkeys.dev/) - Community resources and guides

### Platform Documentation
- [iOS AuthenticationServices](https://developer.apple.com/documentation/authenticationservices)
- [Android Credential Manager](https://developer.android.com/training/sign-in/passkeys)
- [iOS Passkeys Developer Guide](https://developer.apple.com/documentation/authenticationservices/public-private_key_authentication/supporting_passkeys)
- [Android Passkeys Implementation Guide](https://developer.android.com/training/sign-in/passkeys)

### Domain Verification Tools
- [Apple App Site Association Validator](https://developer.apple.com/help/app-store-connect/configure-app-store-connect/verify-domain-ownership)
- [Google Digital Asset Links Tester](https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://yourdomain.com&relation=delegate_permission/common.handle_all_urls)
- [Digital Asset Links Generator](https://developers.google.com/digital-asset-links/tools/generator)
- [Apple Team ID Lookup](https://developer.apple.com/account/)

### Testing & Debugging
- [WebAuthn.io](https://webauthn.io/) - Test WebAuthn implementations
- [Passkeys Debugger](https://github.com/MasterKale/SimpleWebAuthn) - Debug WebAuthn flows
- [Yubico WebAuthn Demo](https://demo.yubico.com/webauthn-technical/registration) - Test various scenarios

### Security Resources
- [FIDO Alliance](https://fidoalliance.org/) - Security specifications and guidelines
- [WebAuthn Security Considerations](https://w3c.github.io/webauthn/#sctn-security-considerations)
- [OWASP Authentication Guide](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

---

**Made with ❤️ for the Flutter community**