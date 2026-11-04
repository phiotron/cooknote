# CLAUDE.md — APP-005 · CookNote

App mobile CHỈ dành cho điện thoại. Mở Claude ngay trong thư mục này vẫn có đủ lệnh / (đã chép từ gốc); script của bộ khung chạy bằng `bash ../../scripts/<tên>.sh`. Quy tắc gốc: `D:/DemoChung/CLAUDE.md` (`../../CLAUDE.md`) và quy trình `../../docs/PROCESS.md`. File này chỉ chứa phần RIÊNG của app.

- Mã app: APP-005
- Thư mục: apps/APP-005-cooknote
- Giai đoạn hiện tại: G2 xong code, chờ thử máy thật
- Nền tảng: Android (v1); iOS để sau (D-001)
- Quy mô: chuẩn
- Stack: Flutter

## Điểm dừng (Claude cập nhật bằng /end; đọc mục này đầu tiên khi quay lại app sau thời gian dài)
- Cập nhật lần cuối: 2026-11-04
- Đang làm dở: không có. G2 xong phần code (danh mục, thẻ, tìm không dấu, lọc, sắp xếp, lưới/dòng, Đã nấu): lint sạch, 86 test đạt, APK release build được (63,7 MB, đủ 3 kiến trúc, vẫn không có quyền INTERNET/CAMERA/bộ nhớ). CHƯA thử trên điện thoại thật (cả G1 lẫn G2)
- Bước tiếp theo: người dùng thử G1 và G2 trên máy thật (danh sách ở BACKLOG, mục "Biên bản thử máy thật"); sau đó /phase APP-005 làm G3 (sao lưu bền lâu, thử sớm Google Drive). AC-03 kéo thả dòng: người dùng chưa chọn nên vẫn dùng ô nhiều dòng
- Đang chờ (ai/cái gì): người dùng: thử máy thật G1, G2, phát hành dưới tên cá nhân hay công ty, Play Age Signals; file mẫu xuất từ Paprika và Recipe Keeper (cần ở G9)
- Lưu ý dễ vấp: (1) Không dùng ML Kit, vì nó gửi số liệu về Google (D-003). (2) Chưa biết Google Drive trên Android có cho ghi tự động vào thư mục không, phải thử ở G3 (SPEC mục 7). (3) Galaxy A13 chạy 32-bit: build APK đủ kiến trúc (L-011). (4) Định dạng sao lưu chỉ được mở rộng, không phá vỡ (AC-55); G2 thêm bảng categories, recipe_categories, recipe_tags, cook_log nên phải vào định dạng sao lưu. (5) Flutter chưa có trong PATH, xem mục "Lệnh". (6) Máy thử là máy người dùng: không tự chạy adb. (7) Danh sách tải toàn bộ công thức khớp: 338 ms với 5.000 công thức trên máy tính, có thể vượt ngưỡng 300 ms trên điện thoại (TESTING, D-006)

## Mô tả
- Mục đích: Sổ tay công thức nấu ăn: lưu và nhập công thức từ web hoặc ảnh, chế độ nấu, danh sách đi chợ, lịch thực đơn, tủ bếp; offline, sao lưu tự động (chức năng tương đương Paprika 3, Recipe Keeper, CookBook)
- Người dùng chính: người nấu ăn gia đình, sinh viên, người làm bánh; giữ công thức nhiều năm; Việt Nam và toàn cầu (vi/en)

## Đọc trước khi làm (theo thứ tự)
Quay lại app sau thời gian dài: mục "Điểm dừng" ở trên → `docs/RUNBOOK.md` (cách chạy lại) → dùng `/revive`. Làm việc thường: `docs/SPEC.md` → `docs/BACKLOG.md` → `docs/DECISIONS.md` → `docs/ARCHITECTURE.md` → `docs/TESTING.md`; khi làm tính năng lớn: `docs/plans/PLAN-*.md` đã duyệt; app nhập từ ngoài: báo cáo mới nhất trong `docs/audits/`

## Lệnh (điền chính xác khi chọn stack; Claude phải chạy đúng các lệnh này, không tự bịa)
Flutter 3.47.8 ở `C:/src/flutter`, CHƯA có trong PATH. Trong Git Bash chạy trước: `export PATH="/c/src/flutter/bin:$PATH"` (D-004). Các lệnh dưới đã chạy thử ngày 2026-11-04, trừ dòng "Chạy dev".
- Cài đặt: `flutter pub get` (tự sinh file dịch từ `lib/l10n/*.arb`)
- Sinh mã sau khi sửa bảng trong `lib/src/data/database.dart`: `dart run build_runner build` (commit cả `*.g.dart`, D-004)
- Chạy dev: CHƯA kiểm chứng (cần máy thật hoặc giả lập; dự kiến `flutter run -d <id>`)
- Lint: `flutter analyze`
- Typecheck: `flutter analyze`
- Định dạng: `dart format lib test`
- Test: `flutter test`
- Build thử trên máy: `flutter build apk --release` (đủ kiến trúc, L-011; KHÔNG thêm `--target-platform android-arm64`), cài bằng `adb install -r build/app/outputs/flutter-apk/app-release.apk` (chỉ khi người dùng cho phép dùng điện thoại). Vẫn ký bằng khóa debug của template, CHƯA dùng để phát hành. Bản phát hành Play: `flutter build appbundle`, CHƯA chạy (cần khóa ký).
- Kiểm quyền trong APK: `"$LOCALAPPDATA/Android/Sdk/build-tools/37.0.0/aapt2.exe" dump permissions build/app/outputs/flutter-apk/app-release.apk`

## Quy ước riêng của app
- Cấu trúc thư mục code: `lib/src/data/` (drift, kho dữ liệu, ảnh), `lib/src/features/<tính năng>/` (màn hình), `lib/src/ui/` (widget dùng chung), `lib/src/providers.dart`, `lib/src/app.dart` (router, theme), `lib/l10n/` (file dịch .arb và mã sinh). Test phản chiếu ở `test/`.
- Đặt tên, quản lý state, điều hướng, lưu dữ liệu: Riverpod 3 (provider viết tay), go_router, drift/SQLite (D-004 tới D-006). Mọi chữ giao diện nằm trong `.arb`. Dữ liệu chỉ trên máy, mạng chỉ dùng cho nhập từ web (D-002)

## Bài học áp dụng cho app này
ID bài học liên quan trong `../../lessons/LESSONS.md`: L-001, L-002, L-003, L-004 (nhập từ web), L-007, L-008, L-009, L-010 (camera, thông báo), L-011 (build đủ kiến trúc)

## Ghi nhớ riêng (Claude cập nhật khi phát hiện điều lẽ ra phải biết sớm hơn)
- Widget test có đọc file ảnh: Windows giữ khóa file đang hiện, nên kiểm việc xóa ảnh bằng `RecordingImageStore` trong `test/helpers.dart`, không kiểm sự có mặt của file. Việc thật chạy ở isolate khác phải chờ bằng `waitUntil`. Trước khi gọi Back hệ thống trong test phải `pump` (đã có trong `systemBack`).
