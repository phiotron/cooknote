# [A004-cooknote] product.md + CONTEXT.md — báo cáo phiên con A

Phiên điều phối #1 · ngày 2026-11-05 · phạm vi: `product.md`, `CONTEXT.md`, file này.

## Đã làm / file đã đổi
- **`product.md`** (mới, tiếng Anh, ~1.270 dòng): brief gửi Claude Design làm mockup Hi-Fi **toàn bộ app**, theo cấu trúc
  của `A002-vigon/product.md` (bản v2, chi tiết nhất xưởng hiện có). Gồm:
  - §1 tổng quan, 6 persona (gia đình, sinh viên, làm bánh, thiếu niên 14 tuổi, người dùng quốc tế chuyển từ app khác,
    người lớn tuổi chữ 200 %), 7 việc chính theo thứ tự ưu tiên, 9 nguyên tắc, bảng khác biệt S-30 (miễn phí mọi tính
    năng, dữ liệu trọn đời bằng định dạng mở, tiếng Việt chuẩn) + lệnh "không bắt chước đối thủ".
  - §2 ràng buộc: khung 360×800 dp + 393×852 pt, chỉ dọc; **bản sắc đề xuất "sổ tay bếp ấm"** (giấy ấm, mực, ruy-băng,
    tab sổ; tối = "bếp ban đêm"; font đủ dấu tiếng Việt, Noto Sans đã có; tránh mũ đầu bếp/ớt/dao nĩa; icon dùng được
    khi đổi tên vì "CookNote" chưa tra nhãn hiệu); WCAG 2.2 AA (48 dp, 64 dp trong chế độ nấu, 200 %, 4.5:1, nhãn đọc);
    mục riêng "dùng trong bếp" (xa 1 m, tay ướt); bảng 18 chuỗi dài nhất EN|VI; quy ước số/phân số/đơn vị/ngày.
  - §3 45 luật nghiệp vụ chép sát SPEC (có mã AC).
  - §4 kiến trúc thông tin, route hiện có + dự kiến, luật điều hướng.
  - §5 **58 màn (SCR-00..57) + 6 bề mặt ngoài app (EXT-01..06**: thông báo hẹn giờ, CookNote trong bảng chia sẻ, chỗ
    giữ chỗ cho picker hệ điều hành, icon, **PDF sách công thức**, **trang HTML trong file sao lưu**). Mỗi màn: mục
    đích, thành phần, mọi trạng thái (trống, đang tải, lỗi, không mạng, quyền bị từ chối…), tương tác, chữ EN|VI (khoá
    `.arb` thật, chữ mới ghi `NEW:`), a11y, mã AC.
  - §6 9 luồng prototype (F1 chia sẻ link → lưu + 3 biến thể; F2 nấu có hẹn giờ; F3 thực đơn tuần → đi chợ; F4 sao lưu
    lần đầu 3 đường; F5 quét chữ viết tay; F6 đổi máy; F7 nấu được gì → đi chợ; F8 nhân ½× + đổi hệ mét; F9 xoá/hoàn tác).
  - §7 bảng khác biệt Android/iOS (Back, nhận chia sẻ, bảng chia sẻ, chọn thư mục sao lưu, lớp sao lưu hệ điều hành,
    thông báo, hướng dẫn giọng đọc, in, picker ảnh).
  - §8 dữ liệu mẫu: 10 công thức (5 Việt, 4 Anh, 1 trong thùng rác) có nguyên liệu/bước đầy đủ cho 3 món, 2 danh sách
    đi chợ có món gộp, tủ bếp có "sắp hết hạn"/"hết hạn" đúng theo ngày 2026-11-05, thực đơn tuần 2–8/11, mẫu thực đơn,
    trạng thái sao lưu. Tên miền dùng `.example`.
  - §9 10 rủi ro UX → cơ hội thiết kế; §10 ngoài phạm vi + đề xuất (tách trang riêng, không nối vào luồng).
  - §11 bàn giao: ưu tiên P1/P2/P3, danh sách khung (VI, 200 %, stress, kiểm "nhìn từ xa"), quy tắc tên file
    `design/hifi/<platform>/<theme>/<NN>_<slug>__<state>.png`, bảng slug, trang design system (token → `ColorScheme` +
    `ThemeExtension CookNoteColors`, thang chữ có kiểu riêng cho chế độ nấu), định dạng xuất, lưu `design/hifi/`.
- **`CONTEXT.md`** (mới, tiếng Việt, dạng A001): ~60 thuật ngữ chia 8 nhóm (công thức & tổ chức, nhập, nấu, đi chợ,
  thực đơn, tủ bếp, chia sẻ/xuất, sao lưu, app). Mỗi dòng: tên code, chữ VI, định nghĩa, "tránh dùng", mã AC. Không có
  chi tiết cài đặt. Tách rõ các cặp dễ lẫn: Cross off (nấu) ↔ Check off (đi chợ); Merge (đi chợ) ↔ Merge (khôi phục);
  Favorite ↔ Pinned recipe; Duplicate (nhân bản) ↔ Duplicate URL; Export ↔ Backup; Backup reminder ↔ Backup suggestion;
  Category ↔ Aisle.
- Không sửa file nào khác.

## Kiểm tra thế nào
- Đọc lại SPEC F-01..F-14 từng AC, đối chiếu với màn (bảng dưới). Chạy script kiểm mọi AC-01..AC-65 đều có ít nhất
  một lần nhắc trong `product.md` → không thiếu mã nào.
- Chữ hiển thị: lấy từ `lib/l10n/app_en.arb`/`app_vi.arb` (`main`) và chữ của 3 nhánh UI dở (`wip/g4-web-import`,
  `wip/g5-cook`, `wip/g9-exchange`, đọc bằng `git diff main...<nhánh>`, không checkout). Chữ chưa có ghi `NEW:` kèm bản VI.
- Luồng cũ đối chiếu: `home_screen.dart` (5 tab, FAB, bảng "+", mục Thêm), `recipe_list.dart` (lưới/dòng), editor
  (ô nhiều dòng, chưa kéo thả), `cook_store.dart` ở `wip/g5-cook` (bước hiện tại = bước đầu chưa gạch; gạch giữ 12 giờ;
  ghim lưu ở settings), `meal_planner.dart` (thực đơn mẫu theo ngày lệch, mục có công thức hoặc chữ tự do, khẩu phần
  riêng), `line_classifier.dart` (gợi ý vai trò dòng khi quét: title/ingredient/step/heading/note/noise).

### Bảng AC ↔ màn (chỉ AC có giao diện; [T]-only ghi "không có UI riêng")
| AC | Nội dung ngắn | Màn / mục trong product.md |
|---|---|---|
| AC-01 | 5 tab, nút + mở 4 lựa chọn | §4.1, SCR-02, SCR-03, SCR-46 |
| AC-02 | trường của công thức, thiếu tên không lưu | §3.1, SCR-11 (lỗi "Enter a name", bộ đếm 200) |
| AC-03 | dán khối chữ, dòng `:` thành nhóm, kéo thả, hỏi bỏ thay đổi | SCR-11 (chế độ Text/Lines, tay kéo, Move up/down, hộp "Discard changes?") |
| AC-04 | lưu trong một giao dịch | không có UI riêng (SCR-11 nút Save) |
| AC-05 | xoá có xác nhận + Hoàn tác 5 s, thùng rác 30 ngày, khôi phục | SCR-07 (Delete), SCR-57 snackbar, SCR-13, SCR-06 |
| AC-06 | nhân bản | SCR-07 overflow + snackbar "Duplicate created" |
| AC-07 | ảnh qua picker hệ điều hành, không xin quyền | SCR-11 dải ảnh, EXT-03 |
| AC-08 | chụp bằng app camera hệ điều hành, huỷ không đổi gì | SCR-11, SCR-19, EXT-03 |
| AC-09 | xem: ảnh bìa, thông tin, URL chạm được, ảnh toàn màn | SCR-07, SCR-10 |
| AC-10 | danh mục 3 cấp, kéo sắp xếp, 6 mặc định | SCR-14, SCR-12, §8.2 |
| AC-11 | thẻ + gợi ý | SCR-11, SCR-12 |
| AC-12 | tìm không dấu | SCR-02 |
| AC-13 | lọc kết hợp, sắp xếp, đếm kết quả | SCR-02, SCR-04, SCR-05 |
| AC-14 | lưới/dòng, nhớ lựa chọn | SCR-02 |
| AC-15 | đánh dấu đã nấu, số lần + lần gần nhất | SCR-07, SCR-23 (trạng thái "All steps done") |
| AC-16 | trình duyệt: địa chỉ, tìm, Back/Forward, Lưu luôn hiện | SCR-15 |
| AC-17 | chia sẻ URL → nhập; chữ → màn soạn | SCR-18, SCR-11 (banner chữ chia sẻ), EXT-02, F1 |
| AC-18 | tự điền từ schema.org | SCR-17 (trạng thái "full schema data") |
| AC-19 | chọn đoạn | SCR-16, F1c |
| AC-20 | xem trước, giữ URL, báo trùng URL | SCR-17 (hộp trùng), F1b |
| AC-21 | chờ 20 s, lỗi rõ + Thử lại, không mất phần đã nhập | SCR-15 (4 loại lỗi), SCR-16, F1d |
| AC-22 | tải ảnh web về máy | SCR-17 (tiến độ tải ảnh, bỏ qua ảnh, ảnh lỗi) |
| AC-23 | 1–10 ảnh/camera/PDF, nhận chữ trên máy | SCR-19, SCR-20 |
| AC-24 | gán dòng Tên/NL/Bước/Ghi chú, sửa chữ, giữ ảnh gốc | SCR-21, F5 |
| AC-25 | không cam kết chữ viết tay, màn gán nói rõ | SCR-21 (ghi chú luôn hiện), SCR-20 |
| AC-26 | chế độ nấu: sáng màn, chữ lớn chỉnh được, bước nổi bật, gạch, giữ 12 h | SCR-23, F2 |
| AC-27 | nhận thời lượng thành nút hẹn giờ | SCR-23 (nút trong bước), SCR-07 (chip mờ), §8 R1/R2/R8 |
| AC-28 | nhiều hẹn giờ, chuông + thông báo, xin quyền lần đầu có giải thích, từ chối vẫn chạy + cảnh báo | SCR-24, SCR-25, EXT-01, F2b |
| AC-29 | ghim ≤ 5 | SCR-23 thanh ghim, F2c |
| AC-30 | đọc bước, thiếu giọng → hướng dẫn | SCR-26, §7 |
| AC-31 | tách nguyên liệu có cấu trúc | §2.6, §3.20 (không có UI riêng) |
| AC-32 | nhân khẩu phần, số gọn, dòng không cấu trúc có dấu, chỉ xem, "Lưu theo khẩu phần này" | SCR-08, SCR-07, F8 |
| AC-33 | đổi hệ mét/Mỹ, °C↔°F, không đổi chén/bát | SCR-08, F8 |
| AC-34 | nhiều danh sách, gợi ý, món hay mua | SCR-27, SCR-28, SCR-29 |
| AC-35 | thêm từ công thức/thực đơn, bỏ chọn món có trong tủ, gộp, ghi nguồn | SCR-32, SCR-30, SCR-27 (chú thích nguồn) |
| AC-36 | khu vực tự xếp, nhớ khi chuyển, thêm/đổi tên/sắp xếp | SCR-27, SCR-29, SCR-30, SCR-31 |
| AC-37 | gạch, xuống cuối, xoá món đã gạch + chuyển vào tủ, chia sẻ chữ | SCR-27, SCR-33 |
| AC-38 | lịch ngày/tuần/tháng, bữa đổi được, công thức hoặc chữ, kéo thả, ngày đầu tuần | SCR-34, 35, 36, 37, 38, 42, SCR-53 |
| AC-39 | thực đơn mẫu, áp một thao tác | SCR-39, F3 |
| AC-40 | khoảng ngày → đi chợ | SCR-41 → SCR-32, F3 |
| AC-41 | gợi ý ngẫu nhiên, không lặp, xem trước | SCR-40, F3 |
| AC-42 | tủ bếp, sắp hết hạn/hết hạn, lọc | SCR-43, SCR-44, §8.4 |
| AC-43 | nấu được gì, còn thiếu N, gia vị cơ bản | SCR-45, SCR-53, F7 |
| AC-44 | nhập Paprika/Recipe Keeper, báo kết quả | SCR-22 |
| AC-45 | nhập/xuất .cooknote và JSON | SCR-22, SCR-06, SCR-52 |
| AC-46 | chia sẻ chữ/PDF/.cooknote | SCR-09, SCR-06, EXT-05 |
| AC-47 | PDF sách công thức, in | SCR-52, SCR-14 (từ danh mục), EXT-05 |
| AC-48 | không xin quyền bộ nhớ, dọn file tạm | SCR-09 (không có hộp quyền); dọn file tạm không có UI |
| AC-49 | định dạng `.cooknote` mở + HTML | SCR-47 (câu "đọc bằng trình duyệt"), EXT-06 |
| AC-50 | sao lưu tự động: chọn thư mục 1 lần, chu kỳ, giữ N bản | SCR-47, SCR-48, F4 |
| AC-51 | đọc lại kiểm mã băm; mất quyền → cảnh báo ở màn Công thức | SCR-47 (lỗi verify), SCR-51 (Failing), SCR-02 |
| AC-52 | sao lưu ngay lưu ở nơi khác | SCR-47, SCR-48 (đường dự phòng), F4 C |
| AC-53 | trạng thái lần thành công gần nhất; nhắc > 7 ngày; gợi ý ở 10 công thức | SCR-47, SCR-51, SCR-46 |
| AC-54 | khôi phục: kiểm trước, thay thế/gộp, lỗi giữ dữ liệu | SCR-50, SCR-22 (.cooknote), F6 |
| AC-55 | định dạng chỉ mở rộng | SCR-50 (lỗi "file do bản mới hơn tạo"); phần còn lại không có UI |
| AC-56 | lớp Android Auto Backup, màn Sao lưu nói rõ | SCR-47 (ghi chú Android + biến thể iOS), §7 |
| AC-57 | 1.000 công thức/2.000 ảnh: tiến độ, huỷ được | SCR-49, SCR-50 |
| AC-58 | sáng/tối/hệ thống, vi/en, ngày đầu tuần, hệ đơn vị | SCR-53, §2.5, §2.6 |
| AC-59 | màn chào ≤ 3 trang, bỏ qua, không xin quyền, nút bật sao lưu | SCR-01, F4 A |
| AC-60 | vùng chạm ≥ 48 dp | §2.3, §2.4, SCR-57, §11.4 (`tapMin`, `tapCook`) |
| AC-61 | chữ 200 %, tương phản | §2.3, §11.2 (khung 200 %), §11.4 (tỉ lệ tương phản mỗi cặp token) |
| AC-62 | TalkBack/VoiceOver đọc nút, nguyên liệu, bước + đã gạch, sao, thời gian hẹn giờ | §2.3 + mục A11y từng màn (SCR-07, 23, 24…) |
| AC-63 | màn Giới thiệu | SCR-55, SCR-56 |
| AC-64 | xoá toàn bộ dữ liệu | SCR-54, SCR-53 |
| AC-65 | không gửi dữ liệu | §1.5, SCR-19 (nhận chữ trên máy), SCR-46 footer, SCR-55 (câu tóm tắt) |

## Việc dở / câu hỏi cần Phương quyết (KHÔNG tự đổi phạm vi SPEC)
Những chỗ dưới đây SPEC chưa nói rõ. Trong `product.md` tôi đã chọn cách hiểu ghi ở cột "Đang ghi", Claude Design
vẽ theo đó; Phương duyệt hoặc đổi trước khi gửi.

| # | Câu hỏi | Đang ghi trong product.md |
|---|---|---|
| Q1 | Link chính sách quyền riêng tư và email báo lỗi bảo mật (AC-63) là gì? (phiên con E đang làm store & pháp lý) | Để chỗ giữ chỗ, dặn Claude Design không tự đặt tên miền |
| Q2 | Chế độ nấu có giữ khẩu phần/đơn vị đang xem ở màn xem công thức không? | Có (chip "×2 · Metric" trong chế độ nấu, mở được SCR-08) |
| Q3 | Áp thực đơn mẫu vào ngày/bữa đã có món thì sao? | **Thêm vào**, món cũ giữ nguyên, có Hoàn tác |
| Q4 | Một bữa chứa được nhiều món? | Có (0..n món — hợp mâm cơm Việt "4 món") |
| Q5 | Tủ bếp dùng chung bộ khu vực với đi chợ? | Có (cùng danh sách Aisle) |
| Q6 | Ngày đầu tuần có những lựa chọn nào? | Thứ Hai / Chủ nhật (khớp `weekDates` hiện có) |
| Q7 | URL trong bước/ghi chú và "nguồn" mở bằng trình duyệt trong app hay trình duyệt hệ thống? | Không chốt; code hiện dùng `url_launcher` (hệ thống) |
| Q8 | "Trùng URL" có tính công thức đang ở Thùng rác không? | Ghi là chưa chốt trong CONTEXT.md |
| Q9 | Hẹn giờ chỉ có Huỷ, hay thêm "+1 phút"/tạm dừng? | Chỉ Huỷ (đúng SPEC); không vẽ thêm |
| Q10 | Quét ảnh bằng camera: dùng app camera của hệ điều hành (không xin quyền `CAMERA`) như AC-08? Phiên con D (OCR Android) cần xác nhận | Có — "OS camera", không có hộp xin quyền camera |
| Q11 | Nhận chia sẻ trên iOS cần Share Extension (phiên con B iOS/CI cần biết) — có làm ở v1? | Có (AC-17 áp dụng cả iOS theo D-008); có đề xuất thẻ "Đã lưu vào CookNote" ở §10 |
| Q12 | Số ngày nhắc sao lưu (mặc định 7) chỉnh ở đâu? | Màn Sao lưu, dòng "Remind me after {n} days" |
| Q13 | Thêm "Empty trash" (dọn sạch thùng rác) có được không? SPEC không cấm, không yêu cầu | Ghi `NEW` ở SCR-13, có xác nhận — Phương bỏ nếu không muốn |
| Q14 | SPEC §2/§4 còn ghi "iPhone ở bản sau (D-001)" — đã bị D-008 thay; nên sửa SPEC cho khỏi lệch | product.md theo D-008 (Android + iOS) |

Rủi ro: `product.md` dài (~1.270 dòng). Nếu Claude Design làm một lượt không hết, gửi theo ưu tiên P1 → P2 → P3 ở §11.1.

## Đề xuất cải tiến xưởng
1. **Mẫu `product.md` cấp xưởng**: A002 v2 và file này đã cùng một khung (Contents 11 mục, thẻ trạng thái màn, bảng
   chuỗi dài EN|VI, quy tắc tên file `design/hifi/<platform>/<theme>/<NN>_<slug>__<state>`, design system map sang
   Flutter `ColorScheme` + `ThemeExtension`). Nên đưa thành `playbook/templates/product.md` — lần sau chỉ điền.
2. **Bảng AC ↔ màn** nên là mục bắt buộc của báo cáo phiên product.md (làm ở đây mất ít công, nhưng giúp phiên #2 chia
   nhóm màn cho G1..G6 ngay).
3. **Chữ ở nhánh UI dở**: lệnh `git diff main...<nhánh> -- lib/l10n/app_en.arb | grep '^+ '` lấy được toàn bộ copy đã
   viết mà không checkout — ghi vào fact `nhap-app-tu-ngoai.md` cho app nhập từ ngoài.
4. Nên thêm vào STANDARDS/PLAYBOOK một dòng "app có chế độ dùng khi tay bận (bếp, gym, lái xe…) phải có mục ràng buộc
   riêng trong product.md" (vùng chạm ≥ 64 dp, đọc từ xa, không cử chỉ chính xác).

## Cập nhật 2026-11-05 (lượt 2): áp câu trả lời Q1–Q14 (D-009, SPEC commit 5d1d9b7)
`product.md` lên **Brief v1.1**. Cách đã sửa theo từng câu:

| # | Quyết định của Phương | Đã sửa ở đâu |
|---|---|---|
| Q1 | Email liên hệ/báo lỗi bảo mật = phamphuongphuongnd@gmail.com; link chính sách vẫn chờ | §3 luật 43; SCR-55 (dòng "Contact & security reports" hiện email thật, link chính sách chỉ vẽ dòng, không URL); CONTEXT "About" |
| Q2 | Đồng ý: chế độ nấu giữ khẩu phần/đơn vị đang xem | §3 luật 15; SCR-23 (chip mang từ màn xem); CONTEXT "Cook mode" |
| Q3 | **Khác đề xuất:** đã có món thì hỏi "Thay thế" / "Thêm vào" | §3 luật 27; SCR-39 có hộp hỏi (bản ngày + bản tuần, chữ EN/VI), trạng thái sau Thay thế và sau Thêm vào; slug `menu-templates~replace-or-add`; CONTEXT "Menu template" |
| Q4, Q5, Q6 | Đồng ý (bữa nhiều món; tủ bếp chung khu vực; Thứ Hai/Chủ nhật) | §3 luật 24, 26; CONTEXT "Aisle", "Meal plan" (đã ghi từ lượt 1, nay bỏ dạng giả định) |
| Q7 | **Khác đề xuất:** URL trong bước, ghi chú, URL nguồn mở bằng trình duyệt trong app | §3 luật 4b; SCR-07 mục 7–8; SCR-15 (mục đích + trạng thái "mở từ công thức", chữ "From: {recipe}"); luồng F1f; slug `web~from-recipe`; CONTEXT "Step", "In-app browser" |
| Q8 | Trùng URL tính cả Thùng rác; cho Khôi phục / Lưu bản mới | §3 luật 10; SCR-17 thêm hộp "This recipe is in the trash" (chữ EN/VI), luồng F1b-trash, slug `web-preview~duplicate-trash`; CONTEXT "Duplicate URL" (bỏ "chưa chốt") |
| Q9 | Đồng ý: hẹn giờ chỉ có Huỷ | §3 luật 17; §10 "Decided, do not draw"; CONTEXT "Step timer" |
| Q10 | Camera hệ điều hành, không xin quyền CAMERA | §3 luật 13; SCR-19; CONTEXT "Scan" |
| Q11 | iOS Share Extension đã có (9b646df); giữ thẻ "Đã lưu vào CookNote" | §7 bảng (vẽ thẻ, chữ EN/VI); EXT-02 (slug `ext-share-target~ios-card`); luồng F1e; bỏ khỏi danh sách đề xuất §10; CONTEXT "Shared link" |
| Q12 | Đồng ý: số ngày nhắc chỉnh ở màn Sao lưu | §3 luật 37; CONTEXT "Backup reminder" |
| Q13 | Có "Dọn sạch thùng rác" có xác nhận | §3 luật 3; SCR-13 (nút ở app bar, hộp xác nhận, snackbar, chữ EN/VI, ẩn khi trống); slug `trash~empty`; CONTEXT "Trash" |
| Q14 | SPEC đã sửa sang Android + iOS | product.md vốn theo D-008, không cần sửa |

Không còn câu hỏi mở nào từ lượt 1. Chỗ tôi tự quyết khi áp (Phương xem lại nếu muốn khác):
- Q3 "Thay thế" chỉ xoá món ở **các bữa mà thực đơn mẫu điền vào**, không xoá cả ngày/tuần; áp xong có Hoàn tác.
- Q7 chỉ áp cho link trong công thức; dòng "Chính sách quyền riêng tư" ở màn Giới thiệu ghi trung tính "mở trang web"
  (D-009 không nói tới link này).
