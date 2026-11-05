# Kế hoạch ảnh store — CookNote (Google Play + App Store)

Viết 2026-11-05. **Chụp thật ở phiên điều phối #3 với UI mới** của #2 (ảnh phải là UI thật — S-31, App Review 2.3.3). Số liệu dưới
đây đọc trên trang chính thức ngày **2026-11-05**; kiểm lại ngày chụp (đổi theo năm) và ghi ngày kiểm vào cuối file.

## 1. Kích thước và số lượng bắt buộc
### Google Play — nguồn: [Add preview assets](https://support.google.com/googleplay/android-developer/answer/9866151) (đọc 2026-11-05)
| Thành phần | Bắt buộc | Quy cách |
|---|---|---|
| Icon | **Có** | PNG 32-bit (có alpha), **512 × 512**, ≤ 1024 KB, theo quy cách icon của Play; không huy hiệu/chữ gợi xếp hạng, giá |
| Feature graphic | **Có** ("You must provide a feature graphic to publish") | JPEG hoặc PNG 24-bit **không alpha**, **1024 × 500**; không lặp lại nguyên icon; nội dung chính ở giữa |
| Ảnh chụp | **Có — tối thiểu 2** (tính chung các loại thiết bị), tối đa **8 mỗi loại thiết bị** | JPEG hoặc PNG 24-bit không alpha; cạnh 320–3840 px; cạnh dài ≤ 2 × cạnh ngắn |
| Ảnh để được Play gợi ý | Rất nên | App: **≥ 4 ảnh, ≥ 1080 px**; dọc **9:16, tối thiểu 1080 × 1920** |
| Máy tính bảng, Chromebook, Wear, TV, XR | Không | v1 chỉ nhắm điện thoại, chỉ màn dọc (SPEC mục 5) |
| Video | Không | Bỏ |
**Chọn: 8 ảnh dọc 1080 × 1920 (9:16) mỗi ngôn ngữ.** Mỗi ảnh có thể kèm mô tả thay thế ≤ 140 ký tự (Play hỏi khi tải lên) — dùng chú thích ở mục 2.

### App Store — nguồn: [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) (đọc 2026-11-05)
| Thành phần | Bắt buộc | Quy cách |
|---|---|---|
| iPhone | **Có — 1 đến 10 ảnh** mỗi localization | Trang Apple ghi cỡ **bắt buộc**: "iPhone with Dynamic Island (**medium display**)": **1206 × 2622** hoặc 1179 × 2556 (dọc). App Store Connect tự thu nhỏ từ cỡ cao nhất đã nộp |
| iPhone 6.9" (large display) | Không bắt buộc | 1320 × 2868 / 1290 × 2796 / 1260 × 2736 (dọc). Nộp thêm nếu muốn ảnh nét trên máy lớn |
| iPad 13" | **Chỉ khi app chạy trên iPad** | **2064 × 2752** hoặc 2048 × 2732 (dọc). Project hiện bật iPad (`TARGETED_DEVICE_FAMILY = "1,2"`, chưa commit) → giữ iPad thì **bắt buộc** bộ này; đề xuất v1 chỉ iPhone (`store/app-store.md`) |
| iPhone Duo | Từ **tháng 4/2027** với app dùng SDK iOS 27.1 trở lên | 1398 × 2034 (ngoài), 2007 × 2853 (trong). Không áp dụng cho v1 nếu build bằng SDK 26 |
| Icon App Store | Có | 1024 × 1024 PNG, không alpha, không bo góc (lấy từ `AppIcon` của `ios/`) |
| App Preview (video) | Không | Bỏ |
Mọi ảnh: .jpeg/.jpg/.png, **không kênh alpha, không trong suốt**.
**Chọn: 8 ảnh 1206 × 2622 (simulator iPhone 17 hoặc 17 Pro) mỗi localization**; thêm bộ 1320 × 2868 (iPhone 17 Pro Max) nếu còn thời gian.
Lưu ý: A002 (`apps/A002-vigon/store/screenshots-spec.md`, 2026-11-04) ghi bộ bắt buộc là 6.9" — trang Apple ngày 2026-11-05 ghi
"medium display"; ghi vào STANDARDS khi phiên điều phối cập nhật.

Thứ tự ảnh: 3 ảnh đầu hiện ngay trong kết quả tìm kiếm → đặt 3 ảnh thể hiện khác biệt mạnh nhất lên đầu (S-30).

## 2. 8 cảnh nên chụp (mỗi ngôn ngữ một bộ; chung hai store, chụp riêng từng nền tảng)
| # | Màn | Trạng thái cần dựng | Chú thích vi | Chú thích en |
|---|---|---|---|---|
| 1 | Danh sách công thức, dạng lưới ảnh, giao diện sáng | ≥ 8 công thức có ảnh, vài danh mục; thanh dưới đủ 5 mục | Mọi công thức ở một chỗ, miễn phí | All your recipes, free forever |
| 2 | Xem trước khi nhập từ web | Đã chia sẻ một trang công thức sang app: tên, ảnh, nguyên liệu, các bước đã tự điền; nút Lưu rõ | Lưu công thức từ web một chạm | Save recipes from any website |
| 3 | Chế độ nấu | Bước đang làm nổi bật, 2 nguyên liệu đã gạch, một hẹn giờ đang chạy "Ninh xương 01:45:00" | Chế độ nấu chữ lớn, có hẹn giờ | Cook mode with big text and timers |
| 4 | Sao lưu | Sao lưu tự động bật, "Lần gần nhất: hôm nay, đã kiểm tra", nơi lưu là một thư mục; dòng giải thích định dạng mở đọc được bằng trình duyệt | Giữ công thức cả đời, định dạng mở | Keep your recipes for life |
| 5 | Tìm không dấu (bộ vi) / Quét ảnh gán dòng (bộ en) | vi: ô tìm "pho bo" ra "Phở bò", "Phở gà"; en: màn gán dòng sau khi quét, vài dòng đã gán "Ingredients" | Gõ không dấu vẫn tìm ra | Scan recipes from paper |
| 6 | Nhân khẩu phần + đổi đơn vị | Hệ số 2×, các dòng đã nhân gọn ("1 1/2 cup", "500 g"), một dòng không tách được có dấu báo | Nhân khẩu phần tức thì | Scale servings in a tap |
| 7 | Danh sách đi chợ | Món xếp theo khu vực (Rau củ, Thịt cá, Gia vị…), vài món đã gạch, ghi nguồn công thức | Đi chợ theo từng khu vực | Shopping list by aisle |
| 8 | Lịch thực đơn tuần, giao diện tối | Đủ 7 ngày, bữa Trưa/Tối có món, một bữa "Ăn ngoài" | Xếp thực đơn cả tuần | Plan the whole week |
Dự phòng (thay ảnh 5 hoặc 8 nếu tính năng bị cắt theo D-008): Tủ bếp + "Nấu được gì?" · Sách công thức PDF · màn soạn công thức.
Cắt tính năng nào (F-04 OCR, F-08 thực đơn, F-09 tủ bếp) thì **không** được chụp màn đó.

Quy tắc chung:
- Bộ App Store không có chữ "Android"/"Google Play"/TalkBack; bộ Play không có "iPhone"/"App Store".
- Không khung máy có thương hiệu, không "Số 1", "Tốt nhất", giá, hay so sánh/nêu tên app khác. Không hứa điều app không làm
  (ví dụ "đồng bộ đám mây", "mã hoá").
- Chú thích đặt trong dải màu thương hiệu phía trên ảnh màn hình (màu và font lấy từ design system của #2).

## 3. Dữ liệu mẫu (không dùng dữ liệu hay nội dung của người khác)
- **Công thức tự viết** cho bộ ảnh (không chép chữ từ trang web hay sách — bản quyền, AC-63). Gợi ý vi: Phở bò, Phở gà, Canh chua
  cá lóc, Gà kho gừng, Rau muống xào tỏi, Bánh flan, Chè đậu xanh, Cơm chiên dương châu. en: Banana bread, Tomato soup, Chicken curry,
  Pancakes, Greek salad, Lemon pasta, Oat cookies, Vegetable stir-fry.
- **Ảnh món**: ảnh Phương tự chụp, hoặc ảnh giấy phép CC0 có ghi nguồn trong `store/screenshots/SOURCES.md`; không logo, không người lạ.
- **Ảnh 2 (nhập từ web)**: không chụp trang của web nấu ăn thật (nội dung và nhãn hiệu của họ). Dùng một trang mẫu do mình đăng (ví dụ
  `…/phiotron-legal/cooknote/sample-recipe.html` có JSON-LD `Recipe` và công thức tự viết), hoặc file trong `test/` mở bằng máy chủ cục bộ.
- Nạp dữ liệu bằng một file `.cooknote` mẫu cho từng ngôn ngữ (khôi phục vào máy chụp).
- Thanh trạng thái 9:41, pin đầy, sóng đầy, không thông báo, không tên/email người thật.

## 4. Cách chụp (máy Windows, không iPhone, không adb trên máy thử — D-008)
- **Android**: emulator Pixel cỡ 1080 × 2400 hoặc máy của Phương (Phương tự chụp, không adb trên máy dùng chung). Ghép vào khung
  1080 × 1920 có dải chú thích (không cắt mất nút như lần A002).
- **iOS**: simulator trên GitHub Actions macOS runner (iPhone 17: 1206 × 2622):
  `xcrun simctl status_bar booted override --time 9:41 --batteryState charged --batteryLevel 100`, nạp dữ liệu mẫu, chụp
  `xcrun simctl io booted screenshot <file>.png`, tải về qua artifact. Viết workflow chụp ảnh là việc của #3 (ghi rõ khi giao).
- Tên file: `store/screenshots/<android|ios>-<vi|en>/<nn>-<man>.png`.

## 5. Kiểm sau khi chụp
- Kích thước đúng mục 1, không kênh alpha (`python -I -c "from PIL import Image; im=Image.open(p); print(im.size, im.mode)"` → mode `RGB`).
- Chữ trong ảnh khớp ngôn ngữ trang store; mọi tính năng trong ảnh có trong bản nộp.

Ngày kiểm bảng kích thước lần cuối: **2026-11-05** (trang chính thức Play "Add preview assets" và Apple "Screenshot specifications").
