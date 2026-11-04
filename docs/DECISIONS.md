# DECISIONS — Nhật ký quyết định kiến trúc

Mỗi quyết định một mục, mới nhất ở trên cùng.

## D-005 · Mô hình dữ liệu công thức, ảnh, thùng rác; camera dùng ứng dụng của hệ điều hành · 2026-11-04
- Bối cảnh: G1 làm F-01. Dữ liệu phải bền nhiều năm (D-002) và mở rộng được cho sao lưu (AC-55).
- Quyết định:
  - Bảng `recipes` (thông tin chung, `deletedAt` khác null là trong thùng rác), `recipe_lines` (nguyên liệu và bước chung một bảng, phân biệt bằng `section`, có `position` và `isHeading`), `recipe_photos` (tên file và `position`, vị trí 0 là ảnh bìa), `settings` (khóa-giá trị). Xóa công thức xóa dây chuyền dòng và ảnh.
  - Ảnh là file JPEG trong thư mục `photos/` của bộ nhớ riêng của app; cơ sở dữ liệu chỉ giữ tên file. Khi nhập: xoay theo EXIF, thu nhỏ cạnh dài nhất 2048 px, bỏ toàn bộ EXIF (gồm GPS), chất lượng 85. Xử lý ở isolate riêng để không đứng màn hình.
  - Thùng rác giữ 30 ngày; việc xóa hẳn và dọn ảnh mồ côi chạy lúc mở app (`startupProvider`).
  - Nguyên liệu và bước lưu dạng chữ từng dòng; số lượng, đơn vị, tên tách ở G5 (AC-31), không đổi bảng ở G1.
  - Chụp ảnh bằng ứng dụng camera của hệ điều hành qua `image_picker`, nên KHÔNG khai quyền `CAMERA` trong manifest và không có hộp xin quyền camera.
- Lý do / phương án đã loại: Lưu ảnh dạng blob trong SQLite (loại: cơ sở dữ liệu phình to, sao lưu và đọc chậm). Lưu nguyên liệu thành bảng riêng ngay từ G1 (loại: chưa có bộ tách, tách sai thì mất dữ liệu gốc). Màn camera tự viết bằng thư viện camera (loại: cần quyền `CAMERA`, thêm mã, không cần cho G1).
- Hệ quả cần nhớ:
  - AC-08 của SPEC (màn giải thích rồi xin quyền camera) không còn áp dụng cho chụp ảnh món; quyền camera chỉ cần nếu G8 (quét ảnh) tự mở camera. Phải nói với người dùng và cập nhật SPEC mục 5 khi người dùng đồng ý.
  - Mọi cột hoặc bảng mới phải thêm migration (`schemaVersion` hiện là 1) và vào định dạng sao lưu (AC-55).
  - `ImageStore.delete` bỏ qua lỗi file bị khóa; ảnh mồ côi được dọn ở lần mở app sau.

## D-004 · Phiên bản Flutter, quản lý trạng thái, điều hướng, cơ sở dữ liệu, đa ngôn ngữ · 2026-11-04
- Bối cảnh: G1 khởi tạo dự án. Máy có Flutter 3.47.8 (Dart 3.13.7) ở `C:/src/flutter`, chưa có trong PATH. Người dùng chọn tên gói `com.phiotron.cooknote` (như APP-001).
- Quyết định: Ghim Flutter 3.47.8 (ghi trong CI và mục "Lệnh"). Trạng thái: `flutter_riverpod` 3 (provider viết tay). Điều hướng: `go_router`. Cơ sở dữ liệu: `drift` với `drift_flutter`, file sinh `*.g.dart` được commit. Đa ngôn ngữ: `gen-l10n` chính thức, file `.arb` (vi, en). Ảnh: `image_picker` (chọn và chụp), `image` (xử lý). Mở liên kết: `url_launcher`. Chỉ tạo nền tảng Android. `kotlin.incremental=false` trong `android/gradle.properties` vì dự án ở ổ D: còn pub cache ở ổ C: (xem BUG-002 của APP-001; lần build đầu của app này gặp đúng lỗi đó).
- Lý do / phương án đã loại: Dùng lại đúng cách đã chạy được ở APP-001 nên rủi ro thấp. Provider, Bloc (loại như D-003 của APP-001).
- Mức SDK thực tế của bản build 2026-11-04: targetSdk 36, đủ ba kiến trúc `arm64-v8a`, `armeabi-v7a`, `x86_64` (L-011), do Flutter quản lý.
- Hệ quả cần nhớ: Không trộn cách quản lý trạng thái khác. Thêm iOS sau bằng `flutter create --platforms ios .`.

## D-003 · Nhận chữ từ ảnh bằng Tesseract trên máy, không dùng ML Kit · 2026-11-03
- Bối cảnh: F-04 cần nhận chữ tiếng Việt có dấu và tiếng Anh từ ảnh, không gửi dữ liệu ra ngoài. Trang "ML Kit Android data disclosure" của Google (tra ngày 2026-11-03) ghi rằng các SDK ML Kit gửi về Google số liệu chẩn đoán và sử dụng: thông tin máy, tên gói và phiên bản app, số liệu hiệu năng, cấu hình API, mã lỗi.
- Quyết định: Dùng Tesseract nguồn mở chạy hoàn toàn trên máy, kèm dữ liệu nhận chữ tiếng Việt (`vie`) và tiếng Anh (`eng`). Thư viện Flutter cụ thể, bộ dữ liệu (fast hay best) và ngưỡng AC-25 chốt ở G8, sau khi đánh giá mức bảo trì của thư viện và đo trên bộ ảnh mẫu. Ghi D-xxx khi chốt.
- Lý do / phương án đã loại: ML Kit Text Recognition (loại: gửi số liệu về Google, phải khai Data safety, phá cam kết "không gửi dữ liệu" của D-002, dù nhận chữ chính xác hơn và gọn hơn). Dịch vụ nhận chữ trên đám mây (loại: gửi ảnh ra ngoài, tốn phí, cần mạng).
- Hệ quả cần nhớ: Độ chính xác thấp hơn ML Kit, nhất là chữ viết tay. App nặng thêm phần dữ liệu ngôn ngữ (đo ở G8, NFR dung lượng). Nếu G8 cho thấy Tesseract không đạt mức dùng được thì phải hỏi người dùng trước khi đổi sang ML Kit, và mở lại COMPLIANCE D-04, P-10.

## D-002 · Chỉ lưu trên máy, không máy chủ, không SDK bên thứ ba; sao lưu tự động nhiều lớp vào nơi người dùng chọn · 2026-11-03
- Bối cảnh: App miễn phí, bán ở Việt Nam và toàn cầu. Ba app tham khảo có đồng bộ đám mây (thường là phần trả phí). Người dùng chọn offline, nhưng nhấn mạnh rằng có người dùng giữ công thức cả đời, nên dữ liệu phải giữ được lâu dài.
- Quyết định:
  - Dữ liệu chỉ nằm trong SQLite và thư mục ảnh trên máy. Không tài khoản, không máy chủ, không analytics, quảng cáo hay SDK báo crash. Theo dõi crash qua Android vitals của Play Console.
  - Quyền `INTERNET` chỉ dùng cho nhập từ web (F-03).
  - Độ bền dữ liệu dựa vào nhiều lớp (SPEC F-11):
    1. Sao lưu tự động định kỳ vào thư mục người dùng chọn qua trình chọn thư mục của hệ điều hành (có thể là thư mục đám mây của chính họ), giữ nhiều bản, đọc lại để xác minh sau mỗi lần ghi.
    2. "Sao lưu ngay" lưu được vào bất kỳ đâu.
    3. Android Auto Backup cho cơ sở dữ liệu.
    4. Nhắc khi lâu chưa sao lưu.
    5. Định dạng zip mở, có tài liệu, kèm HTML đọc được không cần app. Định dạng chỉ được mở rộng, không phá vỡ.
- Lý do / phương án đã loại: Đồng bộ Google Drive bằng đăng nhập Google (loại ở v1: cần OAuth, xin phạm vi Drive, thêm hồ sơ tuân thủ; ghi vào Ý tưởng, ưu tiên cho bản sau nếu G3 cho thấy Drive không nhận ghi tự động vào thư mục). Máy chủ riêng và tài khoản (loại: tốn công nhất, cần xóa tài khoản, hợp đồng xử lý dữ liệu, chuyển dữ liệu xuyên biên giới). Chỉ xuất file bằng tay (loại: người dùng quên sao lưu thì mất dữ liệu khi mất máy).
- Hệ quả cần nhớ: Chưa kiểm chứng việc Google Drive trên Android cho ghi định kỳ vào thư mục (SPEC mục 7), phải thử ở G3. Khác APP-004, ở đây `allowBackup` BẬT vì công thức không phải dữ liệu nhạy cảm và đây là một lớp sao lưu. Thêm bất kỳ lời gọi mạng nào ngoài F-03 phải mở lại COMPLIANCE mục D-xx.

## D-001 · Stack Flutter, Android trước · 2026-11-03
- Bối cảnh: Người dùng chọn Flutter khi tạo app (2026-11-03). Đã có ba app Flutter trong D:/DemoChung (APP-001 tới APP-003), Flutter 3.47.8 có sẵn ở `C:/src/flutter`, có máy thử Galaxy A13.
- Quyết định: Flutter (Dart), một codebase. v1 chỉ build và phát hành Android. Phiên bản Flutter, quản lý trạng thái, điều hướng, cơ sở dữ liệu, đa ngôn ngữ chốt ở G1 (ghi D-xxx), ưu tiên dùng lại cách đã chạy được ở APP-001 (Riverpod 3, go_router, drift, gen-l10n).
- Lý do / phương án đã loại: Expo/React Native (loại: người dùng chọn Flutter; nhận chữ và WebView cần development build; mất phần kinh nghiệm build Flutter đã có trên máy này). Kotlin và Swift thuần (loại: hai codebase). iOS ở v1 (loại: Flutter cần máy Mac và Xcode để build iOS, cần tài khoản Apple Developer).
- Hệ quả cần nhớ: Không dùng thứ chỉ có trên Android khi có lựa chọn đa nền tảng, để thêm iOS sau không phải viết lại. Khi thêm iOS phải mở lại các dòng P-01 tới P-05 của COMPLIANCE. Galaxy A13 chạy 32-bit, nên build APK đủ kiến trúc (L-011).
