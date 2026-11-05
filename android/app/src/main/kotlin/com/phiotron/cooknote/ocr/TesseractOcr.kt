package com.phiotron.cooknote.ocr

import android.content.Context
import android.os.SystemClock
import com.googlecode.tesseract.android.TessBaseAPI
import com.googlecode.tesseract.android.TessBaseAPI.PageIteratorLevel

/**
 * One Tesseract instance, reused across pages (init loads ~4.6 MB of models).
 *
 * NOT thread-safe: every method except [stop] must run on the single OCR
 * worker thread (see [OcrPlugin]). [stop] may be called from any thread.
 */
internal class TesseractOcr(context: Context) {

    companion object {
        const val DEFAULT_LANGUAGES = "vie+eng"
        private val ALLOWED_LANGUAGES = setOf("vie+eng", "vie", "eng", "eng+vie")
    }

    private val installer = TessDataInstaller(context)

    private val lock = Any()

    @Volatile
    private var api: TessBaseAPI? = null
    private var apiLanguages: String? = null

    /** Installs data and initialises Tesseract; returns quickly when done before. */
    fun warmUp(languages: String = DEFAULT_LANGUAGES) {
        apiFor(languages)
    }

    /**
     * Recognises one image file. Returns the map documented in
     * `lib/src/scan/android_tesseract_engine.dart` (channel protocol).
     * [isCancelled] is checked between stages; [stop] aborts the LSTM pass.
     */
    fun recognize(
        path: String,
        languages: String,
        pageSegMode: Int,
        isCancelled: () -> Boolean,
    ): Map<String, Any?> {
        val started = SystemClock.elapsedRealtime()
        val image = ImagePreprocessor.prepare(path)
        if (isCancelled()) throw OcrError("cancelled", "Cancelled")

        val tess = apiFor(languages)
        tess.pageSegMode = pageSegMode
        tess.setImage(image.gray, image.width, image.height, 1, image.width)
        // getHOCRText is the only call that runs Recognize() with a monitor,
        // so it is the one [stop] can abort (getUTF8Text ignores stop()).
        // The hOCR string itself is discarded; lines come from the iterator.
        val hocr = tess.getHOCRText(0)
        if (isCancelled()) {
            tess.clear()
            throw OcrError("cancelled", "Cancelled")
        }

        val lines = ArrayList<Map<String, Any?>>()
        if (hocr != null) {
            val it = tess.resultIterator
            if (it != null) {
                try {
                    it.begin()
                    var block = -1
                    do {
                        if (it.isAtBeginningOf(PageIteratorLevel.RIL_BLOCK)) block++
                        val line = it.getUTF8Text(PageIteratorLevel.RIL_TEXTLINE)?.trim()
                        if (line.isNullOrEmpty()) continue
                        val conf = it.confidence(PageIteratorLevel.RIL_TEXTLINE)
                        val box = it.getBoundingBox(PageIteratorLevel.RIL_TEXTLINE)
                        lines.add(
                            mapOf(
                                "text" to line,
                                "confidence" to (conf / 100.0).coerceIn(0.0, 1.0),
                                "block" to maxOf(block, 0),
                                "box" to normalizedBox(box, image),
                            ),
                        )
                    } while (it.next(PageIteratorLevel.RIL_TEXTLINE))
                } finally {
                    it.delete()
                }
            }
        }
        tess.clear()

        return mapOf(
            "lines" to lines,
            "width" to image.sourceWidth,
            "height" to image.sourceHeight,
            "elapsedMs" to (SystemClock.elapsedRealtime() - started).toInt(),
            "engine" to "tesseract ${tess.version} (${tess.libraryFlavor}) $languages " +
                TessDataInstaller.DATA_VERSION,
        )
    }

    /**
     * Aborts a running recognition. Safe from any thread: [lock] guarantees
     * [release] never recycles the instance while `stop` touches it (stop on a
     * recycled TessBaseAPI throws / would use a freed native pointer).
     */
    fun stop() {
        synchronized(lock) { api?.stop() }
    }

    /** Frees the native instance (tens of MB). Next call re-initialises. */
    fun release() {
        synchronized(lock) {
            api?.recycle()
            api = null
            apiLanguages = null
        }
    }

    private fun apiFor(languages: String): TessBaseAPI {
        if (languages !in ALLOWED_LANGUAGES) {
            throw OcrError("invalid_args", "Unsupported languages: $languages")
        }
        api?.let { if (apiLanguages == languages) return it }
        release()
        val dataPath = installer.ensureInstalled()
        val tess = TessBaseAPI()
        // tessdata_fast ships LSTM models only (no legacy engine data).
        if (!tess.init(dataPath.absolutePath, languages, TessBaseAPI.OEM_LSTM_ONLY)) {
            tess.recycle()
            throw OcrError("init_failed", "Tesseract init failed for $languages")
        }
        synchronized(lock) {
            api = tess
            apiLanguages = languages
        }
        return tess
    }

    /** Line box as [left, top, right, bottom] in 0..1 of the upright source image. */
    private fun normalizedBox(box: IntArray?, image: PreparedImage): List<Double>? {
        if (box == null || box.size < 4) return null
        val cw = image.contentWidth.toDouble()
        val ch = image.contentHeight.toDouble()
        fun nx(v: Int) = ((v - image.border) / cw).coerceIn(0.0, 1.0)
        fun ny(v: Int) = ((v - image.border) / ch).coerceIn(0.0, 1.0)
        return listOf(nx(box[0]), ny(box[1]), nx(box[2]), ny(box[3]))
    }
}
