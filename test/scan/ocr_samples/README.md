# Bộ mẫu đo AC-25 (độ chính xác OCR)

Test `test/scan/ocr_accuracy_test.dart` đọc thư mục này mỗi lần `flutter test`.

## Định dạng
Mỗi trang mẫu là một cặp file UTF-8 cùng mã:
- `<mã>.ref.txt` — chữ chuẩn gõ tay (đúng như trên giấy, xuống dòng tuỳ ý: mọi khoảng trắng được gộp).
- `<mã>.ocr.txt` — chữ app nhận được từ ảnh chụp trang đó trên **Galaxy A13** (bản release thật).

Mã bắt đầu bằng ngôn ngữ: `vi-01`, `vi-02`… và `en-01`, `en-02`… Mã khác (vd `example`) chỉ in ra, không tính.

## Ngưỡng (đề xuất ở khảo sát mục 5, chờ Phương xác nhận)
Khi có đủ ≥ 5 trang `vi-*` VÀ ≥ 5 trang `en-*`, test bật kiểm: trung bình mỗi ngôn ngữ ≥ 90% và không trang nào < 80%.
Chưa đủ thì test ghi "skipped" (AC-25 CHƯA kiểm chứng). Bảng in ra có thêm cột "bỏ dấu" để tách lỗi dấu khỏi lỗi chữ cái.

## Quy tắc
- Chỉ dùng trang tự soạn và tự in (không chụp sách có bản quyền).
- Không để thông tin cá nhân trong ảnh hay chữ.
- Ảnh chụp KHÔNG commit vào repo (nặng); chỉ commit hai file chữ.
