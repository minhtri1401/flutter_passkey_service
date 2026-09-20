package com.example.flutter_passkey_service

import java.io.ByteArrayOutputStream

/**
 * Minimal base64url (RFC 4648 §5) codec.
 *
 * Implemented by hand so it runs in plain JVM unit tests (android.util.Base64 is a stub there)
 * and on minSdk 23 (java.util.Base64 needs API 26).
 */
internal object Base64Url {
    private const val ALPHABET =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

    /** Encodes without padding, using `-` and `_`. */
    fun encode(bytes: ByteArray): String {
        val sb = StringBuilder((bytes.size + 2) / 3 * 4)
        var i = 0
        while (i < bytes.size) {
            val b0 = bytes[i].toInt() and 0xFF
            val b1 = if (i + 1 < bytes.size) bytes[i + 1].toInt() and 0xFF else -1
            val b2 = if (i + 2 < bytes.size) bytes[i + 2].toInt() and 0xFF else -1

            sb.append(ALPHABET[b0 shr 2])
            sb.append(ALPHABET[((b0 and 0x03) shl 4) or (if (b1 >= 0) b1 shr 4 else 0)])
            if (b1 >= 0) sb.append(ALPHABET[((b1 and 0x0F) shl 2) or (if (b2 >= 0) b2 shr 6 else 0)])
            if (b2 >= 0) sb.append(ALPHABET[b2 and 0x3F])
            i += 3
        }
        return sb.toString()
    }

    /**
     * Decodes base64url or standard base64, with or without `=` padding.
     * @throws IllegalArgumentException on any character outside both alphabets.
     */
    fun decode(input: String): ByteArray {
        val clean = input.trimEnd('=')
        val out = ByteArrayOutputStream(clean.length * 3 / 4)
        var buffer = 0
        var bits = 0
        for (c in clean) {
            val value = when (c) {
                in 'A'..'Z' -> c - 'A'
                in 'a'..'z' -> c - 'a' + 26
                in '0'..'9' -> c - '0' + 52
                '-', '+' -> 62
                '_', '/' -> 63
                else -> throw IllegalArgumentException("Invalid base64url character: '$c'")
            }
            buffer = (buffer shl 6) or value
            bits += 6
            if (bits >= 8) {
                bits -= 8
                out.write((buffer shr bits) and 0xFF)
            }
        }
        return out.toByteArray()
    }
}
