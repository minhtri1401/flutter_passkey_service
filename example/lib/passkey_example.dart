// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_passkey_service/flutter_passkey_service.dart';
import 'package:flutter_passkey_service/pigeons/messages.g.dart';

class PasskeyExample extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _PasskeyExampleState createState() => _PasskeyExampleState();
}

class _PasskeyExampleState extends State<PasskeyExample> {
  String _status = 'Ready';
  bool _isLoading = false;

  /// Example: Register a new passkey
  Future<void> _registerPasskey() async {
    setState(() {
      _isLoading = true;
      _status = 'Registering passkey...';
    });

    try {
      // Method 1: Traditional approach
      final options = FlutterPasskeyService.createRegistrationOptions(
        // Get this from your server
        challenge: 'your-server-generated-challenge',
        rpName: 'My App',
        rpId: 'example.com', // Your domain
        userId: 'user-123',
        username: 'user@example.com',
        displayName: 'John Doe',
      );

      // Method 2: From JSON (simulating server response)
      // Uncomment to test JSON parsing:
      // final serverJson = getExampleRegistrationJson();
      // final options = FlutterPasskeyService.createRegistrationOptionsFromJson(serverJson);

      // Debug: Convert options to JSON for logging
      print('Registration options: ${options.toJsonString()}');

      // Register the passkey
      final result = await FlutterPasskeyService.register(options);

      setState(() {
        _status = 'Passkey registered successfully!\nID: ${result.id}';
        _isLoading = false;
      });
    } catch (e) {
      _handleError(e);
    }
  }

  /// Example: Authenticate with existing passkey
  Future<void> _authenticateWithPasskey() async {
    setState(() {
      _isLoading = true;
      _status = 'Authenticating with passkey...';
    });

    try {
      // Method 1: Traditional approach
      final request = FlutterPasskeyService.createAuthenticationOptions(
        challenge:
            'your-server-generated-challenge', // Get this from your server
        rpId: 'example.com', // Your domain
        // allowedCredentialIds: ['cred-id-1'], // Optional: restrict to specific credentials
      );

      // Method 2: From JSON (simulating server response)
      // Uncomment to test JSON parsing:
      // final serverJson = getExampleAuthenticationJson();
      // final request = FlutterPasskeyService.createAuthenticationOptionsFromJson(serverJson);

      // Debug: Convert request to JSON for logging
      print('Authentication request: ${request.toJsonString()}');

      // Authenticate with passkey
      final result = await FlutterPasskeyService.authenticate(request);

      setState(() {
        _status =
            'Authentication successful!\nSignature: ${result.response.signature.substring(0, 20)}...';
        _isLoading = false;
      });
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    setState(() {
      _isLoading = false;
    });

    String errorMessage = 'Unknown error occurred';

    if (error is PasskeyException) {
      // Handle structured passkey errors
      switch (error.errorType) {
        case PasskeyErrorType.userCancelled:
          errorMessage = 'User cancelled the operation';
          break;
        case PasskeyErrorType.noCredentialsAvailable:
          errorMessage = 'No passkeys available for authentication';
          break;
        case PasskeyErrorType.insufficientPermissions:
          errorMessage = 'Insufficient permissions for passkey operation';
          break;
        case PasskeyErrorType.invalidParameters:
          errorMessage = 'Invalid parameters: ${error.message}';
          break;
        default:
          errorMessage = "${error.message} (${error.details})";
      }
    } else {
      errorMessage = error.toString();
    }

    setState(() {
      _status = 'Error: $errorMessage';
    });

    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Passkey Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Passkey Example')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Passkey Demo',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _registerPasskey,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.person_add),
              label: Text('Register New Passkey'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _authenticateWithPasskey,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.login),
              label: Text('Authenticate with Passkey'),
            ),
            SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Replace challenge with real server-generated values\n'
                      '• Update rpId to match your domain\n'
                      '• Send results to your server for verification\n'
                      '• Handle different error types appropriately',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example JSON data that could come from your server
  Map<String, dynamic> getExampleRegistrationJson() {
    return {
      "challenge": "example-challenge-from-server",
      "rp": {"name": "My App", "id": "example.com"},
      "user": {
        "id": "user-123",
        "name": "user@example.com",
        "displayName": "John Doe",
      },
      "pubKeyCredParams": [
        {"alg": -7, "type": "public-key"},
        {"alg": -257, "type": "public-key"},
      ],
      "timeout": 60000,
      "attestation": "none",
      "authenticatorSelection": {
        "residentKey": "preferred",
        "userVerification": "required",
        "requireResidentKey": false,
        "authenticatorAttachment": "platform",
      },
      "extensions": {"credProps": true},
    };
  }

  /// Example authentication JSON data
  Map<String, dynamic> getExampleAuthenticationJson() {
    return {
      "challenge": "auth-challenge-from-server",
      "rpId": "example.com",
      "allowCredentials": [
        {
          "id": "example-credential-id",
          "type": "public-key",
          "transports": ["internal", "hybrid"],
        },
      ],
      "timeout": 60000,
      "userVerification": "required",
    };
  }
}
