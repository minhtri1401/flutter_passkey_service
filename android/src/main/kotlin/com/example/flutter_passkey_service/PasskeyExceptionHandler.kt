package com.example.flutter_passkey_service

import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialUnknownException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialInterruptedException
import androidx.credentials.exceptions.NoCredentialException
import androidx.credentials.exceptions.domerrors.*
import androidx.credentials.exceptions.publickeycredential.CreatePublicKeyCredentialDomException
import androidx.credentials.exceptions.publickeycredential.GetPublicKeyCredentialDomException

/**
 * Custom exception class that wraps PasskeyException data and can be thrown.
 * This allows us to use Kotlin's exception handling while still maintaining
 * the structured data format for communication with Flutter.
 */
class PasskeyOperationException(
    val passkeyException: PasskeyException,
    message: String = passkeyException.message,
    cause: Throwable? = null
) : Exception(message, cause) {
    
    constructor(
        errorType: PasskeyErrorType,
        message: String,
        details: String? = null,
        cause: Throwable? = null
    ) : this(
        PasskeyException(
            errorType = errorType,
            message = message,
            details = details ?: ""
        ),
        message,
        cause
    )
}

/**
 * Exception handler for Passkey operations.
 *
 * This class provides centralized exception handling for all passkey-related operations,
 * converting various platform exceptions into standardized [PasskeyException] instances
 * that can be forwarded to Flutter with consistent error types and messages.
 */
class PasskeyExceptionHandler {

    /**
     * Handles exceptions thrown during passkey registration operations.
     *
     * @param exception The exception thrown during registration
     * @return A throwable [PasskeyOperationException] with structured error data
     */
    fun handleRegistrationException(exception: Exception): PasskeyOperationException {
        return when (exception) {
            is IllegalArgumentException -> PasskeyOperationException(
                errorType = PasskeyErrorType.INVALID_PARAMETERS,
                message = "Invalid input parameters provided for passkey registration",
                details = exception.message ?: "",
                cause = exception
            )

            is CreateCredentialCancellationException -> PasskeyOperationException(
                errorType = PasskeyErrorType.USER_CANCELLED,
                message = "User cancelled the passkey registration operation",
                details = exception.message ?: "",
                cause = exception
            )

            is CreatePublicKeyCredentialDomException -> {
                if (exception.message?.contains("Flow has timed out") == true) {
                    PasskeyOperationException(
                        errorType = PasskeyErrorType.USER_CANCELLED,
                        message = "User cancelled the passkey registration operation",
                        details = exception.message ?: "",
                        cause = exception
                    )
                } else {
                    handleDomException(exception.domError, exception)
                }
            }

            is SecurityException -> PasskeyOperationException(
                errorType = PasskeyErrorType.INSUFFICIENT_PERMISSIONS,
                message = "Insufficient permissions for passkey operation",
                details = exception.message ?: "",
                cause = exception
            )

            is CreateCredentialUnknownException -> PasskeyOperationException(
                errorType = PasskeyErrorType.UNKNOWN_ERROR,
                message = "Unknown registration error occurred",
                details = exception.message ?: "",
                cause = exception
            )

            else -> {
                if (exception.message == "Unable to create key during registration") {
                    PasskeyOperationException(
                        errorType = PasskeyErrorType.USER_CANCELLED,
                        message = "User cancelled the passkey registration operation",
                        details = exception.message ?: "",
                        cause = exception
                    )
                } else {
                    PasskeyOperationException(
                        errorType = PasskeyErrorType.UNEXPECTED_ERROR,
                        message = "Unexpected registration error: ${exception.message}",
                        details = exception.message ?: "",
                        cause = exception
                    )
                }
            }
        }
    }

    /**
     * Handles exceptions thrown during passkey authentication operations.
     *
     * @param exception The exception thrown during authentication
     * @return A throwable [PasskeyOperationException] with structured error data
     */
    fun handleAuthenticationException(exception: Exception): PasskeyOperationException {
        return when (exception) {
            is IllegalArgumentException -> PasskeyOperationException(
                errorType = PasskeyErrorType.INVALID_PARAMETERS,
                message = "Invalid authentication parameters provided",
                details = exception.message ?: "",
                cause = exception
            )

            is GetCredentialCancellationException,
            is GetCredentialInterruptedException -> PasskeyOperationException(
                errorType = PasskeyErrorType.USER_CANCELLED,
                message = "User cancelled the authentication operation",
                details = exception.message ?: "",
                cause = exception
            )

            is GetPublicKeyCredentialDomException -> handleDomException(
                exception.domError,
                exception
            )

            is SecurityException -> PasskeyOperationException(
                errorType = PasskeyErrorType.INSUFFICIENT_PERMISSIONS,
                message = "Insufficient permissions for passkey operation",
                details = exception.message ?: "",
                cause = exception
            )

            is NoCredentialException -> PasskeyOperationException(
                errorType = PasskeyErrorType.NO_CREDENTIALS_AVAILABLE,
                message = "No passkey credentials available for authentication",
                details = exception.message ?: "",
                cause = exception
            )

            is CreateCredentialUnknownException -> PasskeyOperationException(
                errorType = PasskeyErrorType.UNKNOWN_ERROR,
                message = "Unknown authentication error occurred",
                details = exception.message ?: "",
                cause = exception
            )

            else -> PasskeyOperationException(
                errorType = PasskeyErrorType.UNEXPECTED_ERROR,
                message = "Unexpected authentication error: ${exception.message}",
                details = exception.message ?: "",
                cause = exception
            )
        }
    }

    /**
     * Handles DOM exceptions by converting them to standardized passkey exceptions.
     *
     * All DOM exceptions are consolidated into specific error types with descriptive messages
     * based on the type of DOM error encountered.
     *
     * @param domError The DOM error from the credential manager
     * @param originalException The original exception that was thrown
     * @return A throwable [PasskeyOperationException] with DOM error details
     */
    private fun handleDomException(domError: DomError, originalException: Exception): PasskeyOperationException {
        val errorMessage = originalException.message ?: ""
        val (errorType, message) = when (domError) {
            is AbortError -> PasskeyErrorType.USER_CANCELLED to "The passkey operation was aborted"
            is ConstraintError -> PasskeyErrorType.DOM_ERROR to "Passkey constraint validation failed"
            is DataCloneError -> PasskeyErrorType.DOM_ERROR to "Passkey data cannot be processed"
            is DataError -> PasskeyErrorType.INVALID_FORMAT to "Invalid passkey data provided"
            is EncodingError -> PasskeyErrorType.DOM_ERROR to "Passkey data encoding failed"
            is HierarchyRequestError -> PasskeyErrorType.DOM_ERROR to "Invalid passkey operation hierarchy"
            is InUseAttributeError -> PasskeyErrorType.DOM_ERROR to "Passkey attribute already in use"
            is InvalidCharacterError -> PasskeyErrorType.INVALID_FORMAT to "Invalid characters in passkey data"
            is InvalidStateError -> PasskeyErrorType.DOM_ERROR to "Passkey operation in invalid state"
            is InvalidNodeTypeError -> PasskeyErrorType.DOM_ERROR to "Invalid passkey node type"
            is InvalidModificationError -> PasskeyErrorType.DOM_ERROR to "Passkey cannot be modified"
            is NamespaceError -> PasskeyErrorType.DOM_ERROR to "Passkey namespace error"
            is NetworkError -> PasskeyErrorType.NETWORK_ERROR to "Network error during passkey operation"
            is NoModificationAllowedError -> PasskeyErrorType.DOM_ERROR to "Passkey modification not allowed"
            is NotReadableError -> PasskeyErrorType.DOM_ERROR to "Passkey data not readable"
            is NotAllowedError -> PasskeyErrorType.NOT_ALLOWED to "Passkey operation not allowed by platform"
            is NotFoundError -> PasskeyErrorType.CREDENTIAL_NOT_FOUND to "Passkey not found"
            is NotSupportedError -> PasskeyErrorType.OPERATION_NOT_SUPPORTED to "Passkey operation not supported"
            is OperationError -> PasskeyErrorType.DOM_ERROR to "Passkey operation failed internally"
            is OptOutError -> PasskeyErrorType.USER_OPTED_OUT to "User opted out of passkey operation"
            is QuotaExceededError -> PasskeyErrorType.SYSTEM_ERROR to "Passkey quota limit exceeded"
            is ReadOnlyError -> PasskeyErrorType.DOM_ERROR to "Passkey data is read-only"
            is SecurityError -> PasskeyErrorType.SECURITY_VIOLATION to "Passkey operation security violation"
            is SyntaxError -> PasskeyErrorType.INVALID_FORMAT to "Invalid passkey data format"
            is TimeoutError -> PasskeyErrorType.USER_TIMEOUT to "Passkey operation timed out"
            is TransactionInactiveError -> PasskeyErrorType.DOM_ERROR to "Passkey transaction not active"
            is UnknownError -> PasskeyErrorType.UNKNOWN_ERROR to "Unknown passkey operation error"
            is VersionError -> PasskeyErrorType.DOM_ERROR to "Passkey version incompatibility"
            is WrongDocumentError -> PasskeyErrorType.DOM_ERROR to "Passkey operation in wrong context"
            else -> PasskeyErrorType.DOM_ERROR to "Unrecognized passkey DOM error"
        }

        return PasskeyOperationException(
            errorType = errorType,
            message = message,
            details = errorMessage,
            cause = originalException
        )
    }
}
