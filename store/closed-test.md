# Closed test trên Google Play — Bepbook (tài khoản cá nhân)

Viết 2026-11-05. Mục đích: đủ điều kiện xin quyền **production** cho tài khoản Play **cá nhân** (S-12, COMPLIANCE P-09). Luật kiểm
trên trang chính thức ngày 2026-11-05 ([App testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465)):
tài khoản cá nhân tạo sau 13/11/2023 phải chạy **closed test với ít nhất 12 tester đã opt-in liên tục ít nhất 14 ngày** ngay trước
khi bấm xin production; trước đó mục Production và Pre-registration bị khoá. Áp dụng **cho từng app**. Kiểm lại trang này ngày bắt đầu.

Closed test cũng là dịp **thử máy thật** những AC [M] mà máy Windows và CI không thử được — nhất là rủi ro số 1 của SPEC (sao lưu
tự động vào thư mục Google Drive/OneDrive). Không dùng adb trên máy thử (D-008); tester tự cài từ Play.

## Luật cần nhớ
- Đồng hồ 14 ngày chạy khi bản closed test **đã được Google duyệt** và **đủ 12 người opt-in**; số người tụt dưới 12 thì những ngày đó
  không tính. **Không pause/halt track** (có thể mất chuỗi ngày). Build mới đẩy vào **cùng track**.
- Tester dùng tài khoản Google thật trên máy Android thật. Google xem cả mức **tương tác thật** và hỏi về góp ý khi xin production.
  Không mua "dịch vụ tester".
- Mục tiêu **15–20 tester** (dư người rời), giữ **14 ngày + 2 ngày đệm**.

## Checklist trước khi gửi duyệt bản closed test (đường găng)
| # | Việc | Ai | Ghi chú |
|---|---|---|---|
| 1 | ~~Chốt tên app~~ **Đã chốt: Bepbook (D-010, 2026-11-05)** — tra lại tên trên App Store Connect khi tạo app | Phương | Tên trên trang closed test hiện cho tester; đổi sau vẫn được nhưng tốn công đổi icon/ảnh/chính sách |
| 2 | Tài khoản Play Console cá nhân đã có (fact `tai-khoan-store`); kiểm thông tin xác minh nhà phát triển đầy đủ (S-15) | Phương | |
| 3 | Đăng chính sách quyền riêng tư lên web, lấy URL | Phương | Play bắt Privacy policy + Data safety trước khi duyệt mọi track. Nội dung `docs/legal/privacy-policy.md` |
| 4 | Tạo upload keystore **ngoài repo**, `android/key.properties` (không commit); bật Play App Signing | Phương (tự tạo, S-61) | Claude không tạo khoá. Hướng dẫn trong `docs/RELEASE.md` mục "Ký ứng dụng" khi phiên code viết |
| 5 | Build `flutter build appbundle` từ `main`; chạy `aapt2 dump permissions` trên APK release: chỉ các quyền ở SPEC mục 5 (`INTERNET`, `POST_NOTIFICATIONS`, quyền hẹn giờ chốt ở G5), không `READ_MEDIA_*`, không `CAMERA` | Phiên #3 / Phương | Khác danh sách → sửa Data safety + chính sách mục 4 trước |
| 6 | Tạo app trong Play Console: tên đã chốt, ngôn ngữ mặc định **vi-VN** (thêm en-US), App, Free | Phương | Không đăng nhập hộ (luật xưởng) |
| 7 | Điền App content: privacy policy, ads, app access, content rating, target audience, data safety… | Phương | Trả lời sẵn: `store/google-play.md` |
| 8 | Store listing tối thiểu: tên, mô tả ngắn/dài, icon 512, feature graphic 1024×500, ≥ 2 ảnh điện thoại | Phương | Closed test không cần ảnh đẹp; ảnh chính chụp ở #3 (`store/screenshots-plan.md`) |
| 9 | Tạo track **Closed testing**, thêm tester (Google Group), chọn quốc gia, gửi duyệt | Phương | |
| 10 | Có danh sách ≥ 15 người đồng ý tham gia | Phương | Mục "Mời tester" |

## Lịch đề xuất (đếm từ ngày bản closed test được duyệt)
| Ngày | Mốc |
|---|---|
| Ngay (song song #1) | Bước 1–4 và 10: chốt tên, đăng chính sách, tạo keystore, gom tester |
| Khi có build Android chạy được đủ luồng chính (sớm nhất cuối #1, chậm nhất đầu #2) | Bước 5–9, gửi duyệt. **Không đợi UI mới**: đẩy bản hiện có, build sau đẩy tiếp vào cùng track |
| Duyệt xong | Gửi link opt-in, nhắc cài trong ngày. Đủ 12 người → **Ngày 0**, ghi vào Nhật ký |
| Ngày 3, 7, 11 | Tin nhắc (mẫu dưới). Kiểm số opt-in (Test and release → Testing → Closed testing → Testers) |
| Trong #2 | Đẩy build UI mới vào cùng track (tăng versionCode), nhờ tester thử danh sách bên dưới |
| Ngày 14 + 2 ngày đệm | Dashboard → Apply for production → điền form (câu trả lời mẫu dưới) |
| Sau đó (thường tới ~7 ngày) | Google xét. Được duyệt → #3 đẩy production. Bị từ chối → đọc lý do, test thêm 14 ngày với tương tác nhiều hơn |

## Mời tester
**Cách khuyên dùng: Google Group.**
1. groups.google.com → Create group, ví dụ `cooknote-testers` (tên nhóm nội bộ, có thể đặt `bepbook-testers`). Ai xem thành viên: chỉ quản lý (giữ riêng email tester).
2. Mời tester vào nhóm, hoặc gửi link nhóm để họ bấm Join.
3. Play Console → Closed testing → track → Testers → **Google Groups** → nhập email nhóm → Save.
4. Copy link opt-in ("Join on the web") gửi cho tester.
5. Tester mở link **bằng đúng tài khoản Google trên điện thoại Android** → "Become a tester" → tải từ Google Play.

Danh sách tester (tên, email) giữ ở chỗ riêng của Phương, **không commit vào repo** (dữ liệu cá nhân của người khác).
Nguồn tester: người thân, đồng nghiệp, bạn bè dùng Android và hay nấu ăn; nhóm cộng đồng người làm app ở Việt Nam (chỉ nhận người
thật dùng thật). Nên có vài đời máy khác nhau (Samsung, Xiaomi, Oppo: tiết kiệm pin mạnh, ảnh hưởng hẹn giờ) và vài người dùng
Google Drive/OneDrive.

## Mẫu tin nhắn (Phương tự gửi; Claude không gửi)
**Lời mời (vi):**
> Chào bạn, mình đang làm app sổ tay công thức nấu ăn "Bepbook" (miễn phí, không quảng cáo, không cần tài khoản, công thức nằm trên
> máy bạn). Google bắt app mới phải có ít nhất 12 người thử trong 14 ngày liền mới được phát hành. Bạn giúp mình nhé:
> 1) Vào [link nhóm] bấm tham gia; 2) mở [link opt-in] bằng đúng Gmail trên điện thoại Android, bấm "Become a tester";
> 3) cài app từ Google Play. Bạn chỉ cần **giữ tham gia và giữ app trên máy ít nhất 16 ngày (tới [ngày])**, mỗi tuần mở app lưu
> hoặc nấu thử vài món (ví dụ chia sẻ một trang công thức từ Chrome sang Bepbook). App không gửi dữ liệu của bạn đi đâu.
> Góp ý gửi mình qua [email/Zalo] hoặc nút "Gửi phản hồi" trên trang Play. Cảm ơn bạn nhiều!

**Invite (en):**
> Hi! I'm building "Bepbook", a free recipe notebook app with no ads and no account; your recipes stay on your phone. Google requires
> new apps to be tested by at least 12 people for 14 days in a row before release. Could you help? 1) Join [group link];
> 2) open [opt-in link] with the Google account on your Android phone and tap "Become a tester"; 3) install from Google Play.
> Please **stay in the test and keep the app installed for at least 16 days (until [date])**, and save or cook a few recipes each week
> (for example, share a recipe page from Chrome to Bepbook). The app does not send your data anywhere.
> Feedback: [email] or "Send feedback" on the Play page. Thank you!

**Nhắc ngày 3 / 7 / 11 (vi):**
> Nhắc nhẹ: Bepbook đang ở ngày [n]/14 của đợt thử. Bạn đừng bấm "Rời khỏi chương trình" và đừng gỡ app tới [ngày] nhé. Mở app
> lưu thêm 1 công thức hoặc thử chế độ nấu giúp mình. Có lỗi gì cứ nhắn mình. Cảm ơn!

**Reminder day 3 / 7 / 11 (en):**
> Quick reminder: Bepbook is on day [n] of 14. Please don't leave the program or uninstall the app before [date]. Save one more
> recipe or try cook mode if you can. Tell me about anything that breaks. Thanks!

**Khi có build mới (vi):**
> Bepbook vừa có bản mới [mô tả ngắn]. Vào Google Play → Bepbook → Cập nhật, thử giúp mình [màn/tính năng] rồi góp ý nhé.

## Nhờ tester thử (AC [M] cần máy thật)
Gửi kèm tin mời hoặc tin nhắc ngày 3. Mỗi tester chọn 1–2 mục, báo "được / không được + đời máy + Android mấy":
- **Sao lưu tự động vào Google Drive/OneDrive (rủi ro số 1, AC-50, AC-51):** Thêm → Sao lưu → bật sao lưu tự động, chọn một thư mục
  trong Google Drive (hoặc OneDrive). Hôm sau mở app: file `CookNote-YYYY-MM-DD-HHmmss.cooknote` có trong thư mục trên Drive không? Có báo lỗi không?
- **Chia sẻ từ trình duyệt (AC-17, AC-18):** trong Chrome mở một trang công thức → Chia sẻ → Bepbook → màn xem trước có đủ tên,
  nguyên liệu, các bước, ảnh không? Thử 1 trang tiếng Việt, 1 trang tiếng Anh.
- **Trang không có dữ liệu công thức (AC-19):** bôi đen chữ, gán "Là nguyên liệu" / "Là các bước".
- **Hẹn giờ khi khóa máy (AC-28):** chế độ nấu → bấm một thời gian trong bước → khóa máy → có chuông và thông báo đúng giờ không?
- **Quét ảnh (AC-23, AC-24):** chụp một trang sách nấu ăn hoặc công thức viết tay → chữ nhận ra có dùng được không?
- **Đọc bước (AC-30):** máy có giọng đọc tiếng Việt không?
- **Khôi phục trên máy khác (SPEC mục 8):** "Sao lưu ngay" → mở file trên một máy khác đã cài Bepbook → Khôi phục → đủ ảnh không?
- **Cỡ chữ lớn, TalkBack (AC-61, AC-62):** bật chữ cỡ lớn nhất của máy → các màn chính có bị cắt chữ không?
Ghi kết quả vào `notes/<ngày>-closed-test-feedback.md` (không ghi tên/email tester) để phiên điều phối cập nhật `docs/TESTING.md`.

## Theo dõi trong 14 ngày
- Mỗi lần nhắc: xem số opt-in; dưới 14 người thì mời thêm ngay.
- Gom góp ý vào `notes/<ngày>-closed-test-feedback.md`; lỗi thật → việc sửa ở #2.
- Xem Play Console → Android vitals (crash/ANR), Pre-launch report, mục Testing feedback (Ratings and reviews → Testing feedback).
- Ghi số liệu cho form production: số tester, số build đã đẩy, số góp ý, thay đổi đã làm.

### Nhật ký (điền khi chạy)
| Ngày | Số opt-in | Build (versionCode) | Việc / góp ý chính |
|---|---|---|---|
| | | | |

## Câu trả lời mẫu cho form "Apply for production"
Form tiếng Anh; câu hỏi có thể đổi. **Thay mọi `[...]` bằng số liệu thật** — không bịa số, Google đối chiếu với dữ liệu track.
- **How did you recruit users for your closed test?**
  `I invited friends, family and colleagues who cook at home and use Android phones, through a Google Group. [N] testers joined, each with their own phone and Google account.`
- **How easy was it to recruit testers?** → chọn đúng thực tế.
- **Describe the engagement you received from testers.**
  `Over [14+] days testers saved recipes from websites (by sharing links from their browser), scanned recipe pages, used cook mode with timers, built shopping lists and tried backup to their own Google Drive folders. I sent reminders on days 3, 7 and 11 and released [K] updated builds.`
- **Provide a summary of the feedback you received and how you collected it.**
  `Feedback came through Play testing feedback and direct messages. Main points: [ví dụ: một số trang tiếng Việt không tự điền được, hẹn giờ trễ trên máy X, chữ bị cắt ở màn Y].`
- **Who is the intended audience of your app?**
  `Home cooks aged 13 and over in Vietnam and worldwide, in Vietnamese or English, who want to keep their recipes for many years without an account.`
- **Describe how your app provides value to users.**
  `Bepbook collects recipes from websites and photos into one offline notebook, with cook mode and timers, scaling, shopping lists, a meal planner and a pantry. Every feature is free, and automatic backups use an open format readable in any browser, so users never lose their recipes.`
- **How many installs do you expect in your first year?** → mức thấp, thực tế.
- **What changes did you make based on what you learned during closed testing?** `[liệt kê thay đổi thật, kèm build]`
- **How did you decide that your app is ready for production?**
  `All features passed [N] automated tests and manual checks on testers' phones (web import, timers on a locked screen, backup to Google Drive); no crashes or ANRs in Android vitals during the test; reported issues were fixed and verified in build [k].`

## iOS (để so sánh)
App Store **không** có luật 12 tester × 14 ngày. TestFlight: tester nội bộ (thành viên App Store Connect) không cần duyệt; tester
ngoài cần Beta App Review cho build đầu. Không có iPhone → thử bằng simulator trên GitHub Actions (D-008); TestFlight khi mượn được máy.
