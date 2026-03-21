// ignore: depend_on_referenced_packages
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/pigeons/messages.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/example/flutter_passkey_service/Messages.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.example.flutter_passkey_service',
    ),
    swiftOut: 'ios/Classes/Messages.swift',
    dartPackageName: 'flutter_passkey_service',
  ),
)
/// Represents a standardized passkey exception that can be thrown across platforms
class PasskeyException {
  PasskeyException({
    required this.errorType,
    required this.message,
    required this.details,
  });

  /// Error type identifying the specific type of error
  PasskeyErrorType errorType;

  /// Error message describing what went wrong
  String message;

  /// Optional additional details about the error
  String details;
}

/// Predefined error types for consistent error handling across platforms
enum PasskeyErrorType {
  // Input validation errors
  invalidParameters,
  missingRequiredField,
  invalidFormat,
  decodingChallenge,

  // User interaction errors
  userCancelled,
  userTimeout,
  userOptedOut,

  // Permission and security errors
  insufficientPermissions,
  securityViolation,
  notAllowed,
  domainNotAssociated,

  // Credential and authentication errors
  noCredentialsAvailable,
  credentialNotFound,
  invalidCredential,
  credentialAlreadyExists,
  invalidResponse,
  notHandled,
  failed,

  // Platform and system errors
  platformNotSupported,
  operationNotSupported,
  systemError,
  networkError,

  // DOM and WebAuthn specific errors
  domError,
  webauthnError,
  attestationError,
  excludeCredentialsMatch,

  // iOS specific errors
  unexpectedAuthorizationResponse,
  wkErrorDomain,

  // Unknown and unexpected errors
  unknownError,
  unexpectedError,
}

/// Represents the response data for authentication generation options
class AuthGenerateOptionResponseData {
  AuthGenerateOptionResponseData({
    required this.rpId,
    required this.challenge,
    required this.allowCredentials,
    required this.timeout,
    required this.userVerification,
    this.hints,
    this.extensions,
  });

  /// The relying party identifier
  String rpId;

  /// The challenge string
  String challenge;

  /// List of allowed credentials
  List<AuthGenerateOptionAllowCredential> allowCredentials;

  /// Timeout value in milliseconds
  int timeout;

  /// User verification requirement
  String userVerification;

  /// Hints for the authenticator
  List<String?>? hints;

  /// Extensions for authentication
  AuthGenerateOptionExtension? extensions;
}

/// Represents extensions for authentication options
class AuthGenerateOptionExtension {
  AuthGenerateOptionExtension({this.appid, this.prf});

  /// AppID extension
  bool? appid;

  /// PRF extension input parameters
  PrfExtensionInput? prf;
}

/// Represents an allowed credential for authentication
class AuthGenerateOptionAllowCredential {
  AuthGenerateOptionAllowCredential({
    required this.id,
    required this.type,
    required this.transports,
  });

  /// The credential identifier
  String id;

  /// The credential type
  String type;

  /// List of transport methods
  List<String> transports;
}

/// Represents the response data for authentication verification
class AuthVerifyResponse {
  AuthVerifyResponse({
    this.verified = false,
    this.accessToken = '',
    this.user,
    required this.refreshToken,
  });

  /// Whether the authentication was verified
  bool verified;

  /// Access token for authenticated session
  String accessToken;

  /// User information (optional)
  User? user;

  /// Refresh token for session renewal
  String refreshToken;
}

/// Represents user information
class User {
  User({this.id = '', this.username = '', this.phone, this.email});

  /// User identifier
  String id;

  /// Username
  String username;

  /// Phone number (optional)
  String? phone;

  /// Email address (optional)
  String? email;
}

/// Represents the response data for creating a passkey
class CreatePasskeyResponseData {
  CreatePasskeyResponseData({
    required this.rawId,
    this.authenticatorAttachment,
    required this.type,
    required this.id,
    required this.response,
    required this.clientExtensionResults,
    this.username = 'username',
  });

  /// Raw identifier
  String rawId;

  /// Authenticator attachment type
  String? authenticatorAttachment;

  /// Type of credential
  String type;

  /// Credential identifier
  String id;

  /// Response data from passkey creation
  CreatePasskeyResponse response;

  /// Client extension results
  CreatePasskeyExtension clientExtensionResults;

  /// Username associated with the passkey
  String username;
}

/// Represents the response from passkey creation
class CreatePasskeyResponse {
  CreatePasskeyResponse({
    required this.clientDataJSON,
    required this.attestationObject,
    this.transports,
    this.authenticatorData,
    this.publicKeyAlgorithm,
    this.publicKey,
  });

  /// Client data JSON
  String clientDataJSON;

  /// Attestation object
  String attestationObject;

  /// List of transport methods
  List<String?>? transports;

  /// Authenticator data
  String? authenticatorData;

  /// Public key algorithm identifier
  int? publicKeyAlgorithm;

  /// Public key
  String? publicKey;
}

/// Represents client extension results for passkey creation
class CreatePasskeyExtension {
  CreatePasskeyExtension({this.credProps, this.prf});

  /// Credential properties extension (optional)
  CreatePasskeyExtensionProps? credProps;

  /// PRF extension (optional)
  PrfExtensionOutput? prf;
}

/// Represents credential properties extension
class CreatePasskeyExtensionProps {
  CreatePasskeyExtensionProps({required this.rk});

  /// Resident key flag
  bool rk;
}

/// Represents the response data for passkey authentication
class GetPasskeyAuthenticationResponseData {
  GetPasskeyAuthenticationResponseData({
    this.authenticatorAttachment,
    required this.id,
    required this.rawId,
    required this.response,
    required this.type,
    this.clientExtensionResults,
    this.username = 'username',
  });

  /// Authenticator attachment type
  String? authenticatorAttachment;

  /// Credential identifier
  String id;

  /// Raw identifier
  String rawId;

  /// Authentication response data
  GetPasskeyAuthenticationResponse response;

  /// Type of credential
  String type;

  /// Client extension results
  AuthPasskeyExtensionResult? clientExtensionResults;

  /// Username associated with the passkey
  String username;
}

/// Represents client extension results for passkey authentication
class AuthPasskeyExtensionResult {
  AuthPasskeyExtensionResult({this.appid, this.prf});

  /// AppID extension result
  bool? appid;

  /// PRF extension output results
  PrfExtensionOutput? prf;
}

/// Represents the authentication response from passkey
class GetPasskeyAuthenticationResponse {
  GetPasskeyAuthenticationResponse({
    required this.clientDataJSON,
    required this.authenticatorData,
    required this.signature,
    this.userHandle,
  });

  /// Client data JSON
  String clientDataJSON;

  /// Authenticator data
  String authenticatorData;

  /// Digital signature
  String signature;

  /// User handle (optional)
  String? userHandle;
}

/// Represents the data for generating registration options
class RegisterGenerateOptionData {
  RegisterGenerateOptionData({
    required this.challenge,
    required this.rp,
    required this.user,
    required this.pubKeyCredParams,
    required this.timeout,
    required this.attestation,
    required this.excludeCredentials,
    required this.authenticatorSelection,
    required this.extensions,
    this.hints,
    this.attestationFormats,
  });

  /// Challenge string
  String challenge;

  /// Relying party information
  RegisterGenerateOptionRp rp;

  /// User information
  RegisterGenerateOptionUser user;

  /// Public key credential parameters
  List<RegisterGenerateOptionPublicKeyParams> pubKeyCredParams;

  /// Timeout value in milliseconds
  int timeout;

  /// Attestation preference
  String attestation;

  /// Credentials to exclude from registration
  List<RegisterGenerateOptionExcludeCredential> excludeCredentials;

  /// Authenticator selection criteria
  RegisterGenerateOptionAuthenticatorSelection authenticatorSelection;

  /// Extensions for registration
  RegisterGenerateOptionExtension extensions;

  /// Hints for the authenticator
  List<String?>? hints;

  /// Attestation formats
  List<String?>? attestationFormats;
}

/// Represents a credential to exclude from registration
class RegisterGenerateOptionExcludeCredential {
  RegisterGenerateOptionExcludeCredential({
    required this.id,
    required this.type,
    required this.transports,
  });

  /// Credential identifier
  String id;

  /// Credential type
  String type;

  /// List of transport methods
  List<String> transports;
}

/// Represents relying party information for registration
class RegisterGenerateOptionRp {
  RegisterGenerateOptionRp({required this.name, required this.id});

  /// Relying party name
  String name;

  /// Relying party identifier
  String id;
}

/// Represents user information for registration
class RegisterGenerateOptionUser {
  RegisterGenerateOptionUser({
    required this.id,
    required this.name,
    this.displayName = '',
  });

  /// User identifier
  String id;

  /// User name
  String name;

  /// Display name (defaults to empty string)
  String displayName;
}

/// Represents public key credential parameters
class RegisterGenerateOptionPublicKeyParams {
  RegisterGenerateOptionPublicKeyParams({
    required this.alg,
    required this.type,
  });

  /// Algorithm identifier
  int alg;

  /// Credential type
  String type;
}

/// Represents authenticator selection criteria
class RegisterGenerateOptionAuthenticatorSelection {
  RegisterGenerateOptionAuthenticatorSelection({
    required this.residentKey,
    required this.userVerification,
    required this.requireResidentKey,
    this.authenticatorAttachment = 'platform',
  });

  /// Resident key requirement
  String residentKey;

  /// User verification requirement
  String userVerification;

  /// Whether resident key is required
  bool requireResidentKey;

  /// Authenticator attachment preference
  String authenticatorAttachment;
}

/// Represents extensions for registration
class RegisterGenerateOptionExtension {
  RegisterGenerateOptionExtension({required this.credProps, this.prf});

  /// Credential properties extension
  bool credProps;

  /// PRF extension input parameters
  PrfExtensionInput? prf;
}

/// Represents the response data for registration verification
class RegisterVerifyResponse {
  RegisterVerifyResponse({
    required this.verified,
    this.accessToken = '',
    required this.user,
    required this.refreshToken,
  });

  /// Whether the registration was verified
  bool verified;

  /// Access token for authenticated session
  String accessToken;

  /// User information
  User user;

  /// Refresh token for session renewal
  String refreshToken;
}

/// Host API for passkey operations from Flutter to native platforms
@HostApi()
abstract class PasskeyHostApi {
  /// Registers a new passkey credential
  @async
  CreatePasskeyResponseData register(RegisterGenerateOptionData options);

  /// Authenticates with an existing passkey
  @async
  GetPasskeyAuthenticationResponseData authenticate(
    AuthGenerateOptionResponseData request,
  );
}

/// WebAuthn PRF Extension Input payload
/// The WebAuthn specification stipulates eval dictionaries contain `first` (and optionally `second`)
/// salt strings. The underlying platform APIs (like Android Credential Manager) expect these Strings
/// to be Base64URL-encoded representations of a 32-byte ArrayBuffer.
class PrfExtensionInput {
  PrfExtensionInput({this.eval});

  /// The dictionary structure containing salts ('first' and optionally 'second')
  Map<String?, String?>? eval;
}

/// Represents PRF extension output results
class PrfExtensionOutput {
  PrfExtensionOutput({this.enabled, this.results});

  /// Whether PRF is enabled for this credential
  bool? enabled;

  /// The dictionary structure containing derived salts ('first' and optionally 'second')
  Map<String?, String?>? results;
}
