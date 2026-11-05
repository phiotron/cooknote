# [A004-cooknote] OCR Android (Tesseract) — báo cáo phiên con · 2026-11-05

Phiên điều phối #1. Brief: bộ nhận chữ trên máy cho Android + giao diện Dart chung để iOS Vision cắm vào ở #2.
Số đo chi tiết: `docs/audits/OCR-ANDROID-BUILD-2026-11-05.md`.

## Đã làm
1. **Nguồn thư viện đã kiểm:** Tesseract4Android 4.9.0 **chỉ có trên JitPack** (Maven Central 0 kết quả / 404). Thêm JitPack bằng
   `exclusiveContent` chỉ cho group `cz.adaptech.tesseract4android`. Biến thể **openmp** (một instance, A13 có 8 lõi; đổi về
   standard = bỏ `-openmp` ở một dòng). AAR không có quy tắc R8 → thêm `android/app/proguard-rules.pro`.
2. **tessdata_fast** `vie` (531 275 B) + `eng` (4 113 088 B) vào `assets/tessdata/`. `vie` nhỏ nhưng KHÔNG hỏng: mạng LSTM
   433 KB ≈ `eng` 402 KB; nhỏ vì từ điển `vie` chỉ 67 KB (eng 3,7 MB). Cả hai chỉ có LSTM → khởi tạo `OEM_LSTM_ONLY`.
3. **Kotlin** (`android/app/src/main/kotlin/com/phiotron/cooknote/ocr/`):
   - `TessDataInstaller` chép tessdata ra `noBackupFilesDir/tesseract/tessdata/` lần đầu (dấu `DATA_VERSION` + `lastUpdateTime`
     của app; ghi file tạm rồi đổi tên). Dùng `noBackupFilesDir` thay `filesDir` (brief) để Auto Backup (AC-56) không mang
     4,6 MB dữ liệu vốn có trong APK.
   - `ImagePreprocessor`: xoay/lật theo EXIF, cạnh dài 2000–3000 px (giảm mẫu lúc giải mã cho đỡ RAM, ảnh nhỏ phóng ≤ 2×),
     xám (luma), viền trắng 10 px; nhị phân hoá để Tesseract tự làm (Otsu) như khảo sát mục 4.
   - `TesseractOcr`: một `TessBaseAPI` dùng lại giữa các trang, `vie+eng`, psm mặc định 3; chạy nhận dạng qua `getHOCRText(0)`
     vì đó là lời gọi duy nhất có monitor nên `stop()` huỷ được (`getUTF8Text` của thư viện bỏ qua `stop()` — đã đọc mã C++);
     trả từng dòng (RIL_TEXTLINE) + độ tin cậy 0..1 + số khối + hộp bao chuẩn hoá. Khoá giữa `stop()` và `recycle()`.
   - `PdfPageRenderer`: AC-23 PDF bằng `android.graphics.pdf.PdfRenderer` có sẵn (không gói mới, không quyền), ≤ 10 trang,
     cạnh dài 3000 px, nền trắng, JPEG 95 vào `cacheDir/ocr_pdf/`; PDF có mật khẩu → mã `pdf_protected`.
   - `OcrPlugin` (MethodChannel `com.phiotron.cooknote/ocr`, một luồng nền, kết quả về luồng chính, `cancel` huỷ cả hàng đợi,
     không log chữ hay đường dẫn) đăng ký trong `MainActivity.configureFlutterEngine`.
4. **Dart** (`lib/src/scan/`): `ocr_engine.dart` (interface), `android_tesseract_engine.dart`, `fake_ocr_engine.dart`,
   `scan_pipeline.dart` (nhiều ảnh ≤ 10 + PDF → nối `line_classifier.dart`), `ocr_providers.dart` (`ocrEngineProvider`),
   `ocr_accuracy.dart` (độ chính xác ký tự, có bản bỏ dấu, tự dựng sẵn dấu tiếng Việt vì Dart không có NFC),
   `ocr_licenses.dart` + `assets/tessdata/LICENSES-ocr.txt` (S-70).
5. **Test** (`test/scan/`): 44 đạt, 2 bỏ qua (AC-25 chưa có mẫu thật). Bộ mẫu AC-25 chạy lại được: `test/scan/ocr_samples/`.
   Toàn bộ `flutter test` (cây chung, 2026-11-05 10:55): 385 đạt, 3 bỏ qua. `flutter analyze`: No issues found.
6. **APK release** build được (bản HEAD + chỉ phần OCR, xem "Việc dở" về build cây chung), số đo bên dưới.

## File đã đổi
- Sửa: `android/build.gradle.kts`, `android/app/build.gradle.kts`, `android/app/src/main/kotlin/com/phiotron/cooknote/MainActivity.kt`
- Mới: `android/app/proguard-rules.pro`, `android/app/src/main/kotlin/com/phiotron/cooknote/ocr/{OcrPlugin,TesseractOcr,ImagePreprocessor,PdfPageRenderer,TessDataInstaller}.kt`
- Mới: `assets/tessdata/{vie,eng}.traineddata`, `assets/tessdata/LICENSES-ocr.txt`
- Mới: `lib/src/scan/{ocr_engine,android_tesseract_engine,fake_ocr_engine,scan_pipeline,ocr_providers,ocr_accuracy,ocr_licenses}.dart`
- Mới: `test/scan/{ocr_accuracy,scan_pipeline,android_tesseract_engine,ocr_licenses}_test.dart`, `test/scan/ocr_samples/` (README + ví dụ)
- Mới: `docs/audits/OCR-ANDROID-BUILD-2026-11-05.md`, file này
- KHÔNG đổi: `pubspec.yaml/.lock` (dòng `assets/tessdata/` đã có), `AndroidManifest.xml`, `ios/`, `.github/`, `lib/src/features/`, `lib/l10n/`.

## Nguồn + giấy phép
| Thành phần | Phiên bản | Nguồn | Giấy phép |
|---|---|---|---|
| Tesseract4Android (openmp) | 4.9.0 | JitPack `cz.adaptech.tesseract4android:tesseract4android-openmp:4.9.0` | Apache-2.0 |
| Tesseract OCR (trong AAR) | 5.5.1 | github.com/tesseract-ocr/tesseract | Apache-2.0 |
| Leptonica (trong AAR) | 1.85.0 | leptonica.org | BSD-2 (Leptonica) |
| libjpeg (trong AAR) | 9f | ijg.org | IJG (phải ghi "based in part on the work of the Independent JPEG Group" — đã có trong file giấy phép) |
| libpng (trong AAR) | 1.6.48 | libpng.org | PNG Reference Library License v2 |
| LLVM OpenMP (tĩnh, trong AAR) | NDK r27 | llvm.org | Apache-2.0 WITH LLVM-exception |
| tessdata_fast `vie`, `eng` | commit `87416418` | github.com/tesseract-ocr/tessdata_fast | Apache-2.0 |
Không có GPL/AGPL. Không có file NOTICE ở ba kho Apache (đã kiểm 404). Văn bản đầy đủ: `assets/tessdata/LICENSES-ocr.txt`.
**Cần làm:** gọi `registerOcrLicenses()` (`lib/src/scan/ocr_licenses.dart`) trong `main()` trước `runApp` — `lib/main.dart` ngoài
phạm vi phiên này.

## Dung lượng APK (byte thật; trước = HEAD `bbc5b8d`, sau = HEAD + file OCR, build trong worktree tách rời)
| APK | Trước | Sau | Tăng |
|---|---|---|---|
| Đủ kiến trúc | 71 576 158 | 97 357 938 | +25,8 MB |
| armeabi-v7a | 23 034 002 | 31 630 190 | +8,6 MB |
| arm64-v8a | 24 641 862 | 35 412 954 | +10,8 MB |
| x86_64 | 26 191 902 | 37 440 482 | +11,2 MB |
- NFR Play một kiến trúc ≤ 45 MB: **đạt** (35,4 / 31,6 MB). NFR APK đủ kiến trúc ≤ 80 MB: **KHÔNG đạt** (97,4 MB) vì `.so` lưu không
  nén. Thử `useLegacyPackaging = true` (không commit): **45,1 MB**. Ba phương án + đề xuất: audit mục 7 — **cần phiên điều phối chốt**.
- **Vấp:** build tăng dần của Flutter không đưa file mới trong `assets/tessdata/` vào APK; phải `flutter clean` (audit mục 5).

## Quyền (aapt2) — giống hệt trước/sau, APK đủ kiến trúc và split armeabi-v7a
```
package: com.phiotron.cooknote
permission: com.phiotron.cooknote.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
uses-permission: name='com.phiotron.cooknote.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
```
OCR không thêm quyền (S-40). Manifest AAR chỉ có `uses-sdk`.

## 16 KB (S-11) và 32-bit
- `.so` 32-bit **có**: `lib/armeabi-v7a/lib{tesseract,leptonica,jpeg,pngx}.so` (ELF32, căn 4 KB — hợp lệ cho 32-bit).
- Mọi `.so` 64-bit (arm64-v8a, x86_64) căn LOAD ≥ 0x4000 (`llvm-readelf -lW`); `zipalign -c -P 16 -v 4` APK đủ kiến trúc +
  split arm64: **Verification successful**. **Đạt.**
- R8: `dexdump` xác nhận `TessBaseAPI.mNativeData/onProgressValues/nativeGetHOCRText/nativeStop` còn nguyên.

## API Dart cho UI #2
```dart
final engine = ref.read(ocrEngineProvider);           // null → ẩn "Quét ảnh" (nền tảng chưa hỗ trợ)
await engine?.warmUp();                                // khi mở màn quét (chép dữ liệu + khởi tạo, lần đầu ~1–2 s?)
final result = await scanImages(engine!, paths,        // ≤ kMaxScanPages (10); ném ArgumentError nếu 0 hoặc > 10
    onProgress: (done, total) => ...);                 // "Đang đọc trang 2/5"
final (pdf, result) = await scanPdf(engine, pdfPath);  // pdf.truncated → báo "chỉ quét 10 trang đầu"
result.lines   // List<ScannedLine>: .suggestion (ClassifiedLine: text đã làm sạch + LineRole + confidence),
               // .ocr (OcrLine: text gốc, confidence 0..1, block, box 0..1), .page, .isDoubtful (tô nhạt)
result.plainText                                       // chép toàn bộ chữ (nút "Sao chép chữ" — cần cho đo AC-25)
await engine.cancel();                                 // nút Huỷ → scanImages ném OcrException(isCancelled)
await engine.dispose();                                // rời màn quét (giải phóng vài chục MB)
```
- Lỗi: `OcrException.code` ∈ `OcrErrorCode` (`image_unreadable`, `image_too_large`, `pdf_unreadable`, `pdf_protected`,
  `init_failed`, `unavailable`, `ocr_failed`, `cancelled`) → map sang chuỗi `.arb` ở #2.
- Ảnh PDF vẽ ra bị xoá ở lần `renderPdf` sau: muốn giữ làm ảnh công thức (AC-24) thì chép qua ImageStore trước.
- Widget test: `ocrEngineProvider.overrideWithValue(FakeOcrEngine.fromText({...}, delay: ...))`.
- Ngưỡng tô nhạt `kDoubtfulOcrConfidence = 0.6` là đề xuất, chỉnh sau khi thử máy.

## API cho iOS Vision #2
Hai cách, chọn một:
1. **Dùng chung lớp Dart (khuyên):** viết Swift handler cho cùng kênh `com.phiotron.cooknote/ocr` với đúng giao thức trong
   doc của `android_tesseract_engine.dart` (`recognize` → `{lines:[{text, confidence 0..1, block, box:[l,t,r,b] gốc trên-trái]}, width,
   height, elapsedMs, engine}`, `renderPdf` → `{pages, pageCount}`, `warmUp`/`cancel`/`release`, lỗi = mã `OcrErrorCode`). Khi đó
   chỉ cần thêm `TargetPlatform.iOS` vào `ocrEngineProvider` (có thể đổi tên lớp thành `ChannelOcrEngine`).
   Lưu ý Vision: `boundingBox` gốc dưới-trái → `top = 1 - maxY`; `VNRecognizedText.confidence` đã 0..1; ngôn ngữ
   `recognitionLanguages = ["vi-VT", "en-US"]` (kiểm mã `vi` mà Vision hỗ trợ trên iOS đích — CHƯA kiểm chứng); PDF dùng PDFKit
   `PDFPage.thumbnail(of:for:)` hoặc `CGPDFDocument`.
2. Lớp Dart riêng `implements OcrEngine`, đọc map bằng `OcrPage.fromChannelMap`.
- `assets/tessdata/` (≈ 4,6 MB) cũng bị đóng vào app iOS dù Vision không cần → xem "Việc dở".

## Hướng dẫn Phương tự thử trên Galaxy A13 (KHÔNG adb)
Chưa có UI quét (làm ở #2), nên phần lớn chỉ thử được sau #2. Ngay bây giờ:
1. Khi cây chung build lại được (xem Việc dở): `flutter clean` rồi `flutter build apk --release`, cài
   `build/app/outputs/flutter-apk/app-release.apk` như mọi lần → mở app, dùng bình thường 1 phút:
   **không sập lúc mở** = thư viện native 32-bit nạp được (OCR chỉ nạp khi gọi, nên đây chưa chứng minh Tesseract chạy).
Sau khi #2 có màn quét:
2. In 5 trang tiếng Việt + 5 trang tiếng Anh tự soạn (công thức ngắn, cỡ chữ sách 11–12 pt), chụp bằng camera hệ thống: đủ sáng,
   một ảnh hơi nghiêng, một ảnh có bóng nhẹ.
3. Mỗi trang: Quét ảnh → bấm giờ từ lúc bấm tới khi hiện dòng (NFR ≤ 10 s/trang; ghi lần đầu và lần thứ hai riêng — lần đầu có
   chép dữ liệu). Bấm "Sao chép chữ", dán vào Google Keep/Zalo gửi sang máy tính.
4. Trên máy tính lưu thành `test/scan/ocr_samples/vi-01.ocr.txt`… và gõ chữ chuẩn vào `vi-01.ref.txt`… rồi chạy
   `flutter test test/scan/ocr_accuracy_test.dart` → bảng % đúng + % bỏ dấu; đủ 5+5 trang thì test tự kiểm ngưỡng AC-25.
5. Thử thêm: 10 ảnh một lần (không sập, RAM), ảnh xoay ngang (EXIF), một PDF 2 trang, một PDF có mật khẩu (phải báo lỗi rõ),
   bấm Huỷ giữa trang 2, tắt mạng hoàn toàn (vẫn chạy).
6. Ghi kết quả vào biên bản thử máy thật.

## Việc dở / CHƯA kiểm chứng
- **AC-25 (độ chính xác) và tốc độ trên Galaxy A13: CHƯA kiểm chứng** (không có máy, không adb). Hàm đo + bộ mẫu đã sẵn.
- **Mã Kotlin chưa chạy thật lần nào** (chỉ biên dịch + R8 qua). Các điểm cần thử máy: chép tessdata, `init vie+eng`, EXIF, PDF,
  huỷ, OpenMP trên A55 (nóng máy/pin?).
- **`flutter build apk --release` trên cây chung đang lỗi, không do OCR**: `checkReleaseAarMetadata` — `flutter_local_notifications`
  đòi bật core library desugaring; `receive_sharing_intent` đòi compileSdk 37 (AGP 9.1.0 khuyên tối đa 36). Phiên B đã ghi và chuyển
  cho điều phối (notes/2026-11-05-ios-ci.md mục "Cấu hình Android cần điều phối làm"). Cả hai đều sửa `android/app/build.gradle.kts`
  — file tôi cũng sửa (khối `dependencies` + `proguardFiles`): khi sửa, giữ hai đoạn đó. Số đo APK lấy từ worktree tách rời =
  HEAD `bbc5b8d` + đúng file OCR. **Sau khi sửa phải build lại cây chung (`flutter clean` trước) và kiểm `unzip -l` có tessdata.**
- `android/.kotlin/` (thư mục phiên Kotlin do build tạo) đang hiện là untracked → nên thêm vào `.gitignore` (đang do phiên khác sửa).
- `registerOcrLicenses()` chưa được gọi trong `main()` (ngoài phạm vi).
- tessdata bị đóng vào cả app iOS (Flutter assets chung) nếu iOS dùng Vision: +4,6 MB vô ích. Cách: (a) ở #2 chuyển tessdata
  sang `android/app/src/main/assets/tessdata/` (chỉ Android) và đọc bằng `context.assets` thay vì khoá Flutter — sửa một dòng trong
  `TessDataInstaller` + bỏ dòng pubspec (phiên quản pubspec); hoặc (b) chấp nhận.
- Văn bản PDF có lớp chữ (PDF số, không phải ảnh quét) đang bị vẽ ra ảnh rồi OCR — chậm và kém hơn đọc chữ thẳng; đọc lớp chữ cần
  gói mới (vd `syncfusion_flutter_pdf`/`pdfrx`) → để phiên quản dependency cân nhắc, v1 chấp nhận.
- Tham số thử dần nếu AC-25 kém: psm 6 cho ảnh đã cắt, `thresholding_method` Sauvola, `user_defined_dpi`, tessdata_best (+22 MB).

## Đề xuất cải tiến xưởng
- **Mẫu "kiểm thư viện native"** (S-11) dùng lại cho mọi app: tải AAR → `llvm-readelf -lW` từng `.so` theo ABI → kiểm manifest AAR,
  POM, quy tắc R8 có sẵn chưa → kiểm lại trên APK cuối (`zipalign -c -P 16`). Nên thành checklist trong `playbook/checklists/`.
- **Đo dung lượng "trước/sau" bằng `git worktree add --detach` trong scratchpad**: không đụng thư mục dùng chung, không đổi nhánh,
  và không bị build lỗi do phiên song song khác làm hỏng. Nên ghi vào WORKFLOW cho phiên con song song.
- Khi nhiều phiên con cùng chạm `android/app/build.gradle.kts`, brief nên chỉ định MỘT phiên sở hữu file đó (phiên kia gửi đoạn cần
  thêm qua báo cáo) để khỏi đụng nhau.
- `ocr_accuracy.dart` (Levenshtein + dựng dấu tiếng Việt) và lớp `TessDataInstaller` tái dùng được cho app khác cần OCR/tiếng Việt.
