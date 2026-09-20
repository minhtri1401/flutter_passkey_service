# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-09-20

### Changed
- **Shared Darwin package.** `ios/` and `macos/` are replaced by one `darwin/` Swift package with a `Package.swift` (Swift Package Manager) and a single podspec (CocoaPods). Apps on Flutter 3.24+ with SPM enabled build the plugin as a Swift package; other apps keep using CocoaPods.
- **iOS/macOS user handle now follows the WebAuthn JSON format.** `user.id` is base64url-decoded before being handed to the authenticator, matching Android. See Migration.
- **`createRegistrationOptionsFromJson` / `createAuthenticationOptionsFromJson` no longer inject defaults.** Fields the server omits (`timeout`, `userVerification`, `authenticatorSelection` and its members, credential `transports`) stay null and are left to the platform. `createRegistrationOptions` / `createAuthenticationOptions` keep their explicit defaults.
- Pigeon models: `timeout`, `userVerification`, `authenticatorSelection` (and its four fields) and credential `transports` are nullable.
- Android: `androidx.credentials` 1.6.0 (stable); `play-services-auth` dependency removed.

### Added
- iOS/macOS apply `displayName`, `userVerification` and `attestation` from the options.
- iOS 18+ / macOS 15+ evaluate PRF salts at registration when `extensions.prf.eval` is set, returning `clientExtensionResults.prf.results` like Android.
- Android forwards `hints`, `attestationFormats` and the `appid` extension.
- Kotlin unit tests for request JSON, response parsing and exception mapping.

### Fixed
- iOS 18+ / macOS 15+ excluded-credential matches now map to `excludeCredentialsMatch` instead of `unknownError`.
- "No credentials" and "domain not associated" detection no longer depends on one exact English sentence; it scans the error's description, failure reason, debug description and underlying errors. Matching is still against English needles, so on a non-English device a no-credentials cancel may still surface as `userCancelled`.
- Android no longer crashes when a credential provider omits optional response fields (`transports`, `authenticatorData`, `publicKey`, `publicKeyAlgorithm`, `userHandle`); a missing required field yields `invalidResponse`.
- iOS/macOS report `transports: ["internal", "hybrid"]` and `null` (not `""`) for fields AuthenticationServices does not expose.
- A second `register`/`authenticate` call while one is pending fails fast with `operationNotSupported` instead of hanging the first call forever.
- Stale macOS `Messages.swift` eliminated (single generated file).
- Android maps a WebAuthn `InvalidStateError` during registration (an `excludeCredentials` entry matched) to `excludeCredentialsMatch`, the same type iOS/macOS return.

### Migration
1. **iOS/macOS user handle.** Passkeys registered on iOS/macOS with 0.0.x carry a user handle equal to the UTF-8 bytes of the `userId` string you passed. Their assertions still return the same `userHandle` as before. New registrations use the base64url-decoded bytes, matching Android. If your server compares `userHandle` to its stored `user.id`, accept both forms during the transition or re-register iOS users. iOS/macOS now decode `user.id` as base64url bytes exactly as Android does. A string that happens to be valid base64 but is not your intended handle (for example `user-123`) decodes to unintended bytes rather than failing, so base64url-encode your handle before sending it. `invalidFormat` is returned only when the string cannot be decoded at all or decodes to zero bytes.
2. **JSON defaults.** If you relied on the plugin adding `userVerification: required` or `authenticatorAttachment: platform` to server JSON, send them from the server.
3. **CocoaPods apps:** run `pod install` in `ios/` and `macos/` after upgrading.

## [0.0.7] - 2026-04-22

### Added
- **macOS platform support**: Full passkey registration and authentication on macOS 13.0+ via the native `AuthenticationServices` framework. Contributed by [@hhanh00](https://github.com/hhanh00) in [#2](https://github.com/minhtri1401/flutter_passkey_service/pull/2).
- PRF extension support on macOS 15.0+ for deterministic symmetric key (KEK) derivation.
- Large Blob extension support on macOS 14.0+ for on-authenticator blob storage.
- `preferImmediatelyAvailableCredentials` flag exposed across all platforms for prompt behavior control.

### Fixed
- Corrected macOS podspec platform declaration from `:osx, '10.14'` to `:osx, '13.0'` so the pod manifest aligns with the `@available(macOS 13.0, *)` runtime gating in the plugin Swift sources. This prevents CocoaPods from attempting to build for unsupported macOS versions.
- Replaced placeholder metadata (`http://example.com` homepage, generic author) in the macOS podspec with the repository homepage and plugin author.

## [0.0.6]

### Fixed
- Replaced hardcoded `username: "username"` in Passkey authentication and registration responses with dynamically passed usernames for registration and empty strings for authentication across iOS and Android, conforming strictly with the WebAuthn standard and correct mapping expectations.

## [0.0.5] - 2026-03-21

### Added
- **WebAuthn Large Blob Extension**: Support for storing and retrieving up to 1KB of opaque data directly on the passkey authenticator hardware across iOS 17+ and Android.
- Comprehensive JSON parsing support and unit tests for the `largeBlob` WebAuthn extension.

## [0.0.4] - 2026-03-21

### Added
- Included `hints`, `attestationFormats`, and `extensions` to WebAuthn creation underlying parameters for robust JSON mapping.
- Implemented `clientExtensionResults` support within authentication response payloads.
- **WebAuthn PRF (Key Encryption Key)** extension support across iOS 18+ and Android Credential Manager, allowing extraction of symmetric keys from deterministic PRF salts directly during authentication.
- Added `enablePrf` parameter directly to `createRegistrationOptions` for enabling PRF evaluation during passkey registrations.
- Added PRF KEK Extraction Example directly inside the `example` application's UI demonstrating symmetric key derivation.

### Changed
- Standardized and completely overhauled `README.md` to remove duplicated guides, ensuring much clearer setup instructions for both iOS and Android.
- Expanded the Dart unit test suite extensively to verify missing field defaults and string JSON edge cases natively.

### Fixed
- Migrated explicitly nullable fields (`userHandle`, `authenticatorAttachment`, `publicKey`, etc.) in `messages.dart` to fully align natively with the permissive WebAuthn standard and prevent FIDO hardware decoder issues.

## [0.0.3] - 2025-09-09

### Added
- Enhanced JSON integration support for server communication
- New helper methods for creating options from server JSON responses
- JSON serialization extension methods for debugging and logging
- Improved developer experience with comprehensive API documentation

### Enhanced
- Updated documentation with detailed JSON workflow examples
- Added production-ready integration examples
- Improved error handling documentation
- Enhanced comprehensive guide with server integration patterns

## [0.0.2] - 2024-09-07

### Added
- Initial release of Flutter Passkey Service
- Cross-platform support for iOS 16.0+ and Android API 28+
- WebAuthn compliant passkey registration and authentication
- Type-safe API generated with Pigeon for reliable Flutter-to-native communication
- Comprehensive error handling with `PasskeyException`
- Support for biometric authentication (Touch ID, Face ID, Fingerprint)
- Device PIN/passcode authentication support
- Cross-device passkey synchronization via platform providers
- Helper methods for creating registration and authentication options
- Complete API documentation with examples

### iOS Features
- Native iOS AuthenticationServices integration
- Support for Touch ID, Face ID, and device passcode
- Associated Domains capability support
- Graceful fallback for unsupported iOS versions

### Android Features
- Android Credential Manager API integration
- Biometric authentication support
- Google Play Services integration
- Digital Asset Links configuration support

### Developer Experience
- Professional README.md with comprehensive guides
- Type-safe API with full IntelliSense support
- Detailed error types and handling
- Example application demonstrating usage
- Unit and integration testing support

### Technical Implementation
- Pigeon-generated type-safe communication layer
- Shared exception handling across platforms
- Manual JSON serialization for compatibility
- Lazy initialization to prevent startup crashes
- Clean separation of concerns with utility classes

[0.0.7]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.7
[0.0.6]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.6
[0.0.5]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.5
[0.0.4]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.4
[0.0.3]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.3
[0.0.2]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.2