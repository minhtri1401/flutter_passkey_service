package com.example.flutter_passkey_service

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class PasskeyRequestJsonTest {

    private fun baseRegistration(
        timeout: Long? = null,
        selection: RegisterGenerateOptionAuthenticatorSelection? = null,
        hints: List<String?>? = null,
        attestationFormats: List<String?>? = null,
        extensions: RegisterGenerateOptionExtension = RegisterGenerateOptionExtension(credProps = true),
        exclude: List<RegisterGenerateOptionExcludeCredential> = emptyList(),
    ) = RegisterGenerateOptionData(
        challenge = "Y2hhbGxlbmdl",
        rp = RegisterGenerateOptionRp(name = "My App", id = "example.com"),
        user = RegisterGenerateOptionUser(id = "dXNlcjEyMw", name = "user@example.com", displayName = "User"),
        pubKeyCredParams = listOf(RegisterGenerateOptionPublicKeyParams(alg = -7L, type = "public-key")),
        timeout = timeout,
        attestation = "none",
        excludeCredentials = exclude,
        authenticatorSelection = selection,
        extensions = extensions,
        hints = hints,
        attestationFormats = attestationFormats,
    )

    @Test
    fun create_minimalOptions_omitAbsentFields() {
        val json = Json.parseToJsonElement(PasskeyJson.buildCreateRequestJson(baseRegistration())).jsonObject

        assertEquals("Y2hhbGxlbmdl", json["challenge"]!!.jsonPrimitive.content)
        assertEquals("example.com", json["rp"]!!.jsonObject["id"]!!.jsonPrimitive.content)
        assertEquals("dXNlcjEyMw", json["user"]!!.jsonObject["id"]!!.jsonPrimitive.content)
        assertEquals(-7L, json["pubKeyCredParams"]!!.jsonArray[0].jsonObject["alg"]!!.jsonPrimitive.content.toLong())
        assertEquals("none", json["attestation"]!!.jsonPrimitive.content)
        assertEquals(0, json["excludeCredentials"]!!.jsonArray.size)
        assertFalse(json.containsKey("timeout"))
        assertFalse(json.containsKey("authenticatorSelection"))
        assertFalse(json.containsKey("hints"))
        assertFalse(json.containsKey("attestationFormats"))
        assertEquals(true, json["extensions"]!!.jsonObject["credProps"]!!.jsonPrimitive.content.toBoolean())
        assertFalse(json["extensions"]!!.jsonObject.containsKey("prf"))
    }

    @Test
    fun create_fullOptions_includeEverything() {
        val option = baseRegistration(
            timeout = 120000L,
            selection = RegisterGenerateOptionAuthenticatorSelection(
                residentKey = "required", userVerification = "preferred",
                requireResidentKey = true, authenticatorAttachment = "platform",
            ),
            hints = listOf("client-device", null),
            attestationFormats = listOf("packed"),
            extensions = RegisterGenerateOptionExtension(
                credProps = true,
                prf = PrfExtensionInput(eval = mapOf<String?, String?>("first" to "c2FsdA", "second" to null)),
                largeBlob = LargeBlobExtensionRegistrationInput(support = "required"),
            ),
            exclude = listOf(
                RegisterGenerateOptionExcludeCredential(id = "Y3JlZA", type = "public-key", transports = listOf("internal")),
                RegisterGenerateOptionExcludeCredential(id = "Y3JlZDI", type = "public-key", transports = null),
            ),
        )
        val json = Json.parseToJsonElement(PasskeyJson.buildCreateRequestJson(option)).jsonObject

        assertEquals(120000L, json["timeout"]!!.jsonPrimitive.content.toLong())
        val sel = json["authenticatorSelection"]!!.jsonObject
        assertEquals("required", sel["residentKey"]!!.jsonPrimitive.content)
        assertEquals("preferred", sel["userVerification"]!!.jsonPrimitive.content)
        assertEquals(true, sel["requireResidentKey"]!!.jsonPrimitive.content.toBoolean())
        assertEquals("platform", sel["authenticatorAttachment"]!!.jsonPrimitive.content)
        assertEquals(listOf("client-device"), json["hints"]!!.jsonArray.map { it.jsonPrimitive.content })
        assertEquals(listOf("packed"), json["attestationFormats"]!!.jsonArray.map { it.jsonPrimitive.content })
        val exclude = json["excludeCredentials"]!!.jsonArray
        assertEquals(listOf("internal"), exclude[0].jsonObject["transports"]!!.jsonArray.map { it.jsonPrimitive.content })
        assertFalse(exclude[1].jsonObject.containsKey("transports"))
        val ext = json["extensions"]!!.jsonObject
        assertEquals("c2FsdA", ext["prf"]!!.jsonObject["eval"]!!.jsonObject["first"]!!.jsonPrimitive.content)
        assertFalse(ext["prf"]!!.jsonObject["eval"]!!.jsonObject.containsKey("second"))
        assertEquals("required", ext["largeBlob"]!!.jsonObject["support"]!!.jsonPrimitive.content)
    }

    @Test
    fun create_prfWithoutEval_emitsEmptyPrfObject() {
        val option = baseRegistration(extensions = RegisterGenerateOptionExtension(credProps = true, prf = PrfExtensionInput()))
        val ext = Json.parseToJsonElement(PasskeyJson.buildCreateRequestJson(option)).jsonObject["extensions"]!!.jsonObject
        assertTrue(ext.containsKey("prf"))
        assertEquals(0, ext["prf"]!!.jsonObject.size)
    }

    private fun baseAuth(
        allow: List<AuthGenerateOptionAllowCredential> = emptyList(),
        timeout: Long? = null,
        userVerification: String? = null,
        hints: List<String?>? = null,
        extensions: AuthGenerateOptionExtension? = null,
    ) = AuthGenerateOptionResponseData(
        rpId = "example.com",
        challenge = "Y2hhbGxlbmdl",
        allowCredentials = allow,
        timeout = timeout,
        userVerification = userVerification,
        hints = hints,
        extensions = extensions,
        preferImmediatelyAvailableCredentials = null,
    )

    @Test
    fun get_minimalOptions_omitAbsentFields() {
        val json = Json.parseToJsonElement(PasskeyJson.buildGetRequestJson(baseAuth())).jsonObject
        assertEquals("example.com", json["rpId"]!!.jsonPrimitive.content)
        assertFalse(json.containsKey("allowCredentials"))
        assertFalse(json.containsKey("timeout"))
        assertFalse(json.containsKey("userVerification"))
        assertFalse(json.containsKey("hints"))
        assertFalse(json.containsKey("extensions"))
    }

    @Test
    fun get_fullOptions_includeEverything() {
        val request = baseAuth(
            allow = listOf(AuthGenerateOptionAllowCredential(id = "Y3JlZA", type = "public-key", transports = listOf("internal", "hybrid"))),
            timeout = 60000L,
            userVerification = "required",
            hints = listOf("security-key"),
            extensions = AuthGenerateOptionExtension(
                appid = true,
                prf = PrfExtensionInput(eval = mapOf<String?, String?>("first" to "c2FsdA")),
                largeBlob = LargeBlobExtensionAuthInput(read = null, write = byteArrayOf(1, 2, 3, 4, 5)),
            ),
        )
        val json = Json.parseToJsonElement(PasskeyJson.buildGetRequestJson(request)).jsonObject
        assertEquals("Y3JlZA", json["allowCredentials"]!!.jsonArray[0].jsonObject["id"]!!.jsonPrimitive.content)
        assertEquals(60000L, json["timeout"]!!.jsonPrimitive.content.toLong())
        assertEquals("required", json["userVerification"]!!.jsonPrimitive.content)
        assertEquals(listOf("security-key"), json["hints"]!!.jsonArray.map { it.jsonPrimitive.content })
        val ext = json["extensions"]!!.jsonObject
        assertEquals(true, ext["appid"]!!.jsonPrimitive.content.toBoolean())
        assertEquals("c2FsdA", ext["prf"]!!.jsonObject["eval"]!!.jsonObject["first"]!!.jsonPrimitive.content)
        assertEquals("AQIDBAU", ext["largeBlob"]!!.jsonObject["write"]!!.jsonPrimitive.content)
    }

    @Test
    fun get_largeBlobRead_emitsReadTrue() {
        val request = baseAuth(extensions = AuthGenerateOptionExtension(largeBlob = LargeBlobExtensionAuthInput(read = true)))
        val lb = Json.parseToJsonElement(PasskeyJson.buildGetRequestJson(request)).jsonObject["extensions"]!!.jsonObject["largeBlob"]!!.jsonObject
        assertEquals(true, lb["read"]!!.jsonPrimitive.content.toBoolean())
        assertFalse(lb.containsKey("write"))
    }
}
