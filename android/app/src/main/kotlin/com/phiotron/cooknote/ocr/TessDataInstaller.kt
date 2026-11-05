package com.phiotron.cooknote.ocr

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.FlutterInjector
import java.io.File

/**
 * Copies the bundled `assets/tessdata/<lang>.traineddata` files (Flutter
 * assets) to a real directory, because Tesseract needs file paths.
 *
 * Target: `noBackupFilesDir/tesseract/tessdata/`. `noBackupFilesDir` instead of
 * `filesDir` so Android Auto Backup (AC-56, on for the DB) does not upload
 * ~4.6 MB of data that ships inside the APK anyway.
 *
 * A stamp file records [DATA_VERSION] plus the app's `lastUpdateTime`, so the
 * data is copied once per install/update and never on later scans. Each file
 * is written to a temp file first and renamed, so a crash mid-copy never
 * leaves a truncated `.traineddata` that Tesseract would choke on.
 */
internal class TessDataInstaller(private val context: Context) {

    companion object {
        /** tessdata_fast commit the bundled files come from (2026-11-05). */
        const val DATA_VERSION = "tessdata_fast@87416418"
        val LANGUAGES = listOf("vie", "eng")
        private const val STAMP = ".installed"
    }

    /** Directory to pass to `TessBaseAPI.init` (the parent of `tessdata/`). */
    val dataPath: File = File(context.noBackupFilesDir, "tesseract")

    private val tessdataDir = File(dataPath, "tessdata")

    /** Ensures all [LANGUAGES] are installed; returns [dataPath]. Blocking. */
    @Synchronized
    fun ensureInstalled(): File {
        val stamp = File(tessdataDir, STAMP)
        val expected = "$DATA_VERSION/${lastUpdateTime()}"
        val complete = LANGUAGES.all { File(tessdataDir, "$it.traineddata").length() > 0 }
        if (complete && stamp.isFile && stamp.readText() == expected) return dataPath

        if (!tessdataDir.isDirectory && !tessdataDir.mkdirs()) {
            throw OcrError("init_failed", "Cannot create $tessdataDir")
        }
        val loader = FlutterInjector.instance().flutterLoader()
        for (lang in LANGUAGES) {
            val key = loader.getLookupKeyForAsset("assets/tessdata/$lang.traineddata")
            val target = File(tessdataDir, "$lang.traineddata")
            val tmp = File(tessdataDir, "$lang.traineddata.tmp")
            context.assets.open(key).use { input ->
                tmp.outputStream().use { output -> input.copyTo(output, 1 shl 16) }
            }
            if (target.exists()) target.delete()
            if (!tmp.renameTo(target)) {
                throw OcrError("init_failed", "Cannot install $lang.traineddata")
            }
        }
        stamp.writeText(expected)
        return dataPath
    }

    private fun lastUpdateTime(): Long = try {
        val pm = context.packageManager
        val info = if (Build.VERSION.SDK_INT >= 33) {
            pm.getPackageInfo(context.packageName, PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.getPackageInfo(context.packageName, 0)
        }
        info.lastUpdateTime
    } catch (e: PackageManager.NameNotFoundException) {
        0L
    }
}

/** Error reported to Dart as a `PlatformException` with [code]. */
internal class OcrError(val code: String, message: String) : Exception(message)
