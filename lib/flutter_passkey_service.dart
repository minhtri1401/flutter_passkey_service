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
    int timeout = 60000,
    String userVerification = 'required',
  }) {
    return AuthGenerateOptionResponseData(
      rpId: rpId,
      challenge: challenge,
      allowCredentials: allowCredentials,
      timeout: timeout,
      userVerification: userVerification,
    );
  }
}
