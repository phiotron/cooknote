package com.phiotron.cooknote

import com.phiotron.cooknote.ocr.OcrPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // On-device OCR (F-04): Tesseract4Android behind a MethodChannel.
        flutterEngine.plugins.add(OcrPlugin())
    }
}
