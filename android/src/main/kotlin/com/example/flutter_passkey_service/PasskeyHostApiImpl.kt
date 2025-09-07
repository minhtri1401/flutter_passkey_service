package com.example.flutter_passkey_service

import android.app.Activity
import android.content.Context
import androidx.credentials.CredentialManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class PasskeyHostApiImpl(context: Context) : PasskeyHostApi {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val credentialManager = CredentialManager.create(context)
    private val passkeyService = PasskeyAuthServiceImpl(credentialManager)
    private val exceptionHandler = PasskeyExceptionHandler()
    private var activity: Activity? = null
    
    fun setActivity(activity: Activity?) {
        this.activity = activity
    }
    
    /**
     * Registers a new passkey credential.
     * 
     * @param options The registration options from Flutter
     * @param callback Result callback to Flutter
     */
    override fun register(
        options: RegisterGenerateOptionData,
        callback: (Result<CreatePasskeyResponseData>) -> Unit
    ) {
        scope.launch {
            try {
                // Get the current activity context
                val activityContext = getCurrentActivity() ?: throw IllegalStateException("No active activity found")
                
                // Use the passkey service to register
                passkeyService.register(options, activityContext).collect { result ->
                    callback(Result.success(result))
                }
            } catch (e: PasskeyOperationException) {
                // Convert to Flutter exception format
                val flutterException = PasskeyException(
                    errorType = e.passkeyException.errorType,
                    message = e.passkeyException.message,
                    details = e.passkeyException.details
                )
                callback(Result.failure(FlutterError("PASSKEY_ERROR", e.message, flutterException)))
            } catch (e: Exception) {
                val handledException = exceptionHandler.handleRegistrationException(e)
                val flutterException = PasskeyException(
                    errorType = handledException.passkeyException.errorType,
                    message = handledException.passkeyException.message,
                    details = handledException.passkeyException.details
                )
                callback(Result.failure(FlutterError("PASSKEY_ERROR", e.message, flutterException)))
            }
        }
    }
    
    /**
     * Authenticates with an existing passkey.
     * 
     * @param request The authentication request from Flutter
     * @param callback Result callback to Flutter
     */
    override fun authenticate(
        request: AuthGenerateOptionResponseData,
        callback: (Result<GetPasskeyAuthenticationResponseData>) -> Unit
    ) {
        scope.launch {
            try {
                // Get the current activity context
                val activityContext = getCurrentActivity() ?: throw IllegalStateException("No active activity found")
                
                // Use the passkey service to authenticate
                passkeyService.authenticate(request, activityContext).collect { result ->
                    callback(Result.success(result))
                }
            } catch (e: PasskeyOperationException) {
                // Convert to Flutter exception format
                val flutterException = PasskeyException(
                    errorType = e.passkeyException.errorType,
                    message = e.passkeyException.message,
                    details = e.passkeyException.details
                )
                callback(Result.failure(FlutterError("PASSKEY_ERROR", e.message, flutterException)))
            } catch (e: Exception) {
                val handledException = exceptionHandler.handleAuthenticationException(e)
                val flutterException = PasskeyException(
                    errorType = handledException.passkeyException.errorType,
                    message = handledException.passkeyException.message,
                    details = handledException.passkeyException.details
                )
                callback(Result.failure(FlutterError("PASSKEY_ERROR", e.message, flutterException)))
            }
        }
    }
    
    /**
     * Gets the current activity context.
     */
    private fun getCurrentActivity(): Activity? {
        return activity ?: throw IllegalStateException("No active activity found. Make sure the plugin is properly attached to an activity.")
    }
}
