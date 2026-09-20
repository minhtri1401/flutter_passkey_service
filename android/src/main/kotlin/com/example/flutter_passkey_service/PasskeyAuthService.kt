package com.example.flutter_passkey_service

import android.content.Context
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PublicKeyCredential
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

/**
 * Service interface for handling Passkey authentication and registration operations.
 *
 * This interface provides methods to create and authenticate with passkeys using the
 * Android Credential Manager API. Passkeys offer a secure, phishing-resistant alternative
 * to traditional passwords by using cryptographic key pairs stored securely on the device.
 *
 * ## Key Features
 * - **Biometric Authentication**: Users can authenticate using fingerprint, face unlock, or device PIN
 * - **Cross-Device Sync**: Passkeys are synced across devices via Google Password Manager
 * - **Phishing Resistant**: Cryptographic verification prevents phishing attacks
 * - **No Passwords**: Eliminates the need for users to remember complex passwords
 *
 * @see [Android Passkey Documentation](https://developer.android.com/training/sign-in/passkeys)
 */
interface PasskeyAuthService {

    /**
     * Initiates the Passkey authentication flow for existing users.
     *
     * This method launches the Android Credential Manager to authenticate a user with an existing
     * passkey. The user will be prompted to select from available credentials and verify their
     * identity using biometric authentication or device PIN.
     *
     * ## Authentication Process
     * 1. Validates the authentication request parameters
     * 2. Launches the Credential Manager UI
     * 3. User selects their account and authenticates
     * 4. Returns the authentication response for server verification
     *
     * @param request The [AuthGenerateOptionResponseData] containing authentication options including:
     *   - `challenge`: Cryptographically random challenge from your server
     *   - `rpId`: Your domain identifier (e.g., "example.com")
     *   - `allowCredentials`: List of credential IDs to allow for authentication
     *   - `timeout`: Maximum time allowed for the operation (in milliseconds)
     *   - `userVerification`: Required level of user verification
     *
     * @param activityContext The [Context] of the activity that will display the authentication UI.
     *   This context is required for launching the Credential Manager interface.
     *
     * @return A [Flow] that emits [GetPasskeyAuthenticationResponseData] containing:
     *   - `authenticatorData`: Signed authenticator data
     *   - `clientDataJSON`: Client data with challenge and origin
     *   - `signature`: Digital signature for verification
     *   - `userHandle`: User identifier associated with the credential
     *
     * @throws SecurityException If the calling app is not authorized to use passkeys
     * @throws IllegalArgumentException If required parameters are missing or invalid
     * @throws CancellationException If the user cancels the authentication flow
     *
     * @sample
     * ```kotlin
     * val authRequest = AuthGenerateOptionResponseData(
     *     rpId = "example.com",
     *     challenge = "base64-encoded-challenge",
     *     allowCredentials = listOf(allowedCredential),
     *     timeout = 60000,
     *     userVerification = "required"
     * )
     *
     * passkeyService.authenticate(authRequest, activity)
     *     .collect { response ->
     *         // Send response to server for verification
     *         verifyAuthentication(response)
     *     }
     * ```
     */
    fun authenticate(
        request: AuthGenerateOptionResponseData,
        activityContext: Context
    ): Flow<GetPasskeyAuthenticationResponseData>

    /**
     * Initiates the Passkey registration flow for new users or adding credentials.
     *
     * This method creates a new passkey credential for a user account. The user will be prompted
     * to authenticate using biometric verification or device PIN to securely store the new
     * credential in their device's credential manager.
     *
     * ## Registration Process
     * 1. Validates the registration request parameters
     * 2. Launches the Credential Manager for credential creation
     * 3. User authenticates to confirm credential creation
     * 4. Returns the registration response for server storage
     *
     * @param option The [RegisterGenerateOptionData] containing registration options including:
     *   - `challenge`: Cryptographically random challenge from your server
     *   - `rp`: Relying party information (your app's name and domain)
     *   - `user`: User account details (ID, username, display name)
     *   - `pubKeyCredParams`: Supported cryptographic algorithms
     *   - `authenticatorSelection`: Preferred authenticator characteristics
     *   - `attestation`: Level of attestation required
     *   - `excludeCredentials`: Existing credentials to exclude from creation
     *
     * @param activityContext The [Context] of the activity that will display the registration UI.
     *   This context is required for launching the Credential Manager interface.
     *
     * @return A [Flow] that emits [CreatePasskeyResponseData] containing:
     *   - `id`: Base64URL-encoded credential ID
     *   - `rawId`: Raw bytes of the credential ID
     *   - `response`: Attestation response with public key and authenticator data
     *   - `type`: Credential type (always "public-key" for passkeys)
     *   - `authenticatorAttachment`: How the authenticator is attached ("platform" or "cross-platform")
     *   - `clientExtensionResults`: Results of any requested extensions
     *
     * @throws SecurityException If the calling app is not authorized to create passkeys
     * @throws IllegalArgumentException If required parameters are missing or invalid
     * @throws InvalidStateException If a credential with the same ID already exists
     * @throws CancellationException If the user cancels the registration flow
     *
     * @sample
     * ```kotlin
     * val registerOption = RegisterGenerateOptionData(
     *     challenge = "base64-encoded-challenge",
     *     rp = RegisterGenerateOptionRp(name = "My App", id = "example.com"),
     *     user = RegisterGenerateOptionUser(
     *         id = "user-123",
     *         name = "user@example.com",
     *         displayName = "John Doe"
     *     ),
     *     pubKeyCredParams = listOf(/* supported algorithms */),
     *     timeout = 60000,
     *     attestation = "none",
     *     excludeCredentials = emptyList(),
     *     authenticatorSelection = RegisterGenerateOptionAuthenticatorSelection(/*...*/)
     * )
     *
     * passkeyService.register(registerOption, activity)
     *     .collect { response ->
     *         // Send response to server for storage
     *         storeCredential(response)
     *     }
     * ```
     */
    fun register(
        option: RegisterGenerateOptionData,
        activityContext: Context
    ): Flow<CreatePasskeyResponseData>
}


class PasskeyAuthServiceImpl(private val credentialManager: CredentialManager) :
    PasskeyAuthService {
    private val exceptionHandler = PasskeyExceptionHandler()

    override fun register(
        option: RegisterGenerateOptionData,
        activityContext: Context
    ): Flow<CreatePasskeyResponseData> = flow {
        try {
            val request = CreatePublicKeyCredentialRequest(PasskeyJson.buildCreateRequestJson(option))
            val response = credentialManager.createCredential(activityContext, request)
            val responseJson = (response as CreatePublicKeyCredentialResponse).registrationResponseJson
            emit(PasskeyJson.parseCreateResponse(responseJson, option.user.name))
        } catch (e: Exception) {
            throw exceptionHandler.handleRegistrationException(e)
        }
    }

    override fun authenticate(
        request: AuthGenerateOptionResponseData,
        activityContext: Context
    ): Flow<GetPasskeyAuthenticationResponseData> = flow {
        try {
            val getCredentialRequest = GetCredentialRequest.Builder()
                .addCredentialOption(GetPublicKeyCredentialOption(PasskeyJson.buildGetRequestJson(request)))
                .setPreferImmediatelyAvailableCredentials(
                    request.preferImmediatelyAvailableCredentials ?: false
                )
                .build()
            val response = credentialManager.getCredential(activityContext, getCredentialRequest)
            val cred = response.credential as PublicKeyCredential
            emit(PasskeyJson.parseGetResponse(cred.authenticationResponseJson))
        } catch (e: Exception) {
            throw exceptionHandler.handleAuthenticationException(e)
        }
    }
}
