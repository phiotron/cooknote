# BACKLOG — CookNote (APP-005)

Nguồn sự thật về việc cần làm. Claude đọc đầu phiên, cập nhật cuối phiên (`/end`). Việc chưa xong ghi dạng "[ ] ..." đầu dòng sau dấu gạch; xong đổi thành "[x]". `scripts/status.sh` đếm các việc chưa xong.

## Giai đoạn xây dựng
Chia SPEC thành các giai đoạn nhỏ (mỗi giai đoạn: làm được trong một vài phiên, kiểm chứng được độc lập). Ghi dạng:
"### G1 · tên — trạng thái: done (code, lint, test đạt; còn thử máy thật ở cổng) | doing | done", dưới đó là các việc, mỗi việc gắn AC liên quan.

Hai lý do đặt sao lưu sớm (G3): người dùng ưu tiên giữ dữ liệu lâu dài, và cần thử sớm rủi ro Google Drive (SPEC mục 7). Định dạng sao lưu mở rộng dần khi các giai đoạn sau thêm dữ liệu (AC-55). Cuối mỗi giai đoạn: chạy `/check-ac`, thử trên máy thật (Galaxy A13) và ghi biên bản (L-003).

### G1 · Nền dự án, công thức, ảnh — trạng thái: done (code, lint, test đạt; còn thử máy thật ở cổng)
- [x] Khởi tạo dự án Flutter Android trong thư mục app (không ghi đè tài liệu), chạy `flutter doctor`. Chốt phiên bản Flutter, Riverpod, go_router, drift, gen-l10n (D-004 trở đi). Hỏi người dùng tên gói Android
- [x] Chạy thử từng lệnh của hồ sơ stack, chỉ ghi lệnh chạy được vào mục "Lệnh" của CLAUDE.md (L-009)
- [x] Mô hình dữ liệu: công thức, nhóm nguyên liệu và bước, ảnh, thùng rác (AC-02, AC-04, AC-05)
- [x] Thanh điều hướng 5 mục, màn danh sách tối thiểu, nút "+" (AC-01)
- [x] Màn soạn: tách khối chữ thành dòng và nhóm, hỏi khi bấm Back (AC-03)
- [ ] Kéo để sắp xếp dòng nguyên liệu và bước (AC-03): CHƯA làm. Ô nhập nhiều dòng không kéo được từng dòng; cần đổi thiết kế (danh sách dòng kéo thả) nên hỏi người dùng trước, xem G2
- [x] Sửa, xóa có hoàn tác, thùng rác 30 ngày, nhân bản (AC-05, AC-06)
- [x] Ảnh (AC-07, AC-08):
  - Trình chọn ảnh hệ thống; chụp bằng ứng dụng camera của hệ điều hành nên không có quyền camera để xin (D-005; lệch AC-08, chờ người dùng đồng ý).
  - Chép vào bộ nhớ riêng, thu nhỏ còn 2048 px, bỏ EXIF vị trí.
  - Dọn file thừa.
- [x] Màn xem công thức, xem ảnh toàn màn hình (AC-09)
- [x] Chuỗi giao diện nằm trong file .arb vi/en ngay từ đầu (một phần AC-58)
- [x] Build APK release đủ kiến trúc (L-011), kiểm quyền trong manifest đã build (một phần AC-65)

### G2 · Tổ chức, tìm kiếm, lọc — trạng thái: todo
- [ ] Nếu người dùng chọn: màn soạn dạng danh sách dòng kéo thả cho nguyên liệu và bước (AC-03)
- [ ] Danh mục lồng 3 cấp, danh mục mặc định, thẻ có gợi ý (AC-10, AC-11)
- [ ] Tìm không phân biệt dấu trên tên, nguyên liệu, bước, ghi chú, nguồn; đo với 5.000 công thức (AC-12, NFR)
- [ ] Bộ lọc kết hợp, sắp xếp, đếm kết quả (AC-13)
- [ ] Xem dạng lưới hoặc dòng, nhớ lựa chọn (AC-14)
- [ ] Lịch sử "Đã nấu" (AC-15)

### G3 · Sao lưu bền lâu và khôi phục — trạng thái: todo
- [ ] Viết `docs/BACKUP-FORMAT.md` phiên bản 1. Tạo gói `.cooknote` gồm manifest, mã băm, ảnh, và HTML đọc được không cần app (AC-49)
- [ ] Thử thật quyền ghi thư mục lâu dài trên Galaxy A13 với thư mục trên máy, Google Drive, OneDrive; ghi kết quả và D-xxx (SPEC mục 7, AC-50)
- [ ] Sao lưu tự động theo chu kỳ khi mở app hoặc vào nền, xoay vòng N bản, chỉ xóa file của mình (AC-50)
- [ ] Đọc lại và kiểm mã băm sau khi ghi; cảnh báo khi mất quyền ghi (AC-51)
- [ ] "Sao lưu ngay" qua bảng chia sẻ hoặc trình lưu file (AC-52)
- [ ] Màn Sao lưu: lần gần nhất, dung lượng, nhắc khi quá 7 ngày, gợi ý bật khi có 10 công thức (AC-53)
- [ ] Khôi phục: kiểm trước, thay thế hoặc gộp, tự sao lưu trước khi thay thế (AC-54)
- [ ] Đưa file mẫu phiên bản 1 vào `test/`; test khôi phục chạy trên mọi phiên bản định dạng (AC-55)
- [ ] Android Auto Backup: tra giới hạn hiện hành, chỉ cấu hình cơ sở dữ liệu và cài đặt, thử đổi máy hoặc cài lại (AC-56)
- [ ] Đo sao lưu và khôi phục 1.000 công thức có 2.000 ảnh, có thanh tiến độ, hủy được (AC-57). Quyết có cần sao lưu tăng dần không (SPEC mục 7)

### G4 · Nhập công thức từ web — trạng thái: todo
- [ ] Trình duyệt trong app có nút "Lưu công thức" (AC-16)
- [ ] Nhận URL và chữ qua "Chia sẻ" từ app khác (AC-17)
- [ ] Đọc schema.org Recipe: JSON-LD, @graph, HowToSection, microdata, thời gian ISO 8601. Bộ trang mẫu offline trong `test/` (AC-18)
- [ ] Chế độ "Chọn đoạn" cho trang không có dữ liệu Recipe (AC-19)
- [ ] Màn xem trước, giữ nguồn, phát hiện URL trùng (AC-20)
- [ ] Thời gian chờ 20 giây, báo lỗi và thử lại; thử ở chế độ máy bay (AC-21)
- [ ] Tải ảnh về máy (AC-22); kiểm lại manifest chỉ thêm `INTERNET` (AC-65)

### G5 · Chế độ nấu, khẩu phần, đơn vị, hẹn giờ — trạng thái: todo
- [ ] Bộ tách nguyên liệu có cấu trúc vi/en, bộ 100 dòng mẫu thật (AC-31)
- [ ] Nhân khẩu phần, hiện số gọn, "Lưu theo khẩu phần này" (AC-32)
- [ ] Đổi hệ mét và hệ Mỹ, °C và °F (AC-33)
- [ ] Chế độ nấu: màn hình sáng, chữ lớn, gạch dòng, giữ trạng thái 12 giờ (AC-26)
- [ ] Nhận thời gian trong bước thành nút hẹn giờ (AC-27)
- [ ] Nhiều hẹn giờ, báo cả khi máy khóa (AC-28). Tra chính sách Google Play về báo giờ chính xác và dịch vụ chạy nền, ghi D-xxx, hỏi người dùng trước khi thêm quyền
- [ ] Ghim tối đa 5 công thức (AC-29); đọc bước bằng giọng đọc của hệ điều hành (AC-30)

### G6 · Danh sách đi chợ và tủ bếp — trạng thái: todo
- [ ] Nhiều danh sách, gợi ý món, "Món hay mua" (AC-34)
- [ ] Thêm từ công thức, gộp món trùng cùng loại đơn vị, bỏ chọn món có trong Tủ bếp (AC-35)
- [ ] Khu vực tự xếp theo từ điển vi/en, nhớ lựa chọn của người dùng, sắp xếp khu vực (AC-36)
- [ ] Gạch, xóa món đã gạch, chuyển vào Tủ bếp, chia sẻ dạng chữ (AC-37)
- [ ] Tủ bếp: hạn dùng, sắp hết hạn, hết hạn (AC-42)
- [ ] "Nấu được gì?" (AC-43)
- [ ] Mở rộng định dạng sao lưu lên phiên bản 2, thêm file mẫu vào `test/` (AC-55)

### G7 · Lịch thực đơn và thực đơn mẫu — trạng thái: todo
- [ ] Lịch ngày, tuần, tháng; bữa tùy chỉnh; kéo để chuyển món (AC-38)
- [ ] Thực đơn mẫu, áp vào ngày hoặc tuần (AC-39)
- [ ] Đẩy nguyên liệu của một khoảng ngày sang đi chợ (AC-40)
- [ ] Gợi ý ngẫu nhiên theo bộ lọc (AC-41)
- [ ] Mở rộng định dạng sao lưu, thêm file mẫu (AC-55)

### G8 · Quét công thức từ ảnh — trạng thái: todo
- [ ] Đánh giá thư viện Flutter cho Tesseract (mức bảo trì, giấy phép, chạy được trên máy 32-bit), chọn dữ liệu fast hay best, ghi D-xxx (D-003)
- [ ] Nhận chữ từ ảnh, camera, PDF, nhiều trang (AC-23)
- [ ] Màn gán dòng vào tên, nguyên liệu, bước, ghi chú (AC-24)
- [ ] Bộ ảnh mẫu, đo tỉ lệ ký tự đúng, chốt lại ngưỡng AC-25 với người dùng; đo dung lượng app (NFR)

### G9 · Nhập file của app khác, xuất, chia sẻ, in — trạng thái: todo
- [ ] Xin người dùng file mẫu xuất từ Paprika và Recipe Keeper; nhập không tạo bản trùng, báo số công thức bị bỏ qua (AC-44)
- [ ] Nhập và xuất JSON schema.org Recipe (AC-45)
- [ ] Chia sẻ một công thức dạng chữ, PDF, `.cooknote` (AC-46)
- [ ] Sách công thức PDF có bìa, mục lục, số trang; in (AC-47)
- [ ] Không xin quyền bộ nhớ, dọn file tạm (AC-48)

### G10 · Giao diện, ngôn ngữ, tiếp cận, pháp lý, hoàn thiện — trạng thái: todo
- [ ] Giao diện sáng, tối, theo hệ thống; đổi ngôn ngữ; ngày đầu tuần; hệ đơn vị mặc định (AC-58)
- [ ] Màn chào có nút bật sao lưu tự động (AC-59)
- [ ] Vùng chạm, cỡ chữ 200%, tương phản, TalkBack (AC-60, AC-61, AC-62)
- [ ] Màn Giới thiệu, chính sách quyền riêng tư vi/en, email báo lỗi bảo mật, giấy phép nguồn mở (AC-63)
- [ ] Xóa toàn bộ dữ liệu (AC-64)
- [ ] Rà `pubspec.lock` và manifest đã build: không có SDK gửi dữ liệu, chỉ có các quyền ở SPEC mục 5 (AC-65)
- [ ] Đo đủ NFR trên Galaxy A13 và ghi vào TESTING; làm SBOM, MASVS, SECURITY; cập nhật COMPLIANCE
- [ ] Thử khôi phục trên máy Android khác, hoặc sau khi gỡ và cài lại app (SPEC mục 8)

## Việc kế tiếp (tối đa 5, theo thứ tự)
1. Người dùng thử G1 trên điện thoại thật (xem "Biên bản thử máy thật") và trả lời hai câu về AC-03 và AC-08
2. Sau khi qua cổng G1: G2 (danh mục, thẻ, tìm không dấu, lọc, sắp xếp, "Đã nấu")
3. G3: sao lưu bền lâu, và thử sớm rủi ro Google Drive

## Lỗi đã biết (đang mở)
Mỗi lỗi: BUG-xxx · mô tả · cách tái hiện · mức độ (chặn / nặng / nhẹ) · cách tạm tránh.
(Chưa có)

## Lỗi đã sửa đáng nhớ (nguồn cho bài học)
Mỗi lỗi: BUG-xxx · nguyên nhân gốc · cách sửa · làm sao tránh lần sau.
(Chưa có)

## Ý tưởng ngoài SPEC (chưa được duyệt, KHÔNG tự làm)
- Đồng bộ nhiều máy qua Google Drive của người dùng (đăng nhập Google, thư mục dữ liệu riêng của app). Ưu tiên cao nếu G3 cho thấy Drive không nhận ghi tự động vào thư mục (D-002)
- Phiên bản iOS: cần máy Mac và tài khoản Apple Developer; khi làm phải mở lại COMPLIANCE P-01 tới P-05
- Sao lưu có mã hóa bằng mật khẩu do người dùng đặt
- Khóa app bằng PIN hoặc sinh trắc học
- Nhập file của CookBook – Recipe Manager khi có file mẫu
- Tính dinh dưỡng tự động từ cơ sở dữ liệu thực phẩm; đổi thể tích sang khối lượng theo từng nguyên liệu
- Nhắc món trong Tủ bếp sắp hết hạn bằng thông báo hệ thống
- Chữ đậm, nghiêng trong các bước
- Widget màn hình chính (công thức ghim, thực đơn hôm nay)

## Biên bản thử máy thật
Mỗi lần thử: ngày · máy và phiên bản hệ điều hành · bản app · đã thử gì · kết quả · lỗi phát hiện.
(Chưa có lần nào.)

### Việc người dùng cần thử cho cổng G1 (CHƯA kiểm chứng trên máy thật)
APK: `apps/APP-005-cooknote/build/app/outputs/flutter-apk/app-release.apk` (61,9 MB, đủ kiến trúc, ký khóa debug). Máy đề nghị: Galaxy A13.
- AC-01: thanh dưới có 5 mục; nút "+" nằm trong vùng ngón cái; bấm "+" ra bảng chọn.
- AC-02, AC-04: thêm công thức đủ trường, tắt hẳn app, mở lại vẫn còn.
- AC-03: dán một khối chữ nhiều dòng vào Nguyên liệu (dòng cuối bằng `:` là tiêu đề nhóm); nhập tên rồi bấm Back hệ thống thì hỏi "Bỏ thay đổi?".
- AC-05, AC-06: xóa, thanh Hoàn tác 5 giây, thùng rác, khôi phục, nhân bản.
- AC-07: thêm ảnh từ thư viện (nhiều ảnh) và chụp bằng camera; không có hộp xin quyền bộ nhớ hay thư viện ảnh; ảnh chụp từ máy có định vị thì ảnh trong app không còn vị trí.
- AC-09: chạm ảnh xem toàn màn hình, vuốt chuyển ảnh, chụm hai ngón phóng to; liên kết trong ghi chú chạm được.
- Chế độ máy bay: toàn bộ chức năng ở trên vẫn dùng được.

