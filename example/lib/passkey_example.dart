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
      // Create registration options
      final options = FlutterPasskeyService.createRegistrationOptions(
        // Get this from your server
        challenge: 'your-server-generated-challenge',
        rpName: 'My App',
        rpId: 'example.com', // Your domain
        userId: 'user-123',
        username: 'user@example.com',
        displayName: 'John Doe',
      );

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
      // Create authentication options
      final request = FlutterPasskeyService.createAuthenticationOptions(
        challenge:
            'your-server-generated-challenge', // Get this from your server
        rpId: 'example.com', // Your domain
        // allowCredentials: [], // Optional: specify which credentials to allow
      );

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
}
