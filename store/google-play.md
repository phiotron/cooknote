# Hồ sơ Google Play — Bepbook (bản nháp, chưa nộp)

Viết 2026-11-05 (phiên con "[A004-cooknote] Store & pháp lý 2 nền tảng", phiên điều phối #1). Dán vào Play Console ở phiên #3;
Phương duyệt tên và nội dung trước khi nộp. Bản App Store tương ứng: `store/app-store.md` — sửa một bên thì sửa bên kia.
Số liệu Play kiểm trên trang chính thức **2026-11-05** (nguồn cuối file). Không sao chép chữ của Paprika, Recipe Keeper, CookBook
(SPEC mục 1, mục 7); mô tả tự viết từ SPEC F-01..F-14.

> **TÊN ĐÃ CHỐT (D-010, 2026-11-05): Bepbook.** Tên cũ "CookNote" trùng 2 app cùng thể loại trên Play nên đã bỏ; "Bepbook" tra Play,
> web, WIPO không có kết quả. Chi tiết và link: mục "Tên app" của `store/app-store.md`. `android:label` và các chuỗi trong app đổi
> theo ở phiên #2.

Cách đếm: mỗi trường nằm trong một khối `text` có nhãn `<!-- field: … limit=… -->`; chạy `python store/check_limits.py` để đếm ký tự
(và byte cho keyword Apple). Kết quả lần chạy gần nhất ghi ở cuối file.

## Tên ứng dụng (≤ 30 ký tự, Play đếm ký tự kể cả chữ có dấu)
<!-- field: play.name.vi limit=30 -->
```text
Bepbook: Sổ Công Thức
```
<!-- field: play.name.en limit=30 -->
```text
Bepbook: Recipe Notebook
```
- Tên dưới icon trên máy: `Bepbook` (`android:label` hiện vẫn là `CookNote` — đổi ở #2, D-010).
- Không dùng "Recipe Keeper", "Recipe Manager", "Paprika", "CookBook" trong tên: đó là tên app đối thủ (Play Metadata policy, rủi ro nhãn hiệu).

## Mô tả ngắn (≤ 80 ký tự)
<!-- field: play.short.vi limit=80 -->
```text
Sổ công thức offline: nhập từ web, chế độ nấu, đi chợ. Mọi tính năng miễn phí.
```
<!-- field: play.short.en limit=80 -->
```text
Offline recipe book: web import, cook mode, groceries. Every feature is free.
```

## Mô tả đầy đủ (≤ 4.000 ký tự)
Thể hiện khác biệt S-30 ngay ở khối đầu ("Vì sao chọn Bepbook"): miễn phí toàn bộ, không tài khoản, giữ cả đời bằng định dạng mở
đọc được không cần app, tiếng Việt chuẩn — đúng `APP.md` "Tiêu chuẩn áp dụng". Không nêu tên đối thủ.

**Phải đối chiếu lại ở #3 (S-31: mô tả đúng app thật):** nếu cuối #2 cắt tính năng theo D-008 thì xoá đúng dòng tương ứng:
(1) "file sao lưu xuất từ một số app công thức phổ biến" (F-10/AC-44) → (2) dòng "Từ ảnh"/"From photos" và cụm "Quét ảnh đọc được
chữ tiếng Việt" (F-04) → (3) dòng "Tủ bếp… Nấu được gì?" và "Mặc định bỏ chọn món đã có" (F-09) → (4) dòng "Lịch thực đơn…" và
"cả tuần thực đơn" (F-08). Câu "vẫn báo khi máy khóa màn hình" chỉ giữ nếu AC-28 đạt trên máy thật. Câu "Sao lưu của Android cũng
có thể khôi phục công thức (không gồm ảnh)" chỉ giữ nếu AC-56 đã thử.

### Tiếng Việt
<!-- field: play.full.vi limit=4000 -->
```text
Bepbook là sổ tay công thức nấu ăn trên điện thoại. Lưu công thức từ trang web hoặc từ ảnh, nấu theo khi tay đang bận, xếp thực đơn cả tuần và đi chợ với một danh sách. Mọi thứ nằm trên điện thoại của bạn, và mọi tính năng đều miễn phí.

VÌ SAO CHỌN BEPBOOK
• Miễn phí toàn bộ. Không thuê bao, không bản trả phí, không quảng cáo, không mua trong app.
• Không cần tài khoản. Mở app là ghi được ngay. Nhà phát triển không nhận công thức của bạn.
• Giữ được cả đời. Sao lưu tự động dùng định dạng mở, có tài liệu: một file zip chứa JSON thuần, ảnh và các trang HTML. Bạn mở được bản sao lưu bằng trình duyệt bất kỳ để đọc hoặc in công thức, kể cả khi không còn Bepbook.
• Tiếng Việt chuẩn. Gõ "pho bo" vẫn ra "Phở bò". Hiểu các đơn vị chén, bát, muỗng canh, thìa cà phê. Quét ảnh đọc được chữ tiếng Việt có dấu.

LƯU CÔNG THỨC
• Tự soạn: nguyên liệu và các bước chia nhóm, khẩu phần, thời gian, nguồn, ghi chú, đánh giá, yêu thích, tối đa 20 ảnh.
• Từ web: chia sẻ đường dẫn từ trình duyệt sang Bepbook, hoặc mở trình duyệt có sẵn trong app. Trang có dữ liệu công thức được tự điền; trang khác thì bôi đen chữ rồi gán là nguyên liệu hay các bước. Luôn có màn xem trước để sửa, và giữ đường dẫn nguồn.
• Từ ảnh: quét trang sách hay công thức viết tay. Việc nhận chữ chạy ngay trên điện thoại, ảnh không bị tải lên đâu cả.
• Nhập file Bepbook (.cooknote), JSON theo chuẩn schema.org Recipe, và file sao lưu xuất từ một số app công thức phổ biến.

NẤU
• Chế độ nấu giữ màn hình sáng, chữ lớn, chạm để gạch nguyên liệu và bước đã làm.
• Thời gian ghi trong bước thành nút hẹn giờ. Chạy nhiều hẹn giờ cùng lúc, vẫn báo khi máy đang khóa màn hình.
• Đọc to bước đang làm bằng giọng đọc của điện thoại.
• Nhân khẩu phần (½×, 2×, 3× hoặc số tùy ý), đổi giữa hệ mét và hệ Mỹ.

XẾP THỰC ĐƠN VÀ ĐI CHỢ
• Lịch thực đơn theo ngày, tuần, tháng; thực đơn mẫu dùng lại được; gợi ý ngẫu nhiên cho bữa còn trống.
• Danh sách đi chợ xếp theo khu vực trong chợ, siêu thị. Thêm nguyên liệu từ một công thức hay cả tuần thực đơn; món trùng được gộp.
• Tủ bếp có hạn dùng, và "Nấu được gì?" xếp công thức theo nguyên liệu bạn đang có.

SẮP XẾP VÀ CHIA SẺ
• Danh mục lồng nhau, thẻ, bộ lọc, sắp xếp. Xem dạng lưới hoặc dạng dòng.
• Chia sẻ công thức dạng chữ, PDF hoặc file Bepbook (.cooknote). Xuất sách công thức PDF có bìa và mục lục.
• Thùng rác giữ công thức đã xóa 30 ngày.

DỮ LIỆU CỦA BẠN
• Công thức, ảnh và các danh sách chỉ lưu trên điện thoại.
• Sao lưu tự động ghi vào thư mục bạn chọn, ví dụ thư mục do app lưu trữ đám mây của chính bạn đồng bộ, và kiểm lại từng file sau khi ghi.
• Sao lưu của Android cũng có thể khôi phục công thức (không gồm ảnh) khi bạn cài máy mới cùng tài khoản Google.
• Internet chỉ dùng để tải trang web bạn mở và ảnh của công thức.

DỄ DÙNG
• Tiếng Việt và tiếng Anh. Giao diện sáng và tối. Hỗ trợ cỡ chữ lớn và TalkBack.

Bepbook là công cụ cá nhân. Công thức nhập từ trang web thuộc về tác giả của chúng; Bepbook giữ đường dẫn nguồn và chỉ dành cho bạn dùng riêng.
```

### English
<!-- field: play.full.en limit=4000 -->
```text
Bepbook is a recipe notebook for your phone. Save recipes from websites or photos, cook from them when your hands are busy, plan the week and shop from one list. Everything stays on your phone, and every feature is free.

WHY BEPBOOK
• Free, all of it. No subscription, no premium tier, no ads, no in-app purchases.
• No account. Open the app and start writing. The developer never receives your recipes.
• Built to last a lifetime. Automatic backups use an open, documented format: a zip file with plain JSON, your photos and HTML pages. Open a backup in any web browser to read or print your recipes, even without Bepbook.
• Vietnamese done right. Search "pho bo" and find "Phở bò". Units such as chén, bát, muỗng canh and thìa cà phê are understood. Scanning reads Vietnamese text with diacritics.

SAVE RECIPES
• Write your own: ingredients and steps in groups, servings, times, source, notes, rating, favorites, up to 20 photos.
• From the web: share a link from your browser to Bepbook, or use the built-in browser. Pages with recipe data fill in automatically; on other pages, select text and mark it as ingredients or steps. You always get a preview before saving, and the source link is kept.
• From photos: scan a cookbook page or a handwritten recipe. Text recognition runs on your phone; photos are not uploaded anywhere.
• Import Bepbook (.cooknote) files, schema.org Recipe JSON, and backup files exported from some popular recipe apps.

COOK
• Cook mode keeps the screen on, uses large text and lets you tap to cross off ingredients and steps.
• Times written in steps become timers. Run several at once; they still alert you when the phone is locked.
• Read the current step aloud with your phone's voice.
• Scale servings (½×, 2×, 3× or any number) and convert between metric and US units.

PLAN AND SHOP
• Meal planner by day, week or month, reusable menus, and random suggestions for empty meals.
• Shopping lists sorted by store aisle. Add ingredients from one recipe or a whole week of meals; matching items are combined.
• Pantry with expiry dates, and "What can I cook?" ranks recipes by what you already have.

ORGANIZE AND SHARE
• Nested categories, tags, filters and sorting. Grid or list view.
• Share a recipe as text, PDF or a Bepbook (.cooknote) file. Make a PDF cookbook with a cover and table of contents.
• Trash keeps deleted recipes for 30 days.

YOUR DATA
• Recipes, photos and lists are stored only on your phone.
• Automatic backup writes to a folder you choose, for example a folder synced by your own cloud storage app, and checks every file after writing it.
• Android's own backup can also bring back your recipes (without photos) when you set up a new phone with the same Google account.
• The internet is used only to load web pages you open and their recipe photos.

EASY TO USE
• Vietnamese and English. Light and dark themes. Large text and TalkBack supported.

Bepbook is a personal tool. Recipes you import from websites belong to their authors; Bepbook keeps the source link and is meant for your personal use.
```

## Ghi chú phát hành (≤ 500 ký tự mỗi ngôn ngữ)
<!-- field: play.release.vi limit=500 -->
```text
Bản đầu tiên: soạn và nhập công thức từ web hoặc ảnh, chế độ nấu có hẹn giờ, nhân khẩu phần và đổi đơn vị, danh sách đi chợ, lịch thực đơn, tủ bếp, chia sẻ và xuất PDF, sao lưu tự động bằng định dạng mở.
```
<!-- field: play.release.en limit=500 -->
```text
First release: write recipes or import them from the web or photos, cook mode with timers, scaling and unit conversion, shopping lists, meal planner, pantry, sharing and PDF export, automatic backup in an open format.
```
Bản closed test: thêm dòng "Bản thử — góp ý giúp mình qua nút Gửi phản hồi trên trang Play." (`store/closed-test.md`).
Cắt tính năng ở #2 → bỏ đúng cụm trong câu này.

## Phân loại, giá, quốc gia
- Loại: **App** · Danh mục: **Food & Drink** (Ăn uống). Thẻ (tags) khi Play hỏi: chọn trong danh sách của Play các thẻ gần
  "Recipes", "Cooking", "Meal planning", "Shopping list" nếu có (danh sách thẻ đổi theo thời gian).
- Giá: **Miễn phí**. Không quảng cáo, không mua trong app (S-82, S-83 không bật).
- Quốc gia: mọi quốc gia Play có mặt, theo COMPLIANCE M-01 (loại nước bị cấm vận toàn diện khi Play Console cho chọn). Play không
  có ở Trung Quốc đại lục.
- Thông tin liên hệ trên trang store: email `phamphuongphuongnd@gmail.com` (fact `tai-khoan-store`, chốt 2026-11-05); website: để
  trống hoặc trang hỗ trợ cùng site với chính sách; điện thoại: không bắt buộc.
- Tên nhà phát triển: **Phiotron** (fact `tai-khoan-store`).

## App content (Play Console → Policy and programs → App content) — trả lời đề xuất
| Mục | Trả lời | Ghi chú |
|---|---|---|
| Privacy policy | URL công khai của `docs/legal/privacy-policy.md` | CHƯA đăng — Phương đăng (gợi ý URL trong file chính sách). Cùng URL đặt ở màn Giới thiệu (AC-63, S-13) |
| Ads | **No, my app does not contain ads** | |
| App access | **All functionality is available without special access** | Không đăng nhập. Trình duyệt trong app cần mạng — ghi chú cho reviewer nếu Play hỏi thêm |
| Content rating (IARC) | Xem mục "Xếp hạng nội dung" dưới | |
| Target audience and content | **13–15, 16–17, 18 trở lên** (không chọn nhóm dưới 13). "Appeals to children?" → **No** | S-84: không vào Families (COMPLIANCE P-12). App Store xếp 16+/17+ vì trình duyệt đầy đủ — đã chốt phương án A, D-010 (xem `store/app-store.md`) |
| News app | No | |
| Government app | No | |
| Financial features | "My app doesn't provide any financial features" (chọn đúng câu chữ hiện hành) | |
| Health apps | No — dinh dưỡng chỉ là chữ người dùng tự nhập hoặc nhập từ web, app không tư vấn sức khoẻ | Câu chữ form đổi theo thời gian: đọc kỹ khi điền |
| Data safety | Xem mục dưới | |
| Photo and video permissions | Không áp dụng nếu manifest cuối **không** có `READ_MEDIA_IMAGES`/`READ_MEDIA_VIDEO` (ảnh qua trình chọn của hệ thống, AC-07) | Kiểm bằng `aapt2 dump permissions` ở #3 |
| Foreground service / Exact alarm | **Chưa chốt** — hẹn giờ nấu chọn cách ở G5 (SPEC mục 5). Nếu manifest cuối có `FOREGROUND_SERVICE_*` hoặc `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` thì Play bắt khai báo riêng (lý do: hẹn giờ nấu do người dùng bật) | Việc của #3, đối chiếu manifest đã gộp |

### Xếp hạng nội dung (IARC) — trả lời đề xuất
- Danh mục bảng hỏi: **"All Other App Types"** / tiện ích (không phải game, không phải mạng xã hội). Câu chữ danh mục đổi theo
  thời gian — chọn mục không phải game, không phải giao tiếp.
- Bạo lực, tình dục, ngôn từ, ma tuý, cờ bạc, kinh dị: **No** (app không có nội dung sẵn; công thức do người dùng tự ghi).
- Người dùng tương tác / trao đổi nội dung với nhau trong app: **No** (chia sẻ chỉ qua bảng chia sẻ của hệ điều hành tới app khác).
- Chia sẻ vị trí: **No** · Mua hàng số: **No**.
- **Truy cập Internet không giới hạn / trình duyệt web: Yes** — Bepbook có trình duyệt trong app với thanh địa chỉ và tìm kiếm (AC-16), mở được cả trang `http` có nhãn "Không mã hóa" (AC-66, D-010). Đối tượng Play vẫn khai **13+** (D-010: App Store 16+/17+ do trình duyệt đầy đủ; Play không bị ràng buộc theo cách đó).
  Trả lời đúng thực tế. Dự kiến IARC ghi chú "Unrestricted Internet" ở mục yếu tố tương tác; mức tuổi dự kiến vẫn thấp
  (Everyone / PEGI 3 / 3+) — *(chưa kiểm: đọc kết quả thật khi điền)*.
- Kết quả ghi vào COMPLIANCE (S-14) kèm ngày.

## Data safety (S-13, S-42)
Định nghĩa của Play (trang "Provide information for Google Play's Data safety section", đọc 2026-11-05):
"collect" = dữ liệu được truyền từ app ra khỏi máy; dữ liệu chỉ xử lý trên máy không phải khai; **không cần khai dữ liệu thu từ
một WebView mà người dùng tự duyệt web mở**; app cho người dùng tự tải dữ liệu lên kho đám mây của chính họ (Drive, Dropbox…) theo
điều khoản của nhà cung cấp đó, và app không bao giờ truy cập dữ liệu đó → không phải khai là thu thập.

Trả lời theo thứ tự form:
1. "Does your app collect or share any of the required user data types?" → **No**.
2. Play bỏ qua các câu loại dữ liệu. Trang store hiện **"No data collected"** và **"No data shared with third parties"**.
3. Nếu form vẫn hỏi: mã hoá khi truyền → không áp dụng (app không gửi dữ liệu người dùng); xoá dữ liệu → trong app (Cài đặt →
   "Xóa toàn bộ dữ liệu", AC-64) hoặc gỡ app.

Đối chiếu từng hành vi (căn cứ để trả lời No):
| Hành vi | Có dữ liệu rời máy? | Vì sao không phải khai |
|---|---|---|
| Trình duyệt trong app (AC-16) | Trình duyệt gửi yêu cầu tới trang người dùng mở | WebView duyệt web mở — Play nói rõ không phải khai; app không chèn mã theo dõi, không đọc cookie |
| Nhập từ web (F-03): tải HTML + ảnh của trang người dùng chọn | Yêu cầu tải trang (địa chỉ trang, địa chỉ IP như mọi trình duyệt) tới chính trang đó | Người dùng chủ động mở/chia sẻ đúng trang đó; không có dữ liệu cá nhân nào của người dùng được gửi; nhà phát triển không nhận gì |
| Ảnh, camera (AC-07, AC-08) | Không | Trình chọn ảnh / app camera của hệ điều hành; ảnh chép vào bộ nhớ riêng của app, bỏ EXIF (D-005) — xử lý trên máy |
| Quét ảnh OCR (F-04) | Không | Tesseract trên máy (D-003), không ML Kit |
| Hẹn giờ, thông báo (AC-28) | Không | Thông báo cục bộ, không Firebase/FCM, không push |
| Đọc bước (AC-30) | Tuỳ bộ giọng đọc của hệ điều hành | App gọi giọng đọc của hệ điều hành; bộ giọng (ví dụ của Google) có thể dùng mạng theo cài đặt của máy — đó là dịch vụ hệ thống, không phải SDK trong app *(ghi trong chính sách)* |
| Sao lưu tự động vào thư mục chọn (F-11) | Chỉ khi người dùng chọn thư mục của app đám mây của chính họ | Đúng trường hợp FAQ của Play: người dùng tự đưa lên kho của chính họ, theo điều khoản nhà cung cấp; app không truy cập |
| "Sao lưu ngay", chia sẻ chữ/PDF/`.cooknote` | Theo đích người dùng chọn trong bảng chia sẻ | Chuyển do người dùng chủ động, biết rõ đích → không tính "chia sẻ" |
| **Android Auto Backup** (DB + cài đặt, không ảnh; `allowBackup=true`, `data_extraction_rules.xml`) | Có: hệ điều hành đưa bản sao lên **tài khoản Google của chính người dùng** | Do dịch vụ sao lưu của Android thực hiện, gắn với tài khoản Google của người dùng, nhà phát triển không có cách đọc; tương tự trường hợp "người dùng tải lên kho đám mây của chính họ" trong FAQ. Play không có câu hỏi riêng cho Auto Backup *(đánh giá theo định nghĩa, không phải câu chữ của Play — đọc lại FAQ ngày điền)*. Chính sách quyền riêng tư nói rõ lớp này |
| Chuyển máy trực tiếp (device-to-device, mang cả ảnh) | Từ máy cũ sang máy mới của người dùng | Không qua nhà phát triển |
| Báo crash | Không có SDK | Chỉ Android vitals của Play Console (số liệu Google tự thu theo cài đặt máy) |

Sai lệch phải khai lại trước khi phát hành bản đó (S-42): thêm SDK analytics/crash/quảng cáo, ML Kit, đồng bộ đám mây có đăng nhập,
bất kỳ lời gọi mạng nào ngoài F-03.

**Đối chiếu ở #3 trước khi bấm Submit:** `pubspec.lock` (không gói analytics/ads/crash/ML Kit), manifest đã gộp của bản release
(`aapt2 dump permissions`), danh sách quyền khớp `docs/legal/privacy-policy.md` mục 4.

## Đồ hoạ store
Kích thước và 8 cảnh: `store/screenshots-plan.md`. Icon 512×512 và feature graphic 1024×500: chưa có (làm ở #2/#3 với UI mới).

## Nguồn đã đọc 2026-11-05 (trang chính thức)
- [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152) — App name 30, Short description 80, Full description 4.000; giới hạn tính cho mọi loại ký tự.
- [Add preview assets](https://support.google.com/googleplay/android-developer/answer/9866151) — icon, feature graphic, ảnh chụp (số liệu ở `store/screenshots-plan.md`).
- [Provide information for Google Play's Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469) — định nghĩa collect/share, WebView duyệt web mở, FAQ "upload to Google Drive or Dropbox".
- [App testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465) — 12 tester × 14 ngày (chi tiết `store/closed-test.md`).
- [Target API level requirements](https://support.google.com/googleplay/android-developer/answer/11926878) — từ 31/08/2026 app mới và cập nhật phải target API 36 (khớp S-10).

## Kết quả đếm (chạy `python store/check_limits.py`, 2026-11-05)
Xem mục cuối `store/app-store.md` (một lần chạy đếm cả hai file).
