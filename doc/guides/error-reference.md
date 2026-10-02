# PasskeyErrorType reference for flutter_passkey_service

Last updated: 2026-10-03 (plugin version 0.1.0)

Every failure in `flutter_passkey_service` is thrown as a `PasskeyException` with three fields: `errorType` (a `PasskeyErrorType` enum value), `message` (short, English, plugin-authored) and `details` (the underlying platform error text). Catch it like this:

```dart
try {
  final response = await FlutterPasskeyService.authenticate(options);
} on PasskeyException catch (e) {
  switch (e.errorType) {
    case PasskeyErrorType.userCancelled:
      // expected: user dismissed the sheet
      break;
    case PasskeyErrorType.noCredentialsAvailable:
      // offer registration or another sign-in method
      break;
    case PasskeyErrorType.domainNotAssociated:
      // configuration bug: fix AASA / assetlinks.json
      break;
    default:
      log('${e.errorType}: ${e.message} (${e.details})');
  }
}
```

## Errors you should handle in every app

| `errorType` | Platforms | When it happens | Recommended handling |
|---|---|---|---|
| `userCancelled` | iOS, macOS, Android | The user dismissed the passkey sheet, pressed cancel, or the Android flow timed out while waiting for the user. | Silent return to the previous screen. Not an error to show. |
| `noCredentialsAvailable` | iOS, macOS, Android | Authentication was requested but no passkey exists for this `rpId` on the device or in the synced keychain. On iOS this is also returned when `preferImmediatelyAvailableCredentials` is true and no local passkey exists. | Offer registration or a fallback sign-in method. |
| `domainNotAssociated` | iOS, macOS | The app is not associated with `rpId`. Apple could not fetch or validate `/.well-known/apple-app-site-association`, or the Associated Domains capability is missing. | Configuration bug. See the troubleshooting guide. |
| `excludeCredentialsMatch` | iOS 16+, macOS 13.5+, Android | Registration was called with `excludeCredentials` that matches a passkey already on the device. | Tell the user a passkey already exists and switch to authentication. |
| `userTimeout` | Android | The Credential Manager flow raised a WebAuthn `TimeoutError`. | Allow the user to retry. |
| `userOptedOut` | Android | The user opted out of passkeys in the provider (`OptOutError`). | Offer another sign-in method. |

## Full list

| `errorType` | Category | Platforms | Source |
|---|---|---|---|
| `invalidParameters` | Input validation | Android | `IllegalArgumentException` while building the request. |
| `missingRequiredField` | Input validation | reserved | Not raised by 0.1.0. |
| `invalidFormat` | Input validation | iOS, macOS, Android | Android: WebAuthn `DataError`, `InvalidCharacterError` or `SyntaxError`. iOS/macOS: `user.id` could not be base64url-decoded or decoded to zero bytes, or `prf.eval.first` is missing or not base64url. |
| `decodingChallenge` | Input validation | iOS, macOS | The `challenge` string is not valid base64url. |
| `userCancelled` | User interaction | iOS, macOS, Android | See table above. |
| `userTimeout` | User interaction | Android | WebAuthn `TimeoutError`. |
| `userOptedOut` | User interaction | Android | WebAuthn `OptOutError`. |
| `insufficientPermissions` | Permission | Android | `SecurityException` from Credential Manager. |
| `securityViolation` | Permission | Android | WebAuthn `SecurityError`, typically an `rpId` that does not match `assetlinks.json`. |
| `notAllowed` | Permission | Android | WebAuthn `NotAllowedError`. Common causes: `rpId` mismatch, missing user verification, request made without a foreground Activity. |
| `domainNotAssociated` | Permission | iOS, macOS | See table above. |
| `noCredentialsAvailable` | Credential | iOS, macOS, Android | See table above. |
| `credentialNotFound` | Credential | Android | WebAuthn `NotFoundError`. |
| `invalidCredential` | Credential | reserved | Not raised by 0.1.0. |
| `credentialAlreadyExists` | Credential | reserved | Not raised by 0.1.0; excluded-credential matches use `excludeCredentialsMatch`. |
| `invalidResponse` | Credential | iOS, macOS, Android | iOS/macOS: `ASAuthorizationError.invalidResponse`. Android: the provider's response JSON lacks a required field; `details` names it. |
| `notHandled` | Credential | iOS, macOS | `ASAuthorizationError.notHandled` or `.notInteractive` (the request could not be shown). |
| `failed` | Credential | iOS, macOS | `ASAuthorizationError.failed` with no recognized domain-association text. |
| `platformNotSupported` | Platform | reserved | Not raised by 0.1.0. The deployment targets (iOS 16, macOS 13) stop the app installing on older OS versions, and extensions above the OS floor (largeBlob, PRF) are silently ignored rather than rejected. |
| `operationNotSupported` | Platform | iOS, macOS, Android | iOS/macOS: a `register` or `authenticate` call is still in progress; wait for it to finish. Android: WebAuthn `NotSupportedError`. |
| `systemError` | Platform | iOS, macOS, Android | iOS/macOS: no key window was available to present the passkey sheet (call after the first frame is rendered). Android: WebAuthn `QuotaExceededError`. |
| `networkError` | Platform | Android | WebAuthn `NetworkError`. Credential Manager may need network access to validate `assetlinks.json`. |
| `domError` | WebAuthn | Android | Any other WebAuthn DOM error (`ConstraintError`, `EncodingError`, `InvalidStateError` during authentication, `OperationError`, and so on). Read `details` for the original message. |
| `webauthnError` | WebAuthn | reserved | Not raised by 0.1.0. |
| `attestationError` | WebAuthn | reserved | Not raised by 0.1.0. |
| `excludeCredentialsMatch` | WebAuthn | iOS, macOS, Android | Android `InvalidStateError` during registration; iOS 18+/macOS 15+ `ASAuthorizationError.matchedExcludedCredential`; iOS 16-17 `WKErrorDomain` code 8. |
| `unexpectedAuthorizationResponse` | iOS specific | iOS, macOS | The system returned a credential type the plugin did not request. |
| `wkErrorDomain` | iOS specific | iOS, macOS | An `NSError` outside `ASAuthorizationError` that the plugin does not classify. `details` holds the domain and code. |
| `unknownError` | Unknown | iOS, macOS, Android | `ASAuthorizationError.unknown`, Android `CreateCredentialUnknownException`, or WebAuthn `UnknownError`. |
| `unexpectedError` | Unknown | Android | Any exception not covered above. `details` holds the original message. |

## Platform notes

- iOS and macOS detect "no credentials" and "not associated with domain" by scanning the English text of the system error chain. On a device set to another language, a no-credentials cancel can surface as `userCancelled`.
- Android `CreatePublicKeyCredentialDomException` with the text "Flow has timed out" is mapped to `userCancelled`, not `userTimeout`, because the Credential Manager sheet closes without user action.
- Android reports `credProps.rk` as `false` when the provider omits it; this is not an error.
