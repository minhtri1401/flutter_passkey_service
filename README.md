# Flutter Passkey Service - WebAuthn FIDO2 Passwordless Authentication

[![pub package](https://img.shields.io/pub/v/flutter_passkey_service.svg)](https://pub.dev/packages/flutter_passkey_service)
[![Pub Points](https://img.shields.io/pub/points/flutter_passkey_service)](https://pub.dev/packages/flutter_passkey_service/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A robust, production-ready Flutter plugin for integrating **Passkeys** (WebAuthn/FIDO2) passwordless authentication on iOS, macOS, and Android. Transform user authentication with biometric security and eliminate passwords.

## 📖 Table of Contents

- [Features](#-features)
- [Platform Support](#-platform-support)
- [Installation](#-installation)
- [Domain Verification Setup](#-domain-verification-setup)
  - [iOS Setup](#ios-setup)
  - [Android Setup](#android-setup)
- [Usage Guide](#-usage-guide)
  - [Registration Flow](#1-registration-flow)
  - [Authentication Flow](#2-authentication-flow)
  - [Working with Server JSON](#3-working-with-server-json)
  - [Error Handling](#4-error-handling)
- [Advanced Usage](#️-advanced-usage)
- [Security Considerations](#-security-considerations)
- [Contributing & Support](#-contributing--support)
- [License](#-license)

---

## ✨ Features

- **Passwordless Authentication**: Secure biometric and device-based authentication.
- **Cross-Platform**: Unifies iOS AuthenticationServices and Android Credential Manager APIs.
- **Cross-Device Sync**: Auto-sync across devices via iCloud Keychain and Google Password Manager.
- **WebAuthn Compliant**: Full compliance with W3C WebAuthn standards.
- **Advanced Extensions**: Native support for **PRF** (derive symmetric Key Encryption Keys) and **Large Blob** (store data directly on the passkey).
- **Type-Safe API**: Reliable Flutter-to-native communication generated with Pigeon.
- **JSON Serialization**: Easy conversion to and from server JSON responses.

## 📋 Platform Support

| Platform | Minimum Version | Supported Features |
|----------|-----------------|--------------------|
| **iOS**     | 16.0+          | Touch ID, Face ID, Device Passcode, External Authenticators, Resident Keys |
| **macOS**   | 13.0+          | Touch ID, Device Password, External Authenticators, Resident Keys (Large Blob on 14+, PRF on 15+) |
| **Android** | API 28+ (9.0)  | Fingerprint, Face Unlock, Device PIN, External Authenticators, Resident Keys |

## 🚀 Installation

Add `flutter_passkey_service` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_passkey_service: ^0.0.3
```

Run:
```bash
flutter pub get
```

---

## 🔧 Domain Verification Setup

⚠️ **Important**: Passkeys require cryptographic proof that your app is tied to a specific web domain. **Domain verification is mandatory.**

### iOS Setup (Apple App Site Association)

1. **Add Capability**: In Xcode, go to your target's **Signing & Capabilities**, add **Associated Domains**, and enter `webcredentials:yourdomain.com`.
2. **Host Association File**: Create an `apple-app-site-association` file (no `.json` extension) and host it at `https://yourdomain.com/.well-known/apple-app-site-association`.

   ```json
   {
     "webcredentials": {
       "apps": ["TEAMID.com.yourcompany.yourapp"]
     }
   }
   ```
   *(Ensure Response Content-Type is `application/json`)*

### Android Setup (Digital Asset Links)

1. **Get SHA256 Fingerprint**: Obtain the SHA256 signature of your release and debug keystores.
2. **Host Asset Links File**: Create an `assetlinks.json` file and host it at `https://yourdomain.com/.well-known/assetlinks.json`.

   ```json
   [{
     "relation": ["delegate_permission/common.handle_all_urls"],
     "target": {
       "namespace": "android_app",
       "package_name": "com.yourcompany.yourapp",
       "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
     }
   }]
   ```
   *(Ensure Response Content-Type is `application/json`)*

---

## 💻 Usage Guide

### 1. Registration Flow

Create a new Passkey credential for the user. Usually, you request creation options from your backend.

```dart
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

Future<void> registerPasskey() async {
  try {
    final options = FlutterPasskeyService.createRegistrationOptions(
      challenge: 'base64url-encoded-challenge-from-server',
      rpName: 'Your App Name',
      rpId: 'yourdomain.com', // Must match verified domain
      userId: 'user-unique-id',
      username: 'user@example.com',
      displayName: 'John Doe',
    );
    
    // Perform biometric authentication to create the Passkey
    final response = await FlutterPasskeyService.register(options);
    
    // Send `response` back to your server to store the public key
    print('Registration successful: ${response.id}');
  } on PasskeyException catch (e) {
    print('Registration failed: ${e.message}');
  }
}
```

### 2. Authentication Flow

Authenticate a user with an existing Passkey.

```dart
Future<void> authenticate() async {
  try {
    final request = FlutterPasskeyService.createAuthenticationOptions(
      challenge: 'base64url-encoded-challenge-from-server',
      rpId: 'yourdomain.com', // Must match verified domain
    );
    
    // Prompt biometric authentication
    final response = await FlutterPasskeyService.authenticate(request);
    
    // Send `response` back to your server to verify the signature
    print('Authentication successful: ${response.id}');
  } on PasskeyException catch (e) {
    print('Authentication failed: ${e.message}');
  }
}
```

### 3. Working with Server JSON

Often, your server will generate the WebAuthn options directly as JSON. The plugin natively supports parsing these.

```dart
// Register
final serverRegistrationJson = await backend.getRegistrationOptions();
final registerOptions = FlutterPasskeyService.createRegistrationOptionsFromJson(serverRegistrationJson);
final regResponse = await FlutterPasskeyService.register(registerOptions);

// Authenticate
final serverAuthJson = await backend.getAuthenticationOptions();
final authOptions = FlutterPasskeyService.createAuthenticationOptionsFromJson(serverAuthJson);
final authResponse = await FlutterPasskeyService.authenticate(authOptions);
```

You can also export options back to JSON for debugging:
```dart
print(registerOptions.toJsonString());
```

### 4. Error Handling

The plugin provides a unified `PasskeyException` with typed errors.

```dart
try {
  await FlutterPasskeyService.authenticate(request);
} on PasskeyException catch (e) {
  switch (e.errorType) {
    case PasskeyErrorType.userCancelled:
      print('User cancelled the biometric prompt');
      break;
    case PasskeyErrorType.noCredentialsAvailable:
      print('No passkeys found for this site.');
      break;
    case PasskeyErrorType.platformNotSupported:
      print('Passkeys are not supported on this OS version.');
      break;
    case PasskeyErrorType.domainNotAssociated:
      print('Domain verification failed. Check assetlinks.json / apple-app-site-association.');
      break;
    default:
      print('Unhandled passkey error: ${e.message}');
  }
}
```

### 5. WebAuthn Extensions (PRF & Large Blob)

**PRF (Key Encryption Key)**
The PRF extension allows you to derive a symmetric key (KEK) during authentication, tied strictly to the passkey. This is perfect for encrypting local offline game saves or profiles.

```dart
// 1. Enable PRF during Registration
final regOptions = FlutterPasskeyService.createRegistrationOptions(
  /* ... */
  enablePrf: true, 
);

// 2. Derive Key during Authentication
final authOptions = FlutterPasskeyService.createAuthenticationOptionsFromJson(serverAuthJson);
// Send your salt to derive the KEK
authOptions.extensions = AuthGenerateOptionExtension(
  prf: PrfExtensionInput(eval: {'first': 'base64url-encoded-salt-here'})
);
final response = await FlutterPasskeyService.authenticate(authOptions);
final derivedKey = response.clientExtensionResults?.prf?.results?['first'];
```

**Large Blob Storage**
The Large Blob extension lets you store up to 1KB of arbitrary data directly within the passkey hardware.

```dart
// 1. Enable Large Blob Support during Registration
final regOptions = FlutterPasskeyService.createRegistrationOptions(
  /* ... */
  enableLargeBlob: true,
);

// 2. Write Data during Authentication
final authOptionsWrite = FlutterPasskeyService.createAuthenticationOptions(
  /* ... */
  largeBlobWrite: Uint8List.fromList('Hello World'.codeUnits),
);
await FlutterPasskeyService.authenticate(authOptionsWrite);

// 3. Read Data during Authentication
final authOptionsRead = FlutterPasskeyService.createAuthenticationOptions(
  /* ... */
  largeBlobRead: true,
);
final response = await FlutterPasskeyService.authenticate(authOptionsRead);
final blobData = response.clientExtensionResults?.largeBlob?.blob;
```

## 📚 Tutorials & Articles

To get an in-depth understanding of the transition to passwordless logins and see a complete conceptual walkthrough of this plugin, check out this comprehensive guide:
- 📖 [**Unlock the Future of Authentication: A Guide to Passwordless Login with Passkey**](https://dev.to/tri_dev_dhm/unlock-the-future-of-authentication-a-guide-to-passwordless-login-with-passkey-516b)

## 🏗️ Advanced Usage

For granular control, you can define custom options using the typed model classes directly:

```dart
final customOptions = RegisterGenerateOptionData(
  challenge: '...',
  rp: RegisterGenerateOptionRp(name: 'App', id: 'domain.com'),
  user: RegisterGenerateOptionUser(id: 'user', name: 'user', displayName: 'User'),
  pubKeyCredParams: [
    RegisterGenerateOptionPublicKeyParams(alg: -7, type: 'public-key'), // ES256
    RegisterGenerateOptionPublicKeyParams(alg: -257, type: 'public-key'), // RS256
  ],
  timeout: 60000,
  attestation: 'direct',
  authenticatorSelection: RegisterGenerateOptionAuthenticatorSelection(
    residentKey: 'required',
    userVerification: 'required',
    authenticatorAttachment: 'platform',
  ),
);
```

## 🔐 Security Considerations

- **Server-Side Verification**: This plugin only handles the client-side component of WebAuthn. You MUST securely verify the cryptographic signatures on your backend.
- **Challenge Generation**: Challenges must be generated server-side using cryptographically secure random number generators to prevent replay attacks.
- **HTTPS**: Apple and Google require your associated domain to be served over secure HTTPS.
- **Verification Result**: Always use `clientDataJSON`, `authenticatorData`, and `signature` to securely verify the passkey login or credential registration.

## 🤝 Contributing & Support

- **Repository**: [GitHub](https://github.com/minhtri1401/flutter_passkey_service)
- **Issue Tracker**: [Report a bug or request a feature](https://github.com/minhtri1401/flutter_passkey_service/issues)
- Contributions are welcome! Read the `CONTRIBUTING.md` for guidelines.

### 🌟 Contributors

Thanks to these wonderful people who have contributed to the project:

| Contributor | Contribution |
|-------------|--------------|
| [@minhtri1401](https://github.com/minhtri1401) | Project creator & maintainer — iOS & Android implementation, PRF and Large Blob extensions |
| [@hhanh00](https://github.com/hhanh00) | macOS platform support ([#2](https://github.com/minhtri1401/flutter_passkey_service/pull/2)) |

Want your name here? Check out [CONTRIBUTING.md](./CONTRIBUTING.md) and open a pull request!

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.