# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-09-07

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

[0.0.1]: https://github.com/your-username/flutter_passkey_service/releases/tag/v0.0.1