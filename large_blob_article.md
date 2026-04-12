# Beyond Authentication: Storing Secure Data with Passkey Large Blob

![Large Blob Passkey Vault](assets/large_blob_banner.png)

What if your passkey was more than just a key? What if it was also a tiny, cryptographically secure "vault" that travels with you? 

The **Large Blob extension** in WebAuthn allows you to store and retrieve small amounts of arbitrary data (up to 1024 bytes) directly on the passkey hardware. This data is protected by the same biometric security as the passkey itself and is synchronizable across devices through services like iCloud Keychain or Google Password Manager.

In this guide, we'll show you how to leverage the Large Blob feature in your Flutter apps using `flutter_passkey_service`.

---

## What is the Large Blob Extension?

Most WebAuthn extensions are designed for authentication metadata. **Large Blob** is unique because it provides **data storage**. 

### Key Use Cases:
* **Portable Settings**: Store a user's encryption salt, theme preference, or a small recovery token that stays with the passkey even if they delete the app.
* **Offline Access**: Store a small offline-only JWT or a local "permission bit" that can be verified without a network connection.
* **Secondary Secrets**: Save a small cryptographic seed that can be used to re-derive other local keys.

### Limitations:
* **Size**: Most authenticators are capped at **1KB (1024 bytes)**.
* **Hardware Support**: While growing, not all authenticators (especially older security keys) support Large Blob storage yet.

---

## Implementing Large Blob in Flutter

Using `flutter_passkey_service`, Large Blob management is integrated directly into the standard registration and authentication flows.

### 1. Enable Support during Registration

To use Large Blob, you must first signal that you want to support it when the passkey is being created.

```dart
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

Future<void> registerWithLargeBlob() async {
  final options = FlutterPasskeyService.createRegistrationOptions(
    challenge: 'your-server-generated-challenge',
    rpName: 'My Secure App',
    rpId: 'example.com',
    userId: 'user-123',
    username: 'user@example.com',
    enableLargeBlob: true, // <-- Enable support here
  );

  final response = await FlutterPasskeyService.register(options);
  
  // Verify if the authenticator actually accepted the extension
  final supported = response.clientExtensionResults?.largeBlob?.supported ?? false;
  print('Passkey Created. Large Blob Supported: $supported');
}
```

### 2. Writing Data during Authentication

Writing to the Large Blob happens during an authentication attempt. You provide the bytes you want to save, and once the user verifies via Face ID/Touch ID, the data is committed to the authenticator.

```dart
import 'dart:typed_data';
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

Future<void> saveToPasskey() async {
  final dataToSave = Uint8List.fromList('My Secret Data'.codeUnits);

  final request = FlutterPasskeyService.createAuthenticationOptions(
    challenge: 'your-server-generated-challenge',
    rpId: 'example.com',
    largeBlobWrite: dataToSave, // <-- Pass the bytes to write here
  );

  // When the user authenticates, the data is written
  await FlutterPasskeyService.authenticate(request);
  print('Data saved successfully to the passkey!');
}
```

### 3. Reading Data during Authentication

Retrieving the data is just as simple. During authentication, set `largeBlobRead: true`, and the authenticator will return the stored bytes upon successful biometric verification.

```dart
Future<void> readFromPasskey() async {
  final request = FlutterPasskeyService.createAuthenticationOptions(
    challenge: 'your-server-generated-challenge',
    rpId: 'example.com',
    largeBlobRead: true, // <-- Set read to true
  );

  final result = await FlutterPasskeyService.authenticate(request);
  
  // Extract the blob from the results
  final storedBlob = result.clientExtensionResults?.largeBlob?.blob;
  
  if (storedBlob != null) {
    final message = String.fromCharCodes(storedBlob);
    print('Recovered Data: $message');
  } else {
    print('No data found in the Large Blob.');
  }
}
```

---

## Best Practices

1. **Check for Support**: Since Large Blob is a hardware-dependent extension, always check `response.clientExtensionResults?.largeBlob?.supported` after registration. If it returns false, you should have a fallback storage mechanism (like Secure Storage or your backend).
2.  **Encryption**: While the Large Blob is protected by biometrics, it is still "just bytes" on the authenticator. If you are storing highly sensitive information, consider encrypting the data *before* writing it to the Large Blob (using a key derived via the **PRF extension**!).
3.  **Size Management**: Keep your payloads lean. Stay well under the 1024-byte limit to ensure compatibility across as many different authenticators as possible.

## Conclusion

The Large Blob extension transforms passkeys from simple login tools into secure, portable data carriers. Whether you're storing user preferences or cryptographic salts, `flutter_passkey_service` makes it easy to add this advanced WebAuthn capability to your Flutter application.

Happy building!
