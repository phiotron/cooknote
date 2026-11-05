# A004-cooknote · Bepbook (tên cũ CookNote) — APP.md

> Brief và trạng thái của app. **Chỉ phiên điều phối sửa file này**; phiên con ghi báo cáo vào `notes/`.
> App **đã code trước khi vào xưởng** (đã qua G1–G3). Biên bản và việc thử máy thật: `docs/MANUAL-TESTS.md`.

## Brief
- **Mã app / thư mục:** `A004-cooknote` → `apps/A004-cooknote/`, đã ghi trong `apps/REGISTRY.md`
- **Bundle ID** (không đổi): `com.phiotron.cooknote` · **Repo:** https://github.com/phiotron/cooknote (private, nhánh `main`)
- **Một câu mô tả:** Sổ tay công thức nấu ăn trên điện thoại: nhập từ web hoặc ảnh, chế độ nấu, nhân khẩu phần, đi chợ,
  lịch thực đơn, tủ bếp. Offline, không tài khoản, sao lưu tự động bằng định dạng mở.
- **Người dùng mục tiêu:** người nấu ăn gia đình, sinh viên, người làm bánh; giữ công thức nhiều năm; Việt Nam và toàn cầu (vi/en).
- **Kiếm tiền:** miễn phí, mọi tính năng mở (không quảng cáo, không IAP).
- **Nền tảng:** Android + iOS (D-008; iOS build/test trên GitHub Actions macOS runner) · **Stack:** Flutter 3.47.8, Riverpod 3, go_router, drift/SQLite.
- **Tài liệu tham chiếu:** `docs/SPEC.md` (F-01..F-14, AC-01..AC-65, nguồn sự thật về hành vi), `docs/DECISIONS.md` (D-001..D-008),
  `docs/ARCHITECTURE.md`, `docs/BACKUP-FORMAT.md`, `docs/TESTING.md`, `docs/SECURITY.md`, `docs/COMPLIANCE.md`, `docs/RISKS.md`,
  `docs/RELEASE.md`, `docs/audits/OCR-RESEARCH-2026-11.md`; thuật ngữ `CONTEXT.md` và mô tả gửi Claude Design `product.md` (do phiên con A tạo).

## Tiêu chuẩn áp dụng (`playbook/STANDARDS.md`, chốt 2026-11-05)
- **Khác đối thủ ở đâu (S-30):** mọi tính năng miễn phí (Paprika thu phí từng nền tảng, Recipe Keeper khoá bớt); không tài khoản;
  dữ liệu giữ cả đời nhờ sao lưu tự động bằng định dạng mở, đọc được bằng trình duyệt không cần app; tiếng Việt chuẩn
  (tìm không dấu, đơn vị chén/bát/muỗng, OCR tiếng Việt).
- **Mục A:** bắt buộc toàn bộ. Lưu ý S-11 (trang 16 KB) cho thư viện native Tesseract.
- **Mục B được bật:** **S-84** (đối tượng mọi lứa tuổi từ 13: khai đối tượng 13+ trên Play, không vào Families; bảng hỏi tuổi
  Apple tính cả trình duyệt web trong app). Không bật S-80..S-83, S-85..S-89 (không tài khoản, không thu tiền, không quảng
  cáo/analytics, không gửi dữ liệu lên server, không AI, không tự mã hoá).
- **Sao lưu hệ điều hành:** giữ BẬT cả Android Auto Backup (DB, không ảnh — AC-56) và iCloud backup trên iOS; công thức không
  phải dữ liệu nhạy cảm. Khác fact xưởng `ios-ma-hoa-va-sao-luu` (fact đó cho app dữ liệu tài chính). Chính sách ghi rõ.
- **Thị trường:** Việt Nam + toàn cầu, trừ Trung Quốc đại lục; không có hoạt động thương mại ở EU (S-87 không bật).

## MVP: giữ đủ SPEC (D-008)
SPEC có 14 tính năng, vượt mức "≤ 5" của Playbook. Phương chọn giữ đủ. Cách giữ ngân sách 3 phiên: dồn mọi dependency vào 1 phiên con,
làm DB v3 ngay ở #1, rồi ở #2 chỉ còn UI chạy song song theo nhóm màn.

| # | Tính năng | Trạng thái 2026-11-04 |
|---|---|---|
| F-01 | Công thức (soạn, ảnh, thùng rác, nhân bản) | ✅ code G1 (thiếu kéo thả dòng AC-03) |
| F-02 | Danh mục, thẻ, tìm không dấu, lọc, sắp xếp, Đã nấu | ✅ code G2 |
| F-03 | Nhập từ web + Chia sẻ | logic có (`lib/src/web_import/`); UI dở ở nhánh `wip/g4-web-import` |
| F-04 | Quét ảnh OCR | chỉ có `lib/src/scan/line_classifier.dart`; engine chưa có |
| F-05/06 | Chế độ nấu, hẹn giờ, khẩu phần, đổi đơn vị | logic có (`lib/src/cooking/`); UI dở ở `wip/g5-cook` |
| F-07 | Danh sách đi chợ | chưa có DB; test dở ở `wip/g6-tests` |
| F-08 | Lịch thực đơn, thực đơn mẫu | logic xếp có (`lib/src/menu/meal_planner.dart`); chưa có DB |
| F-09 | Tủ bếp, "Nấu được gì?" | chưa có DB; test dở ở `wip/g6-tests` |
| F-10 | Nhập Paprika/RK, JSON, chia sẻ, PDF sách | logic có (`lib/src/exchange/`, `lib/src/cookbook/`); UI dở ở `wip/g9-exchange` |
| F-11 | Sao lưu bền lâu + khôi phục | ✅ code G3 (chưa thử máy thật) |
| F-12..14 | Giao diện/ngôn ngữ/màn chào, tiếp cận, pháp lý | một phần (sáng/tối, vi/en) |

**Thứ tự dời sang v1.1 nếu cuối #2 chưa xong:** (1) nhập Paprika/Recipe Keeper → (2) OCR → (3) Tủ bếp + "Nấu được gì?" → (4) Lịch thực đơn.

## Màn hình & luồng chính
Thanh dưới 5 mục: **Công thức · Thực đơn · Đi chợ · Tủ bếp · Thêm**. Nút "+" ở Công thức mở: Nhập tay / Từ web / Quét ảnh / Nhập file.
Màn: danh sách công thức (lưới/dòng, tìm, lọc, sắp xếp) · xem công thức · soạn công thức · xem ảnh toàn màn hình · thùng rác · danh mục ·
trình duyệt trong app + xem trước nhập · chọn đoạn · quét ảnh + gán dòng · chế độ nấu (hẹn giờ, ghim, đọc bước) · khẩu phần/đơn vị ·
các danh sách đi chợ + khu vực · lịch thực đơn ngày/tuần/tháng + thực đơn mẫu + gợi ý ngẫu nhiên · tủ bếp + "Nấu được gì?" ·
nhập/xuất/chia sẻ/PDF sách công thức · sao lưu + khôi phục · cài đặt · màn chào 3 trang · giới thiệu.
Chi tiết từng màn và trạng thái: `product.md`.
Luồng nhanh nhất: Chia sẻ link từ trình duyệt → CookNote → xem trước → Lưu.

## Trạng thái
| Phiên điều phối | Ngày | Phiên con đã mở | Kết quả |
|---|---|---|---|
| #1 Chuyển + product.md + nền | 2026-11-04..05 | A product.md · B iOS + CI + dependency · C DB v3 + backup v2 · D OCR Android · E store & pháp lý | A, C, E xong; B, D bị dừng giữa chừng (phần chính đã commit). Phiên F `a004-merge-wip` (2026-11-05): đã gộp g5+g4+g9 vào `main`, 390 test đạt, APK release có INTERNET + tessdata, **CI Android + iOS xanh** (`d3687d2`, `e28349c`); báo cáo `notes/2026-11-05-gop-wip.md` |
| #2 Áp UI Hi-Fi + đủ tính năng | 2026-11-05.. | F0 design system + khung 5 tab/route stub (một mình) → G1 công thức · G2 đưa vào · G3 nấu · G4 đi chợ · G5 thực đơn+tủ bếp · G6 thêm/sao lưu/cài đặt → H so mockup + build + ảnh store | 🔨 Đang làm — mockup Hi-Fi v1 `90c0c71`; kế hoạch `docs/PLAN-phien-2.md` |
| #3 Phát hành | | ảnh store · Android · iOS | |

Kế hoạch đầy đủ 3 phiên: `../../memory/sessions/2026-11-04-A004-cooknote.md`.

**Việc dở / bước tiếp (cập nhật 2026-11-05, sau phiên F):**
- ✅ **XONG:** gộp wip + manifest (INTERNET, SEND) + `.gitignore` + build APK release + CI xanh — chi tiết ở `notes/2026-11-05-gop-wip.md`. Mục 2 mục dưới (gộp wip, Android chưa build) giữ để tham chiếu lịch sử. Còn lại của #1: quyết iOS sao lưu tự động + cleartext http; (đã dọn dấu vết nguồn cũ 2026-11-05: hook, tài liệu quy trình cũ → `docs/MANUAL-TESTS.md`); Phương chọn tên + tuổi Apple + duyệt product.md.
- ~~Gộp 3 nhánh wip vào `main`~~ (đã làm): `wip/g5-cook` (logic nấu, 263 test đạt, 1 import thừa;
  phần Android trùng desugaring đã có) → `wip/g4-web-import` (13 test UI hỏng vì `ShareIntentListener` gọi plugin thật trong test → cho
  test dùng bản giả) → `wip/g9-exchange` (10 lint nhỏ; `backup_data.dart`/`recipe_repository.dart` đã bị C đổi → gỡ xung đột cẩn thận).
  `wip/g6-tests` KHÔNG gộp: C đã dùng lại. Sau gộp: analyze + toàn bộ test + build APK release.
- **Android chưa build lại trên cây chung:** commit `0aeca87` (desugaring + compileSdk 37) chưa chạy build/CI. Còn thiếu ở manifest:
  quyền `INTERNET` cho bản release (F-03 sẽ hỏng nếu thiếu) và intent-filter `SEND text/plain` (AC-17) — `notes/2026-11-05-ios-ci.md`.
  Thêm `android/.kotlin/` vào `.gitignore`. CI iOS chưa có lần chạy xanh trọn vẹn sau `d16f83f`.
- ✅ **Đã chốt D-010 (2026-11-05) và áp vào tài liệu** (`notes/2026-11-05-ap-d010.md`): tên **Bepbook**; tuổi Apple A (16+/17+); cho phép http (ngoại lệ ở COMPLIANCE 2b + chính sách, AC-66); sao lưu iOS bằng thư mục + bookmark (AC-67). **Còn lại cho #2 (code):** đổi tên hiển thị trong `.arb`/`android:label`/`CFBundleDisplayName`, màn Sao lưu iOS, cảnh báo http, xoá dữ liệu WebView (AC-64).
- ✅ **Mockup Hi-Fi v1 đã có (2026-11-05):** `design/hifi/` (945 khung HTML, token, asset; PNG + zip chỉ ở máy), link `design/LINKS.md`,
  ghi chú quyết định + chuỗi mới ở `design/hifi/README.md`. Phiên điều phối #2 đã mở — xem `docs/PLAN-phien-2.md`.
- ✅ Phương **đã duyệt** `product.md` v1.1 (58 màn, đủ Q1–Q14 + D-010, tên Bepbook) ngày 2026-11-05. Bước tiếp của Phương: gửi Claude Design → lưu link + export HTML vào `design/hifi/` → mở phiên #2.
- Phương: file mẫu Paprika/Recipe Keeper vào `test/fixtures/exchange/` trước #2; Apple Developer + App ID + secrets theo `docs/ci.md`;
  đăng chính sách lên web; upload keystore ngoài repo; closed test 12 × 14 ngày sớm; tự thử APK (không adb) theo
  `notes/2026-11-05-ocr-android.md` và `docs/MANUAL-TESTS.md`.

## Lệnh (đã chạy thật 2026-11-04; phải dùng đúng, không đoán)
Flutter 3.47.8 ở `C:/src/flutter`, **chưa có trong PATH**. Git Bash: `export PATH="/c/src/flutter/bin:$PATH"` trước mọi lệnh.
- Cài: `flutter pub get` (tự sinh file dịch từ `lib/l10n/*.arb`)
- Sinh mã sau khi sửa bảng `lib/src/data/database.dart`: `dart run build_runner build` (commit cả `*.g.dart`)
- Lint/typecheck: `flutter analyze` · Định dạng: `dart format lib test` · Test: `flutter test`
- Build thử Android: `flutter build apk --release` (**không** thêm `--target-platform android-arm64`: Galaxy A13 chạy 32-bit)
- Bản phát hành Play: `flutter build appbundle` (cần khoá ký ngoài repo; chưa chạy)
- Kiểm quyền trong APK: `"$LOCALAPPDATA/Android/Sdk/build-tools/37.0.0/aapt2.exe" dump permissions build/app/outputs/flutter-apk/app-release.apk`
- iOS: chỉ build và test trên GitHub Actions macOS runner (`.github/workflows/`); Windows không build iOS cục bộ.

## Quy ước code
- `lib/src/data/` (drift, kho dữ liệu, ảnh) · `lib/src/features/<tính năng>/` (màn hình) · `lib/src/ui/` (widget dùng chung) ·
  `lib/src/providers.dart` · `lib/src/app.dart` (router, theme) · `lib/l10n/` (.arb và mã sinh). Logic thuần theo miền:
  `cooking/`, `web_import/`, `exchange/`, `cookbook/`, `menu/`, `scan/`, `backup/`. Test phản chiếu ở `test/`.
- Riverpod 3 provider viết tay, go_router, drift. Mọi chữ giao diện nằm trong `.arb`. Dữ liệu chỉ trên máy; mạng chỉ cho nhập từ web (D-002).
- Định dạng sao lưu chỉ được mở rộng (`docs/BACKUP-FORMAT.md`); bảng mới phải vào `lib/src/backup/backup_data.dart` và có file mẫu trong `test/`.

## Lưu ý dễ vấp
- **Không dùng ML Kit** (gửi số liệu về Google, D-003).
- **Không tự dùng adb trên điện thoại** (D-008): máy thử dùng chung với app khác; Phương tự cài và thử.
- **Widget test có DB:** dùng `pump(Duration)` khi chờ mã có `Future.delayed` (`pump()` không tiến giờ giả); không ghi DB nhiều lần
  trong một `runAsync`. Test xoá ảnh dùng `RecordingImageStore` (`test/helpers.dart`) vì Windows giữ khoá file đang hiện; trước khi gọi
  Back hệ thống phải `pump` (đã có trong `systemBack`).
- `flutter_tester` treo giữ khoá `sqlite3.dll` → `taskkill //F //IM flutter_tester.exe` (chỉ khi chắc đó là test của app này).
- `kotlin.incremental=false` trong `android/gradle.properties` là cố ý (dự án ở ổ D, pub cache ở ổ C).
- Chưa biết Google Drive trên Android có cho ghi định kỳ vào thư mục chọn qua SAF không (D-007): phải thử máy thật.
- Danh sách tải toàn bộ công thức: 338 ms với 5.000 công thức trên máy tính (TESTING, D-006).

## Quyết định riêng của app (chi tiết: `docs/DECISIONS.md`)
- **D-001** Flutter; ~~Android trước~~ → **D-008: Android + iOS ở v1**.
- **D-002** Chỉ lưu trên máy, không máy chủ/SDK bên thứ ba; mạng chỉ cho nhập web; sao lưu nhiều lớp.
- **D-003** OCR trên máy, không ML Kit → **D-008:** Android Tesseract4Android (MethodChannel, vie+eng fast), iOS Apple Vision.
- **D-004** Flutter 3.47.8, Riverpod 3, go_router, drift, gen-l10n. · **D-005** Mô hình công thức/ảnh/thùng rác; camera qua app hệ điều hành.
- **D-006** Tìm không dấu bằng cột chỉ mục. · **D-007** Sao lưu zip mở, SAF, đọc lại xác minh.
- **D-008 (2026-11-04)** Chuyển vào xưởng; đủ SPEC + thứ tự cắt; Android + iOS; UI thiết kế mới qua Claude Design; không adb.
- **2026-11-04** Phần UI dở của agent cũ: nhánh `wip/g4-web-import`, `wip/g5-cook`, `wip/g6-tests`, `wip/g9-exchange` (tham khảo, không merge thẳng).
- **2026-11-04** Tài khoản Google Play và Apple đứng tên cá nhân (theo xưởng).
- **D-010 (2026-11-05, Phương chốt qua popup):** (1) tên app đổi thành **Bepbook** ("Bepbook: Sổ Công Thức" / "Bepbook: Recipe Notebook"; mã app, bundle `com.phiotron.cooknote` giữ nguyên); (2) tuổi Apple **A** — giữ trình duyệt đầy đủ AC-16, nhận 16+/17+, Play vẫn khai 13+; (3) trình duyệt **cho phép http**, phải ghi ngoại lệ vào COMPLIANCE S-01 + chính sách, AC-64 xoá cả dữ liệu WebView; (4) sao lưu tự động iOS = **chọn thư mục qua UIDocumentPicker + bookmark**, ghi định kỳ (làm ở #2). Cần ghi vào `docs/DECISIONS.md` + cập nhật `store/`, `product.md` (tên mới) ở phiên sau.

## Retro (điền khi phát hành)
- Tổng phiên điều phối / phiên con:
- Chậm nhất ở đâu, vì sao:
- Thứ tái dùng được cho app sau:
- Cải tiến đề xuất cho Playbook:
