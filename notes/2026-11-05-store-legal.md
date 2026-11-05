# [A004-cooknote] Store & pháp lý 2 nền tảng — báo cáo phiên con

Phiên điều phối #1 · 2026-11-05. Chỉ sửa tài liệu trong phạm vi brief (`store/`, `docs/legal/`, `docs/COMPLIANCE.md`, phần store
của `docs/RELEASE.md`). Không sửa code, pubspec, `ios/`, `android/`, APP.md, file cấp xưởng. Không đăng nhập/gửi gì lên Play
Console hay App Store Connect. Không dùng subagent.

## Đã làm / file đã đổi
| File | Việc |
|---|---|
| `store/google-play.md` (mới) | Tên vi/en, mô tả ngắn, mô tả dài vi/en (khối đầu nêu khác biệt S-30), ghi chú phát hành, danh mục, App content (ads, app access, target audience 13+, IARC có "trình duyệt = Yes"…), **Data safety "No data collected"** kèm bảng căn cứ từng hành vi (WebView, nhập web, OCR, thông báo, giọng đọc, sao lưu thư mục, **Android Auto Backup**, chuyển máy), danh sách dòng phải xoá khi cắt tính năng, nguồn |
| `store/app-store.md` (mới) | **Tra trùng tên có link** + 3 tên đề xuất; App Information (danh mục, phân phối trừ Trung Quốc, đề xuất chỉ iPhone, DSA trader, Content Rights); tên/phụ đề/keyword (byte)/promo/mô tả vi + en; **bảng hỏi tuổi mới** (Unrestricted Web Access = Yes → 16+/17+, lựa chọn A/B); **App Privacy "Data Not Collected"** + căn cứ iCloud; export compliance `false`; ghi chú App Review; kết quả đếm |
| `store/check_limits.py` (mới) | Script đếm ký tự/byte mọi trường có nhãn `<!-- field: … limit=… -->` trong `store/*.md`, báo keyword trùng/ngắn; exit 1 nếu vượt |
| `store/closed-test.md` (mới) | Luật 12 × 14 (kiểm trang Play hôm nay), checklist đường găng 10 bước, lịch, Google Group, thư mời + nhắc **vi/en**, danh sách nhờ tester thử AC [M] (ưu tiên sao lưu vào Google Drive — rủi ro số 1), nhật ký, câu trả lời mẫu form production |
| `store/screenshots-plan.md` (mới) | Kích thước bắt buộc Play + Apple (đọc trang chính thức hôm nay), 8 cảnh + chú thích vi/en, dữ liệu mẫu tự viết (không chụp trang web thật), cách chụp không adb, kiểm sau khi chụp |
| `docs/legal/privacy-policy.md` (mới) | Chính sách vi + en cho cả 2 nền tảng: không thu thập; dữ liệu trên máy, bỏ EXIF; **sao lưu hệ điều hành đang bật** (Android Auto Backup DB không ảnh; chuyển máy có ảnh; iCloud/máy tính), file `.cooknote` không mã hoá; quyền + khi nào dùng Internet; OCR/giọng đọc; trang web trong app; **bản quyền công thức nhập từ web (AC-63)**; **13+**; quyền người dùng; liên hệ. Ghi chú nội bộ: phải đối chiếu gì trước khi đăng, nơi đăng |
| `docs/legal/terms.md` (mới) | Điều khoản ngắn vi + en: nguyên trạng, bản quyền công thức, không phải lời khuyên dinh dưỡng/dị ứng, hẹn giờ, tự giữ sao lưu, EULA chuẩn Apple |
| `docs/COMPLIANCE.md` | Trỏ về tài liệu gốc + STANDARDS của xưởng; phạm vi 2 nền tảng (D-008), sao lưu hệ điều hành bật, 13+; **mở lại P-01..P-05** cho iOS (P-04 không áp dụng); thêm **P-13 (tên, S-71)**, **P-14 (S-30/S-31)**; gắn mã S-xx vào từng dòng; mục 3 ngày kiểm 2026-11-05; **mục 4 mới: bảng đối chiếu S-xx ↔ dòng hồ sơ**, mọi mục còn "chưa" ghi rõ |
| `docs/RELEASE.md` | Dòng Store (cả hai, chưa nộp); mục "Hồ sơ store" trỏ tới các file trên, tên chưa chốt, URL chính sách gợi ý |

## Kết quả tra trùng tên (S-71) — 2026-11-05
**"CookNote" đã bị dùng cho đúng loại app, trên cả 2 store, kể cả ở Việt Nam:**
- Google Play: [CookNote — DEROU Software](https://play.google.com/store/apps/details?id=note.CookNote) (sổ công thức, 10+ lượt tải);
  [Cooknote - Sổ tay nấu ăn — BECEN JOINT STOCK COMPANY](https://play.google.com/store/apps/details?id=com.enetty.cooknote) (tiếng Việt, có quảng cáo, đăng nhập đồng bộ, cập nhật 27/02/2026).
- App Store: [Cooknote - Sổ tay nấu ăn — BECEN](https://apps.apple.com/vn/app/id6758554557) (Food & Drink, 12+);
  [CookNotes: Your Kitchen Helper](https://apps.apple.com/app/id6760633319) (tính năng gần như trùng); [MyCookNote](https://apps.apple.com/fr/app/mycooknote/id6761327357).
- Nhãn hiệu: [WIPO Global Brand Database](https://branddb.wipo.int/en/similarname) — "cooknote": **không có kết quả**. Chưa tra trực tiếp USPTO, Cục SHTT.
- **3 tên đề xuất (Phương quyết, phiên này KHÔNG đổi tên):** **Sổ Bếp** · **Bepbook** (không có kết quả nào trên Play/web/WIPO) ·
  **Bếp Nhớ** (gần âm "Bếp Nhỏ" — nhãn ngành thực phẩm). Chi tiết, link tìm kiếm và lý do loại "Mâm Nhà" (nhãn đã đăng ký ở VN):
  `store/app-store.md` mục "Tra trùng tên".

## Kiểm tra thế nào
- Đọc trang chính thức bằng trình duyệt trong app, **2026-11-05** (link ở cuối `store/google-play.md`, `store/app-store.md`):
  Play — Create and set up your app (30/80/4.000), Add preview assets, Data safety, App testing requirements (12 × 14), Target API level;
  Apple — App information, Platform version information, Age ratings values and definitions, App Privacy Details, Upcoming requirements,
  Screenshot specifications. Khớp STANDARDS v1, trừ 2 điểm ở "Đề xuất cải tiến xưởng".
- `python -I store/check_limits.py` → 18 trường đều OK, exit 0 (bảng ở cuối `store/app-store.md`); keyword EN 98/100 byte, VI 88/100 byte.
  Kiểm cả NFC (chữ Việt dựng sẵn).
- Đối chiếu code (chỉ đọc): `AndroidManifest.xml` (`allowBackup=true`, chưa khai quyền), `res/xml/backup_rules.xml`,
  `data_extraction_rules.xml`, `pubspec.yaml` (không SDK analytics/ads/ML Kit), `ios/Runner/Info.plist` + `project.pbxproj` (chưa commit,
  của phiên iOS), `lib/l10n/app_vi.arb` (nhãn "Sao lưu tự động", "Thùng rác").
- Không chạy `flutter analyze/test` (không đổi code).

## Phương phải làm
1. **Quyết tên app** (giữ "CookNote" có rủi ro, hoặc chọn 1 trong 3 tên) — trước khi tạo trang Play cho closed test.
2. **Quyết xếp hạng tuổi App Store**: A. giữ trình duyệt đầy đủ (AC-16) → 16+ (17+ trên iOS < 26), lệch "13+" của APP.md; hay
   B. thu hẹp trình duyệt (bỏ thanh địa chỉ/ô tìm) → có thể 4+ (sửa AC-16 ở #2). Ghi D-xxx.
3. **Đăng chính sách** (`docs/legal/privacy-policy.md`, tuỳ chọn `terms.md`) và trang hỗ trợ lên GitHub Pages của repo public chung
   `phiotron-legal` (fact `tai-khoan-store`; repo chưa có link) → gửi URL cho phiên code (màn Giới thiệu, AC-63). Chỉ đăng sau khi
   đối chiếu bản build thật (ghi chú nội bộ đầu file).
4. **Email**: đã dùng `phamphuongphuongnd@gmail.com` (fact xưởng, chốt 2026-11-05) cho hỗ trợ + báo lỗi bảo mật. A002 lại in
   `phamphuongphuong@gmail.com` (thiếu "nd") trong chính sách và store — kiểm xem địa chỉ nào đúng. Muốn email bảo mật riêng → thay `[EMAIL_BẢO_MẬT]`.
5. Tài khoản: Apple Developer cá nhân (chưa có) + App ID `com.phiotron.cooknote`; Play: upload keystore ngoài repo; khai DSA trader
   status (đề xuất "không phải trader") và trả lời Content Rights trên App Store Connect (cam kết pháp lý — Phương tự trả lời).
6. Gom 15–20 tester Android ngay (`store/closed-test.md`), gửi thư mời khi bản closed test được duyệt.

## Việc dở / rủi ro (cho phiên điều phối)
- **iPad:** `ios/` hiện `TARGETED_DEVICE_FAMILY = "1,2"` → nếu giữ, App Store bắt ảnh iPad 13" và App Review thử trên iPad. Đề xuất chỉ iPhone ở v1 (việc của phiên iOS).
- **`PrivacyInfo.xcprivacy` chưa có** (P-02) — phiên iOS thêm (tracking false, không loại dữ liệu, API cần lý do).
- **Sao lưu tự động trên iOS:** F-11 dùng `saf_util`/`saf_stream` (chỉ Android) → mô tả App Store cố ý không nhắc "sao lưu tự động vào thư mục". Có bản iOS thì thêm lại.
- **iCloud:** chính sách + mô tả iOS nói dữ liệu nằm trong sao lưu iCloud — đúng chỉ khi DB/ảnh không bị đặt cờ loại khỏi sao lưu. Phiên iOS đổi chỗ lưu thì sửa chính sách mục 3.
- **Quyền Android cuối cùng** (hẹn giờ: foreground service / exact alarm chốt ở G5) → khai báo Play riêng + sửa chính sách mục 4 nếu có.
- **"Xóa toàn bộ dữ liệu" (AC-64)** nên xoá cả cookie/dữ liệu WebView của trình duyệt trong app — chính sách cố ý không hứa điều này; đề xuất thêm vào AC-64 ở #2.
- **NETWORK (MASVS, S-60):** trình duyệt mở được trang `http`; cần quyết chặn cleartext cho "Nhập từ web" hay ghi ngoại lệ (COMPLIANCE S-01).
- Mô tả store liệt kê đủ F-01..F-14; cuối #2 cắt tính năng thì xoá đúng các dòng đã đánh dấu trong `store/google-play.md`.
- IARC: mức tuổi khi trả lời "trình duyệt = Yes" chưa kiểm được (chỉ có trong bảng hỏi Play Console).
- App Store Connect có nhận tên "CookNote: Recipe Notebook" khi đã có "Cooknote - Sổ tay nấu ăn" hay không: chưa thử được (cần tài khoản).

## Đề xuất cải tiến xưởng
1. **STANDARDS / checklist iOS:** (a) keyword App Store là **100 byte**, không phải 100 ký tự — tiếng Việt có dấu tốn 2–3 byte/chữ
   (A002 `store/app-store.md` đếm theo ký tự: keyword VI 96 ký tự = 121 byte, **có thể bị App Store Connect từ chối**); (b) cỡ ảnh iPhone
   bắt buộc trang Apple ghi hôm nay là "Dynamic Island (medium display)" 1206×2622, không phải 6.9"; (c) S-23/S-84: **trình duyệt
   trong app = Unrestricted Web Access → 16+** — thêm vào bước grill: "app có WebView duyệt tự do không?" vì nó quyết xếp hạng tuổi.
2. **Tái dùng `store/check_limits.py`** cho mọi app (đưa vào `playbook/templates/` cùng quy ước nhãn `<!-- field: … -->`): hết đếm tay.
3. **Tra trùng tên ngay ở bước grill phiên #1** (trước khi đặt `android:label`, icon, bundle name) — lần này phát hiện trùng khi app đã
   có tên trong code. Cách tra nhanh đã chạy được: Play search qua trình duyệt, `site:apps.apple.com "<tên>"`, WIPO GBD (URL kết quả
   dựng được bằng `asStructure`).
4. Fact `tai-khoan-store` và bản A002 lệch email (có/không "nd") — chốt một nguồn và rà lại A002.
