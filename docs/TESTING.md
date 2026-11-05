# TESTING — Bepbook (A004-cooknote)

## Nguyên tắc
- Mỗi AC trong SPEC phải được kiểm chứng bằng ĐÚNG MỘT trong hai cách: test tự động, hoặc kiểm tra tay có ghi biên bản trong `MANUAL-TESTS.md`. Ghi rõ ở cột "Cách kiểm chứng" của SPEC.
- Logic nghiệp vụ, xử lý dữ liệu, định dạng, tính toán: BẮT BUỘC có test tự động.
- Lỗi đã sửa: nếu khả thi, thêm test chặn lỗi quay lại trước khi coi là xong.
- Không báo "test đạt" khi chưa chạy lệnh test trong phiên và đọc kết quả.

## Các tầng
| Tầng | Kiểm cái gì | Công cụ | Khi nào chạy |
|------|-------------|---------|--------------|
| Lint + typecheck | Lỗi cú pháp, kiểu | {{điền theo stack}} | Mỗi giai đoạn, mỗi commit (CI) |
| Unit | Hàm, logic | {{...}} | Mỗi giai đoạn |
| Component/màn hình | Giao diện chính hoạt động đúng | {{...}} | Mỗi giai đoạn có UI |
| Tay trên máy thật | Cảm ứng, quyền, offline, hiệu năng, bàn phím, xoay màn hình | Người dùng | Cuối mỗi giai đoạn (Cổng 3) và trước phát hành |

## Ma trận thử máy thật (tối thiểu trước phát hành)
- [ ] Ít nhất 1 máy Android thật (ghi đời máy, phiên bản)
- [ ] Ít nhất 1 máy iOS thật nếu SPEC có iOS
- [ ] Màn hình nhỏ nhất theo SPEC
- [ ] Mất mạng giữa chừng; mạng yếu
- [ ] Từ chối từng quyền thiết bị; thu hồi quyền khi đang dùng
- [ ] Thoát app và mở lại (trạng thái, dữ liệu còn đúng)
- [ ] Có cuộc gọi/thông báo chen ngang
- [ ] Chạy lâu 10–15 phút: không giật, không nóng máy bất thường

## Bảng truy vết: mỗi AC phải có bằng chứng kiểm chứng
Cập nhật khi viết test hoặc khi thử tay. Một AC chưa có dòng ở đây hoặc cột "Kết quả lần cuối" trống nghĩa là CHƯA được kiểm chứng.
| AC (SPEC) | Cách | Test hoặc biên bản (tên test / mục trong MANUAL-TESTS) | Kết quả lần cuối (ngày, lệnh hoặc máy, đạt/hỏng) |
|-----------|------|----------------------------------------------------|-----------------------------------------------------|
| AC-01 | tự động / tay | | |

## Yêu cầu phi chức năng (SPEC mục 5b): đo bằng gì
| Yêu cầu | Cách đo | Kết quả lần cuối |
|---------|---------|------------------|
| | | |

## Lệnh
Xem mục "Lệnh" trong `CLAUDE.md` của app (một nơi duy nhất).

## Kết quả đo G2 (2026-11-04)
Đo trên máy tính phát triển bằng `flutter test test/data/search_perf_test.dart` (SQLite trong bộ nhớ, 5.000 công thức, mỗi công thức 4 nguyên liệu, 2 bước, ghi chú). KHÔNG phải số đo trên điện thoại; điện thoại sẽ chậm hơn, nên SPEC 5b (tìm không quá 300 ms với 5.000 công thức) CHƯA được kiểm chứng.
- Mở danh sách đầy đủ, không lọc: 338 ms (đã vượt 300 ms ngay trên máy tính, dù mục này là xem tất cả chứ không phải tìm).
- Tìm "pho bo" (1.000 kết quả): 48 ms. Tìm "so 4999" (1 kết quả): 5 ms. Lọc kết hợp sao và chữ: 12 ms.
- Việc cần làm: đo lại trên Galaxy A13 ở G10; nếu danh sách đầy đủ vượt ngưỡng thì phân trang hoặc bỏ việc đọc tách ảnh bìa và lịch sử nấu cho từng dòng (D-006, mục Hệ quả).
