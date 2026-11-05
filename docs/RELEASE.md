# RELEASE — Bepbook (A004-cooknote)

## Định danh
- Bundle ID / package name:
- Phiên bản hiện tại (versionName / versionCode / buildNumber):
- Store: Google Play [x] · App Store [x] (D-008) · phân phối nội bộ [ ] — chưa nộp bản nào (2026-11-05)

## Ký ứng dụng
- Nơi cất keystore/chứng chỉ (NGOÀI repo, có sao lưu): {{...}}
- Người giữ mật khẩu: {{...}}
- KHÔNG ghi mật khẩu vào file này.

## Hồ sơ store
Bản nháp 2026-11-05 (phiên con "Store & pháp lý 2 nền tảng"); số liệu store kiểm trên trang chính thức cùng ngày. Đếm giới hạn ký
tự/byte: `python store/check_limits.py` (chạy lại sau mỗi lần sửa chữ).
- **Tên: ĐÃ CHỐT "Bepbook" (D-010, 2026-11-05)** — tên cũ "CookNote" trùng app cùng loại trên cả hai store (S-71). Bản tra và link:
  `store/app-store.md` mục "Tên app". Mã app, bundle ID, tên repo giữ nguyên. Tra lại tên trên App Store Connect khi tạo app.
- Tên, mô tả ngắn, mô tả dài, ghi chú phát hành, Data safety, IARC, đối tượng mục tiêu (Play): `store/google-play.md`.
- Tên, phụ đề, keyword (≤ 100 **byte**), promotional text, mô tả, xếp hạng tuổi, App Privacy, export compliance, ghi chú App Review
  (App Store): `store/app-store.md`.
- Ảnh chụp màn hình: kích thước bắt buộc từng store + 8 cảnh: `store/screenshots-plan.md` (chụp thật ở #3 với UI mới).
- Phân loại: Play **Food & Drink**, đối tượng 13–15/16–17/18+, IARC dự kiến mức thấp nhất kèm "Unrestricted Internet";
  App Store **Food & Drink** / phụ **Productivity**, **16+** (iOS 26+; 17+ trên iOS cũ hơn) vì trình duyệt đầy đủ trong app — đã chốt phương án A, D-010 (COMPLIANCE P-05); Play khai 13+.
- Đường dẫn chính sách quyền riêng tư: CHƯA đăng. Nội dung `docs/legal/privacy-policy.md` (+ `docs/legal/terms.md` tuỳ chọn);
  gợi ý `https://phiotron.github.io/phiotron-legal/cooknote/privacy` (repo public chung, fact `tai-khoan-store`). Support URL App
  Store: `…/cooknote/support` (phải có thông tin liên hệ).
- Closed test Play (tài khoản cá nhân, 12 tester × 14 ngày): `store/closed-test.md`.
- Liên hệ công khai: `phamphuongphuongnd@gmail.com` · Tên nhà phát triển Play: Phiotron · App Store: họ tên thật (tài khoản cá nhân).

## Lịch sử phát hành
| Phiên bản | Ngày | Nội dung | Ghi chú |
|-----------|------|----------|---------|

## Sau phát hành
- Theo dõi crash tại: {{công cụ / console của store}}
- Nơi nhận phản hồi người dùng:
- Mốc rà soát: sau 1 ngày, 1 tuần → ghi kết quả vào `docs/MANUAL-TESTS.md`
