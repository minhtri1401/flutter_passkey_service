package com.example.flutter_passkey_service

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArrayBuilder
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonObjectBuilder
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.add
import kotlinx.serialization.json.addJsonObject
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.longOrNull
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonArray
import kotlinx.serialization.json.putJsonObject

/**
 * Converts Pigeon option objects to Credential Manager request JSON and parses the
 * provider's response JSON back into Pigeon data classes.
 *
 * Pure JVM: no Android framework types, so it is covered by unit tests.
 * Request JSON follows WebAuthn L3 `PublicKeyCredentialCreationOptionsJSON` /
 * `PublicKeyCredentialRequestOptionsJSON`. Fields the caller left null are omitted so the
 * platform applies its own defaults.
 */
internal object PasskeyJson {

    // ---------------------------------------------------------------- requests

    fun buildCreateRequestJson(option: RegisterGenerateOptionData): String = buildJsonObject {
        put("challenge", option.challenge)
        putJsonObject("rp") {
            put("name", option.rp.name)
            put("id", option.rp.id)
        }
        putJsonObject("user") {
            put("id", option.user.id)
            put("name", option.user.name)
            put("displayName", option.user.displayName)
        }
        putJsonArray("pubKeyCredParams") {
            option.pubKeyCredParams.forEach { param ->
                addJsonObject {
                    put("type", param.type)
                    put("alg", param.alg)
                }
            }
        }
        option.timeout?.let { put("timeout", it) }
        put("attestation", option.attestation)
        putStringArrayIfPresent("attestationFormats", option.attestationFormats)
        putStringArrayIfPresent("hints", option.hints)
        putJsonArray("excludeCredentials") {
            option.excludeCredentials.forEach { addCredentialDescriptor(it.id, it.type, it.transports) }
        }
        option.authenticatorSelection?.let { sel ->
            putJsonObject("authenticatorSelection") {
                sel.residentKey?.let { put("residentKey", it) }
                sel.userVerification?.let { put("userVerification", it) }
                sel.requireResidentKey?.let { put("requireResidentKey", it) }
                sel.authenticatorAttachment?.let { put("authenticatorAttachment", it) }
            }
        }
        putJsonObject("extensions") {
            put("credProps", option.extensions.credProps)
            option.extensions.prf?.let { prf -> putJsonObject("prf") { putPrfEval(prf.eval) } }
            option.extensions.largeBlob?.let { lb ->
                putJsonObject("largeBlob") { put("support", lb.support ?: "preferred") }
            }
        }
    }.toString()

    fun buildGetRequestJson(request: AuthGenerateOptionResponseData): String = buildJsonObject {
        put("challenge", request.challenge)
        put("rpId", request.rpId)
        if (request.allowCredentials.isNotEmpty()) {
            putJsonArray("allowCredentials") {
                request.allowCredentials.forEach { addCredentialDescriptor(it.id, it.type, it.transports) }
            }
        }
        request.timeout?.let { put("timeout", it) }
        request.userVerification?.let { put("userVerification", it) }
        putStringArrayIfPresent("hints", request.hints)
        val ext = request.extensions
        if (ext != null && (ext.appid != null || ext.prf != null || ext.largeBlob != null)) {
            putJsonObject("extensions") {
                ext.appid?.let { put("appid", it) }
                ext.prf?.let { prf -> putJsonObject("prf") { putPrfEval(prf.eval) } }
                ext.largeBlob?.let { lb ->
                    putJsonObject("largeBlob") {
                        if (lb.read == true) {
                            put("read", true)
                        } else {
                            lb.write?.let { put("write", Base64Url.encode(it)) }
                        }
                    }
                }
            }
        }
    }.toString()

    private fun JsonObjectBuilder.putStringArrayIfPresent(key: String, values: List<String?>?) {
        val nonNull = values?.filterNotNull() ?: return
        if (nonNull.isEmpty()) return
        putJsonArray(key) { nonNull.forEach { add(it) } }
    }

    private fun JsonArrayBuilder.addCredentialDescriptor(id: String, type: String, transports: List<String>?) {
        addJsonObject {
            put("type", type)
            put("id", id)
            transports?.let { t -> putJsonArray("transports") { t.forEach { add(it) } } }
        }
    }

    private fun JsonObjectBuilder.putPrfEval(eval: Map<String?, String?>?) {
        if (eval == null) return
        putJsonObject("eval") {
            eval.forEach { (key, value) -> if (key != null && value != null) put(key, value) }
        }
    }

    // --------------------------------------------------------------- responses

    fun parseCreateResponse(responseJson: String, username: String): CreatePasskeyResponseData {
        val root = Json.parseToJsonElement(responseJson).jsonObject
        val response = root.requiredObject("response")
        return CreatePasskeyResponseData(
            rawId = root.requiredString("rawId"),
            authenticatorAttachment = root.optionalString("authenticatorAttachment"),
            type = root.requiredString("type"),
            id = root.requiredString("id"),
            response = CreatePasskeyResponse(
                clientDataJSON = response.requiredString("clientDataJSON"),
                attestationObject = response.requiredString("attestationObject"),
                transports = response.optionalStringArray("transports"),
                authenticatorData = response.optionalString("authenticatorData"),
                publicKeyAlgorithm = (response["publicKeyAlgorithm"] as? JsonPrimitive)?.longOrNull,
                publicKey = response.optionalString("publicKey"),
            ),
            clientExtensionResults = (root["clientExtensionResults"] as? JsonObject)
                ?.let(::parseCreateExtensions) ?: CreatePasskeyExtension(),
            username = username,
        )
    }

    fun parseGetResponse(responseJson: String): GetPasskeyAuthenticationResponseData {
        val root = Json.parseToJsonElement(responseJson).jsonObject
        val response = root.requiredObject("response")
        return GetPasskeyAuthenticationResponseData(
            authenticatorAttachment = root.optionalString("authenticatorAttachment"),
            id = root.requiredString("id"),
            rawId = root.requiredString("rawId"),
            response = GetPasskeyAuthenticationResponse(
                clientDataJSON = response.requiredString("clientDataJSON"),
                authenticatorData = response.requiredString("authenticatorData"),
                signature = response.requiredString("signature"),
                userHandle = response.optionalString("userHandle"),
            ),
            type = root.requiredString("type"),
            clientExtensionResults = (root["clientExtensionResults"] as? JsonObject)?.let(::parseGetExtensions),
            username = "",
        )
    }

    private fun parseCreateExtensions(json: JsonObject) = CreatePasskeyExtension(
        credProps = (json["credProps"] as? JsonObject)?.let {
            CreatePasskeyExtensionProps(rk = (it["rk"] as? JsonPrimitive)?.booleanOrNull ?: false)
        },
        prf = (json["prf"] as? JsonObject)?.let(::parsePrfOutput),
        largeBlob = (json["largeBlob"] as? JsonObject)?.let {
            LargeBlobExtensionRegistrationOutput(supported = (it["supported"] as? JsonPrimitive)?.booleanOrNull)
        },
    )

    private fun parseGetExtensions(json: JsonObject) = AuthPasskeyExtensionResult(
        appid = (json["appid"] as? JsonPrimitive)?.booleanOrNull,
        prf = (json["prf"] as? JsonObject)?.let(::parsePrfOutput),
        largeBlob = (json["largeBlob"] as? JsonObject)?.let { lb ->
            val blob = lb.optionalString("blob")?.let { encoded ->
                try { Base64Url.decode(encoded) } catch (_: IllegalArgumentException) { null }
            }
            LargeBlobExtensionAuthOutput(blob = blob, written = (lb["written"] as? JsonPrimitive)?.booleanOrNull)
        },
    )

    private fun parsePrfOutput(json: JsonObject): PrfExtensionOutput {
        val results = (json["results"] as? JsonObject)
            ?.mapValues { (_, v) -> (v as? JsonPrimitive)?.contentOrNull }
            ?.takeIf { it.isNotEmpty() }
        return PrfExtensionOutput(
            enabled = (json["enabled"] as? JsonPrimitive)?.booleanOrNull,
            results = results?.let { HashMap<String?, String?>(it) },
        )
    }

    // ------------------------------------------------------------------ helpers

    private fun JsonObject.optionalString(key: String): String? =
        (this[key] as? JsonPrimitive)?.takeUnless { it is JsonNull }?.contentOrNull

    private fun JsonObject.optionalStringArray(key: String): List<String>? =
        (this[key])?.takeUnless { it is JsonNull }?.jsonArray?.map { it.jsonPrimitive.content }

    private fun JsonObject.requiredString(key: String): String =
        optionalString(key) ?: throw missing(key)

    private fun JsonObject.requiredObject(key: String): JsonObject =
        (this[key] as? JsonObject) ?: throw missing(key)

    private fun missing(field: String) = PasskeyOperationException(
        errorType = PasskeyErrorType.INVALID_RESPONSE,
        message = "Missing $field in provider response",
        details = "The credential provider returned JSON without the required field '$field'",
    )
}
