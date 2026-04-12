# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.0.4]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.4
[0.0.3]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.3
[0.0.2]: https://github.com/minhtri1401/flutter_passkey_service/releases/tag/v0.0.2