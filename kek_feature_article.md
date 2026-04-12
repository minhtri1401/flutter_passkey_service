# Unlock Local Encryption with Passkeys: A Guide to the KEK (PRF) Feature

Passkeys are revolutionizing the way we authenticate by providing a secure, passwordless experience. But did you know that passkeys can do more than just authenticate users with a server? With the **Passkey PRF (Pseudo-Random Function) extension**, you can securely derive symmetric **Key Encryption Keys (KEK)** directly from the passkey itself.

In this article, we will explore what the KEK feature is, why it is incredibly useful, and how you can implement it in your Flutter app using the `flutter_passkey_service` package.

---

## What is the KEK (PRF Extension) Feature?

The PRF extension allows an authenticator (like Face ID, Touch ID, or a security key) to evaluate a pseudo-random function using a secret tied specifically to the credential. Simply put, it allows you to derive a symmetric encryption key from the passkey during the authentication process. 

### Why is this useful?
Typically, if you want to encrypt local data (like an offline game save, a local profile, or a secure offline wallet), you need a password to derive an encryption key. With the PRF extension, you can **eliminate the local password** completely. 

The derived Key Encryption Key (KEK) is tied strictly to the user's passkey. This makes it perfect for:
* **Encrypting local offline data** (e.g., game saves, private diaries)
* **Secure local storage** without requiring a backend to hold encryption keys
* **Zero-knowledge architectures** where the server never sees the plaintext data or the encryption keys

---

## How to Implement KEK Derivation in Flutter

The `flutter_passkey_service` makes it incredibly simple to integrate the PRF extension. The flow consists of two main parts:
1. Registering the passkey with PRF support enabled.
2. Authenticating with a "salt" to derive the encryption key.

### Step 1: Enable PRF during Registration

When you create a new passkey, you need to tell the authenticator that you intend to use the PRF extension for this credential. You do this by setting `enablePrf: true` when generating the registration options.

```dart
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

Future<void> registerPasskeyWithPrf() async {
  // Generate options (usually done by communicating with your backend)
  final options = FlutterPasskeyService.createRegistrationOptions(
    challenge: 'your-server-generated-challenge',
    rpName: 'My Secure App',
    rpId: 'example.com', // Must match verified domain
    userId: 'user-123',
    username: 'user@example.com',
    enablePrf: true, // <-- 1. Enable PRF here
  );

  // Perform registration
  final result = await FlutterPasskeyService.register(options);
  
  // Optional: You can verify if PRF is actually supported by the authenticator
  // final prfEnabled = result.clientExtensionResults?.prf?.enabled ?? false;
  
  print('Passkey registered successfully! PRF Supported: true');
}
```

### Step 2: Authenticate and Derive the KEK

When the user comes back to the app and you need the encryption key to decrypt their local data, you prompt an authentication process. 

You must provide a **salt** (exactly 32 bytes, base64url encoded representation of an ArrayBuffer). The authenticator evaluates this salt using its internal secret to generate the deterministically derived KEK.

```dart
import 'dart:convert';
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

Future<void> deriveKEK() async {
  // 1. Prepare your 32-byte salt
  // Note: For real applications, this salt can be deterministically 
  // generated or stored alongside the encrypted data.
  final randomBytes = List<int>.generate(32, (i) => i % 256);
  final prfSaltObject = base64Url.encode(randomBytes);
  
  // 2. Add the PRF extension to the authentication request
  final request = FlutterPasskeyService.createAuthenticationOptionsFromJson({
    "challenge": "your-server-generated-challenge",
    "rpId": "example.com",
    "extensions": {
      "prf": {
        "eval": {
          "first": prfSaltObject // Pass the salt to the PRF evaluator
        }
      }
    }
  });

  // 3. Authenticate the user
  final result = await FlutterPasskeyService.authenticate(request);
  
  // 4. Extract the derived KEK
  final prfResult = result.clientExtensionResults?.prf;
  
  if (prfResult != null && prfResult.results?['first'] != null) {
     final derivedKEK = prfResult.results!['first']!;
     print('Successfully derived KEK: $derivedKEK');
     
     // 🚀 You can now use `derivedKEK` (base64url encoded) as a symmetric 
     // key for AES encryption to decrypt your local offline data!
  } else {
     print('KEK Derivation is either not supported on this passkey or failed.');
  }
}
```

---

## Best Practices and Considerations

* **Salt Management**: The 32-byte salt you pass during authentication (`eval: {"first": salt}`) is required every time you want to derive the same key. You can safely store this salt in plaintext alongside the encrypted file on the device, as the KEK can only be derived if the user successfully performs a biometric passkey authentication.
* **Why Derive at Authentication vs Registration?**: During registration, we only enable the feature (asking the authenticator if it supports PRF). The KEK is not actively stored anywhere; it is mathematically derived using your specific `salt` and a secret tied to the passkey. Thus, providing the `salt` and evaluating the PRF string must happen during authentication whenever the key is needed to unlock your vault. 
* **Fallback Mechanisms**: Not all operating systems or physical security keys support the PRF extension yet. Always check the result to ensure the key was derived, and consider implementing a fallback mechanism (like a traditional PIN/Password) for unsupported devices.
* **Cryptography**: The derived key is returned as a base64url encoded string. You will need to decode it back into bytes before passing it to symmetric cryptographic algorithms (like AES-GCM) provided by libraries such as `cryptography` or `pointycastle` in Flutter.

## Conclusion

The Passkey PRF extension is a powerful tool for developers looking to build highly secure, privacy-first, offline-capable applications. By using `flutter_passkey_service`, deriving a Key Encryption Key is as simple as flipping a boolean during registration and passing a salt during authentication. 

Encrypting user data without forcing them to remember complex passwords is now a reality. Happy coding!
