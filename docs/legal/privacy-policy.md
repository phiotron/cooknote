# Chính sách quyền riêng tư — Bepbook (bản nháp để đăng)

> **Ghi chú nội bộ, KHÔNG đăng phần này.**
> - Viết 2026-11-05 (phiên con "[A004-cooknote] Store & pháp lý 2 nền tảng") cho **Android + iOS** (D-008), từ SPEC mục 3–6 (F-03,
>   F-04, F-05, F-11, F-14), D-002, D-003, D-005, D-007, APP.md "Tiêu chuẩn áp dụng" (giữ bật Android Auto Backup và iCloud backup;
>   đối tượng 13+). Đối chiếu code lúc viết: `android/app/src/main/AndroidManifest.xml` (`allowBackup="true"`, chưa khai quyền nào —
>   plugin sẽ thêm `INTERNET`, `POST_NOTIFICATIONS`… ở #2), `res/xml/backup_rules.xml` + `data_extraction_rules.xml` (sao lưu đám mây
>   loại `photos/` và `safety/`; chuyển máy trực tiếp mang cả ảnh), `ios/Runner/Info.plist` (commit `9b646df`; có `NSCameraUsageDescription`,
>   `NSPhotoLibraryUsageDescription`).
> - **Trước khi đăng (phiên #3):** đối chiếu mục 4 với danh sách quyền thật (`aapt2 dump permissions` bản release + Info.plist), mục 3
>   với cách lưu thật trên iOS (DB/ảnh có bị loại khỏi sao lưu không), mục 5 với cách hẹn giờ chốt ở G5, và bỏ dòng tính năng bị cắt
>   (OCR, nhập file app khác…). Chính sách hứa sai còn tệ hơn không có (S-42).
> - Thay `[Tên nhà phát triển]` bằng đúng tên hiển thị trên store (Play: Phiotron; App Store tài khoản cá nhân: họ tên thật), điền
>   ngày hiệu lực. Email lấy từ fact xưởng `tai-khoan-store` (`phamphuongphuongnd@gmail.com`, chốt 2026-11-05) — dùng chung cho báo
>   lỗi bảo mật (AC-63). Phương muốn email riêng cho bảo mật thì thay `[EMAIL_BẢO_MẬT]`/`[SECURITY_EMAIL]`.
> - Nơi đăng (fact `tai-khoan-store`): GitHub Pages của repo public chung `phiotron-legal`, mỗi app một thư mục — gợi ý
>   `https://phiotron.github.io/phiotron-legal/cooknote/privacy` (vi + en cùng trang) và `…/cooknote/support` (Support URL App Store).
>   URL phải mở được không cần đăng nhập, không phải PDF tải về, ổn định lâu dài. Sau khi có URL: điền vào màn Giới thiệu (AC-63,
>   việc của phiên code), Play Console (App content → Privacy policy), App Store Connect (Privacy Policy URL).
> - Tên app trong bản này là "Bepbook" (D-010, 2026-11-05; tên cũ CookNote đã bỏ). File sao lưu vẫn có đuôi `.cooknote`.
> - D-010 (2026-11-05) đã thêm vào bản vi + en: trang `http` được tải không mã hóa (mục trình duyệt), "Xóa toàn bộ dữ liệu" xóa cả dữ liệu trình duyệt, sao lưu tự động có cả iPhone (thư mục trong Tệp + bookmark lưu trên máy). Mục tuổi: chính sách ghi 13+ (Play); App Store xếp 16+/17+ vì trình duyệt đầy đủ — không mâu thuẫn (13+ là mức tối thiểu của chính sách).
> - Không phải tư vấn pháp lý.

---

## Tiếng Việt

**Chính sách quyền riêng tư của Bepbook**
Ngày hiệu lực: [điền ngày đăng]

Bepbook là sổ tay công thức nấu ăn cho điện thoại Android và iPhone. Chính sách này giải thích app lưu dữ liệu gì, lưu ở đâu, khi nào app dùng Internet và bạn kiểm soát dữ liệu ra sao. Chính sách áp dụng cho cả bản Android (Google Play) và bản iPhone (App Store).

**1. Chúng tôi không thu thập dữ liệu của bạn**
Bepbook không có máy chủ, không có tài khoản người dùng, không có quảng cáo, không có công cụ phân tích, theo dõi hay báo lỗi của bên thứ ba. Nhà phát triển Bepbook không nhận, không xem, không bán và không chia sẻ bất kỳ dữ liệu nào bạn nhập vào app.

**2. Dữ liệu nằm trên điện thoại của bạn**
Những gì bạn tạo trong app (công thức, ảnh, danh mục, thẻ, lịch sử nấu, lịch thực đơn, danh sách đi chợ, tủ bếp, cài đặt) được lưu trong vùng lưu trữ riêng của app trên điện thoại. App khác không đọc được vùng này. Công thức và ghi chú có thể chứa thông tin do chính bạn viết (ví dụ "công thức của bà ngoại") hoặc ảnh có người; những thông tin đó cũng chỉ nằm trên máy bạn.
Khi bạn thêm ảnh, app chép ảnh vào vùng lưu trữ riêng, thu nhỏ và xóa toàn bộ thông tin đi kèm trong ảnh (EXIF), gồm cả vị trí chụp.

**3. Sao lưu**
Vì dữ liệu chỉ nằm trên máy, Bepbook cho bạn nhiều cách giữ bản sao. Mọi cách đều do bạn chọn đích, và nhà phát triển không truy cập được bản nào.
- **Sao lưu tự động vào thư mục bạn chọn (Android và iPhone).** Bạn chọn một thư mục bằng trình chọn thư mục của hệ điều hành, có thể là thư mục trên máy hoặc thư mục do app lưu trữ đám mây của chính bạn (Android: ví dụ Google Drive, OneDrive; iPhone: thư mục trong ứng dụng Tệp, gồm iCloud Drive) quản lý. Trên iPhone, app ghi nhớ quyền truy cập thư mục đó trên chính máy của bạn để lần sau ghi tiếp mà không hỏi lại; thông tin này không rời khỏi máy và không nằm trong file sao lưu. App ghi file sao lưu vào đó theo chu kỳ bạn đặt và giữ số bản bạn chọn. Nếu thư mục thuộc dịch vụ đám mây, việc tải lên do app của dịch vụ đó (hoặc iCloud) làm, theo điều khoản và chính sách của dịch vụ đó.
- **Sao lưu ngay.** App tạo file sao lưu rồi mở bảng chia sẻ hoặc trình lưu file của hệ điều hành để bạn chọn nơi lưu hay gửi (ví dụ app Tệp, Google Drive, email).
- **File sao lưu `.cooknote` không được mã hóa.** Đó là file zip theo định dạng mở, có tài liệu, chứa dữ liệu dạng JSON, ảnh và các trang HTML đọc được bằng trình duyệt. Ai có file đều đọc được, nên hãy cất ở nơi an toàn.
- **Sao lưu của hệ điều hành (đang bật).**
  - Android: Bepbook cho phép tính năng sao lưu tự động của Android. Nếu bạn bật sao lưu trên máy, Android đưa bản sao cơ sở dữ liệu và cài đặt của Bepbook (không gồm ảnh) lên tài khoản Google của chính bạn, và khôi phục khi bạn cài lại app hoặc cài máy mới cùng tài khoản. Khi chuyển dữ liệu trực tiếp từ máy cũ sang máy mới (bằng cáp hoặc không dây), Android có thể mang theo cả ảnh. Việc này do Google và hệ điều hành thực hiện theo chính sách của Google; nhà phát triển không truy cập được bản sao lưu này.
  - iPhone: dữ liệu của Bepbook nằm trong Sao lưu iCloud và bản sao lưu iPhone bằng máy tính nếu bạn dùng các tính năng đó. Việc này do Apple và iOS thực hiện theo chính sách của Apple; nhà phát triển không truy cập được bản sao lưu này.
  - Muốn dữ liệu Bepbook không vào sao lưu của hệ điều hành, bạn tắt sao lưu cho app hoặc cho máy trong phần cài đặt của điện thoại.

**4. Quyền trên điện thoại và khi nào app dùng Internet**
Bepbook chỉ xin quyền khi bạn dùng tới tính năng cần quyền đó, và vẫn dùng được nếu bạn từ chối.
- **Internet:** chỉ dùng cho trình duyệt trong app và tính năng "Nhập từ web": tải trang web bạn mở hoặc chia sẻ sang Bepbook, và tải ảnh của công thức về máy để xem được khi không có mạng. App không gửi công thức hay dữ liệu nào của bạn đi qua Internet.
- **Thông báo:** để báo khi hết giờ hẹn giờ nấu. App hỏi lần đầu bạn bật hẹn giờ, sau một lời giải thích. Thông báo được tạo ngay trên máy, không đi qua máy chủ nào. Từ chối thì hẹn giờ vẫn chạy khi app đang mở.
- **Ảnh:** app dùng trình chọn ảnh của hệ điều hành và chỉ nhận đúng ảnh bạn chọn; app không xin quyền đọc toàn bộ thư viện ảnh trên Android.
- **Camera:** trên Android, chụp ảnh bằng ứng dụng camera của hệ điều hành nên Bepbook không xin quyền camera. Trên iPhone, iOS hỏi quyền camera lần đầu bạn chọn chụp ảnh trong app.
- **Giữ màn hình sáng** trong chế độ nấu; trở lại như cũ khi bạn thoát.
- App không xin quyền vị trí, danh bạ, micro. Chọn file khôi phục, chọn thư mục sao lưu và chia sẻ đều dùng trình chọn và bảng chia sẻ của hệ điều hành, chỉ truy cập đúng file hoặc thư mục bạn chọn.

**5. Xử lý ngay trên máy**
- **Quét công thức từ ảnh:** việc nhận chữ chạy hoàn toàn trên điện thoại (Android: Tesseract nguồn mở; iPhone: bộ nhận chữ Vision của Apple). Ảnh và chữ nhận được không bị gửi đi.
- **Đọc bước:** app dùng giọng đọc của hệ điều hành. Một số bộ giọng đọc của hệ điều hành có thể dùng mạng theo cài đặt trên máy bạn; việc đó do Google hoặc Apple quản lý theo chính sách của họ.
- Tìm kiếm, nhân khẩu phần, đổi đơn vị, gợi ý thực đơn, xuất PDF đều chạy trên máy.

**6. Trang web bạn mở trong app**
Trình duyệt trong Bepbook dùng thành phần trình duyệt của hệ điều hành. Trang web bạn mở có thể tự đặt cookie và thu thập dữ liệu theo chính sách riêng của trang đó, như khi bạn mở trang bằng trình duyệt thường. Trình duyệt này cũng mở được trang web dùng địa chỉ `http` (không mã hóa): khi đó đường truyền giữa máy bạn và trang đó không được mã hóa, nên người khác trên cùng mạng (ví dụ Wi-Fi công cộng) có thể đọc hoặc sửa nội dung trang bạn tải. App hiện nhãn "Không mã hóa" trên thanh địa chỉ cho những trang đó; đừng nhập mật khẩu hay số thẻ trên chúng. Bepbook không gửi dữ liệu nào của bạn tới trang ngoài yêu cầu tải trang. Bepbook không chèn mã theo dõi vào trang và không đọc dữ liệu đăng nhập hay cookie của trang. Khi bạn bấm lưu, app chỉ lấy nội dung công thức (tên, nguyên liệu, các bước, ảnh, nguồn) để lưu vào máy bạn.
Các liên kết trong app (ví dụ liên kết nguồn, liên kết tới chính sách này, email báo lỗi) mở bằng trình duyệt hoặc app email của bạn; các app đó hoạt động theo chính sách riêng của chúng.

**7. Bản quyền công thức nhập từ web**
Công thức bạn nhập từ trang web hoặc quét từ sách thuộc bản quyền của tác giả hoặc nhà xuất bản. Bepbook giữ tên trang và đường dẫn nguồn của công thức, và chỉ dành cho bạn lưu để dùng riêng. Hãy tôn trọng quyền của tác giả khi chia sẻ hoặc in lại công thức.

**8. Dữ liệu cửa hàng ứng dụng có thể thu thập**
Khi bạn tải app qua Google Play hoặc App Store, Google hoặc Apple có thể thu thập thông tin về việc cài đặt và sự cố của app theo chính sách của họ và cài đặt trên máy bạn. Nhà phát triển chỉ thấy số liệu tổng hợp, ẩn danh trong Play Console và App Store Connect, không dùng được để nhận ra bạn.

**9. Quyền của bạn**
Vì dữ liệu chỉ nằm trên máy bạn, bạn tự thực hiện mọi quyền ngay trong app: xem và sửa từng công thức và danh sách; xuất toàn bộ dữ liệu ra file sao lưu theo định dạng mở để mang đi nơi khác; xóa từng mục, hoặc xóa toàn bộ dữ liệu trong Cài đặt → "Xóa toàn bộ dữ liệu" (việc này cũng xóa cookie, bộ nhớ đệm và dữ liệu của trình duyệt trong app); hoặc gỡ app. Gỡ app hay xóa toàn bộ dữ liệu không xóa các file sao lưu bạn đã lưu ở nơi khác và không xóa bản sao lưu của hệ điều hành; bạn tự xóa chúng ở nơi lưu. Nhà phát triển không giữ bản nào để xóa giúp bạn.

**10. Độ tuổi**
Bepbook dành cho người từ 13 tuổi trở lên và không nhắm tới trẻ em dưới 13 tuổi. App không thu thập dữ liệu của bất kỳ ai, kể cả trẻ em. Trình duyệt trong app cho phép mở mọi trang web; cha mẹ có thể dùng công cụ kiểm soát của Google hoặc Apple để giới hạn.

**11. Bảo mật**
Dữ liệu được bảo vệ bằng cơ chế cách ly ứng dụng của Android và iOS. App không có khóa riêng và không mã hóa file sao lưu, vì vậy hãy dùng khóa màn hình của điện thoại và cất file sao lưu ở nơi an toàn. Nếu bạn phát hiện lỗi bảo mật, hãy báo qua email ở mục 13.

**12. Thay đổi chính sách**
Nếu Bepbook thay đổi cách xử lý dữ liệu (ví dụ thêm tính năng gửi dữ liệu ra ngoài), chúng tôi sẽ cập nhật chính sách này và ngày hiệu lực trước khi phát hành bản có thay đổi. Đây là bản đầu tiên của chính sách.

**13. Liên hệ**
[Tên nhà phát triển], nhà phát triển Bepbook
Email hỗ trợ và báo lỗi bảo mật: phamphuongphuongnd@gmail.com [EMAIL_BẢO_MẬT nếu khác]

---

## English

**Bepbook Privacy Policy**
Effective date: [fill in on publishing]

Bepbook is a recipe notebook for Android phones and iPhone. This policy explains what data the app stores, where it is stored, when the app uses the internet, and how you control your data. It applies to both the Android version (Google Play) and the iPhone version (App Store).

**1. We do not collect your data**
Bepbook has no server, no user accounts, no ads, and no third-party analytics, tracking or crash reporting tools. The Bepbook developer does not receive, view, sell or share any data you enter in the app.

**2. Your data stays on your phone**
What you create in the app (recipes, photos, categories, tags, cooking history, meal plans, shopping lists, pantry, settings) is stored in the app's private storage on your phone. Other apps cannot read it. Recipes and notes may contain information you write yourself (for example "Grandma's recipe") or photos of people; that information also stays only on your phone.
When you add a photo, the app copies it into its private storage, resizes it and removes all embedded photo information (EXIF), including the location where it was taken.

**3. Backups**
Because your data lives only on your phone, Bepbook gives you several ways to keep a copy. You choose where each copy goes, and the developer cannot access any of them.
- **Automatic backup to a folder you choose (Android and iPhone).** You pick a folder with the system folder picker. It can be a folder on the phone or a folder managed by your own cloud storage app (Android: for example Google Drive or OneDrive; iPhone: a folder in the Files app, including iCloud Drive). On iPhone, the app remembers its access to that folder on your device so it can write again later without asking; this stays on your phone and is not part of the backup file. The app writes backup files there on the schedule you set and keeps the number of copies you choose. If the folder belongs to a cloud service, that service's app (or iCloud) does the uploading, under its own terms and privacy policy.
- **Back up now.** The app creates a backup file and opens the system share sheet or file saver so you can choose where to save or send it (for example the Files app, Google Drive or email).
- **`.cooknote` backup files are not encrypted.** They are zip files in an open, documented format with your data as JSON, your photos and HTML pages you can read in a web browser. Anyone who has the file can read it, so keep it somewhere safe.
- **Operating system backups (turned on).**
  - Android: Bepbook allows Android's automatic backup. If backup is on for your phone, Android uploads a copy of Bepbook's database and settings (not photos) to your own Google account, and restores it when you reinstall the app or set up a new phone with the same account. When you transfer data directly from an old phone to a new one (by cable or wirelessly), Android may also bring your photos. This is done by Google and the operating system under Google's policies; the developer cannot access these backups.
  - iPhone: Bepbook data is included in iCloud Backup and in iPhone backups made on a computer, if you use those features. This is done by Apple and iOS under Apple's policies; the developer cannot access these backups.
  - If you do not want Bepbook data in your operating system backups, turn off backup for the app or for the phone in your phone's settings.

**4. Phone permissions and when the app uses the internet**
Bepbook asks for a permission only when you use a feature that needs it, and keeps working if you say no.
- **Internet:** used only by the built-in browser and "Import from web": to load a web page you open or share to Bepbook, and to download the recipe's photos so you can see them offline. The app does not send your recipes or any of your data over the internet.
- **Notifications:** to alert you when a cooking timer ends. The app asks the first time you start a timer, after a short explanation. Notifications are created on your phone and do not pass through any server. If you say no, timers still run while the app is open.
- **Photos:** the app uses the system photo picker and receives only the photos you pick; on Android it does not ask for access to your whole photo library.
- **Camera:** on Android, photos are taken with the system camera app, so Bepbook does not ask for the camera permission. On iPhone, iOS asks for camera access the first time you choose to take a photo in the app.
- **Keep the screen on** in cook mode; it returns to normal when you leave.
- The app does not ask for location, contacts or microphone. Choosing a restore file, choosing a backup folder and sharing all use the system pickers and share sheet, and access only the file or folder you choose.

**5. Processing on your phone**
- **Scanning a recipe from a photo:** text recognition runs entirely on your phone (Android: open-source Tesseract; iPhone: Apple's Vision text recognition). Photos and recognized text are not sent anywhere.
- **Reading steps aloud:** the app uses your phone's system voice. Some system voices may use the network depending on your phone's settings; this is managed by Google or Apple under their policies.
- Search, scaling servings, unit conversion, meal suggestions and PDF export all run on your phone.

**6. Web pages you open in the app**
Bepbook's browser uses the operating system's web view. Web pages you open may set cookies and collect data under their own policies, just as when you visit them in a regular browser. The browser can also open web pages that use an `http` address (not encrypted): the connection between your phone and such a page is not encrypted, so other people on the same network (for example public Wi-Fi) may be able to read or alter the page you load. The app shows a "Not encrypted" label in the address bar for these pages; do not enter passwords or card numbers on them. Bepbook sends none of your data to a page beyond the request to load it. Bepbook does not inject tracking code into pages and does not read pages' sign-in data or cookies. When you save, the app takes only the recipe content (name, ingredients, steps, photos, source) and stores it on your phone.
Links in the app (for example source links, the link to this policy, or the security email) open in your browser or email app, which follow their own policies.

**7. Copyright of recipes imported from the web**
Recipes you import from websites or scan from books belong to their authors or publishers. Bepbook keeps the page name and source link of each imported recipe, and is meant for saving recipes for your personal use. Please respect authors' rights when you share or reprint recipes.

**8. Data the app stores may collect**
When you install the app from Google Play or the App Store, Google or Apple may collect information about installs and app crashes under their own policies and your device settings. The developer sees only aggregated, anonymous figures in Play Console and App Store Connect and cannot use them to identify you.

**9. Your rights**
Because your data is only on your phone, you exercise every right directly in the app: view and edit each recipe and list; export all your data to a backup file in an open format to take it elsewhere; delete single items, or delete everything in Settings → "Delete all data" (this also clears the in-app browser's cookies, cache and site data); or uninstall the app. Uninstalling or deleting all data does not remove backup files you saved elsewhere or your operating system backups; delete those where they are stored. The developer keeps no copy that could be deleted for you.

**10. Age**
Bepbook is intended for people aged 13 and over and is not directed at children under 13. The app does not collect data from anyone, including children. The built-in browser can open any website; parents can use Google's or Apple's parental controls to limit this.

**11. Security**
Your data is protected by the Android and iOS app sandbox. The app has no separate lock and does not encrypt backup files, so use your phone's screen lock and keep backup files somewhere safe. If you find a security issue, please report it to the email in section 13.

**12. Changes to this policy**
If Bepbook changes how it handles data (for example by adding a feature that sends data off your phone), we will update this policy and its effective date before releasing that version. This is the first version of this policy.

**13. Contact**
[Developer name], developer of Bepbook
Support and security reports: phamphuongphuongnd@gmail.com [SECURITY_EMAIL if different]
