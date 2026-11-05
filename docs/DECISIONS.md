# DECISIONS — Nhật ký quyết định kiến trúc

Mỗi quyết định một mục, mới nhất ở trên cùng.

## D-009 · Chốt 14 câu mở của product.md · 2026-11-05
- Bối cảnh: phiên con A viết `product.md` để lại 14 câu (Q1–Q14, `notes/2026-11-05-product-md.md`). Phương trả lời qua popup.
- Quyết định:
  - Áp thực đơn mẫu vào ngày/bữa đã có món → hỏi "Thay thế" hay "Thêm vào" (AC-39).
  - Link trong bước, ghi chú, URL nguồn → mở bằng **trình duyệt trong app** (có nút "Lưu công thức") (AC-09).
  - Phát hiện trùng URL tính cả công thức ở Thùng rác, kèm lựa chọn Khôi phục (AC-20).
  - Thêm "Dọn sạch thùng rác" có xác nhận (AC-05).
  - Giữ đề xuất của product.md: chế độ nấu giữ khẩu phần/đơn vị đang xem; một bữa có nhiều món; tủ bếp dùng chung khu vực
    với đi chợ; ngày đầu tuần Thứ Hai/Chủ nhật; hẹn giờ chỉ có Hủy; số ngày nhắc sao lưu chỉnh ở màn Sao lưu.
  - Camera quét ảnh dùng app camera của hệ điều hành, không xin quyền CAMERA (như AC-08). Nhận chia sẻ trên iOS qua Share Extension.
  - Email liên hệ: phamphuongphuongnd@gmail.com; link chính sách: chờ Phương đăng lên web.
- Hệ quả: SPEC AC-05, AC-09, AC-20, AC-39 và mục 2, 4, 5 (iPhone) đã sửa theo.

## D-008 · Chuyển vào Mobile App Studio; đủ SPEC, Android + iOS, OCR hai nền tảng · 2026-11-04
- Bối cảnh: App chuyển từ `D:/DemoChung/apps/APP-005-cooknote` sang `D:/Mobile App/apps/A004-cooknote` (mã xưởng `A004-cooknote`), làm theo `WORKFLOW.md` của xưởng: phiên điều phối + phiên con, tối đa 3 phiên điều phối.
- Quyết định (Phương chốt qua popup):
  - Giữ đủ SPEC (F-01..F-14). Nếu cuối phiên điều phối #2 chưa xong thì dời sang v1.1 theo thứ tự: (1) nhập Paprika/Recipe Keeper → (2) quét ảnh OCR → (3) Tủ bếp + "Nấu được gì?" → (4) Lịch thực đơn.
  - **Thay D-001:** v1 phát hành cả Android và iOS. iOS build và test trên GitHub Actions macOS runner (máy Windows, không Mac, không iPhone → thử trên simulator).
  - **Bổ sung D-003:** Android tự bọc Tesseract4Android 4.9.0 qua MethodChannel, dữ liệu `vie`+`eng` bản fast (`docs/audits/OCR-RESEARCH-2026-11.md`). iOS dùng Apple Vision (trên máy, không gửi dữ liệu); thử tiếng Việt trước, kém thì iOS cũng dùng Tesseract.
  - Giao diện thiết kế mới toàn bộ qua Claude Design từ `product.md`; UI hiện tại chỉ tham khảo luồng.
  - Không dùng adb trên máy thử; Phương tự cài APK và thử theo danh sách.
- Hệ quả cần nhớ: Mở lại COMPLIANCE P-01..P-05 (iOS). Phần UI dở của các agent cũ nằm ở nhánh `wip/g4-web-import`, `wip/g5-cook`, `wip/g6-tests`, `wip/g9-exchange` (chỉ tham khảo, không merge thẳng).

## D-007 · Sao lưu: gói zip mở, ghi vào thư mục người dùng chọn qua SAF, đọc lại để xác minh · 2026-11-04
- Bối cảnh: G3 làm F-11. Người dùng giữ công thức cả đời (D-002) nên sao lưu là tính năng sống còn, và phải đọc được dù CookNote không còn.
- Quyết định:
  - Định dạng `.cooknote`: zip chứa `manifest.json` (mã băm SHA-256 từng file), `data.json` (JSON thuần, độc lập với bảng cơ sở dữ liệu), `images/`, `html/` (đọc bằng trình duyệt), `README.txt`. Tài liệu ở `docs/BACKUP-FORMAT.md`. Chỉ được mở rộng, có file mẫu mỗi phiên bản trong `test/fixtures/` và test khôi phục tất cả (AC-55).
  - Thư viện: `archive` (zip), `crypto` (SHA-256), `saf_util` + `saf_stream` (thư mục Storage Access Framework), `file_picker` (chọn file để khôi phục), `share_plus` (bảng chia sẻ cho "Sao lưu ngay"), `package_info_plus` (phiên bản app trong manifest). Không thêm quyền nào vào manifest (kiểm trên APK, 2026-11-04).
  - Sao lưu tự động: chọn thư mục MỘT lần bằng trình chọn thư mục của Android (quyền ghi lâu dài), chu kỳ hằng ngày (23 giờ) hoặc hằng tuần (6 ngày 23 giờ) tính từ lần kiểm gần nhất, chạy lúc mở app (`startupProvider`) và lúc app vào nền (`BackupLifecycleObserver`). Chỉ ghi file mới khi mã băm `data.json` khác lần trước. Lỗi không làm chu kỳ trôi: lần mở app sau thử lại.
  - Mỗi lần ghi: tạo file tạm, đọc lại kiểm mã băm, ghi vào thư mục, LIỆT KÊ và ĐỌC LẠI đúng file vừa ghi ở nơi lưu rồi kiểm mã băm lần nữa (AC-51). Hỏng thì xóa file hỏng, không tính thành công. Chỉ sau đó mới xoay vòng.
  - Xoay vòng: giữ N bản mới nhất (1 tới 30, mặc định 5), chỉ xóa file có tên đúng mẫu `CookNote-YYYY-MM-DD-HHmmss.cooknote`. SPEC AC-50 còn đòi nhận bằng `manifest.json`; bản này CHỈ nhận bằng tên (đọc manifest của từng file ở nơi lưu từ xa tốn thời gian và băng thông), nên file người dùng tự đặt đúng tên đó trong thư mục sao lưu cũng bị tính là của app.
  - Khôi phục: kiểm toàn bộ TRƯỚC, hai chế độ (thay thế, gộp), thay thế thì tự sao lưu dữ liệu hiện tại vào thư mục riêng của app (giữ 2 bản).
  - Android Auto Backup làm lớp phụ: `allowBackup=true`, loại thư mục `photos` và `safety` khỏi sao lưu đám mây (giới hạn 25 MB), chuyển máy trực tiếp vẫn mang ảnh. Đường dẫn `app_flutter` là của `path_provider` trên Android, CHƯA kiểm chứng trên máy thật.
- Lý do / phương án đã loại: Đồng bộ qua đăng nhập Google Drive (loại, D-002). Ghi trực tiếp bằng đường dẫn `dart:io` vào thư mục ngoài (loại: Android 11 trở lên không cho). Mã hóa file bằng mật khẩu (để Ý tưởng: cần quản lý mật khẩu, mất mật khẩu là mất dữ liệu). Nén thêm ảnh trong gói (loại: ảnh JPEG đã nén, chỉ tốn CPU).
- Hệ quả cần nhớ:
  - CHƯA kiểm chứng trên máy thật: Google Drive và OneDrive có cho ghi định kỳ vào thư mục qua SAF không (rủi ro số 1 của SPEC mục 7); `pasteLocalFile` với file lớn; Auto Backup. Nếu Drive không cho, "Sao lưu ngay và lưu ở nơi khác" cùng lời nhắc là lớp chính.
  - Mọi bảng hoặc cột mới ở G5 tới G9 phải thêm vào `exportData` và `importData` (`lib/src/backup/backup_data.dart`) và có test khôi phục.
  - Trong widget test, hàm chờ phải tiến thời gian giả (`pump(Duration)`), vì mã sao lưu dùng `Future.delayed(Duration.zero)` để nhường giao diện.

## D-006 · Tìm kiếm không dấu bằng cột chỉ mục; danh mục, thẻ, lịch sử nấu là bảng riêng · 2026-11-04
- Bối cảnh: G2 làm F-02 (AC-10 tới AC-15). Tìm "pho bo" phải ra "Phở bò", phải đủ nhanh với 5.000 công thức, và lên được từ cơ sở dữ liệu G1 mà không mất dữ liệu.
- Quyết định:
  - `recipes.searchKey` (tên, nguyên liệu, bước, ghi chú, nguồn) và `recipes.ingredientsKey` (riêng nguyên liệu) là chữ đã hạ chữ thường và bỏ dấu bằng `normalizeText`, tính lại mỗi lần lưu. Tìm là `LIKE '%từ%'` cho từng từ, mọi từ phải khớp.
  - Bảng mới: `categories` (cha-con qua `parentId`, `position`, tối đa 3 cấp), `recipe_categories`, `recipe_tags` (`tag` giữ cách viết, `tagKey` đã chuẩn hóa), `cook_log`. `schemaVersion` 2; `onUpgrade` thêm hai cột, tạo bốn bảng và tính chỉ mục cho công thức cũ (có test `migration_test.dart` dựng đúng cơ sở dữ liệu G1).
  - Lọc theo danh mục gồm cả danh mục con. Lọc theo thẻ cần đủ mọi thẻ đã chọn. Sắp xếp làm trong Dart sau khi lọc: tên theo thứ tự không dấu, mục thiếu giá trị (chưa ghi thời gian nấu, chưa nấu) luôn xếp cuối.
  - Danh mục mặc định (6 mục theo ngôn ngữ) tạo MỘT lần ở lần mở app đầu, đánh dấu bằng khóa `categoriesSeeded` trong `settings`, nên xóa hết rồi cũng không tạo lại.
- Lý do / phương án đã loại: SQLite FTS5 (loại: tách từ của FTS không bỏ dấu tiếng Việt, thêm bảng ảo và đồng bộ khó, mà `LIKE` trên cột đã chuẩn hóa đã đủ nhanh, xem TESTING). Lọc và sắp xếp hết trong SQL (loại: viết dài, sắp xếp theo tên không dấu không làm được trong SQLite mặc định). Lọc hết trong Dart (loại: phải đọc toàn bộ nội dung công thức).
- Hệ quả cần nhớ: Công thức mới nhập (G4, G7, G9) phải đi qua `RecipeRepository.save` để có chỉ mục; ghi thẳng vào bảng `recipes` thì tìm không ra. Mọi bảng mới của G2 phải có trong định dạng sao lưu (G3, AC-55). Danh sách tải toàn bộ công thức khớp rồi sắp xếp trong bộ nhớ: nếu đo trên máy thật vượt ngưỡng 300 ms (SPEC 5b) thì phải phân trang hoặc đẩy sắp xếp xuống SQL.

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
  - Người dùng đã đồng ý ngày 2026-11-04; SPEC AC-08 và mục 5 đã sửa theo. Quyền camera chỉ cần nếu G8 (quét ảnh) tự mở camera, khi đó hỏi lại.
  - Mọi cột hoặc bảng mới phải thêm migration (`schemaVersion` hiện là 1) và vào định dạng sao lưu (AC-55).
  - `ImageStore.delete` bỏ qua lỗi file bị khóa; ảnh mồ côi được dọn ở lần mở app sau.

## D-004 · Phiên bản Flutter, quản lý trạng thái, điều hướng, cơ sở dữ liệu, đa ngôn ngữ · 2026-11-04
- Bối cảnh: G1 khởi tạo dự án. Máy có Flutter 3.47.8 (Dart 3.13.7) ở `C:/src/flutter`, chưa có trong PATH. Người dùng chọn tên gói `com.phiotron.cooknote` (như APP-001).
- Quyết định: Ghim Flutter 3.47.8 (ghi trong CI và mục "Lệnh"). Trạng thái: `flutter_riverpod` 3 (provider viết tay). Điều hướng: `go_router`. Cơ sở dữ liệu: `drift` với `drift_flutter`, file sinh `*.g.dart` được commit. Đa ngôn ngữ: `gen-l10n` chính thức, file `.arb` (vi, en). Ảnh: `image_picker` (chọn và chụp), `image` (xử lý). Mở liên kết: `url_launcher`. Chỉ tạo nền tảng Android. `kotlin.incremental=false` trong `android/gradle.properties` vì dự án ở ổ D: còn pub cache ở ổ C: (xem BUG-002 của APP-001; lần build đầu của app này gặp đúng lỗi đó).
- Lý do / phương án đã loại: Dùng lại đúng cách đã chạy được ở APP-001 nên rủi ro thấp. Provider, Bloc (loại như D-003 của APP-001).
- Mức SDK thực tế của bản build 2026-11-04: targetSdk 36, đủ ba kiến trúc `arm64-v8a`, `armeabi-v7a`, `x86_64` (L-011), do Flutter quản lý.
- Hệ quả cần nhớ: Không trộn cách quản lý trạng thái khác. Thêm iOS sau bằng `flutter create --platforms ios .`.

## D-003 · Nhận chữ từ ảnh bằng Tesseract trên máy, không dùng ML Kit · 2026-11-03 (bổ sung bởi D-008)
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

## D-001 · Stack Flutter, Android trước · 2026-11-03 (phần "Android trước" bị thay bởi D-008)
- Bối cảnh: Người dùng chọn Flutter khi tạo app (2026-11-03). Đã có ba app Flutter trong D:/DemoChung (APP-001 tới APP-003), Flutter 3.47.8 có sẵn ở `C:/src/flutter`, có máy thử Galaxy A13.
- Quyết định: Flutter (Dart), một codebase. v1 chỉ build và phát hành Android. Phiên bản Flutter, quản lý trạng thái, điều hướng, cơ sở dữ liệu, đa ngôn ngữ chốt ở G1 (ghi D-xxx), ưu tiên dùng lại cách đã chạy được ở APP-001 (Riverpod 3, go_router, drift, gen-l10n).
- Lý do / phương án đã loại: Expo/React Native (loại: người dùng chọn Flutter; nhận chữ và WebView cần development build; mất phần kinh nghiệm build Flutter đã có trên máy này). Kotlin và Swift thuần (loại: hai codebase). iOS ở v1 (loại: Flutter cần máy Mac và Xcode để build iOS, cần tài khoản Apple Developer).
- Hệ quả cần nhớ: Không dùng thứ chỉ có trên Android khi có lựa chọn đa nền tảng, để thêm iOS sau không phải viết lại. Khi thêm iOS phải mở lại các dòng P-01 tới P-05 của COMPLIANCE. Galaxy A13 chạy 32-bit, nên build APK đủ kiến trúc (L-011).
