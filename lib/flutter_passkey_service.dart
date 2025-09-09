import 'dart:convert';
import 'package:flutter/services.dart';
import 'pigeons/messages.g.dart';

/// Main API class for Flutter Passkey Service
class FlutterPasskeyService {
  /// Registers a new passkey for the user
  ///
  /// [options] - Registration options containing user info, RP info, etc.
  /// Returns [CreatePasskeyResponseData] with the created credential information
  ///
  /// Throws [PasskeyException] if registration fails
  static Future<CreatePasskeyResponseData> register(
    RegisterGenerateOptionData options,
  ) async {
    try {
      final hostApi = PasskeyHostApi();
      return await hostApi.register(options);
    } catch (e) {
      if (e is PlatformException && e.details is PasskeyException) {
        throw e.details as PasskeyException;
      }
      rethrow;
    }
  }

  /// Authenticates the user with an existing passkey
  ///
  /// [request] - Authentication request containing challenge, RP ID, etc.
  /// Returns [GetPasskeyAuthenticationResponseData] with authentication result
  ///
  /// Throws [PasskeyException] if authentication fails
  static Future<GetPasskeyAuthenticationResponseData> authenticate(
    AuthGenerateOptionResponseData request,
  ) async {
    try {
      final hostApi = PasskeyHostApi();
      return await hostApi.authenticate(request);
    } catch (e) {
      if (e is PlatformException && e.details is PasskeyException) {
        throw e.details as PasskeyException;
      }
      rethrow;
    }
  }

  /// Helper method to create registration options
  static RegisterGenerateOptionData createRegistrationOptions({
    required String challenge,
    required String rpName,
    required String rpId,
    required String userId,
    required String username,
    String displayName = '',
    int timeout = 60000,
    String attestation = 'none',
    List<RegisterGenerateOptionExcludeCredential> excludeCredentials = const [],
    String authenticatorAttachment = 'platform',
  }) {
    return RegisterGenerateOptionData(
      challenge: challenge,
      rp: RegisterGenerateOptionRp(name: rpName, id: rpId),
      user: RegisterGenerateOptionUser(
        id: userId,
        name: username,
        displayName: displayName.isEmpty ? username : displayName,
      ),
      pubKeyCredParams: [
        RegisterGenerateOptionPublicKeyParams(
          alg: -7,
          type: 'public-key',
        ), // ES256
        RegisterGenerateOptionPublicKeyParams(
          alg: -257,
          type: 'public-key',
        ), // RS256
      ],
      timeout: timeout,
      attestation: attestation,
      excludeCredentials: excludeCredentials,
      authenticatorSelection: RegisterGenerateOptionAuthenticatorSelection(
        residentKey: 'preferred',
        userVerification: 'required',
        requireResidentKey: false,
        authenticatorAttachment: authenticatorAttachment,
      ),
      extensions: RegisterGenerateOptionExtension(credProps: true),
    );
  }

  /// Helper method to create authentication options
  static AuthGenerateOptionResponseData createAuthenticationOptions({
    required String challenge,
    required String rpId,
    List<AuthGenerateOptionAllowCredential> allowCredentials = const [],
    List<String>? allowedCredentialIds,
    int timeout = 60000,
    String userVerification = 'required',
  }) {
    // Convert allowedCredentialIds to allowCredentials if provided
    final credentials =
        allowedCredentialIds
            ?.map(
              (id) => AuthGenerateOptionAllowCredential(
                id: id,
                type: 'public-key',
                transports: ['internal', 'hybrid'],
              ),
            )
            .toList() ??
        allowCredentials;

    return AuthGenerateOptionResponseData(
      rpId: rpId,
      challenge: challenge,
      allowCredentials: credentials,
      timeout: timeout,
      userVerification: userVerification,
    );
  }

  /// Creates [RegisterGenerateOptionData] from JSON
  ///
  /// This is useful when receiving registration options from your server.
  /// The JSON should match the WebAuthn PublicKeyCredentialCreationOptions format.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   "challenge": "base64url-challenge",
  ///   "rp": {"name": "My App", "id": "example.com"},
  ///   "user": {"id": "user-123", "name": "user@example.com", "displayName": "John Doe"},
  ///   "pubKeyCredParams": [{"alg": -7, "type": "public-key"}],
  ///   "timeout": 60000,
  ///   "attestation": "none"
  /// };
  /// final options = FlutterPasskeyService.createRegistrationOptionsFromJson(json);
  /// ```
  static RegisterGenerateOptionData createRegistrationOptionsFromJson(
    Map<String, dynamic> json,
  ) {
    return RegisterGenerateOptionData(
      challenge: json['challenge'] as String,
      rp: RegisterGenerateOptionRp(
        name: json['rp']['name'] as String,
        id: json['rp']['id'] as String,
      ),
      user: RegisterGenerateOptionUser(
        id: json['user']['id'] as String,
        name: json['user']['name'] as String,
        displayName: json['user']['displayName'] as String? ?? '',
      ),
      pubKeyCredParams:
          (json['pubKeyCredParams'] as List<dynamic>?)
              ?.map(
                (param) => RegisterGenerateOptionPublicKeyParams(
                  alg: param['alg'] as int,
                  type: param['type'] as String,
                ),
              )
              .toList() ??
          [
            RegisterGenerateOptionPublicKeyParams(
              alg: -7,
              type: 'public-key',
            ), // ES256
            RegisterGenerateOptionPublicKeyParams(
              alg: -257,
              type: 'public-key',
            ), // RS256
          ],
      timeout: json['timeout'] as int? ?? 60000,
      attestation: json['attestation'] as String? ?? 'none',
      excludeCredentials:
          (json['excludeCredentials'] as List<dynamic>?)
              ?.map(
                (cred) => RegisterGenerateOptionExcludeCredential(
                  id: cred['id'] as String,
                  type: cred['type'] as String,
                  transports:
                      (cred['transports'] as List<dynamic>?)?.cast<String>() ??
                      ['internal'],
                ),
              )
              .toList() ??
          [],
      authenticatorSelection: _parseAuthenticatorSelection(
        json['authenticatorSelection'] as Map<String, dynamic>?,
      ),
      extensions: RegisterGenerateOptionExtension(
        credProps: json['extensions']?['credProps'] as bool? ?? true,
      ),
    );
  }

  /// Creates [AuthGenerateOptionResponseData] from JSON
  ///
  /// This is useful when receiving authentication options from your server.
  /// The JSON should match the WebAuthn PublicKeyCredentialRequestOptions format.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   "challenge": "base64url-challenge",
  ///   "rpId": "example.com",
  ///   "allowCredentials": [
  ///     {"id": "credential-id", "type": "public-key", "transports": ["internal"]}
  ///   ],
  ///   "timeout": 60000,
  ///   "userVerification": "required"
  /// };
  /// final options = FlutterPasskeyService.createAuthenticationOptionsFromJson(json);
  /// ```
  static AuthGenerateOptionResponseData createAuthenticationOptionsFromJson(
    Map<String, dynamic> json,
  ) {
    return AuthGenerateOptionResponseData(
      rpId: json['rpId'] as String,
      challenge: json['challenge'] as String,
      allowCredentials:
          (json['allowCredentials'] as List<dynamic>?)
              ?.map(
                (cred) => AuthGenerateOptionAllowCredential(
                  id: cred['id'] as String,
                  type: cred['type'] as String,
                  transports:
                      (cred['transports'] as List<dynamic>?)?.cast<String>() ??
                      ['internal', 'hybrid'],
                ),
              )
              .toList() ??
          [],
      timeout: json['timeout'] as int? ?? 60000,
      userVerification: json['userVerification'] as String? ?? 'required',
    );
  }

  /// Creates [RegisterGenerateOptionData] from JSON string
  ///
  /// Convenience method that parses JSON string and calls [createRegistrationOptionsFromJson]
  static RegisterGenerateOptionData createRegistrationOptionsFromJsonString(
    String jsonString,
  ) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return createRegistrationOptionsFromJson(json);
  }

  /// Creates [AuthGenerateOptionResponseData] from JSON string
  ///
  /// Convenience method that parses JSON string and calls [createAuthenticationOptionsFromJson]
  static AuthGenerateOptionResponseData
  createAuthenticationOptionsFromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return createAuthenticationOptionsFromJson(json);
  }

  /// Helper method to parse authenticator selection from JSON
  static RegisterGenerateOptionAuthenticatorSelection
  _parseAuthenticatorSelection(Map<String, dynamic>? json) {
    if (json == null) {
      return RegisterGenerateOptionAuthenticatorSelection(
        residentKey: 'preferred',
        userVerification: 'required',
        requireResidentKey: false,
        authenticatorAttachment: 'platform',
      );
    }

    return RegisterGenerateOptionAuthenticatorSelection(
      residentKey: json['residentKey'] as String? ?? 'preferred',
      userVerification: json['userVerification'] as String? ?? 'required',
      requireResidentKey: json['requireResidentKey'] as bool? ?? false,
      authenticatorAttachment:
          json['authenticatorAttachment'] as String? ?? 'platform',
    );
  }
}

/// Extension methods for convenient JSON serialization
extension RegisterGenerateOptionDataExtension on RegisterGenerateOptionData {
  /// Converts [RegisterGenerateOptionData] to JSON Map
  ///
  /// Useful for debugging or sending to server for verification
  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      'rp': {'name': rp.name, 'id': rp.id},
      'user': {
        'id': user.id,
        'name': user.name,
        'displayName': user.displayName,
      },
      'pubKeyCredParams': pubKeyCredParams
          .map((param) => {'alg': param.alg, 'type': param.type})
          .toList(),
      'timeout': timeout,
      'attestation': attestation,
      'excludeCredentials': excludeCredentials
          .map(
            (cred) => {
              'id': cred.id,
              'type': cred.type,
              'transports': cred.transports,
            },
          )
          .toList(),
      'authenticatorSelection': {
        'residentKey': authenticatorSelection.residentKey,
        'userVerification': authenticatorSelection.userVerification,
        'requireResidentKey': authenticatorSelection.requireResidentKey,
        'authenticatorAttachment':
            authenticatorSelection.authenticatorAttachment,
      },
      'extensions': {'credProps': extensions.credProps},
    };
  }

  /// Converts [RegisterGenerateOptionData] to JSON string
  String toJsonString() => jsonEncode(toJson());
}

/// Extension methods for convenient JSON serialization
extension AuthGenerateOptionResponseDataExtension
    on AuthGenerateOptionResponseData {
  /// Converts [AuthGenerateOptionResponseData] to JSON Map
  ///
  /// Useful for debugging or sending to server for verification
  Map<String, dynamic> toJson() {
    return {
      'rpId': rpId,
      'challenge': challenge,
      'allowCredentials': allowCredentials
          .map(
            (cred) => {
              'id': cred.id,
              'type': cred.type,
              'transports': cred.transports,
            },
          )
          .toList(),
      'timeout': timeout,
      'userVerification': userVerification,
    };
  }

  /// Converts [AuthGenerateOptionResponseData] to JSON string
  String toJsonString() => jsonEncode(toJson());
}
