package com.phiotron.cooknote.ocr

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import java.io.File
import kotlin.math.max
import kotlin.math.min

/**
 * An 8-bit grayscale image ready for Tesseract, with a white border.
 *
 * [contentWidth] x [contentHeight] is the photo after EXIF rotation and
 * scaling; [width] x [height] adds [border] pixels on each side.
 * [sourceWidth] x [sourceHeight] is the EXIF-upright size of the original file.
 */
internal class PreparedImage(
    val gray: ByteArray,
    val width: Int,
    val height: Int,
    val border: Int,
    val sourceWidth: Int,
    val sourceHeight: Int,
) {
    val contentWidth get() = width - 2 * border
    val contentHeight get() = height - 2 * border
}

/**
 * Pre-processing from OCR-RESEARCH-2026-11 section 4, using only framework
 * classes (no extra library):
 * 1. rotate/flip upright from EXIF orientation;
 * 2. long side into [MIN_LONG]..[MAX_LONG] px (down-sample while decoding to
 *    keep memory low on a 32-bit phone, then scale exactly; small images are
 *    enlarged at most 2x);
 * 3. grayscale (luma);
 * 4. [BORDER] px white border.
 * Binarisation is left to Tesseract (Otsu) as the research suggests trying first.
 */
internal object ImagePreprocessor {
    const val MIN_LONG = 2000
    const val MAX_LONG = 3000
    const val BORDER = 10

    fun prepare(path: String): PreparedImage {
        val file = File(path)
        if (!file.isFile) throw OcrError("image_unreadable", "No such file")

        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
            throw OcrError("image_unreadable", "Not a decodable image")
        }

        val orientation = readOrientation(path)
        var sample = 1
        val long = max(bounds.outWidth, bounds.outHeight)
        while (long / (sample * 2) >= MIN_LONG) sample *= 2

        val decoded = try {
            BitmapFactory.decodeFile(
                path,
                BitmapFactory.Options().apply {
                    inSampleSize = sample
                    inPreferredConfig = Bitmap.Config.ARGB_8888
                },
            )
        } catch (e: OutOfMemoryError) {
            throw OcrError("image_too_large", "Out of memory while decoding")
        } ?: throw OcrError("image_unreadable", "Decoding failed")

        val decodedLong = max(decoded.width, decoded.height)
        val scale = when {
            decodedLong > MAX_LONG -> MAX_LONG.toFloat() / decodedLong
            decodedLong < MIN_LONG -> min(2f, MIN_LONG.toFloat() / decodedLong)
            else -> 1f
        }
        val matrix = Matrix()
        if (scale != 1f) matrix.postScale(scale, scale)
        applyExifOrientation(matrix, orientation)

        val upright = if (matrix.isIdentity) {
            decoded
        } else {
            try {
                Bitmap.createBitmap(decoded, 0, 0, decoded.width, decoded.height, matrix, true)
            } catch (e: OutOfMemoryError) {
                decoded.recycle()
                throw OcrError("image_too_large", "Out of memory while scaling")
            }.also { if (it !== decoded) decoded.recycle() }
        }

        try {
            return toGrayWithBorder(upright, swapped(orientation, bounds))
        } finally {
            upright.recycle()
        }
    }

    /** EXIF-upright size of the source file. */
    private fun swapped(orientation: Int, bounds: BitmapFactory.Options): Pair<Int, Int> =
        when (orientation) {
            ExifInterface.ORIENTATION_TRANSPOSE,
            ExifInterface.ORIENTATION_ROTATE_90,
            ExifInterface.ORIENTATION_TRANSVERSE,
            ExifInterface.ORIENTATION_ROTATE_270 -> bounds.outHeight to bounds.outWidth
            else -> bounds.outWidth to bounds.outHeight
        }

    private fun readOrientation(path: String): Int = try {
        ExifInterface(path).getAttributeInt(
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.ORIENTATION_NORMAL,
        )
    } catch (e: Exception) {
        // PNG/WebP without EXIF, or unreadable metadata: treat as upright.
        ExifInterface.ORIENTATION_NORMAL
    }

    private fun applyExifOrientation(m: Matrix, orientation: Int) {
        when (orientation) {
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> m.postScale(-1f, 1f)
            ExifInterface.ORIENTATION_ROTATE_180 -> m.postRotate(180f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> m.postScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> { m.postRotate(90f); m.postScale(-1f, 1f) }
            ExifInterface.ORIENTATION_ROTATE_90 -> m.postRotate(90f)
            ExifInterface.ORIENTATION_TRANSVERSE -> { m.postRotate(-90f); m.postScale(-1f, 1f) }
            ExifInterface.ORIENTATION_ROTATE_270 -> m.postRotate(-90f)
        }
    }

    private fun toGrayWithBorder(bmp: Bitmap, source: Pair<Int, Int>): PreparedImage {
        val w = bmp.width
        val h = bmp.height
        val outW = w + 2 * BORDER
        val outH = h + 2 * BORDER
        val out = ByteArray(outW * outH)
        out.fill(0xFF.toByte())
        val row = IntArray(w)
        for (y in 0 until h) {
            bmp.getPixels(row, 0, w, 0, y, w, 1)
            var o = (y + BORDER) * outW + BORDER
            for (x in 0 until w) {
                val c = row[x]
                val a = c ushr 24
                val r = (c shr 16) and 0xFF
                val g = (c shr 8) and 0xFF
                val b = c and 0xFF
                var lum = (r * 77 + g * 150 + b * 29) shr 8
                // Transparent pixels (PNG screenshots) become white, not black.
                if (a < 255) lum = (lum * a + 255 * (255 - a)) / 255
                out[o++] = lum.toByte()
            }
        }
        return PreparedImage(out, outW, outH, BORDER, source.first, source.second)
    }
}
