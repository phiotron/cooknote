# Hồ sơ App Store — CookNote (bản nháp, chưa nộp)

Viết 2026-11-05 (phiên con "[A004-cooknote] Store & pháp lý 2 nền tảng", phiên điều phối #1). Dán vào App Store Connect ở phiên #3;
Phương duyệt trước khi nộp. Phải khớp bản Play (`store/google-play.md`) và khớp code (S-31, S-42). Số liệu Apple kiểm trên trang
chính thức **2026-11-05** (nguồn cuối file). Không sao chép chữ của Paprika, Recipe Keeper, CookBook; không nêu tên app khác trong
metadata (Apple: keyword không được chứa tên app/công ty khác).

Trạng thái project iOS lúc viết (thư mục `ios/` **chưa commit**, phiên "iOS + CI" đang làm — đọc, không sửa):
`CFBundleDisplayName = CookNote`, min iOS 15.0, `ITSAppUsesNonExemptEncryption = false`, có `NSCameraUsageDescription` và
`NSPhotoLibraryUsageDescription`, **`TARGETED_DEVICE_FAMILY = "1,2"` (iPhone + iPad)**, chưa có `PrivacyInfo.xcprivacy`.
Trước khi dán ở #3: đối chiếu lại `ios/Runner/Info.plist`, `project.pbxproj` và CI iOS.

## Tra trùng tên (S-71) — kiểm 2026-11-05
**Kết luận: "CookNote" đã có người dùng cho đúng loại app này, trên cả hai store, kể cả ở Việt Nam.** Không tự đổi tên — Phương quyết.

| Nơi | Kết quả | Link |
|---|---|---|
| Google Play | **"CookNote"** — DEROU Software, sổ công thức cá nhân, Food & Drink, 10+ lượt tải, cập nhật 21/07/2025 | [note.CookNote](https://play.google.com/store/apps/details?id=note.CookNote) |
| Google Play | **"Cooknote - Sổ tay nấu ăn"** — BECEN JOINT STOCK COMPANY (VN), sổ tay nấu ăn tiếng Việt, có quảng cáo, đăng nhập đồng bộ, hẹn giờ trong bước, tìm theo nguyên liệu; cập nhật 27/02/2026 | [com.enetty.cooknote](https://play.google.com/store/apps/details?id=com.enetty.cooknote) |
| Google Play | Tìm "cooknote": 2 app trên đứng đầu kết quả | [tìm kiếm](https://play.google.com/store/search?q=cooknote&c=apps) |
| App Store | **"Cooknote - Sổ tay nấu ăn"** — BECEN JOINT STOCK COMPANY, Food & Drink, 12+, miễn phí | [id6758554557](https://apps.apple.com/vn/app/id6758554557) |
| App Store | **"CookNotes: Your Kitchen Helper"** — Joy Ngen Jiaxi, Lifestyle; tính năng gần như trùng (nhập từ link/ảnh/chữ viết tay, tủ bếp, đi chợ, hẹn giờ, khẩu phần) | [id6760633319](https://apps.apple.com/app/id6760633319) |
| App Store | "MyCookNote: Recipe Finder" — Gokhan Alp Atar | [id6761327357](https://apps.apple.com/fr/app/mycooknote/id6761327357) |
| App Store | "CookNote 料理レシピの簡単メモアプリ" (Nhật) — chỉ thấy trong mục "khách cũng xem", chưa mở được trang riêng | (qua tìm kiếm web) |
| Nhãn hiệu | WIPO Global Brand Database, tên chứa "cooknote": **không có kết quả** (cơ sở này có dữ liệu Cục SHTT Việt Nam, USPTO, EUIPO…) | [WIPO GBD](https://branddb.wipo.int/en/similarname) |
| Nhãn hiệu | Tìm web "CookNote trademark": không thấy bản ghi; chưa tra trực tiếp USPTO, Cục SHTT (wipopublish) | — |

Đánh giá rủi ro:
- App Store Connect chặn tên **đã có y hệt**; "CookNote: Recipe Notebook" khác chuỗi với "Cooknote - Sổ tay nấu ăn" nên **có thể**
  vẫn được nhận — chưa thử (cần tài khoản Apple Developer). Google Play không chặn trùng tên.
- Nhưng ở Việt Nam, người dùng tìm "cooknote" sẽ gặp app của BECEN trước (có quảng cáo, đăng nhập, thu thập dữ liệu — ngược hẳn
  cam kết của mình): dễ nhầm, khó nổi trên kết quả tìm kiếm, và nếu BECEN đăng ký nhãn hiệu sau này thì mình có thể bị yêu cầu đổi tên.
- Đổi tên **trước** khi tạo trang Play cho closed test là rẻ nhất (icon, chính sách, ảnh chưa làm).

**3 tên đề xuất** (đã tra Play, web và WIPO ngày 2026-11-05; mỗi tên đi kèm phần mô tả sau dấu hai chấm như Ví Gọn):
| # | Tên | Store vi / en | Tra được | Ưu / nhược |
|---|---|---|---|---|
| 1 | **Sổ Bếp** | "Sổ Bếp: Công Thức Nấu Ăn" / "Sổ Bếp: Recipe Notebook" | Play: không app nào tên "Sổ Bếp" ([tìm](https://play.google.com/store/search?q=s%E1%BB%95%20b%E1%BA%BFp&c=apps)); tìm web App Store: không có; WIPO: không có nhãn "Sổ Bếp" (chỉ các nhãn chứa "BẾP"/"BEP" khác nghĩa) | Dễ hiểu với người Việt, đúng tinh thần "sổ tay"; người nước ngoài khó gõ dấu → thêm keyword `so bep` |
| 2 | **Bepbook** | "Bepbook: Sổ Công Thức" / "Bepbook: Recipe Notebook" | Play, web, WIPO: **không có kết quả nào** | Tên tự đặt (bếp + book), gõ được ở mọi bàn phím, giữ gốc Việt; nghĩa chưa rõ với người nước ngoài — phần sau dấu hai chấm gánh nghĩa |
| 3 | **Bếp Nhớ** ("căn bếp ghi nhớ" — nói đúng ý giữ công thức cả đời) | "Bếp Nhớ: Sổ Công Thức" / "Bếp Nhớ: Recipe Notebook" | Play: không có; WIPO: không có "Bếp Nhớ", nhưng có nhãn gần âm "Căn Bếp Nhỏ" (nhóm 29), "Bếp Chay Nhỏ" (nhóm 43) | Ý nghĩa hay nhất; rủi ro nhầm "nhớ"/"nhỏ" với nhãn ngành thực phẩm/nhà hàng (khác nhóm 9 của phần mềm) |
Đã loại khi tra: "Mâm Nhà" (nhãn "MÂM NHÀ" đã đăng ký ở VN, nhóm 43, 2025), "Cookfolio", "Kitchen Keepsake" (đã có app), "Ladle…"
(nhiều app recipe tên Ladle). Gợi ý của phiên này: **Bepbook** nếu muốn một tên cho cả thế giới, **Sổ Bếp** nếu ưu tiên Việt Nam.
Tên nào cũng nên tra lại trực tiếp trên App Store (iPhone/App Store Connect) và Cục SHTT trước khi chốt. Bundle ID
`com.phiotron.cooknote` không cần đổi (không hiện ra ngoài).

## Thông tin chung (App Information)
| Trường | Giá trị |
|---|---|
| Bundle ID | `com.phiotron.cooknote` (Phương tạo App ID trên developer.apple.com) |
| SKU | `cooknote-ios-1` (nội bộ) |
| Ngôn ngữ chính | English (U.S.); thêm Vietnamese |
| Danh mục chính / phụ | **Food & Drink** / **Productivity** |
| Giá | Miễn phí; không In-App Purchase, không thuê bao, không quảng cáo |
| Phân phối | Mọi quốc gia/vùng **trừ Trung Quốc đại lục** (S-88 không bật; cần số ICP). Không tự mã hoá → không cần khai báo Pháp (S-89 không bật) |
| Thiết bị | **Đề xuất chỉ iPhone ở v1** (như A002): project hiện bật cả iPad (`"1,2"`) → nếu giữ iPad thì App Review thử trên iPad và **bắt buộc ảnh iPad 13"** (`store/screenshots-plan.md`). Quyết ở phiên điều phối / phiên iOS |
| Copyright | `2026 <họ tên người đăng ký Apple Developer>` (Apple tự thêm ký hiệu ©) |
| Seller | Tài khoản **cá nhân** → App Store hiện họ tên thật; chính sách quyền riêng tư ghi cùng tên |
| Trader status (EU, DSA) | Bắt buộc khai trước khi phát hành ở EU. App miễn phí, không quảng cáo → Phương cân nhắc khai **không phải trader**; khai là trader thì địa chỉ, điện thoại, email hiện công khai ở EU. Phương tự quyết |
| Content Rights | "Does your app contain, show, or access third-party content?" → **Yes** (trình duyệt hiện trang web; công thức nhập từ web). Câu tiếp theo về quyền: app hoạt động như trình duyệt, người dùng tự mở trang và lưu cho mình dùng riêng, giữ nguồn (AC-63) — **Phương tự xác nhận** câu trả lời (lời cam kết pháp lý) |
| Age Rating | Mục "Xếp hạng tuổi" bên dưới |
| Made for Kids | **Không** (S-84: không nhắm trẻ em) |

## URL bắt buộc
| URL | Bắt buộc | Nội dung | Trạng thái |
|---|---|---|---|
| Privacy Policy URL | Có | `docs/legal/privacy-policy.md` (vi + en) | CHƯA đăng — Phương đăng |
| Support URL | Có | Trang hỗ trợ: **phải có thông tin liên hệ thật** (Apple: địa chỉ, email, điện thoại theo luật địa phương nếu bắt buộc) + vài câu hỏi thường gặp (sao lưu, đổi máy, nhập từ web không được) | CHƯA có — cùng site với chính sách |
| Marketing URL | Không | Bỏ trống | — |

## English (U.S.)
<!-- field: ios.name.en limit=30 -->
```text
CookNote: Recipe Notebook
```
<!-- field: ios.subtitle.en limit=30 -->
```text
Offline recipes & meal planner
```
Keywords: Apple tính **100 byte**, mỗi từ > 2 ký tự, phân cách bằng dấu phẩy không cách, không lặp chữ đã có trong tên/phụ đề/tên nhà
phát triển, không tên app hay công ty khác.
<!-- field: ios.keywords.en limit=100 unit=bytes -->
```text
cookbook,organizer,grocery,shopping,list,pantry,import,scan,timer,kitchen,menu,food,cooking,family
```
<!-- field: ios.promo.en limit=170 -->
```text
Save recipes from the web or a photo, cook with big text and timers, plan your week. No account, no ads, every feature free. Your recipes stay on your iPhone.
```

**Description** — khác bản Play: VoiceOver thay TalkBack; sao lưu iPhone/iCloud thay sao lưu Android; **không** nhắc "sao lưu tự
động vào thư mục" vì F-11 hiện dùng `saf_util`/`saf_stream` (chỉ Android). Nếu phiên iOS làm được sao lưu tự động trên iPhone thì
thêm lại dòng đó (lấy từ bản Play) ở #3. Danh sách dòng phải xoá khi cắt tính năng: như `store/google-play.md`.
<!-- field: ios.description.en limit=4000 -->
```text
CookNote is a recipe notebook for your iPhone. Save recipes from websites or photos, cook from them when your hands are busy, plan the week and shop from one list. Everything stays on your iPhone, and every feature is free.

WHY COOKNOTE
• Free, all of it. No subscription, no premium tier, no ads, no in-app purchases.
• No account. Open the app and start writing. The developer never receives your recipes.
• Built to last a lifetime. Backups use an open, documented format: a zip file with plain JSON, your photos and HTML pages. Open a backup in any web browser to read or print your recipes, even without CookNote.
• Vietnamese done right. Search "pho bo" and find "Phở bò". Units such as chén, bát, muỗng canh and thìa cà phê are understood. Scanning reads Vietnamese text with diacritics.

SAVE RECIPES
• Write your own: ingredients and steps in groups, servings, times, source, notes, rating, favorites, up to 20 photos.
• From the web: share a link from Safari to CookNote, or use the built-in browser. Pages with recipe data fill in automatically; on other pages, select text and mark it as ingredients or steps. You always get a preview before saving, and the source link is kept.
• From photos: scan a cookbook page or a handwritten recipe. Text recognition runs on your iPhone; photos are not uploaded anywhere.
• Import CookNote files, schema.org Recipe JSON, and backup files exported from some popular recipe apps.

COOK
• Cook mode keeps the screen on, uses large text and lets you tap to cross off ingredients and steps.
• Times written in steps become timers. Run several at once; they still alert you when your iPhone is locked.
• Read the current step aloud with the system voice.
• Scale servings (½×, 2×, 3× or any number) and convert between metric and US units.

PLAN AND SHOP
• Meal planner by day, week or month, reusable menus, and random suggestions for empty meals.
• Shopping lists sorted by store aisle. Add ingredients from one recipe or a whole week of meals; matching items are combined.
• Pantry with expiry dates, and "What can I cook?" ranks recipes by what you already have.

ORGANIZE AND SHARE
• Nested categories, tags, filters and sorting. Grid or list view.
• Share a recipe as text, PDF or a CookNote file. Make a PDF cookbook with a cover and table of contents.
• Trash keeps deleted recipes for 30 days.

YOUR DATA
• Recipes, photos and lists are stored only on your iPhone.
• Save a full backup to Files, iCloud Drive or any place you choose, and restore it on a new phone.
• If you use iCloud Backup or back up your iPhone to a computer, your CookNote data is included, so restoring your iPhone brings your recipes back.
• The internet is used only to load web pages you open and their recipe photos.

EASY TO USE
• Vietnamese and English. Light and dark themes. Large text and VoiceOver supported.

CookNote is a personal tool. Recipes you import from websites belong to their authors; CookNote keeps the source link and is meant for your personal use.
```
- **What's New**: App Store Connect **không cho nhập ở bản đầu (1.0)**. Dùng câu "Release notes" của Play cho TestFlight "What to Test".

## Vietnamese
<!-- field: ios.name.vi limit=30 -->
```text
CookNote: Sổ Công Thức
```
<!-- field: ios.subtitle.vi limit=30 -->
```text
Nấu ăn, thực đơn, đi chợ
```
Keyword tiếng Việt: chữ có dấu tốn 2–3 byte, nên đếm bằng byte (script). Có thêm vài dạng không dấu vì người dùng hay gõ không dấu
*(chưa kiểm App Store có tự bỏ dấu khi tìm không)*.
<!-- field: ios.keywords.vi limit=100 unit=bytes -->
```text
món ngon,bếp,nội trợ,làm bánh,hẹn giờ,cong thuc,nau an,recipe,cookbook,menu
```
<!-- field: ios.promo.vi limit=170 -->
```text
Lưu công thức từ web hay ảnh, nấu với chữ lớn và hẹn giờ, xếp thực đơn cả tuần. Không tài khoản, không quảng cáo, mọi tính năng miễn phí. Công thức nằm trên iPhone.
```
<!-- field: ios.description.vi limit=4000 -->
```text
CookNote là sổ tay công thức nấu ăn trên iPhone. Lưu công thức từ trang web hoặc từ ảnh, nấu theo khi tay đang bận, xếp thực đơn cả tuần và đi chợ với một danh sách. Mọi thứ nằm trên iPhone của bạn, và mọi tính năng đều miễn phí.

VÌ SAO CHỌN COOKNOTE
• Miễn phí toàn bộ. Không thuê bao, không bản trả phí, không quảng cáo, không mua trong app.
• Không cần tài khoản. Mở app là ghi được ngay. Nhà phát triển không nhận công thức của bạn.
• Giữ được cả đời. Bản sao lưu dùng định dạng mở, có tài liệu: một file zip chứa JSON thuần, ảnh và các trang HTML. Bạn mở được bản sao lưu bằng trình duyệt bất kỳ để đọc hoặc in công thức, kể cả khi không còn CookNote.
• Tiếng Việt chuẩn. Gõ "pho bo" vẫn ra "Phở bò". Hiểu các đơn vị chén, bát, muỗng canh, thìa cà phê. Quét ảnh đọc được chữ tiếng Việt có dấu.

LƯU CÔNG THỨC
• Tự soạn: nguyên liệu và các bước chia nhóm, khẩu phần, thời gian, nguồn, ghi chú, đánh giá, yêu thích, tối đa 20 ảnh.
• Từ web: chia sẻ đường dẫn từ Safari sang CookNote, hoặc mở trình duyệt có sẵn trong app. Trang có dữ liệu công thức được tự điền; trang khác thì bôi đen chữ rồi gán là nguyên liệu hay các bước. Luôn có màn xem trước để sửa, và giữ đường dẫn nguồn.
• Từ ảnh: quét trang sách hay công thức viết tay. Việc nhận chữ chạy ngay trên iPhone, ảnh không bị tải lên đâu cả.
• Nhập file CookNote, JSON theo chuẩn schema.org Recipe, và file sao lưu xuất từ một số app công thức phổ biến.

NẤU
• Chế độ nấu giữ màn hình sáng, chữ lớn, chạm để gạch nguyên liệu và bước đã làm.
• Thời gian ghi trong bước thành nút hẹn giờ. Chạy nhiều hẹn giờ cùng lúc, vẫn báo khi iPhone đang khóa màn hình.
• Đọc to bước đang làm bằng giọng đọc của hệ thống.
• Nhân khẩu phần (½×, 2×, 3× hoặc số tùy ý), đổi giữa hệ mét và hệ Mỹ.

XẾP THỰC ĐƠN VÀ ĐI CHỢ
• Lịch thực đơn theo ngày, tuần, tháng; thực đơn mẫu dùng lại được; gợi ý ngẫu nhiên cho bữa còn trống.
• Danh sách đi chợ xếp theo khu vực trong chợ, siêu thị. Thêm nguyên liệu từ một công thức hay cả tuần thực đơn; món trùng được gộp.
• Tủ bếp có hạn dùng, và "Nấu được gì?" xếp công thức theo nguyên liệu bạn đang có.

SẮP XẾP VÀ CHIA SẺ
• Danh mục lồng nhau, thẻ, bộ lọc, sắp xếp. Xem dạng lưới hoặc dạng dòng.
• Chia sẻ công thức dạng chữ, PDF hoặc file CookNote. Xuất sách công thức PDF có bìa và mục lục.
• Thùng rác giữ công thức đã xóa 30 ngày.

DỮ LIỆU CỦA BẠN
• Công thức, ảnh và các danh sách chỉ lưu trên iPhone.
• Lưu bản sao lưu đầy đủ vào Tệp, iCloud Drive hay nơi bạn chọn, rồi khôi phục trên máy mới.
• Nếu bạn dùng Sao lưu iCloud hoặc sao lưu iPhone bằng máy tính, dữ liệu CookNote nằm trong bản sao lưu đó, nên khôi phục iPhone là có lại công thức.
• Internet chỉ dùng để tải trang web bạn mở và ảnh của công thức.

DỄ DÙNG
• Tiếng Việt và tiếng Anh. Giao diện sáng và tối. Hỗ trợ cỡ chữ lớn và VoiceOver.

CookNote là công cụ cá nhân. Công thức nhập từ trang web thuộc về tác giả của chúng; CookNote giữ đường dẫn nguồn và chỉ dành cho bạn dùng riêng.
```
Câu iCloud chỉ đúng nếu DB và thư mục ảnh **không** bị đặt cờ loại khỏi sao lưu (APP.md: giữ bật iCloud backup; khác fact
`ios-ma-hoa-va-sao-luu` của app tài chính). Phiên iOS đổi chỗ lưu → sửa câu này và chính sách mục 3.

## Xếp hạng tuổi (S-23) — bảng hỏi mới, kiểm 2026-11-05
Trang Apple "Age ratings values and definitions" (đọc 2026-11-05) định nghĩa **Unrestricted Web Access** = "người dùng điều hướng
tới bất kỳ trang web nào trong app hoặc duyệt web tự do, gồm trình duyệt nhúng", và xếp nó vào mức **16+** (thiết bị iOS 26 trở lên;
**Việt Nam cũng 16+** theo bảng riêng của Việt Nam; Brazil A16), **17+** trên thiết bị iOS cũ hơn 26. CookNote có trình duyệt trong
app với thanh địa chỉ, tìm bằng công cụ tìm kiếm, Back/Forward (AC-16) → **phải trả lời Yes**.

| Nhóm câu hỏi | Trả lời đề xuất | Lý do |
|---|---|---|
| In-App Controls: Parental Controls | No | Không có |
| In-App Controls: Age Assurance | No | Không dùng Declared Age Range (COMPLIANCE D-12 chờ quyết) |
| Capabilities: **Unrestricted Web Access** | **Yes** | Trình duyệt trong app, AC-16 |
| Capabilities: User-Generated Content | No | Công thức chỉ nằm trên máy; chia sẻ cho từng người qua bảng chia sẻ, không phát tán rộng trong app |
| Capabilities: Social Media / Messaging and Chat / Advertising | No | Không có |
| Mature Themes (thô tục, kinh dị, rượu-thuốc lá-ma tuý) | None | App không có nội dung sẵn. Công thức người dùng tự nhập (có thể có rượu nấu ăn) không phải nội dung của app. **Nếu app kèm công thức mẫu có rượu/bia → chọn Infrequent** |
| Medical or Wellness (thông tin y tế; chủ đề sức khoẻ: đếm calo, ăn kiêng) | None | Dinh dưỡng là chữ tự do người dùng nhập, app không tính calo, không tư vấn (SPEC mục 4) |
| Sexuality or Nudity / Violence | None | Không có |
| Chance-Based Activities (cờ bạc, thi đấu, loot box) | None / No | Không có |
| Made for Kids | No | |

**Kết quả dự kiến: 16+ (iOS 26+, gồm Việt Nam) / 17+ (iOS < 26).** Nếu trả lời No cho Unrestricted Web Access thì dự kiến **4+**
(Việt Nam 00+).

> **Lệch với APP.md (S-84: đối tượng mọi lứa tuổi từ 13).** Trên App Store, người 13–15 tuổi bị Screen Time chặn tải app 16+.
> Phương chọn một trong hai (ghi D-xxx):
> - **A. Giữ trình duyệt đầy đủ như AC-16** → chấp nhận 16+/17+ trên App Store; Play vẫn khai đối tượng 13+.
> - **B. Thu hẹp trình duyệt**: bỏ thanh địa chỉ và ô tìm, chỉ mở trang được chia sẻ/dán vào và các trang cùng trang web đó →
>   có cơ sở trả lời No → 4+ (cần sửa AC-16, việc của #2; App Review vẫn có thể đánh giá khác).
> Luồng nhập nhanh nhất vốn là "Chia sẻ từ trình duyệt → CookNote" (AC-17), nên B ít ảnh hưởng người dùng. Câu trả lời phải đúng
> với bản nộp; đổi hành vi thì trả lời lại.

Ghi kết quả thật vào COMPLIANCE P-05 khi điền.

## App Privacy — "Data Not Collected" (S-21, S-42)
- "Do you or your third-party partners collect data from this app?" → **No, we do not collect data from this app.**
- Căn cứ (trang Apple "App Privacy Details", đọc 2026-11-05):
  - "Collect" = truyền dữ liệu ra khỏi máy theo cách cho nhà phát triển hoặc đối tác truy cập lâu hơn thời gian phục vụ yêu cầu tức thời.
  - "Dữ liệu chỉ xử lý trên máy không phải là thu thập" → OCR Apple Vision/Tesseract, ảnh, thông báo hẹn giờ cục bộ, tìm kiếm đều trên máy.
  - "Dữ liệu thu qua web view phải khai, **trừ khi bạn cho người dùng duyệt web mở**" → trình duyệt trong app không phải khai.
  - "Bạn không chịu trách nhiệm khai dữ liệu do Apple thu" → **Sao lưu iCloud** (Apple giữ, gắn tài khoản Apple của người dùng,
    nhà phát triển không truy cập) không làm đổi nhãn.
  - Nhập từ web: app tải trang người dùng chọn từ chính trang đó; không gửi dữ liệu người dùng cho nhà phát triển hay đối tác.
  - Không SDK bên thứ ba thu dữ liệu, không analytics, không crash SDK, không quảng cáo → không tracking, không cần ATT (S-83 không bật).
- `ios/Runner/PrivacyInfo.xcprivacy` (việc của phiên iOS, **chưa có** lúc viết): `NSPrivacyTracking = false`, `NSPrivacyTrackingDomains`
  rỗng, `NSPrivacyCollectedDataTypes` rỗng, khai **API cần lý do** mà code và plugin dùng (ví dụ File timestamp, UserDefaults, Disk
  space — kiểm thật bằng cảnh báo của App Store Connect hoặc rà plugin). Plugin tự kèm manifest riêng.
- Privacy Choices URL: không cần.

## Export compliance (S-22)
`ITSAppUsesNonExemptEncryption = false` (đúng với Info.plist hiện tại): app chỉ dùng HTTPS của hệ điều hành; gói `crypto` chỉ để
**băm** SHA-256 (kiểm toàn vẹn file sao lưu, D-007) — băm không phải mã hoá; file sao lưu **không mã hoá** (SPEC mục 6). Không bật S-89.
Nếu sau này thêm mật khẩu cho file sao lưu → xem lại (kinh nghiệm A002: phải khai Pháp).

## Thông tin cho App Review
- Sign-in required: **No**.
- Liên hệ: họ tên + email `phamphuongphuongnd@gmail.com` + số điện thoại của Phương (chỉ Apple thấy).
- Notes (dán nguyên, tiếng Anh; sửa nếu cắt tính năng):
  ```
  CookNote is an offline recipe notebook. There is no account and no server; all data stays on the device.
  Network use: only the built-in browser and "Import from web", which load the web page the user opens and its recipe photos. No user data is sent to the developer or third parties.
  To try web import: tap "+" on the Recipes tab > From web, open any recipe page (for example a page with schema.org Recipe data), tap "Save recipe", then Save in the preview. You can also share a link from Safari to CookNote.
  Scan: "+" > Scan photo. Text recognition runs on the device (Apple Vision); the camera permission prompt appears only when the user chooses to take a photo.
  Cook mode: open a recipe > Cook. Tapping a time in a step starts a timer; the notification permission is requested the first time, after a short explanation.
  Backup: More > Backup > back up now opens the share sheet (Save to Files). Restore uses the Files picker.
  The app is free, has no ads and no in-app purchases.
  ```

## Ảnh chụp và icon
Kích thước, số lượng, 8 cảnh: `store/screenshots-plan.md`. Icon App Store 1024×1024 không alpha lấy từ `AppIcon` của `ios/` (làm ở #2).

## Nguồn đã đọc 2026-11-05 (trang chính thức Apple)
- [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) — Name 2–30 ký tự, Subtitle ≤ 30, Content Rights, Age Rating, Made for Kids.
- [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/) — Promotional Text ≤ 170, Description ≤ 4.000, **Keywords ≤ 100 byte**, mỗi từ > 2 ký tự, không tên app/công ty khác; Support URL phải dẫn tới thông tin liên hệ thật; What's New không có ở bản đầu.
- [Age ratings values and definitions](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/) — Unrestricted Web Access → 16+ (VN 16+, BR A16), 17+ ở OS < 26.
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/) — định nghĩa "collect", xử lý trên máy, web view duyệt web mở, dữ liệu Apple thu.
- [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) — Xcode 26/SDK 26 (từ 28/04/2026), iOS 13+ (từ 09/09/2026), trả lời bảng hỏi tuổi mới (từ 31/01/2026), DSA trader status ở EU. Không có yêu cầu mới nào chưa tới hạn tại ngày kiểm. Khớp STANDARDS S-20, S-23, S-24.
- [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) — số liệu ở `store/screenshots-plan.md`.

## Kết quả đếm (`python store/check_limits.py`, 2026-11-05)
Dán lại sau mỗi lần sửa chữ:
```
OK   app-store.md:ios.name.en chars=25 bytes=25 limit=30 chars
OK   app-store.md:ios.subtitle.en chars=30 bytes=30 limit=30 chars
OK   app-store.md:ios.keywords.en chars=98 bytes=98 limit=100 bytes terms=14 dups=- short=-
OK   app-store.md:ios.promo.en chars=158 bytes=158 limit=170 chars
OK   app-store.md:ios.description.en chars=3001 bytes=3061 limit=4000 chars
OK   app-store.md:ios.name.vi chars=22 bytes=27 limit=30 chars
OK   app-store.md:ios.subtitle.vi chars=24 bytes=34 limit=30 chars
OK   app-store.md:ios.keywords.vi chars=75 bytes=88 limit=100 bytes terms=10 dups=- short=-
OK   app-store.md:ios.promo.vi chars=164 bytes=216 limit=170 chars
OK   app-store.md:ios.description.vi chars=2933 bytes=3841 limit=4000 chars
OK   google-play.md:play.name.vi chars=29 bytes=37 limit=30 chars
OK   google-play.md:play.name.en chars=25 bytes=25 limit=30 chars
OK   google-play.md:play.short.vi chars=78 bytes=104 limit=80 chars
OK   google-play.md:play.short.en chars=77 bytes=77 limit=80 chars
OK   google-play.md:play.full.vi chars=2965 bytes=3910 limit=4000 chars
OK   google-play.md:play.full.en chars=3044 bytes=3104 limit=4000 chars
OK   google-play.md:play.release.vi chars=203 bytes=282 limit=500 chars
OK   google-play.md:play.release.en chars=217 bytes=217 limit=500 chars
```
Mọi trường đạt (exit 0). Chữ tiếng Việt ở dạng NFC (dựng sẵn), nên số ký tự trùng cách đếm của store.
