package com.example.flutter_passkey_service

import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.NoCredentialException
import androidx.credentials.exceptions.domerrors.NotAllowedError
import androidx.credentials.exceptions.publickeycredential.GetPublicKeyCredentialDomException
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertSame

class PasskeyExceptionHandlerTest {
    private val handler = PasskeyExceptionHandler()

    @Test
    fun registration_cancellation_mapsToUserCancelled() {
        val e = handler.handleRegistrationException(CreateCredentialCancellationException("x"))
        assertEquals(PasskeyErrorType.USER_CANCELLED, e.passkeyException.errorType)
    }

    @Test
    fun authentication_noCredential_mapsToNoCredentialsAvailable() {
        val e = handler.handleAuthenticationException(NoCredentialException("none"))
        assertEquals(PasskeyErrorType.NO_CREDENTIALS_AVAILABLE, e.passkeyException.errorType)
    }

    @Test
    fun authentication_cancellation_mapsToUserCancelled() {
        val e = handler.handleAuthenticationException(GetCredentialCancellationException("x"))
        assertEquals(PasskeyErrorType.USER_CANCELLED, e.passkeyException.errorType)
    }

    @Test
    fun authentication_notAllowedDomError_mapsToNotAllowed() {
        val e = handler.handleAuthenticationException(GetPublicKeyCredentialDomException(NotAllowedError(), "denied"))
        assertEquals(PasskeyErrorType.NOT_ALLOWED, e.passkeyException.errorType)
        assertEquals("denied", e.passkeyException.details)
    }

    @Test
    fun alreadyMappedException_passesThroughUnchanged() {
        val original = PasskeyOperationException(PasskeyErrorType.INVALID_RESPONSE, "Missing id in provider response")
        assertSame(original, handler.handleRegistrationException(original))
        assertSame(original, handler.handleAuthenticationException(original))
    }
}
