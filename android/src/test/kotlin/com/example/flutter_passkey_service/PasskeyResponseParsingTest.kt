package com.example.flutter_passkey_service

import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull
import kotlin.test.assertNull

class PasskeyResponseParsingTest {

    private val fullCreateJson = """
        {
          "id": "Y3JlZA", "rawId": "Y3JlZA", "type": "public-key", "authenticatorAttachment": "platform",
          "response": {
            "clientDataJSON": "Y2xpZW50", "attestationObject": "YXR0",
            "transports": ["internal", "hybrid"], "authenticatorData": "YXV0aA",
            "publicKeyAlgorithm": -7, "publicKey": "cHVi"
          },
          "clientExtensionResults": {
            "credProps": {"rk": true},
            "prf": {"enabled": true, "results": {"first": "b3V0"}},
            "largeBlob": {"supported": true}
          }
        }
    """.trimIndent()

    @Test
    fun parseCreate_fullResponse() {
        val r = PasskeyJson.parseCreateResponse(fullCreateJson, username = "user@example.com")
        assertEquals("Y3JlZA", r.id)
        assertEquals("platform", r.authenticatorAttachment)
        assertEquals("user@example.com", r.username)
        assertEquals(listOf("internal", "hybrid"), r.response.transports)
        assertEquals("YXV0aA", r.response.authenticatorData)
        assertEquals(-7L, r.response.publicKeyAlgorithm)
        assertEquals("cHVi", r.response.publicKey)
        assertEquals(true, r.clientExtensionResults.credProps?.rk)
        assertEquals(true, r.clientExtensionResults.prf?.enabled)
        assertEquals("b3V0", r.clientExtensionResults.prf?.results?.get("first"))
        assertEquals(true, r.clientExtensionResults.largeBlob?.supported)
    }

    @Test
    fun parseCreate_thirdPartyProvider_omitsOptionalFields() {
        val json = """
            {"id":"Y3JlZA","rawId":"Y3JlZA","type":"public-key",
             "response":{"clientDataJSON":"Y2xpZW50","attestationObject":"YXR0"}}
        """.trimIndent()
        val r = PasskeyJson.parseCreateResponse(json, username = "u")
        assertNull(r.authenticatorAttachment)
        assertNull(r.response.transports)
        assertNull(r.response.authenticatorData)
        assertNull(r.response.publicKeyAlgorithm)
        assertNull(r.response.publicKey)
        assertNotNull(r.clientExtensionResults)
        assertNull(r.clientExtensionResults.credProps)
        assertNull(r.clientExtensionResults.prf)
    }

    @Test
    fun parseCreate_missingRequiredField_throwsInvalidResponse() {
        val json = """{"id":"Y3JlZA","rawId":"Y3JlZA","type":"public-key","response":{"clientDataJSON":"Y2xpZW50"}}"""
        val e = assertFailsWith<PasskeyOperationException> { PasskeyJson.parseCreateResponse(json, "u") }
        assertEquals(PasskeyErrorType.INVALID_RESPONSE, e.passkeyException.errorType)
        assertEquals("Missing attestationObject in provider response", e.passkeyException.message)
    }

    @Test
    fun parseGet_fullResponse_includingLargeBlobRead() {
        val json = """
            {"id":"Y3JlZA","rawId":"Y3JlZA","type":"public-key","authenticatorAttachment":"platform",
             "response":{"clientDataJSON":"Y2xpZW50","authenticatorData":"YXV0aA","signature":"c2ln","userHandle":"dXNlcjEyMw"},
             "clientExtensionResults":{"prf":{"results":{"first":"b3V0","second":"b3V0Mg"}},"largeBlob":{"blob":"AQIDBAU"}}}
        """.trimIndent()
        val r = PasskeyJson.parseGetResponse(json)
        assertEquals("dXNlcjEyMw", r.response.userHandle)
        assertEquals("c2ln", r.response.signature)
        assertEquals("", r.username)
        assertEquals("b3V0Mg", r.clientExtensionResults?.prf?.results?.get("second"))
        assertContentEquals(byteArrayOf(1, 2, 3, 4, 5), r.clientExtensionResults?.largeBlob?.blob)
        assertNull(r.clientExtensionResults?.largeBlob?.written)
    }

    @Test
    fun parseGet_nullUserHandle_and_noExtensions() {
        val json = """
            {"id":"Y3JlZA","rawId":"Y3JlZA","type":"public-key",
             "response":{"clientDataJSON":"Y2xpZW50","authenticatorData":"YXV0aA","signature":"c2ln","userHandle":null}}
        """.trimIndent()
        val r = PasskeyJson.parseGetResponse(json)
        assertNull(r.response.userHandle)
        assertNull(r.clientExtensionResults)
    }

    @Test
    fun parseGet_missingSignature_throwsInvalidResponse() {
        val json = """{"id":"a","rawId":"a","type":"public-key","response":{"clientDataJSON":"Y2xpZW50","authenticatorData":"YXV0aA"}}"""
        val e = assertFailsWith<PasskeyOperationException> { PasskeyJson.parseGetResponse(json) }
        assertEquals(PasskeyErrorType.INVALID_RESPONSE, e.passkeyException.errorType)
        assertEquals("Missing signature in provider response", e.passkeyException.message)
    }
}
