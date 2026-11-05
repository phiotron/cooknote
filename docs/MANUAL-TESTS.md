# Bepbook — Thử máy thật (biên bản + việc người dùng cần thử)

> Nơi ghi biên bản các AC đánh dấu **[M]** trong `SPEC.md` và việc người dùng tự thử trên máy (không adb, D-008).
> Bảng AC ↔ cách kiểm: `TESTING.md`. Ý tưởng ngoài SPEC (chưa duyệt): cuối file.

## Biên bản thử máy thật
Mỗi lần thử: ngày · máy và phiên bản hệ điều hành · bản app · đã thử gì · kết quả · lỗi phát hiện.
(Chưa có lần nào.) Máy đề nghị: Galaxy A13 (Android, 32-bit nên build không dùng `--target-platform android-arm64`).

## Việc cần thử trước tiên (rủi ro số 1)
**Sao lưu vào thư mục Google Drive/OneDrive** (SPEC mục 7, D-007): Android có cho ghi định kỳ vào thư mục chọn qua SAF không?
Ghi lại nơi nào không ghi được. Nếu Drive không nhận thì sao lưu tự động chỉ ghi vào thư mục trên máy; khi đó nhắc sao lưu
(AC-53) và "Sao lưu ngay" lên Drive là lớp chính.

### Sao lưu và khôi phục (F-11) — CHƯA kiểm chứng trên máy thật
Mục Thêm > Sao lưu.
- Chọn thư mục tự động LẦN LƯỢT: một thư mục trên máy, một trong Google Drive, một trong OneDrive (nếu có). Mỗi nơi: bấm "Sao lưu
  vào thư mục ngay" thì phải thấy file `CookNote-….cooknote` (tên mẫu file giữ nguyên, D-010) và thông báo "Đã sao lưu".
- Tắt hẳn app, mở lại: không sao lưu trùng (dữ liệu không đổi). Thêm một công thức rồi sang ngày sau hoặc đổi chu kỳ để thử tự động.
- "Sao lưu ngay và lưu ở nơi khác": mở bảng chia sẻ, lưu vào Tệp hoặc Drive.
- Khôi phục: từ danh sách trong thư mục, và từ file qua "Khôi phục từ file…". Thử cả "Gộp" và "Thay thế toàn bộ". Chọn một file
  ảnh bất kỳ (không phải sao lưu) thì phải báo lỗi và không đổi dữ liệu.
- Đổi đuôi `.cooknote` thành `.zip` trên máy tính, mở `html/index.html` bằng trình duyệt: đọc được công thức, có ảnh.
- Gỡ app (hoặc xóa dữ liệu) rồi cài lại, khôi phục từ file: mọi công thức và ảnh trở lại (SPEC mục 8).

### Tổ chức, tìm kiếm, lọc (F-02) — CHƯA kiểm chứng trên máy thật
Cài đè APK mới lên bản trước: dữ liệu cũ phải còn (migration đã kiểm bằng test trên máy tính, chưa thử trên máy).
- AC-10: Thêm > Danh mục: 6 danh mục mặc định theo ngôn ngữ; thêm, đổi tên, xóa, kéo tay cầm đổi thứ tự; lồng 3 cấp thì cấp 3
  không còn mục "Thêm danh mục con".
- AC-10, AC-11: khi soạn công thức chọn danh mục (nhiều mục) và gõ thẻ (gợi ý hiện khi gõ, dấu phẩy hoặc Xong để thêm).
- AC-12: ô tìm: gõ "pho bo" ra "Phở bò"; thử tìm theo nguyên liệu, bước, ghi chú, nguồn.
- AC-13: nút Lọc (danh mục, thẻ, sao, yêu thích, thời gian, nguyên liệu) kết hợp ô tìm; số công thức khớp; menu Sắp xếp đủ sáu kiểu
  và đảo chiều.
- AC-14: nút xem lưới/dòng, tắt hẳn app mở lại vẫn giữ.
- AC-15: màn xem công thức: nút "Đánh dấu đã nấu", số lần và lần gần nhất.
- Màn soạn công thức trên màn 360 dp: hàng "Đánh giá" không còn bị tràn.

### Công thức, ảnh (F-01) — CHƯA kiểm chứng trên máy thật
- AC-01: thanh dưới có 5 mục; nút "+" trong vùng ngón cái; bấm "+" ra bảng chọn.
- AC-02, AC-04: thêm công thức đủ trường, tắt hẳn app, mở lại vẫn còn.
- AC-03: dán khối chữ nhiều dòng vào Nguyên liệu (dòng cuối bằng `:` là tiêu đề nhóm); nhập tên rồi bấm Back hệ thống thì hỏi "Bỏ thay đổi?".
  Còn mở: kéo thả dòng (AC-03).
- AC-05, AC-06: xóa, thanh Hoàn tác 5 giây, thùng rác, khôi phục, nhân bản.
- AC-07: thêm ảnh từ thư viện (nhiều ảnh) và chụp bằng camera; không có hộp xin quyền bộ nhớ hay thư viện ảnh; ảnh chụp có định vị thì
  ảnh trong app không còn vị trí.
- AC-09: chạm ảnh xem toàn màn hình, vuốt chuyển ảnh, chụm hai ngón phóng to; liên kết trong ghi chú chạm được.
- Chế độ máy bay: toàn bộ chức năng trên vẫn dùng được.

Các tính năng thêm sau (nhập web, chế độ nấu, đi chợ, tủ bếp, thực đơn, OCR, nhập/xuất file) chưa có mục thử ở đây; thêm khi làm
phiên #2. OCR Android: xem `../notes/2026-11-05-ocr-android.md`.

## Ý tưởng ngoài SPEC (chưa được duyệt, KHÔNG tự làm)
- Đồng bộ nhiều máy qua Google Drive của người dùng (đăng nhập Google, thư mục dữ liệu riêng của app). Ưu tiên cao nếu thử Drive cho thấy
  không ghi tự động vào thư mục được (D-002).
- Sao lưu có mã hóa bằng mật khẩu do người dùng đặt.
- Khóa app bằng PIN hoặc sinh trắc học.
- Nhập file của CookBook – Recipe Manager khi có file mẫu.
- Tính dinh dưỡng tự động từ cơ sở dữ liệu thực phẩm; đổi thể tích sang khối lượng theo từng nguyên liệu.
- Nhắc món trong Tủ bếp sắp hết hạn bằng thông báo hệ thống.
- Chữ đậm, nghiêng trong các bước.
- Widget màn hình chính (công thức ghim, thực đơn hôm nay).
