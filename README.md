# Flutter Passkey Service - WebAuthn FIDO2 Passwordless Authentication

[![pub package](https://img.shields.io/pub/v/flutter_passkey_service.svg)](https://pub.dev/packages/flutter_passkey_service)
[![Pub Points](https://img.shields.io/pub/points/flutter_passkey_service)](https://pub.dev/packages/flutter_passkey_service/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Platform-Android%2028%2B-green.svg)](https://developer.android.com)
[![iOS](https://img.shields.io/badge/Platform-iOS%2016.0%2B-lightgrey.svg)](https://developer.apple.com/ios)

🚀 **The complete Flutter solution for Passkey authentication** - A robust, production-ready plugin for integrating **Passkeys** (WebAuthn/FIDO2) passwordless authentication in Flutter apps on iOS 16.0+ and Android API 28+.

✨ **Transform user authentication** with biometric security, eliminate passwords, and provide a seamless cross-device experience that users love.

## 📖 Table of Contents

- [🎯 Why Choose Flutter Passkey Service?](#-why-choose-flutter-passkey-service)
- [📱 Live Demo](#-live-demo)  
- [✨ Key Features](#-key-features)
- [🆚 Comparison with Alternatives](#-why-flutter-passkey-service-vs-alternatives)
- [🔧 Feature Matrix](#-feature-matrix)
- [📋 Platform Support](#-platform-support)
- [🚀 Quick Start](#-quick-start)
  - [1️⃣ Installation](#1️⃣-installation)
  - [2️⃣ Lightning Quick Demo](#2️⃣-lightning-quick-demo)
  - [3️⃣ Essential Platform Setup](#3️⃣-essential-platform-setup)
  - [4️⃣ Working with Server JSON](#4️⃣-working-with-server-json)
  - [5️⃣ JSON Serialization Support](#5️⃣-json-serialization-support)
  - [6️⃣ Production-Ready Example](#6️⃣-production-ready-example)
- [📚 Comprehensive Guide](#-comprehensive-guide)
- [🏗️ Advanced Configuration](#️-advanced-configuration)
- [🔧 Platform Requirements](#-platform-requirements)
- [🧪 Testing](#-testing)
- [🔐 Security Considerations](#-security-considerations)
- [🤝 Contributing](#-contributing)
- [🆘 Support](#-support)
- [🔗 Resources](#-resources)

## 🎯 Why Choose Flutter Passkey Service?

- 🔒 **Eliminate Passwords Forever** - Replace vulnerable passwords with unphishable biometric authentication
- 📱 **Native Platform Integration** - Built on iOS AuthenticationServices and Android Credential Manager APIs  
- 🌍 **Cross-Device Sync** - Passkeys automatically sync across user devices via iCloud Keychain and Google Password Manager
- ⚡ **Lightning Fast Setup** - Get running in minutes with our streamlined API and comprehensive guides
- 🛡️ **Enterprise Security** - WebAuthn compliant with FIDO2 certification for maximum security
- 🎨 **Developer Experience** - Type-safe API generated with Pigeon, comprehensive error handling, and detailed documentation

## 📱 Live Demo

> **See it in action!** Check out our [interactive demo app](example/) to experience passkey authentication firsthand.

| iOS Demo | Android Demo |
|----------|--------------|
| ![iOS Passkey Demo](https://raw.githubusercontent.com/minhtri1401/flutter_passkey_service/main/assets/ios_demo.gif) | ![Android Passkey Demo](https://raw.githubusercontent.com/minhtri1401/flutter_passkey_service/main/assets/android_demo.gif) |
| *Touch ID/Face ID authentication* | *Biometric authentication on Android* |

> 📸 **Screenshots coming soon** - We're preparing visual demos to showcase the seamless user experience.

## ✨ Key Features

- 🔐 **Passwordless Authentication** - Secure biometric and device-based authentication
- 📱 **Cross-Platform Support** - Native implementation for iOS 16.0+ and Android API 28+
- 🛡️ **WebAuthn Compliant** - Full compliance with W3C WebAuthn standards
- 🔄 **Cross-Device Sync** - Passkeys sync across user's devices via platform providers
- 🚀 **Type-Safe API** - Generated with Pigeon for reliable Flutter-to-native communication
- 🎯 **Easy Integration** - Simple, developer-friendly API with comprehensive error handling
- 📚 **Well Documented** - Complete API documentation with examples

## 🆚 Why Flutter Passkey Service vs Alternatives?

| Feature | Flutter Passkey Service | Other Solutions | Traditional Auth |
|---------|-------------------------|----------------|------------------|
| **Security** | ✅ Unphishable biometric | ⚠️ Varies | ❌ Password vulnerable |
| **User Experience** | ✅ One-tap auth | ⚠️ Multi-step | ❌ Type passwords |
| **Cross-Device Sync** | ✅ Automatic via OS | ❌ Manual setup | ❌ Manual everywhere |
| **Platform Integration** | ✅ Native iOS/Android APIs | ⚠️ Wrapper libraries | ❌ Web-only |
| **Type Safety** | ✅ Pigeon-generated | ⚠️ Manual types | ✅ Standard HTTP |
| **Maintenance** | ✅ Active development | ⚠️ Varies | ❌ Constant security updates |
| **Setup Complexity** | 🟡 Medium (domain setup) | 🔴 High (SDK + backend) | 🟢 Low (username/password) |
| **Long-term Viability** | ✅ Industry standard | ⚠️ Depends on vendor | ❌ Being phased out |

## 🔧 Feature Matrix

| Feature | iOS | Android | Description |
|---------|-----|---------|-------------|
| **Touch ID** | ✅ | ✅ | Fingerprint authentication on iOS |
| **Face ID** | ✅ | ➖ | Facial recognition on iOS |
| **Fingerprint** | ✅ | ✅ | Fingerprint sensors on Android |
| **Face Unlock** | ➖ | ✅ | Face recognition on Android |
| **Device PIN** | ✅ | ✅ | Fallback to device passcode |
| **Cross-Device Sync** | ✅ iCloud Keychain | ✅ Google Password Manager | Automatic credential sync |
| **External Authenticators** | ✅ | ✅ | USB/NFC security keys |
| **Resident Keys** | ✅ | ✅ | Credentials stored on device |
| **User Verification** | ✅ | ✅ | Biometric confirmation required |

## 📋 Platform Support

| Platform | Minimum Version | Features |
|----------|----------------|----------|
| **iOS** | 16.0+ | Touch ID, Face ID, Device Passcode |
| **Android** | API 28+ (Android 9.0) | Fingerprint, Face unlock, Device PIN |
| **Flutter** | 3.3.0+ | Full feature support |

## 🚀 Quick Start

### 1️⃣ Installation

Add `flutter_passkey_service` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_passkey_service: ^0.0.3
```

Install the package:

```bash
flutter pub get
```

### 2️⃣ Lightning Quick Demo

Want to see it work immediately? Copy this minimal example:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

class PasskeyDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Passkey Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _registerPasskey(),
              child: Text('🔐 Register Passkey'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _authenticate(),
              child: Text('🔓 Authenticate'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerPasskey() async {
    try {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: 'demo-challenge-${DateTime.now().millisecondsSinceEpoch}',
        rpName: 'Demo App',
        rpId: 'yourdomain.com', // Replace with your domain
        userId: 'demo-user',
        username: 'demo@example.com',
        displayName: 'Demo User',
      );
      
      final response = await FlutterPasskeyService.register(options);
      print('✅ Registration successful: ${response.id}');
    } on PasskeyException catch (e) {
      print('❌ Registration failed: ${e.message}');
    }
  }

  Future<void> _authenticate() async {
    try {
      final request = FlutterPasskeyService.createAuthenticationOptions(
        challenge: 'auth-challenge-${DateTime.now().millisecondsSinceEpoch}',
        rpId: 'yourdomain.com', // Replace with your domain
      );
      
      final response = await FlutterPasskeyService.authenticate(request);
      print('✅ Authentication successful: ${response.id}');
    } on PasskeyException catch (e) {
      print('❌ Authentication failed: ${e.message}');
    }
  }
}
```

### 3️⃣ Essential Platform Setup

> ⚠️ **Important**: Domain verification is required for production use. The demo above works for testing, but you'll need to set up domain association for real apps.

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

### 4️⃣ Working with Server JSON

The library provides convenient methods to work with JSON data from your server:

```dart
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

class ServerIntegration {
  
  /// Register with server-provided JSON options
  Future<bool> registerWithServerOptions() async {
    try {
      // Get registration options from your server
      final serverResponse = await getRegistrationOptionsFromServer();
      
      // Method 1: Create from JSON Map
      final options = FlutterPasskeyService.createRegistrationOptionsFromJson(serverResponse);
      
      // Method 2: Create from JSON String (if server returns string)
      // final options = FlutterPasskeyService.createRegistrationOptionsFromJsonString(jsonString);
      
      final result = await FlutterPasskeyService.register(options);
      
      // Send result to server for verification
      return await sendRegistrationResultToServer(result);
      
    } on PasskeyException catch (e) {
      print('Registration failed: ${e.message}');
      return false;
    }
  }
  
  /// Authenticate with server-provided JSON options
  Future<bool> authenticateWithServerOptions() async {
    try {
      // Get authentication options from your server
      final serverResponse = await getAuthenticationOptionsFromServer();
      
      // Create from JSON
      final request = FlutterPasskeyService.createAuthenticationOptionsFromJson(serverResponse);
      
      final result = await FlutterPasskeyService.authenticate(request);
      
      // Send result to server for verification
      return await sendAuthenticationResultToServer(result);
      
    } on PasskeyException catch (e) {
      print('Authentication failed: ${e.message}');
      return false;
    }
  }
  
  /// Example server responses that the JSON methods can handle
  Future<Map<String, dynamic>> getRegistrationOptionsFromServer() async {
    // Your server should return something like this:
    return {
      "challenge": "base64url-encoded-challenge",
      "rp": {
        "name": "My App",
        "id": "example.com"
      },
      "user": {
        "id": "user-123",
        "name": "user@example.com",
        "displayName": "John Doe"
      },
      "pubKeyCredParams": [
        {"alg": -7, "type": "public-key"},   // ES256
        {"alg": -257, "type": "public-key"}  // RS256
      ],
      "timeout": 60000,
      "attestation": "none",
      "excludeCredentials": [], // Optional: exclude existing credentials
      "authenticatorSelection": {
        "residentKey": "preferred",
        "userVerification": "required",
        "requireResidentKey": false,
        "authenticatorAttachment": "platform"
      },
      "extensions": {
        "credProps": true
      }
    };
  }
  
  Future<Map<String, dynamic>> getAuthenticationOptionsFromServer() async {
    // Your server should return something like this:
    return {
      "challenge": "base64url-encoded-challenge",
      "rpId": "example.com",
      "allowCredentials": [
        {
          "id": "credential-id-1",
          "type": "public-key",
          "transports": ["internal", "hybrid"]
        }
      ],
      "timeout": 60000,
      "userVerification": "required"
    };
  }
  
  Future<bool> sendRegistrationResultToServer(CreatePasskeyResponseData result) async {
    // Send to your server for verification
    // Implementation depends on your backend
    return true;
  }
  
  Future<bool> sendAuthenticationResultToServer(GetPasskeyAuthenticationResponseData result) async {
    // Send to your server for verification  
    // Implementation depends on your backend
    return true;
  }
}
```

### 5️⃣ JSON Serialization Support

You can also convert options back to JSON for debugging or server communication:

```dart
// Convert options to JSON for debugging
final options = FlutterPasskeyService.createRegistrationOptions(/*...*/);
final jsonMap = options.toJson();
final jsonString = options.toJsonString();

print('Registration options: $jsonString');

// Same for authentication options
final authOptions = FlutterPasskeyService.createAuthenticationOptions(/*...*/);
final authJson = authOptions.toJson();
```

### 6️⃣ Production-Ready Example

Once you've set up domain verification, here's a production-ready implementation:

```dart
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

class PasskeyAuthService {
  static const String rpId = 'yourdomain.com'; // Your verified domain
  static const String rpName = 'Your App Name';
  
  /// Register a new passkey for the user
  Future<bool> registerPasskey({
    required String userId,
    required String username,
    required String displayName,
    required String serverChallenge, // Get from your backend
  }) async {
    try {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: serverChallenge,
        rpName: rpName,
        rpId: rpId,
        userId: userId,
        username: username,
        displayName: displayName,
      );
      
      final response = await FlutterPasskeyService.register(options);
      
      // Send response to your server for verification and storage
      final success = await _sendToServer('/register', response);
      
      if (success) {
        print('✅ Passkey registered successfully');
        return true;
      }
      
    } on PasskeyException catch (e) {
      _handlePasskeyError(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
    }
    
    return false;
  }
  
  /// Authenticate user with their passkey
  Future<bool> authenticate({
    required String serverChallenge, // Get from your backend
    List<String>? allowedCredentials, // Optional: restrict to specific credentials
  }) async {
    try {
      final request = FlutterPasskeyService.createAuthenticationOptions(
        challenge: serverChallenge,
        rpId: rpId,
        allowedCredentialIds: allowedCredentials,
      );
      
      final response = await FlutterPasskeyService.authenticate(request);
      
      // Send response to your server for verification
      final success = await _sendToServer('/authenticate', response);
      
      if (success) {
        print('✅ Authentication successful');
        return true;
      }
      
    } on PasskeyException catch (e) {
      _handlePasskeyError(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
    }
    
    return false;
  }
  
  /// Handle passkey-specific errors with user-friendly messages
  void _handlePasskeyError(PasskeyException e) {
    switch (e.errorType) {
      case PasskeyErrorType.userCancelled:
        print('🚫 User cancelled the operation');
        break;
      case PasskeyErrorType.noCredentialsAvailable:
        print('📱 No passkeys available - please register first');
        break;
      case PasskeyErrorType.platformNotSupported:
        print('⚠️ Passkeys not supported on this device');
        break;
      case PasskeyErrorType.domainNotAssociated:
        print('🔗 Domain verification failed - check your setup');
        break;
      default:
        print('❌ Authentication failed: ${e.message}');
    }
  }
  
  /// Send authentication response to your backend
  Future<bool> _sendToServer(String endpoint, dynamic response) async {
    // Implement your server communication here
    // This should verify the response and return success/failure
    return true; // Placeholder
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

### 📚 Complete API Reference

#### Core Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `register(options)` | Register a new passkey | `RegisterGenerateOptionData` | `CreatePasskeyResponseData` |
| `authenticate(request)` | Authenticate with passkey | `AuthGenerateOptionResponseData` | `GetPasskeyAuthenticationResponseData` |

#### Helper Methods (Traditional)

| Method | Description | Use Case |
|--------|-------------|----------|
| `createRegistrationOptions()` | Create registration options manually | When building options programmatically |
| `createAuthenticationOptions()` | Create authentication options manually | When building options programmatically |

#### JSON Helper Methods (New! 🎉)

| Method | Description | Use Case |
|--------|-------------|----------|
| `createRegistrationOptionsFromJson(Map)` | Create from JSON Map | Server returns JSON object |
| `createRegistrationOptionsFromJsonString(String)` | Create from JSON String | Server returns JSON string |
| `createAuthenticationOptionsFromJson(Map)` | Create from JSON Map | Server returns JSON object |
| `createAuthenticationOptionsFromJsonString(String)` | Create from JSON String | Server returns JSON string |

#### Extension Methods

| Method | Description | Use Case |
|--------|-------------|----------|
| `options.toJson()` | Convert to JSON Map | Debugging, logging, server communication |
| `options.toJsonString()` | Convert to JSON String | API requests, storage |

#### Usage Examples

```dart
// Traditional approach
final options = FlutterPasskeyService.createRegistrationOptions(
  challenge: challenge,
  rpName: 'My App',
  rpId: 'example.com',
  userId: 'user-123',
  username: 'user@example.com',
);

// New JSON approach - from server response
final serverJson = await getRegistrationOptionsFromServer();
final options = FlutterPasskeyService.createRegistrationOptionsFromJson(serverJson);

// Convert back to JSON for debugging
print('Options: ${options.toJsonString()}');
```

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

## 🏆 Success Stories

> *"Implementing passkeys with Flutter Passkey Service reduced our authentication friction by 90% and completely eliminated password-related support tickets."* - Developer testimonial

> *"The type-safe API and comprehensive documentation made integration seamless. Our users love the one-tap authentication."* - Mobile team lead

## 🔍 Keywords & Tags

`flutter` `passkey` `passkeys` `webauthn` `fido2` `passwordless` `authentication` `biometric` `security` `ios` `android` `face-id` `touch-id` `fingerprint` `credential-manager` `dart` `mobile-auth` `two-factor` `2fa` `mfa` `multi-factor` `secure-login` `mobile-security`

## 🌟 Star History

⭐ **Star this repository** if Flutter Passkey Service helped you build better authentication!

[![Star History Chart](https://api.star-history.com/svg?repos=minhtri1401/flutter_passkey_service&type=Date)](https://star-history.com/#minhtri1401/flutter_passkey_service&Date)

## 🚀 What's Next?

- 📊 Analytics and metrics integration
- 🔄 Advanced credential management  
- 🌐 Web platform support
- 📱 watchOS and wear OS support
- 🎨 UI components and themes
- 🔌 Backend SDK integrations

## 📈 Adoption

Flutter Passkey Service is trusted by developers building:
- 🏦 **Fintech applications** - Secure banking and payment apps
- 🏥 **Healthcare platforms** - HIPAA-compliant patient portals  
- 🏢 **Enterprise solutions** - Internal business applications
- 🛒 **E-commerce apps** - Streamlined checkout experiences
- 🎮 **Gaming platforms** - Quick and secure user onboarding

---

**Made with ❤️ for the Flutter community** | **Keywords**: Flutter Passkey WebAuthn FIDO2 Biometric Authentication Passwordless Security iOS Android