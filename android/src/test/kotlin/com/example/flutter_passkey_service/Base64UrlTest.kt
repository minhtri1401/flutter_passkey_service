package com.example.flutter_passkey_service

import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class Base64UrlTest {
    @Test
    fun encode_omitsPadding_and_usesUrlAlphabet() {
        assertEquals("AQIDBAU", Base64Url.encode(byteArrayOf(1, 2, 3, 4, 5)))
        // 0xFB 0xFF -> "-_8" in the URL alphabet ("+/8" in standard)
        assertEquals("-_8", Base64Url.encode(byteArrayOf(0xFB.toByte(), 0xFF.toByte())))
        assertEquals("", Base64Url.encode(byteArrayOf()))
    }

    @Test
    fun decode_acceptsUrlAndStandardAlphabets_withOrWithoutPadding() {
        assertContentEquals(byteArrayOf(1, 2, 3, 4, 5), Base64Url.decode("AQIDBAU"))
        assertContentEquals(byteArrayOf(1, 2, 3, 4, 5), Base64Url.decode("AQIDBAU="))
        assertContentEquals(byteArrayOf(0xFB.toByte(), 0xFF.toByte()), Base64Url.decode("-_8"))
        assertContentEquals(byteArrayOf(0xFB.toByte(), 0xFF.toByte()), Base64Url.decode("+/8="))
        assertContentEquals(byteArrayOf(), Base64Url.decode(""))
    }

    @Test
    fun roundTrip_32RandomBytes() {
        val bytes = ByteArray(32) { (it * 7 + 3).toByte() }
        assertContentEquals(bytes, Base64Url.decode(Base64Url.encode(bytes)))
    }

    @Test
    fun decode_rejectsInvalidCharacters() {
        assertFailsWith<IllegalArgumentException> { Base64Url.decode("AQ!D") }
    }
}
