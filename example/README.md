# flutter_passkey_service_example

Demonstrates how to use the flutter_passkey_service plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## macOS

Real passkey flows on macOS need the associated-domains entitlement (`com.apple.developer.associated-domains` with `webcredentials:yourdomain.com`) in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`, plus a signing team. The checked-in runner builds without them but cannot complete registration or authentication.
