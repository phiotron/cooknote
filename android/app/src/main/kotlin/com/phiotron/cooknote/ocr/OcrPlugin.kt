package com.phiotron.cooknote.ocr

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicInteger

/**
 * MethodChannel `com.phiotron.cooknote/ocr` (protocol documented in
 * `lib/src/scan/android_tesseract_engine.dart`).
 *
 * All OCR/PDF work runs on ONE background thread, in call order; results are
 * posted back on the main thread. `cancel` aborts the running call and every
 * call queued before it (they fail with code `cancelled`).
 *
 * Privacy (D-002/D-003, S-60): never logs recognised text or file paths.
 */
class OcrPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.phiotron.cooknote/ocr"
        private const val TAG = "CookNoteOcr"
        private const val MAX_PDF_PAGES = 10
    }

    private var channel: MethodChannel? = null
    private var executor: ExecutorService? = null
    private var ocr: TesseractOcr? = null
    private var pdf: PdfPageRenderer? = null
    private val main = Handler(Looper.getMainLooper())

    /** Bumped by `cancel`; a call captured an older value => cancelled. */
    private val cancelEpoch = AtomicInteger(0)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        ocr = TesseractOcr(context)
        pdf = PdfPageRenderer(context)
        executor = Executors.newSingleThreadExecutor { r -> Thread(r, "cooknote-ocr") }
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        cancelEpoch.incrementAndGet()
        val engine = ocr
        engine?.stop()
        executor?.let { ex ->
            ex.execute { engine?.release() }
            ex.shutdown()
        }
        executor = null
        ocr = null
        pdf = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val engine = ocr
        val renderer = pdf
        if (engine == null || renderer == null) {
            result.error("unavailable", "OCR plugin detached", null)
            return
        }
        when (call.method) {
            "recognize" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrEmpty()) {
                    result.error("invalid_args", "path is required", null)
                    return
                }
                val languages = call.argument<String>("languages") ?: TesseractOcr.DEFAULT_LANGUAGES
                // 3 = PSM_AUTO (Tesseract default); 6 = single block; 11 = sparse text.
                val psm = call.argument<Int>("pageSegMode") ?: 3
                val epoch = cancelEpoch.get()
                runAsync(result) {
                    if (cancelEpoch.get() != epoch) throw OcrError("cancelled", "Cancelled")
                    engine.recognize(path, languages, psm) { cancelEpoch.get() != epoch }
                }
            }
            "renderPdf" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrEmpty()) {
                    result.error("invalid_args", "path is required", null)
                    return
                }
                val maxPages = (call.argument<Int>("maxPages") ?: MAX_PDF_PAGES)
                    .coerceIn(1, MAX_PDF_PAGES)
                val epoch = cancelEpoch.get()
                runAsync(result) {
                    if (cancelEpoch.get() != epoch) throw OcrError("cancelled", "Cancelled")
                    renderer.render(path, maxPages)
                }
            }
            "warmUp" -> runAsync(result) {
                engine.warmUp()
                null
            }
            "cancel" -> {
                cancelEpoch.incrementAndGet()
                engine.stop()
                result.success(null)
            }
            "release" -> runAsync(result) {
                engine.release()
                null
            }
            else -> result.notImplemented()
        }
    }

    private fun runAsync(result: MethodChannel.Result, work: () -> Any?) {
        val ex = executor
        if (ex == null) {
            result.error("unavailable", "OCR plugin detached", null)
            return
        }
        ex.execute {
            try {
                val value = work()
                main.post { result.success(value) }
            } catch (e: OcrError) {
                main.post { result.error(e.code, e.message, null) }
            } catch (e: OutOfMemoryError) {
                main.post { result.error("image_too_large", "Out of memory", null) }
            } catch (e: Throwable) {
                Log.w(TAG, "OCR failed: ${e.javaClass.simpleName}")
                main.post { result.error("ocr_failed", e.javaClass.simpleName, null) }
            }
        }
    }
}
