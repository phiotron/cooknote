# Khảo sát OCR offline cho CookNote (F-04) — 2026-11

Ngày tra cứu: 2026-11-04 (mọi nguồn dưới đây đều tra ngày này). Phạm vi: nhận chữ NGAY TRÊN MÁY, tiếng Việt có dấu và tiếng Anh, Android gồm armeabi-v7a (Galaxy A13 chạy 32-bit), không quyền INTERNET, không gửi dữ liệu ra ngoài (D-003 loại ML Kit).

Cách đọc: "Đã tra" là có nguồn kèm URL. "CHƯA kiểm chứng" là chưa tra được hoặc chỉ suy ra; cần thử thật. Khảo sát này KHÔNG chạy OCR thật và KHÔNG đo APK, nên không có số đo độ chính xác hay dung lượng APK nào dưới đây là số đo của chúng ta.

## 1. Các lựa chọn

### A. flutter_tesseract_ocr (gói Flutter bọc Tesseract4Android)
- Phiên bản mới nhất 0.4.31; pub.dev ghi "5 months ago" (không có ngày chính xác, tức khoảng giữa năm 2026). Giấy phép BSD-3-Clause. Nền tảng Android, iOS, web. README: "based on Tesseract OCR 4". Nguồn: https://pub.dev/packages/flutter_tesseract_ocr
- Mã nguồn tại github.com/khjde1207/tesseract_ocr: lần đẩy cuối 2026-09-14, 18 issue mở, 68 sao, không lưu trữ (https://api.github.com/repos/khjde1207/tesseract_ocr). Kho này là một fork; mối quan hệ với kho gốc CHƯA kiểm chứng.
- Phần Android dùng file AAR cục bộ không ghi phiên bản (`api(name: 'tesseract4android-release', ext: 'aar')`), minSdk 21, không đặt `abiFilters` (https://raw.githubusercontent.com/khjde1207/tesseract_ocr/master/android/build.gradle). Nên KHÔNG biết bản Tesseract thật bên trong, và CHƯA kiểm chứng AAR đó có 32-bit và có căn 16 KB hay không.
- API theo đường dẫn file (`extractText(path, language: ...)`); dữ liệu ngôn ngữ liệt kê trong `assets/tessdata_config.json` rồi plugin chép ra thư mục tài liệu ở lần chạy đầu (https://pub.dev/packages/flutter_tesseract_ocr, https://pub.dev/packages/tesseract_ocr). README tự nhận chậm hơn ML Kit.
- Issue đã tra (https://api.github.com/repos/khjde1207/tesseract_ocr/issues): #53 (2025-03) dữ liệu huấn luyện không được đọc trên APK release; #44 (2024-02) NullPointerException sau khi phát hành lên Play; #35 (2023-05) tham chiếu null vào TessBaseAPI; #33 (2023-03) app sập khi quét nhiều ảnh liên tiếp; #40 xin API nhận dữ liệu ảnh thay vì file; #56 (2025-07) `extractHocr` treo trên iOS với `vie` (không ảnh hưởng Android). Không thấy issue nào về armeabi-v7a hay 16 KB trong danh sách.
- Quyền: README không nêu; CHƯA kiểm chứng manifest của plugin.

### B. tesseract_ocr (gói Flutter khác)
- 0.5.0, "16 months ago", nhà xuất bản zuraffa.com, BSD-3-Clause, Android và iOS, Tesseract 4.x (Android dùng Tesseract4Android, iOS dùng SwiftyTesseract 4.0.1, có thêm Apple Vision). Nguồn: https://pub.dev/packages/tesseract_ocr
- Cách dùng dữ liệu ngôn ngữ giống A. Bảo trì kém hơn A (16 tháng không cập nhật). Không có thông tin ABI. Không khuyến nghị.

### C. flusseract
- 0.1.3, "2 years ago", MIT, tự biên dịch Tesseract từ nguồn, ABI không nêu, trang có cảnh báo phân tích chưa đủ, 97 lượt tải (https://pub.dev/packages/flusseract). Loại vì bảo trì và rủi ro biên dịch.

### D. Tự bọc Tesseract4Android bằng MethodChannel (Kotlin) — ĐƯỢC ĐỀ XUẤT
- Tesseract4Android 4.9.0 phát hành 2025-06-11 (Tesseract 5.5.1, Leptonica 1.85.0, libpng 1.6.48, thêm `getConfidentText`); 4.8.0 ngày 2024-12-01 thêm hỗ trợ trang 16 KB, minSdk 21, NDK r27c (https://api.github.com/repos/adaptech-cz/Tesseract4Android/releases). Kho: Apache-2.0, 951 sao, 2 issue mở, lần đẩy cuối 2026-02-05, không lưu trữ (https://api.github.com/repos/adaptech-cz/Tesseract4Android). README: https://github.com/adaptech-cz/Tesseract4Android
- 32-bit: file build.gradle không đặt bộ lọc ABI và ghi chú "By default it compiles all available ABIs" (https://raw.githubusercontent.com/adaptech-cz/Tesseract4Android/master/tesseract4android/build.gradle), nghĩa là có armeabi-v7a; issue #79 (2025-09, đã đóng) xác nhận có lib 32-bit nhưng căn 4 KB, điều này không vấn đề với máy 32-bit (trang 16 KB chỉ áp dụng cho máy 64-bit; suy luận, CHƯA kiểm chứng). Thư viện có hai biến thể: `tesseract4android` (một luồng) và `tesseract4android-openmp` (đa luồng, nhanh hơn trên máy nhiều lõi) — README ở trên.
- Issue đã tra (https://api.github.com/repos/adaptech-cz/Tesseract4Android/issues): #71, #79, #80, #83 về căn trang 16 KB (đã đóng); #77, #78 về khởi tạo dữ liệu ngôn ngữ (đường dẫn `tessdata`); PR #87 (2026-08, "Upgrade NDK r27 to r29 for 16 KB") đã đóng, CHƯA biết đã gộp hay không. Không có issue nào nhắc tiếng Việt.
- Tọa độ Maven Central và phiên bản 4.9.0 có xuất hiện trong ví dụ README, nhưng issue #75/#86 nhắc JitPack: CHƯA kiểm chứng kho nào phát hành chính thức; phải kiểm lại trước khi thêm vào Gradle.
- Dung lượng tăng của APK: CHƯA kiểm chứng (không tra được số). Cách đo: dựng một bản APK mẫu `flutter build apk --release --split-per-abi` có và không có thư viện, so file .so của armeabi-v7a.
- Quyền: thư viện chỉ xử lý ảnh trong bộ nhớ nên không nên cần quyền nào; CHƯA kiểm chứng manifest gộp. Phải kiểm bằng aapt2 (lệnh trong CLAUDE.md của app).
- Chi phí: phải tự viết khoảng một lớp Kotlin (khởi tạo TessBaseAPI với `vie+eng`, chạy trên luồng nền, trả danh sách dòng và độ tin cậy) và một lớp Dart gọi MethodChannel. Chưa có số dòng chính xác.

### E. tess-two
- Đã lưu trữ ngày 2022-03-17, "won't be receiving further updates", Tesseract 3.05, Apache-2.0, README đề nghị dùng Tesseract4Android (https://github.com/rmtheis/tess-two). Issue tess-two về sập 32-bit Android 5 và dữ liệu 4.0 không khởi tạo được (qua tìm kiếm, chưa đọc kỹ). LOẠI.

### F. PaddleOCR / ONNX
- paddle_ocr_native 0.1.1 ("3 months ago"): Apache-2.0, offline, ONNX Runtime, mô hình PP-OCRv6 small bản Trung/Anh, thêm khoảng 29 MB, minSdk 26, CHỈ arm64-v8a ("currently ships only arm64-v8a"), không có tiếng Việt trong mô tả, không có quyền. Nguồn: https://pub.dev/packages/paddle_ocr_native. LOẠI: không chạy trên Galaxy A13 32-bit.
- image_text_reader 2.0.1 (MIT, "2 months ago", nhà xuất bản chưa xác minh, PaddleOCR v5 qua ONNX; ngôn ngữ, ABI, dung lượng, quyền đều không nêu; đa ngôn ngữ còn trên lộ trình): https://pub.dev/packages/image_text_reader. LOẠI vì thiếu thông tin ABI và tiếng Việt.
- pp_ocr 0.2.1: hướng Windows (https://pub.dev/packages/pp_ocr). LOẠI. Việc có mô hình PaddleOCR cho tiếng Việt và chạy được 32-bit: CHƯA kiểm chứng.

### G. Tự bọc Tesseract bằng FFI/NDK
- Phải tự biên dịch Tesseract và Leptonica cho 4 ABI; flusseract đã thử và bị bỏ ngỏ. Chi phí cao hơn D mà không thêm lợi ích. LOẠI.

## 2. Dữ liệu ngôn ngữ `vie` và `eng`
Kích thước lấy từ GitHub API ngày 2026-11-04 (số byte của blob, trước khi nén trong APK):

| Bộ | eng | vie | Tổng |
|---|---|---|---|
| tessdata_fast | 4.113.088 B (khoảng 3,9 MiB) | 531.275 B (khoảng 0,5 MiB) | khoảng 4,4 MiB |
| tessdata_best | 15.400.601 B (khoảng 14,7 MiB) | 12.435.550 B (khoảng 11,9 MiB) | khoảng 26,5 MiB |

- Nguồn: https://api.github.com/repos/tesseract-ocr/tessdata_fast/contents/vie.traineddata, .../tessdata_fast/contents/eng.traineddata, .../tessdata_best/contents/vie.traineddata, .../tessdata_best/contents/eng.traineddata. Con số `vie` bản fast nhỏ khác thường (0,5 MiB so với 11,9 MiB của best) nên nên tải file thật và kiểm lại kích thước trước khi dựa vào.
- Giấy phép: tessdata_fast ghi "All data in the repository are licensed under the Apache-2.0" (https://github.com/tesseract-ocr/tessdata_fast). tessdata_best: Apache-2.0 theo đề bài, trang kho tessdata_best CHƯA được tra riêng. Tesseract và Tesseract4Android: Apache-2.0 (Tesseract4Android đã tra; Tesseract lõi theo hiểu biết chung, CHƯA tra trong phiên này).
- `vie` là mô hình riêng, không nằm trong "Latin" (trang tessdata_fast: "all latin-based languages, except vie"), nên cần cả `vie` lẫn `eng`, khởi tạo `vie+eng`. Việc wrapper chấp nhận chuỗi `vie+eng`: CHƯA kiểm chứng.
- Cả hai kho là dữ liệu huấn luyện v4.0.0+ (README Tesseract4Android: cần dữ liệu v4.0.0) và nằm trong thư mục con tên `tessdata`. Bản fast dùng số nguyên, mạng nhỏ, nhanh và kém chính xác hơn một chút; bản best dùng số thực, chậm hơn (https://tesseract-ocr.github.io/tessdoc/Data-Files).

### Đóng gói để chạy offline (không được tải lúc chạy)
1. Đặt `vie.traineddata`, `eng.traineddata` vào `assets/tessdata/` của Flutter (hoặc `android/app/src/main/assets/`).
2. Lần đầu quét, chép ra `context.filesDir/tessdata/` (Tesseract cần đường dẫn file thật, README Tesseract4Android yêu cầu thư mục con `tessdata` và dùng thư mục riêng của app từ Android 10). Ghi dấu phiên bản để chỉ chép lại khi đổi file.
3. Vì README khuyên tải lúc chạy nếu nhiều ngôn ngữ, mà ta CẤM INTERNET, bản fast hai ngôn ngữ (khoảng 4,4 MiB) là hợp lý. Bản best (khoảng 26,5 MiB, sẽ gần gấp đôi sau khi chép ra thư mục riêng trừ khi xóa bản trong asset không được) chỉ chọn nếu số đo AC-25 đòi hỏi.

## 3. Độ chính xác với chữ in tiếng Việt có dấu
- Không tìm được số liệu công bố (tỷ lệ lỗi ký tự) của `vie` bản fast hay best trên chữ in. Mọi con số ước lượng sẽ là bịa nên không đưa vào. CHƯA kiểm chứng.
- Chỉ có định tính: khảo sát năm 2025 về nhận dạng tài liệu tiếng Việt nói độ chính xác còn hạn chế vì dấu thanh và nhiễu (https://arxiv.org/html/2506.05061v1); một bài preprint về sửa dấu sau OCR cho thấy lỗi thường là đúng chữ cái gốc nhưng thiếu hoặc sai dấu (https://www.researchsquare.com/article/rs-10241038, chỉ đọc đoạn trích). Nghĩa là nên đo riêng lỗi dấu (mục 5).
- Tài liệu chính thức: bản best chỉ "slightly better" so với fast (https://tesseract-ocr.github.io/tessdoc/Data-Files).

## 4. Tiền xử lý ảnh nên làm
Nguồn chung: https://tesseract-ocr.github.io/tessdoc/ImproveQuality.html (đã tra). Các bước dưới đây theo tài liệu đó, riêng con số "cạnh dài" là ĐỀ XUẤT của người viết, CHƯA kiểm chứng, cần thử.
1. Xoay: đọc EXIF (android.media.ExifInterface có sẵn, không thêm thư viện) và xoay thẳng; nếu dòng chữ còn nghiêng thì chỉnh góc, vì "skewed pages degrade line segmentation".
2. Thu phóng: Tesseract hoạt động tốt nhất từ khoảng 300 DPI. Ảnh chụp điện thoại 12 MP trở lên dễ quá lớn, cạnh dài khoảng 2000 đến 3000 px là điểm bắt đầu hợp lý để thử (đề xuất). Chữ nhỏ quá thì phóng lên.
3. Thang xám: bắt buộc, nhanh, không mất gì.
4. Nhị phân hóa: Tesseract tự dùng Otsu, kém khi nền không đều; Tesseract 5.0.0 thêm Adaptive Otsu và Sauvola (xem `tesseract --print-parameters | grep thresholding_`). Thử trước với ảnh xám để Tesseract tự làm, nếu kém mới thử Sauvola; việc Tesseract4Android cho đặt biến này: CHƯA kiểm chứng.
5. Viền: thêm viền trắng khoảng 10 px; bỏ viền đen do máy quét hoặc bóng.
6. Chế độ phân trang (psm): mặc định 3 (tự động); thử 6 (một khối đồng nhất) cho ảnh đã cắt, 11 (chữ thưa) cho ghi chú rời.
7. Bật `tessedit_write_images` khi gỡ lỗi để xem ảnh Tesseract thật sự nhận.
Làm các bước này bằng Bitmap/ColorMatrix của Android trong lớp Kotlin để khỏi thêm thư viện; nếu cần thuật toán nặng hơn (Sauvola ngoài Tesseract) mới cân nhắc gói Dart `image` và phải xin duyệt thêm.

## 5. Kiểm chứng ngưỡng AC-25 (≥ 90% ký tự đúng với chữ in)
Bộ mẫu: 5 trang Việt và 5 trang Anh do chính chúng ta soạn và in (không dùng trang có bản quyền), chụp bằng camera hệ thống (đúng cách app nhận ảnh), có mỗi ngôn ngữ vài điều kiện: đủ sáng, hơi nghiêng, bóng đổ nhẹ. Gõ tay bản chữ chuẩn từng trang (NFC, gộp khoảng trắng).
Đo: độ chính xác ký tự = 1 − (khoảng cách Levenshtein giữa chữ nhận và chữ chuẩn) / số ký tự chuẩn. Báo thêm (a) số đo sau khi bỏ dấu, để tách lỗi chữ cái với lỗi dấu, và (b) thời gian mỗi trang.
Quy ước đề xuất (cần người dùng xác nhận): đạt khi trung bình mỗi ngôn ngữ ≥ 90% và không trang nào dưới 80%.
Thực hiện: (1) trên máy tính, chạy tesseract dòng lệnh với `-l vie+eng` bản fast rồi bản best để chọn bộ dữ liệu; (2) lặp lại trên Galaxy A13 thật qua lớp bọc thật, vì phiên bản Tesseract và tiền xử lý khác nhau. Chỉ dòng (2) mới tính là kết quả. Lưu kết quả vào `docs/TESTING.md` khi làm G8 thật. Việc viết hàm đo Levenshtein thành một test Dart nhỏ để chạy lại được cũng nên làm lúc đó.
Chưa có máy thật nào được chạy trong khảo sát này, nên AC-25 hiện CHƯA kiểm chứng.

## 6. ĐỀ XUẤT: phương án D (tự bọc Tesseract4Android 4.9.0, MethodChannel, dữ liệu `vie`+`eng` bản fast đóng gói sẵn)
Lý do:
- Là phương án duy nhất tra được có đủ: đang bảo trì (phát hành 2025-06, đẩy mã 2026-02), Tesseract 5.5.1, Apache-2.0, build mặc định mọi ABI (gồm armeabi-v7a), đã sửa trang 16 KB, không cần quyền nào (cần xác nhận bằng aapt2).
- Gói A (flutter_tesseract_ocr) đang được cập nhật nhưng giấu phiên bản AAR, API theo đường dẫn file, có issue sập và dữ liệu không đọc được trên APK release, và không rõ 32-bit lẫn 16 KB. Bao thêm một lớp ta không kiểm soát.
- PaddleOCR bị loại vì chỉ arm64 và không có tiếng Việt đã tra được.
- Bản fast trước (4,4 MiB), nâng lên best nếu số đo AC-25 đòi.
Rủi ro:
1. Lớn nhất: độ chính xác trên ảnh chụp tiếng Việt có dấu có thể dưới 90% (không có số công bố). Giảm nhẹ: tiền xử lý, thử best, màn gán dòng cho người dùng sửa, và người dùng vẫn nhập tay được; nếu không đạt thì phải sửa AC-25 hoặc chấp nhận nhãn "gợi ý" thay vì ngưỡng.
2. Ta phải tự viết và bảo trì lớp Kotlin (luồng nền, hủy, giải phóng bộ nhớ); phải có test trên máy thật. Đây cũng là thêm phụ thuộc Gradle, cần người dùng duyệt vì khác với quy tắc "không thêm thư viện" của việc này.
3. Hiệu năng trên A13 32-bit (một luồng) có thể vài giây tới chục giây mỗi trang: CHƯA kiểm chứng, cần đo; thử biến thể openmp.
4. Nguồn phát hành (Maven Central hay JitPack) và việc PR #87 đã gộp chưa: CHƯA kiểm chứng.
5. Dung lượng APK tăng: CHƯA kiểm chứng, đo bằng `--split-per-abi`.
Phương án dự phòng: gói A cho một bản thử nhanh (spike) 1 giờ nếu muốn tránh viết Kotlin, nhưng chỉ chấp nhận khi APK release 32-bit chạy được trên A13 và manifest gộp không có INTERNET.

## 7. Việc còn lại trước khi làm giao diện F-04
1. Spike nửa ngày trên Galaxy A13 (cần người dùng cho dùng máy thật): Tesseract4Android 4.9.0 + `vie+eng` fast, đo thời gian và độ chính xác 10 trang mẫu.
2. Xác nhận bằng aapt2 rằng APK release không có INTERNET, CAMERA, bộ nhớ.
3. Ghi quyết định vào DECISIONS.md (D-0xx) sau spike.
