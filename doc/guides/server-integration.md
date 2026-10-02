# Server integration guide for flutter_passkey_service

Last updated: 2026-10-03 (plugin version 0.1.0)

`flutter_passkey_service` handles only the client half of WebAuthn. Your server (the relying party) must generate challenges, store public keys and verify every response. The plugin is backend-agnostic: it works with any library that speaks the W3C WebAuthn JSON format, for example SimpleWebAuthn (Node), webauthn4j (Java), py_webauthn (Python), go-webauthn (Go), web-authn (Ruby) or Corbado, Hanko, Passage and similar hosted services.

## The four-step flow

1. **Server** generates registration or authentication options as JSON (`PublicKeyCredentialCreationOptionsJSON` or `PublicKeyCredentialRequestOptionsJSON`).
2. **App** converts the JSON with `createRegistrationOptionsFromJson` / `createAuthenticationOptionsFromJson` and calls `register` / `authenticate`.
3. **App** serializes the response and posts it back to the server.
4. **Server** verifies the response with its WebAuthn library and stores the credential (registration) or issues a session (authentication).

## Registration

Server JSON the plugin accepts (fields the server omits stay null and are left to the platform):

```json
{
  "challenge": "base64url",
  "rp": { "name": "Example", "id": "example.com" },
  "user": { "id": "base64url-user-handle", "name": "user@example.com", "displayName": "Jane" },
  "pubKeyCredParams": [ { "type": "public-key", "alg": -7 }, { "type": "public-key", "alg": -257 } ],
  "timeout": 60000,
  "attestation": "none",
  "excludeCredentials": [ { "type": "public-key", "id": "base64url-credential-id", "transports": ["internal"] } ],
  "authenticatorSelection": { "residentKey": "required", "userVerification": "required", "authenticatorAttachment": "platform" },
  "hints": ["client-device"],
  "extensions": { "credProps": true, "prf": { "eval": { "first": "base64url-salt" } }, "largeBlob": { "support": "preferred" } }
}
```

```dart
final options = FlutterPasskeyService.createRegistrationOptionsFromJson(serverJson);
final result = await FlutterPasskeyService.register(options);
```

Fields on `CreatePasskeyResponseData` to send back (all strings are base64url):

| Field | Type | Notes |
|---|---|---|
| `id` | String | Credential ID. |
| `rawId` | String | Same bytes as `id`. |
| `type` | String | Always `public-key`. |
| `authenticatorAttachment` | String? | `platform` on both platforms. |
| `response.clientDataJSON` | String | Contains the challenge, origin and type. |
| `response.attestationObject` | String | CBOR attestation object. |
| `response.transports` | List<String>? | Reported by Android; may be null on iOS. |
| `response.authenticatorData` | String? | Android only. |
| `response.publicKeyAlgorithm` | int? | Android only. |
| `response.publicKey` | String? | Android only. |
| `clientExtensionResults.credProps.rk` | bool? | Android; iOS/macOS always null. |
| `clientExtensionResults.prf.enabled` | bool? | Whether PRF is available for this credential. |
| `clientExtensionResults.prf.results` | Map? | Present on iOS 18+/macOS 15+/Android when `extensions.prf.eval` was sent. |
| `clientExtensionResults.largeBlob.supported` | bool? | Whether the authenticator supports largeBlob. |

A minimal serializer:

```dart
Map<String, dynamic> registrationToJson(CreatePasskeyResponseData r) => {
  'id': r.id,
  'rawId': r.rawId,
  'type': r.type,
  'authenticatorAttachment': r.authenticatorAttachment,
  'response': {
    'clientDataJSON': r.response.clientDataJSON,
    'attestationObject': r.response.attestationObject,
    'transports': r.response.transports,
  },
  'clientExtensionResults': {
    if (r.clientExtensionResults.credProps != null)
      'credProps': {'rk': r.clientExtensionResults.credProps!.rk},
  },
};
```

## Authentication

Server JSON the plugin accepts:

```json
{
  "challenge": "base64url",
  "rpId": "example.com",
  "allowCredentials": [ { "type": "public-key", "id": "base64url-credential-id", "transports": ["internal", "hybrid"] } ],
  "timeout": 60000,
  "userVerification": "required",
  "hints": ["client-device"],
  "extensions": { "prf": { "eval": { "first": "base64url-salt" } }, "largeBlob": { "read": true } }
}
```

```dart
final options = FlutterPasskeyService.createAuthenticationOptionsFromJson(serverJson);
final result = await FlutterPasskeyService.authenticate(options);
```

Fields on `GetPasskeyAuthenticationResponseData` to send back:

| Field | Type | Notes |
|---|---|---|
| `id`, `rawId`, `type`, `authenticatorAttachment` | | As for registration. |
| `response.clientDataJSON` | String | base64url. |
| `response.authenticatorData` | String | base64url. |
| `response.signature` | String | base64url. The server verifies this against the stored public key. |
| `response.userHandle` | String? | base64url of the user handle bytes supplied at registration. |
| `clientExtensionResults.prf.results` | Map? | Derived PRF outputs keyed `first` / `second`. |
| `clientExtensionResults.largeBlob.blob` | Uint8List? | Blob contents when `read` was requested. |
| `clientExtensionResults.largeBlob.written` | bool? | Whether a `write` succeeded. |

## Encoding rules

- **Everything binary is base64url without padding**, matching the WebAuthn JSON serialization used by browsers. Do not use standard base64.
- **`user.id` is base64url of the user handle bytes.** Since 0.1.0 iOS and macOS decode it exactly as Android does. A raw string such as `user-123` happens to be valid base64 and decodes to unintended bytes, so always encode on the server: `base64url(utf8("user-123"))` is `dXNlci0xMjM`.
- **`userHandle` in the assertion is the same bytes, base64url-encoded.** Passkeys registered on iOS/macOS with plugin versions before 0.1.0 carry the UTF-8 bytes of the raw string instead; accept both forms during migration or re-register those users.
- **`challenge`** must be at least 16 random bytes generated server-side per request and must be consumed exactly once.
- **`rpId`** must equal the domain in your `apple-app-site-association` and `assetlinks.json` files. Subdomains of the registrable domain are allowed by WebAuthn, but the association files must live on the `rpId` host.
- **Origin.** On iOS/macOS the `clientDataJSON.origin` is `https://<rpId>`. On Android it is `android:apk-key-hash:<base64url-sha256-of-signing-cert>`. Configure your server's expected origins accordingly; most libraries accept a list.

## Defaults the plugin does and does not add

- `createRegistrationOptions` and `createAuthenticationOptions` (the named-parameter builders) fill in ES256 and RS256 `pubKeyCredParams`, a 60 000 ms timeout, `attestation: 'none'`, `residentKey: 'preferred'`, `userVerification: 'required'`, `authenticatorAttachment: 'platform'` and `credProps: true`.
- `createRegistrationOptionsFromJson` and `createAuthenticationOptionsFromJson` add nothing. Fields the server omits stay null.
- `allowedCredentialIds` on `createAuthenticationOptions` is a shortcut that expands each ID to a `public-key` descriptor with `internal` and `hybrid` transports.

## Fields with no platform API

iOS and macOS ignore `pubKeyCredParams`, `timeout`, `hints`, `attestationFormats`, `residentKey`, `requireResidentKey` and the `appid` extension because `AuthenticationServices` exposes no setting for them. Android forwards every field to the provider as JSON.
