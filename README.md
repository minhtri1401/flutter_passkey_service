# flutter_passkey_service: Passkeys (WebAuthn / FIDO2) for Flutter on iOS, macOS and Android

[![pub package](https://img.shields.io/pub/v/flutter_passkey_service.svg)](https://pub.dev/packages/flutter_passkey_service)
[![Pub Points](https://img.shields.io/pub/points/flutter_passkey_service)](https://pub.dev/packages/flutter_passkey_service/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**flutter_passkey_service** is an open-source Flutter plugin that adds passkey registration and sign-in (WebAuthn / FIDO2) to iOS, macOS and Android apps. It wraps Apple's `AuthenticationServices` and Android's `CredentialManager` behind one type-safe Dart API, works with any WebAuthn server, and supports the PRF and largeBlob extensions for key derivation and on-credential storage.

Last updated: 2026-10-03 · Current version: 0.1.0 · License: MIT

### At a glance

| | |
|---|---|
| **What it does** | Create a passkey (`register`) and sign in with a passkey (`authenticate`) using Face ID, Touch ID, fingerprint or device PIN |
| **Platforms** | iOS 16+, macOS 13+, Android API 28+ (library minSdk 23) |
| **Not supported** | Flutter web, Windows, Linux, hardware security keys, conditional UI / passkey autofill |
| **Backend** | Any WebAuthn relying-party server (SimpleWebAuthn, webauthn4j, py_webauthn, go-webauthn, Corbado, Hanko, ...) |
| **Extensions** | PRF (iOS 18+ / macOS 15+ / Android), largeBlob (iOS 17+ / macOS 14+ / Android), credProps |
| **Native APIs** | `ASAuthorizationPlatformPublicKeyCredentialProvider` (Darwin), `androidx.credentials.CredentialManager` 1.6.0 (Android) |
| **Errors** | One `PasskeyException` with a typed `PasskeyErrorType` enum on every platform |
| **For AI agents** | [`llms.txt`](./llms.txt), [`llms-full.txt`](./llms-full.txt), [`context7.json`](./context7.json) |

## 📖 Table of Contents

- [Features](#-features)
- [Platform Support](#-platform-support)
- [Installation](#-installation)
- [Migration to 0.1.0](#migration-to-010)
- [Domain Verification Setup](#-domain-verification-setup)
  - [iOS Setup](#ios-setup)
  - [Android Setup](#android-setup)
- [Usage Guide](#-usage-guide)
  - [Registration Flow](#1-registration-flow)
  - [Authentication Flow](#2-authentication-flow)
  - [Working with Server JSON](#3-working-with-server-json)
  - [Error Handling](#4-error-handling)
- [Advanced Usage](#️-advanced-usage)
- [How it compares](#how-it-compares)
- [FAQ](#faq)
- [Guides](#guides)
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

| Platform | Minimum Version | Notes |
|----------|-----------------|-------|
| **iOS**     | 16.0+          | Platform passkeys (iCloud Keychain). `excludeCredentials` 17.4+, Large Blob 17.0+, PRF 18.0+. `pubKeyCredParams`, `timeout`, `hints`, `attestationFormats`, `residentKey`, `requireResidentKey` and the `appid` extension have no platform API and are ignored; `clientExtensionResults.credProps` is always null. |
| **macOS**   | 13.0+          | Same as iOS. `excludeCredentials` 13.5+, Large Blob 14.0+, PRF 15.0+. |
| **Android** | API 28+ (9.0)  | Credential Manager (`androidx.credentials` 1.6.0). WebAuthn JSON fields are forwarded to the provider as sent; `credProps.rk` is reported as false when the provider omits it. Library minSdk is 23; passkeys require Google Play services on Android 9+. |

Both Swift Package Manager and CocoaPods are supported on iOS and macOS via the shared `darwin/` package.

## 🚀 Installation

Add `flutter_passkey_service` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_passkey_service: ^0.1.0
```

Run:
```bash
flutter pub get
```

## Migration to 0.1.0

1. **iOS/macOS user handle.** Passkeys registered on iOS/macOS with 0.0.x carry a user handle equal to the UTF-8 bytes of the `userId` string you passed. Their assertions still return the same `userHandle` as before. New registrations use the base64url-decoded bytes, matching Android. If your server compares `userHandle` to its stored `user.id`, accept both forms during the transition or re-register iOS users. iOS/macOS now decode `user.id` as base64url bytes exactly as Android does. A string that happens to be valid base64 but is not your intended handle (for example `user-123`) decodes to unintended bytes rather than failing, so base64url-encode your handle before sending it. `invalidFormat` is returned only when the string cannot be decoded at all or decodes to zero bytes.
2. **JSON defaults.** If you relied on the plugin adding `userVerification: required` or `authenticatorAttachment: platform` to server JSON, send them from the server.
3. **CocoaPods apps:** run `pod install` in `ios/` and `macos/` after upgrading.

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
     "relation": ["delegate_permission/common.get_login_creds", "delegate_permission/common.handle_all_urls"],
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
      userId: 'dXNlci11bmlxdWUtaWQ', // base64url of your user handle bytes
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

## How it compares

Facts below were checked against each package's pub.dev page on 2026-10-03. Verify before choosing; both projects move quickly.

| | flutter_passkey_service | [passkeys](https://pub.dev/packages/passkeys) (Corbado) | [local_auth](https://pub.dev/packages/local_auth) |
|---|---|---|---|
| Purpose | WebAuthn passkey registration and assertion against your own server | WebAuthn passkey registration and assertion, optional Corbado backend | Device-local biometric prompt only; no server-verifiable credential |
| Platforms | iOS, macOS, Android | iOS, macOS, Android, Web, Windows | iOS, macOS, Android, Windows |
| PRF extension | Yes (iOS 18+, macOS 15+, Android) | Yes (iOS 18+, macOS 15+, Android, Web, Windows) | n/a |
| largeBlob extension | Yes (iOS 17+, macOS 14+, Android) | Not documented on pub.dev as of 2026-10 | n/a |
| Server JSON helpers | `createRegistrationOptionsFromJson` / `createAuthenticationOptionsFromJson` | Typed request objects | n/a |
| Platform channel | Pigeon (generated, type-safe) | Federated plugin | Federated plugin |
| License | MIT | BSD-3-Clause | BSD-3-Clause |

Choose **flutter_passkey_service** when you want a small, backend-agnostic mobile and desktop passkey client with PRF and largeBlob. Choose **passkeys** when you also need web or Windows. Use **local_auth** only for gating UI behind a biometric check, since it produces nothing a server can verify.

## FAQ

**What is a passkey?**
A passkey is a FIDO2 / WebAuthn credential: a public-private key pair created by the device, unlocked with biometrics or the device PIN, and synced through iCloud Keychain or Google Password Manager. The server stores only the public key, so there is no password to phish or leak.

**Does flutter_passkey_service work with any WebAuthn backend?**
Yes. It exchanges standard WebAuthn JSON (`PublicKeyCredentialCreationOptionsJSON` / `PublicKeyCredentialRequestOptionsJSON`) and returns the standard credential response fields. Any relying-party library can verify the result. See the [server integration guide](./doc/guides/server-integration.md).

**Which OS versions are required?**
iOS 16.0, macOS 13.0 and Android 9 (API 28) with Google Play services. The Android library compiles for minSdk 23 but Credential Manager passkeys need API 28+. PRF needs iOS 18 / macOS 15; largeBlob needs iOS 17 / macOS 14.

**Does it support Flutter web, Windows or Linux?**
No. This plugin covers iOS, macOS and Android only. For web, use the browser WebAuthn API directly or a package that wraps it.

**Do passkeys sync between a user's devices?**
Yes, through the platform provider: iCloud Keychain on Apple devices and Google Password Manager on Android. Cross-ecosystem sign-in uses the hybrid (QR code) flow that the OS presents automatically.

**Why do I get `domainNotAssociated` on iOS?**
Apple could not validate `https://<rpId>/.well-known/apple-app-site-association` for your Team ID and bundle ID, or the Associated Domains capability is missing. See [troubleshooting](./doc/guides/troubleshooting.md).

**Why do I get `noCredentialsAvailable`?**
No passkey exists for `rpId` on this device or in the synced keychain, or `allowCredentials` listed IDs the device does not have. Offer registration, or send an empty `allowCredentials` list for discoverable sign-in.

**How do I derive an encryption key from a passkey?**
Register with `enablePrf: true`, then authenticate with `prfEval: {'first': base64urlSalt}` and read `response.clientExtensionResults?.prf?.results?['first']`. The 32-byte output is suitable as a key-encryption key for local data. See the [PRF guide](./kek_feature_article.md).

**Can I store data on the passkey?**
Yes, up to about 1 KB with the largeBlob extension. Register with `enableLargeBlob: true`, then authenticate with `largeBlobWrite: bytes` or `largeBlobRead: true`. See the [largeBlob guide](./large_blob_article.md).

**Does it support hardware security keys or conditional UI (passkey autofill)?**
No. Only platform passkeys are requested, and the plugin does not call the autofill / conditional-mediation APIs.

**How is this different from local_auth?**
`local_auth` shows a biometric prompt and returns a boolean; nothing is sent to a server. `flutter_passkey_service` produces a signed WebAuthn assertion that your server verifies, so it replaces the password rather than guarding the UI.

**What changed in 0.1.0?**
`ios/` and `macos/` merged into one `darwin/` Swift package with SPM support, iOS/macOS now base64url-decode `user.id` like Android, the JSON helpers stopped injecting defaults, and several option fields became nullable. See [Migration to 0.1.0](#migration-to-010) and the [CHANGELOG](./CHANGELOG.md).

## Guides

- [Error reference](./doc/guides/error-reference.md): every `PasskeyErrorType` value, which platform raises it, and what to do.
- [Server integration](./doc/guides/server-integration.md): JSON shapes, base64url rules, user handle and origin handling.
- [Troubleshooting](./doc/guides/troubleshooting.md): domain association, "no credentials", emulators, macOS entitlements.
- [Deriving a Key Encryption Key with PRF](./kek_feature_article.md) and [storing data with largeBlob](./large_blob_article.md).
- [API reference on pub.dev](https://pub.dev/documentation/flutter_passkey_service/latest/).

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