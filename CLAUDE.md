# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Flutter plugin providing WebAuthn/passkey registration and authentication across iOS (16.0+), macOS (13.0+), and Android (API 23+). Supports PRF extensions for key derivation (iOS 18+, macOS 15.0+, modern Android).

## Commands

This project uses [FVM](https://fvm.app/) for Flutter version management. Always prefix `flutter` and `dart` commands with `fvm`.

```bash
fvm flutter pub get                    # Install dependencies
fvm flutter test                       # Run all Dart unit tests
fvm flutter test test/flutter_passkey_service_test.dart  # Run single test file
fvm flutter analyze                    # Lint (uses flutter_lints via analysis_options.yaml)
fvm dart format lib test               # Format code
fvm dart run pigeon --input lib/pigeons/messages.dart  # Regenerate platform channel code (Dart, Kotlin, Swift)
cd example/android && ./gradlew :flutter_passkey_service:testDebugUnitTest  # Kotlin unit tests
```

Example app: `cd example && fvm flutter run`

## Architecture

**Pigeon-based platform channels** — a single source file (`lib/pigeons/messages.dart`) defines all data models and the `PasskeyHostApi` interface. Running Pigeon generates:
- `lib/pigeons/messages.g.dart` (Dart)
- `android/.../Messages.kt` (Kotlin)
- `darwin/flutter_passkey_service/Sources/flutter_passkey_service/Messages.swift` (Swift, shared by iOS and macOS)

Never edit generated files directly. Edit `messages.dart` and regenerate.

**Dart layer** (`lib/flutter_passkey_service.dart`): Static API surface — `register()`, `authenticate()`, plus helper methods `createRegistrationOptions()` and `createAuthenticationOptions()`. Extension methods provide JSON serialization.

**Android** (`android/src/main/kotlin/.../`): Uses `androidx.credentials.CredentialManager` with Kotlin coroutines. Flow: `FlutterPasskeyServicePlugin` → `PasskeyHostApiImpl` → `PasskeyAuthServiceImpl`. Exception translation in `PasskeyExceptionHandler`.

**Darwin (iOS + macOS)** (`darwin/flutter_passkey_service/Sources/flutter_passkey_service/`): one Swift package used by both platforms (`sharedDarwinSource: true`), built via Swift Package Manager (`Package.swift`) or CocoaPods (`darwin/flutter_passkey_service.podspec`). Uses `AuthenticationServices`. Flow: `FlutterPasskeyServicePlugin` → `PasskeyHostApiImpl` → `PasskeyAuthServiceImpl` → `RegisterController`/`AuthenticateController`. Error mapping in `PasskeyErrorMapping.swift`. Platform differences are limited to `#if os(iOS)`/`os(macOS)` blocks (Flutter vs FlutterMacOS import, messenger accessor, key-window lookup). Availability floors: base iOS 16/macOS 13; `excludedCredentials` iOS 17.4/macOS 13.5; largeBlob iOS 17/macOS 14; PRF iOS 18/macOS 15.

**Error handling**: All platform exceptions map to `PasskeyException` with typed `PasskeyErrorType` enum (~20 cases), providing unified error handling across platforms.

## Key Patterns

- Request/response models defined in Pigeon, not hand-written per platform
- JSON interchange format matches WebAuthn server expectations — manual JSON parsing in native code for flexibility
- Platform services use protocol/interface pattern for testability (`PasskeyAuthService` protocol/interface)
- Android requires Activity context — plugin implements `ActivityAware`
- Android JSON building/parsing lives in `PasskeyJson` (pure JVM, unit-tested); `PasskeyAuthServiceImpl` only talks to CredentialManager

## Domain Verification

Passkeys require associated domain verification:
- **iOS/macOS**: Apple App Site Association file at `https://yourdomain.com/.well-known/apple-app-site-association`
- **Android**: Digital Asset Links at `https://yourdomain.com/.well-known/assetlinks.json`

## Dependencies

- **Dart**: `plugin_platform_interface`, `flutter` SDK
- **Dev**: `pigeon` (^26.0.1) for code generation, `flutter_lints`
- **Android**: `androidx.credentials:credentials:1.6.0`, `credentials-play-services-auth:1.6.0`, `kotlinx-serialization-json`
- **Darwin**: Native `AuthenticationServices` framework, no third-party dependencies

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues for minhtri1401/flutter_passkey_service via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the repo root, created lazily by `/domain-modeling`. See `docs/agents/domain.md`.
