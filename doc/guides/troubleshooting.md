# Troubleshooting flutter_passkey_service

Last updated: 2026-10-03 (plugin version 0.1.0)

## `domainNotAssociated` on iOS or macOS

Apple could not prove the app belongs to `rpId`. Check, in order:

1. The target has the **Associated Domains** capability with the entry `webcredentials:yourdomain.com` (no scheme, no path). On macOS the entitlement is `com.apple.developer.associated-domains` in both `DebugProfile.entitlements` and `Release.entitlements`.
2. `https://yourdomain.com/.well-known/apple-app-site-association` is served with status 200, `Content-Type: application/json`, no redirects, and no `.json` extension on the file name.
3. The file lists the app as `TEAMID.bundle.identifier` under `webcredentials.apps`.
4. `rpId` passed to the plugin equals `yourdomain.com` exactly.
5. Apple caches the association through its CDN. After changing the file, reinstall the app, or during development append `?mode=developer` to the entitlement (`webcredentials:yourdomain.com?mode=developer`) and enable Developer Mode on the device so the file is fetched directly.
6. The device needs network access the first time the association is validated.

## `notAllowed`, `securityViolation` or `networkError` on Android

Credential Manager could not validate Digital Asset Links.

1. `https://yourdomain.com/.well-known/assetlinks.json` returns 200 with `Content-Type: application/json`.
2. The entry uses `"relation": ["delegate_permission/common.get_login_creds"]` (and `common.handle_all_urls` if you also use app links), the exact `package_name`, and the SHA-256 fingerprint of the certificate that signed the installed build. Debug builds use the debug keystore, so list both fingerprints during development.
3. `rpId` equals the host that serves `assetlinks.json`.
4. Google Play services is present and up to date; passkeys on Android use the Play services credential provider. Emulators need a Google Play image and a signed-in Google account.
5. The call is made while an Activity is in the foreground. The plugin implements `ActivityAware`; calling before the first frame or from a background isolate fails with `notAllowed`.

## `noCredentialsAvailable` right after a successful registration

- On iOS, the passkey lives in iCloud Keychain. If iCloud Keychain is off the passkey is local only and will not appear on other devices.
- On Android, the passkey lives in Google Password Manager for the signed-in account. A different account on the same device will not see it.
- `allowCredentials` narrows the search. If the server sends IDs the device does not have, the result is `noCredentialsAvailable` even though other passkeys exist for the `rpId`. Send an empty list for discoverable-credential sign-in.
- `preferImmediatelyAvailableCredentials: true` on iOS suppresses the cross-device (QR) option, so a passkey that lives only on another device reports `noCredentialsAvailable`.

## `excludeCredentialsMatch`

The server sent `excludeCredentials` containing a credential that is already on the device. This is the WebAuthn mechanism for preventing duplicate passkeys per account. Treat it as "already registered" and go to sign-in.

## `invalidFormat` from `user.id`

Since 0.1.0 iOS and macOS decode `user.id` as base64url bytes. Encode the user handle on the server (for example `dXNlci0xMjM` for `user-123`). The error is raised only when the string cannot be decoded at all or decodes to zero bytes.

## PRF results are null

- PRF needs iOS 18 / macOS 15 or a modern Android provider. On older OS versions `clientExtensionResults.prf` is null even when `enablePrf: true` was sent.
- Check `clientExtensionResults.prf.enabled` after registration; if it is false or null the credential cannot evaluate PRF later.
- At authentication, pass the salt via `prfEval: {'first': base64urlSalt}` (named-parameter builder) or `extensions.prf.eval.first` (server JSON). Results are keyed by the same name.
- The derived value is 32 bytes, base64url-encoded. Use it as a key-encryption key, never store it.

## largeBlob results are null

- largeBlob needs iOS 17 / macOS 14 or an Android provider that supports it. Registration must have sent `enableLargeBlob: true` (or `extensions.largeBlob.support`).
- `largeBlobRead` and `largeBlobWrite` are mutually exclusive per authentication call.
- Keep the blob under 1 KB. Larger writes fail at the provider.

## Simulators and emulators

- iOS simulator: recent simulators can create and use platform passkeys when Face ID is enrolled (Features > Face ID > Enrolled), but iCloud Keychain sync and cross-device sign-in do not work. Associated domains still need a reachable, valid AASA file. Test on a physical device before release.
- Android emulator: requires a Google Play system image, a signed-in Google account and a screen lock. Emulators without Play services fail with `notAllowed` or `unknownError`.
- macOS: the checked-in example runner builds without entitlements and cannot complete a real flow. Add the associated-domains entitlement and a signing team.

## The app upgraded from 0.0.x and sign-in breaks on the server

Passkeys registered on iOS/macOS with 0.0.x return `userHandle` equal to the UTF-8 bytes of the raw `userId` string. New registrations return the decoded bytes. Accept both on the server during the transition. See the Migration section of the README.

## Still stuck

Open an issue at https://github.com/minhtri1401/flutter_passkey_service/issues with the `errorType`, `message`, `details`, platform, OS version and plugin version.
