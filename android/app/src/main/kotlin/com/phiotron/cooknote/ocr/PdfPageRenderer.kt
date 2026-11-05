package com.phiotron.cooknote.ocr

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.IOException
import kotlin.math.max

/**
 * Renders PDF pages to JPEG files for OCR (AC-23) with the framework
 * [PdfRenderer] (API 21): no extra library, no permission.
 *
 * Output goes to `cacheDir/ocr_pdf/`, which is emptied at the start of every
 * call, so the Dart side must use (or copy) the files before the next call.
 */
internal class PdfPageRenderer(private val context: Context) {

    companion object {
        /** Long side in px: ~256 DPI for A4, the top of the OCR range. */
        const val TARGET_LONG = ImagePreprocessor.MAX_LONG
        const val JPEG_QUALITY = 95
    }

    /** Returns `{"pages": [path...], "pageCount": total}`. Blocking. */
    fun render(path: String, maxPages: Int): Map<String, Any?> {
        val file = File(path)
        if (!file.isFile) throw OcrError("pdf_unreadable", "No such file")
        val outDir = File(context.cacheDir, "ocr_pdf")
        outDir.deleteRecursively()
        if (!outDir.mkdirs()) throw OcrError("pdf_unreadable", "Cannot create $outDir")

        val pfd = try {
            ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        } catch (e: IOException) {
            throw OcrError("pdf_unreadable", e.message ?: "Cannot open")
        }
        val renderer = try {
            PdfRenderer(pfd)
        } catch (e: SecurityException) {
            pfd.close()
            throw OcrError("pdf_protected", "Password-protected PDF")
        } catch (e: IOException) {
            pfd.close()
            throw OcrError("pdf_unreadable", e.message ?: "Not a PDF")
        }

        renderer.use { pdf ->
            val total = pdf.pageCount
            if (total <= 0) throw OcrError("pdf_unreadable", "No pages")
            val stamp = System.currentTimeMillis()
            val out = ArrayList<String>()
            for (i in 0 until minOf(total, maxPages)) {
                pdf.openPage(i).use { page ->
                    val scale = TARGET_LONG.toFloat() / max(page.width, page.height)
                    val w = max(1, (page.width * scale).toInt())
                    val h = max(1, (page.height * scale).toInt())
                    val bmp = try {
                        Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                    } catch (e: OutOfMemoryError) {
                        throw OcrError("image_too_large", "Out of memory rendering page")
                    }
                    try {
                        // PDF pages are transparent by default; OCR wants white paper.
                        bmp.eraseColor(Color.WHITE)
                        val m = Matrix().apply { setScale(scale, scale) }
                        page.render(bmp, null, m, PdfRenderer.Page.RENDER_MODE_FOR_PRINT)
                        val target = File(outDir, "page-$stamp-${i + 1}.jpg")
                        target.outputStream().use {
                            bmp.compress(Bitmap.CompressFormat.JPEG, JPEG_QUALITY, it)
                        }
                        out.add(target.absolutePath)
                    } finally {
                        bmp.recycle()
                    }
                }
            }
            return mapOf("pages" to out, "pageCount" to total)
        }
    }
}
