# COMPLIANCE — CookNote (A004-cooknote)

Hồ sơ tuân thủ theo tài liệu gốc `D:/Mobile App/reference/tieu-chuan-ban-app-toan-cau.md` (cập nhật 28/10/2026; "L<n>" là Lớp n trong
tài liệu đó) và tiêu chuẩn xưởng `D:/Mobile App/playbook/STANDARDS.md` v1 (mã S-xx; mục 4 đối chiếu hai hệ mã).
Không phải tư vấn pháp lý: trước khi mở bán ở nước nào cần luật sư địa phương xác nhận (tài liệu gốc, phần Tóm tắt).
Cập nhật 2026-11-05 (phiên con "Store & pháp lý 2 nền tảng"): thêm iOS theo D-008, mở lại P-01..P-05, gắn mã S-xx, đã có bản nháp
chính sách và hồ sơ store (`docs/legal/`, `store/`).

## 1. Phạm vi (điền ở /spec, quyết định mục nào áp dụng)
- Thị trường định bán (ghi nhóm theo "Ma trận theo thị trường": A/B/C; nhóm D không được bán): Việt Nam và toàn cầu: nhóm A và nhóm B (gồm Việt Nam), trên **Google Play và App Store** (D-008, thay "iOS để sau" của D-001). Không bán ở Trung Quốc đại lục (S-88 không bật; Play không có ở đó, App Store cần số ICP); Nga (nhóm C) chưa mở. Nhóm D chặn trong Play Console và App Store Connect. Không có hoạt động thương mại ở EU (S-87 không bật).
- Có tài khoản người dùng: không
- Dữ liệu cá nhân thu thập (loại, mục đích, nơi lưu, bên nhận, thời gian giữ): nhà phát triển không thu thập. Người dùng tự ghi công thức, ảnh món, ghi chú, thực đơn, danh sách đi chợ, tủ bếp; có thể có thông tin cá nhân do người dùng tự viết hoặc ảnh có người. Mọi thứ lưu trong SQLite và thư mục ảnh trên máy, không có bên nhận. Bản sao do người dùng tự quyết nơi lưu: thư mục sao lưu tự động người dùng chọn (có thể là Google Drive, OneDrive của chính họ), "Sao lưu ngay" qua bảng chia sẻ, và sao lưu của hệ điều hành **đang bật**: Android Auto Backup (DB + cài đặt, không ảnh) và iCloud/sao lưu máy tính trên iOS (APP.md "Tiêu chuẩn áp dụng"). Giữ tới khi người dùng xóa.
- Dữ liệu rủi ro cao (nhạy cảm, vị trí chính xác, trẻ em, sinh trắc học, hồ sơ hóa bằng AI): không. App không xin vị trí, không dùng sinh trắc học, không AI. Ảnh được thu nhỏ và bỏ toàn bộ EXIF, gồm GPS (D-005).
- Người dưới 18 tuổi có thể dùng: có — **đối tượng từ 13 tuổi** (S-84); không nhắm trẻ em dưới 13, không vào Families / Made for Kids.
- Bán hàng số, thuê bao hoặc thanh toán trong app: không (miễn phí hoàn toàn, mọi tính năng đều mở)
- SDK bên thứ ba (analytics, quảng cáo, đăng nhập xã hội, AI): không có (D-002). Không dùng ML Kit vì gửi số liệu chẩn đoán về Google; nhận chữ trên máy: Android Tesseract4Android, iOS Apple Vision (D-003, D-008). WebView của hệ điều hành dùng cho trình duyệt trong app; trang web người dùng mở tự có chính sách riêng.
- Gửi dữ liệu cho AI bên thứ ba, hoặc app có chatbot/nội dung do AI tạo: không
- Ngành có quy định riêng (y tế, tài chính, trẻ em, ô tô...): không. Dinh dưỡng chỉ là chữ người dùng tự nhập hoặc nhập từ trang web, không tư vấn ăn uống hay y tế.
- Doanh nghiệp siêu nhỏ (dưới 10 người và doanh thu không quá 2 triệu euro, miễn EAA khi cung cấp dịch vụ, L4): phát hành dưới **tài khoản cá nhân** (APP.md, 2026-11-04) → thuộc diện siêu nhỏ. Dù thế nào vẫn giữ mục tiêu WCAG 2.2 AA.

## 2. Danh mục kiểm (Trạng thái: đạt / không áp dụng / chưa. "Bằng chứng": file:dòng, ảnh chụp, đường dẫn, lệnh đã chạy; ghi ngày kiểm)
| ID | Áp dụng khi | Yêu cầu | Nguồn | Trạng thái | Bằng chứng, ngày |
|----|-------------|---------|-------|------------|------------------|
| M-01 | Mọi app | Danh sách thị trường đã chốt; đã loại nước và vùng bị cấm vận toàn diện (rà danh sách OFAC, EU, Anh, LHQ hiện hành) và chặn theo địa lý nếu cần | Tóm tắt, L6, Ma trận | chưa | Đã chốt "mọi nơi trừ Trung Quốc đại lục" (`store/app-store.md`, `store/google-play.md`, 2026-11-05); chưa rà danh sách cấm vận khi chọn quốc gia trong console |
| D-01 | Có dữ liệu cá nhân | Kiểm kê dữ liệu (RoPA) và bản đồ luồng dữ liệu: loại, mục đích, căn cứ pháp lý, nơi lưu, bên nhận, thời gian giữ | L3 nền chung 1 | chưa | Bảng luồng dữ liệu theo từng hành vi ở `store/google-play.md` mục Data safety (2026-11-05); `docs/SECURITY.md` vẫn trống — điền ở #3 |
| D-02 | Có dữ liệu cá nhân | Chính sách quyền riêng tư; đường dẫn đặt trong Play Console, App Store Connect và trong app (S-13, S-41) | L3, L5 | chưa | Bản nháp vi + en cho 2 nền tảng: `docs/legal/privacy-policy.md` (2026-11-05). Còn: Phương đăng web lấy URL; phiên code đặt URL ở màn Giới thiệu (AC-63); điền 2 console |
| D-03 | Có dữ liệu cá nhân | Đồng ý theo từng mục đích, không gộp, rút lại dễ như lúc cho; im lặng không coi là đồng ý (Luật VN 91/2025 Điều 9) | L3 nền chung 2 | không áp dụng | Nhà phát triển không nhận dữ liệu; mọi xử lý chỉ trên máy người dùng (D-002), 2026-11-03 |
| D-04 | Có SDK bên thứ ba | SDK analytics/quảng cáo/AI không khởi động trước khi có đồng ý ở nơi luật đòi (EU, Anh); dùng nền tảng quản lý đồng ý hỗ trợ iOS và Android | L3 "Điểm riêng của app mobile" | không áp dụng | Không có SDK analytics, quảng cáo hay AI; không dùng ML Kit (D-002, D-003), 2026-11-03 |
| D-05 | Có tài khoản | Xóa tài khoản ngay trong app (Apple 5.1.1(v)) và qua một trang web ngoài (Google Play) | L3 nền chung 3, L5 | không áp dụng | Không có tài khoản (S-80 không bật); thay bằng "Xóa toàn bộ dữ liệu" AC-64, 2026-11-03 |
| D-06 | Có dữ liệu cá nhân | Quy trình quyền người dùng: truy cập, sửa, xóa, mang dữ liệu đi, rút đồng ý, phản đối quyết định tự động | L3 nền chung 3 | chưa | Đã mô tả trong chính sách mục 9 (2026-11-05): xem, sửa, xóa trong app (F-01, AC-64); mang đi bằng định dạng mở (AC-45, AC-49). Chờ AC-64 chạy thật |
| D-07 | Dữ liệu rủi ro cao | Đánh giá tác động (DPIA/PIA); bán ở Việt Nam: nộp hồ sơ trong 60 ngày kể từ khi bắt đầu xử lý (Điều 21) | L3 nền chung 4 | không áp dụng | Không có dữ liệu rủi ro cao (mục 1), nhà phát triển không xử lý dữ liệu, 2026-11-03 |
| D-08 | Có dữ liệu cá nhân | Kịch bản xử lý vi phạm theo hạn ngắn nhất trong các thị trường đã chọn (ví dụ 72 giờ ở EU và Việt Nam; xem ma trận L3) | L3 nền chung 5 | chưa | Nhà phát triển không giữ dữ liệu nên không có kho để bị lộ; còn cần ghi kịch bản cho lỗi app làm lộ/mất dữ liệu trên máy (cập nhật, thông báo trong ghi chú phát hành) |
| D-09 | Có dữ liệu cá nhân, bán ở VN | Chỉ định bộ phận hoặc nhân sự bảo vệ dữ liệu (Điều 33(2)); đại diện pháp lý ở nơi luật đòi (EU/Anh, Brazil, Trung Quốc, Hàn Quốc, Thổ Nhĩ Kỳ) | L3 nền chung 6 | chưa | Cần luật sư xác nhận khi nhà phát triển không nhận dữ liệu |
| D-10 | Dùng nhà cung cấp xử lý dữ liệu | Hợp đồng xử lý dữ liệu với cloud, analytics, push, thanh toán, AI; cơ chế chuyển dữ liệu ra nước ngoài hợp pháp (VN: hồ sơ trong 60 ngày từ lần chuyển đầu) | L3 nền chung 7, "Kiến trúc chuyển dữ liệu" | không áp dụng | Không dùng nhà cung cấp xử lý dữ liệu (D-002). Sao lưu Google/iCloud do người dùng bật, giữa người dùng và Google/Apple, nhà phát triển không nhận, 2026-11-05 |
| D-11 | Mọi app | Quyền hệ thống (vị trí, danh bạ, camera, micro, thông báo) chỉ xin khi cần cho tính năng, không ép bật để dùng app (S-40) | L3 "Điểm riêng", L5 Apple 5.1.1 | chưa | Android: camera qua app hệ thống, không xin quyền (AC-08, D-005); iOS: `NSCameraUsageDescription` có sẵn, iOS hỏi lần đầu chụp (Info.plist, commit `9b646df`, 2026-11-05); thông báo xin khi bấm hẹn giờ (AC-28); không xin bộ nhớ, thư viện ảnh, vị trí, danh bạ, micro (SPEC mục 5); kiểm manifest + Info.plist ở #3 (AC-65) |
| D-12 | Người dưới 18 có thể dùng | Dùng tín hiệu tuổi của hệ điều hành (Declared Age Range của Apple, Play Age Signals của Google) và đối chiếu luật tuổi theo thị trường ở L3 (S-84) | L3 "Điểm riêng", L5 | chưa | Đối tượng 13+ (APP.md). Không có nội dung theo tuổi, không giao tiếp giữa người dùng → đề xuất **không tích hợp** API tín hiệu tuổi ở v1; Phương chốt (SPEC mục 7). Lưu ý App Store 16+ vì trình duyệt — xem P-05 |
| D-13 | Gửi dữ liệu cho AI bên thứ ba | Nêu rõ nơi dữ liệu được chia sẻ, kể cả AI bên thứ ba, và xin phép rõ ràng trước khi chia sẻ (Apple 5.1.2(i)) | L3, L5 | không áp dụng | Không dùng AI (S-86 không bật), 2026-11-03 |
| S-01 | Mọi app | Tự kiểm theo 8 nhóm OWASP MASVS v2.1.0: STORAGE, CRYPTO, AUTH, NETWORK, PLATFORM, CODE, RESILIENCE, PRIVACY (ghi kết quả từng nhóm) (S-60) | L2 "Tiêu chí kỹ thuật" | chưa | NETWORK: trình duyệt mở được trang `http` của người dùng — cần quyết chặn cleartext cho phần "Nhập từ web" hay ghi rõ ngoại lệ |
| S-02 | Có API/backend | Kiểm API theo OWASP ASVS 5.0.0; truyền tải mã hóa TLS 1.3 | L2 | không áp dụng | Không có API hay backend của nhà phát triển; chỉ tải trang web người dùng mở (F-03), 2026-11-03 |
| S-03 | Có đăng nhập | Đăng nhập theo OAuth 2.0/OIDC (RFC 9700) hoặc passkey (WebAuthn/FIDO2); có đăng nhập bên thứ ba trên iOS thì có thêm một lựa chọn tương đương theo Apple 4.8 | L2, L5 | không áp dụng | Không có đăng nhập (S-81 không bật), 2026-11-03 |
| S-04 | Mọi app | SBOM sinh tự động (SPDX hoặc CycloneDX) và rà giấy phép nguồn mở theo danh sách SPDX (S-70) | L2 "Chuỗi cung ứng", L6 | chưa | |
| S-05 | Mọi app | Kênh tiếp nhận lỗ hổng công khai (ví dụ security.txt theo RFC 9116 hoặc email) và thủ tục xử lý | L2 | chưa | Email `phamphuongphuongnd@gmail.com` ghi ở chính sách mục 11, 13 (2026-11-05); còn in ở màn Giới thiệu (AC-63) và ghi thủ tục xử lý |
| S-06 | Bán ở EU | CRA: kế hoạch báo lỗ hổng đang bị khai thác và sự cố nghiêm trọng (cảnh báo sớm 24 giờ, thông báo 72 giờ, từ 11/09/2026); công bố thời hạn hỗ trợ cập nhật bảo mật (Recital 60: không dưới năm năm trừ khi tuổi thọ dự kiến ngắn hơn) | L2 CRA | chưa | APP.md: không có hoạt động thương mại ở EU → S-87 không bật; vẫn cần luật sư xác nhận app miễn phí ngoài phạm vi CRA (SPEC mục 7) |
| S-07 | Lưu, xử lý hoặc truyền dữ liệu thẻ | PCI DSS v4.0.1; gợi ý của tài liệu: dùng cổng thanh toán bên thứ ba (hosted page/redirect) để thu hẹp phạm vi | L2 | không áp dụng | Không xử lý dữ liệu thẻ, 2026-11-03 |
| A-01 | Mọi app | Mục tiêu thiết kế WCAG 2.2 mức AA; bán ở EU: chứng minh theo EN 301 549 v3.2.1; kiểm bằng VoiceOver và TalkBack; lưu tuyên bố accessibility cho từng bản phát hành (S-50) | L4 | chưa | |
| C-01 | Bán hàng số/thuê bao | Hiển thị giá và điều kiện trước khi thanh toán; cho hủy ngay trong app; nhắc trước khi gia hạn | L4 "Bảo vệ người tiêu dùng" | không áp dụng | Miễn phí, không bán gì (S-82 không bật), 2026-11-03 |
| C-02 | Bán trực tuyến cho người tiêu dùng EU | Chức năng rút khỏi hợp đồng (Điều 11a Chỉ thị 2023/2673, áp dụng từ 19/06/2026) | L4 | không áp dụng | Không bán trực tuyến, 2026-11-03 |
| C-03 | Bán ở EU | Trách nhiệm sản phẩm (Chỉ thị 2024/2853, sản phẩm đưa ra thị trường sau 09/12/2026): công bố thời hạn cập nhật bảo mật, lưu hồ sơ kiểm thử và vòng đời | L4 | chưa | S-87 không bật (không thương mại ở EU); luật sư xác nhận cùng S-06 |
| P-01 | Phát hành iOS | Build bằng Xcode 26 trở lên với SDK iOS 26 trở lên (từ 28/04/2026) (S-20) | L5 Apple | chưa | **Mở lại 2026-11-05 (D-008).** Khớp trang Apple Upcoming requirements đọc 2026-11-05; iOS tối thiểu 13+ (S-24, đã có hiệu lực 09/09/2026) — project đặt 15.0. Chờ CI iOS của phiên "iOS + CI" |
| P-02 | Phát hành iOS | App privacy details khi nộp; tệp `PrivacyInfo.xcprivacy`; SDK phổ biến kèm privacy manifest và chữ ký (S-21) | L5 Apple | chưa | **Mở lại 2026-11-05.** Nhãn: "Data Not Collected" (`store/app-store.md`, căn cứ trang App Privacy Details). `ios/Runner/PrivacyInfo.xcprivacy` + `ios/ShareExtension/PrivacyInfo.xcprivacy` có từ commit `9b646df`: tracking false, không loại dữ liệu thu thập, API cần lý do FileTimestamp/DiskSpace/UserDefaults (đọc 2026-11-05). Còn: đối chiếu cảnh báo của App Store Connect khi upload build đầu |
| P-03 | Phát hành iOS | `ITSAppUsesNonExemptEncryption` trong Info.plist (NO nếu không mã hóa hoặc chỉ mã hóa miễn trừ) (S-22) | L5 Apple, L6 | chưa | **Mở lại 2026-11-05.** Info.plist (commit `9b646df`) đặt `false` — đúng: chỉ HTTPS của hệ điều hành, `crypto` chỉ băm SHA-256, file sao lưu không mã hóa (S-89 không bật). Đạt khi CI iOS xanh và build upload không bị hỏi lại |
| P-04 | Phát hành iOS, có theo dõi | App Tracking Transparency (từ iOS 14.5; màn hình riêng cho EU từ iOS 27.2) (S-83) | L5 Apple | không áp dụng | Không theo dõi, không quảng cáo, không SDK (D-002); không gọi ATT, 2026-11-05 |
| P-05 | Phát hành iOS | Bảng câu hỏi xếp hạng độ tuổi mới (Việt Nam: 00+, 12+, 16+, 18+ từ 18/06/2026) (S-23) | L5 Apple | chưa | **Mở lại 2026-11-05.** Trả lời đề xuất ở `store/app-store.md`: "Unrestricted Web Access" = Yes (AC-16) → dự kiến **16+** (iOS 26+, cả Việt Nam), 17+ (iOS < 26), theo trang Apple đọc 2026-11-05. **Lệch S-84 (13+) → Phương quyết** giữ trình duyệt đầy đủ hay thu hẹp |
| P-06 | Phát hành Android | targetSdk = API 36 cho app mới và bản cập nhật (từ 31/08/2026, gia hạn tới 01/11/2026) (S-10) | L5 Google | chưa | Trang Target API level đọc 2026-11-05: khớp. Bản build 2026-11-04 targetSdk 36 (D-004); kiểm lại bản AAB phát hành |
| P-07 | Phát hành Android | Hỗ trợ trang bộ nhớ 16 KB (bắt buộc với bản cập nhật từ 01/02/2027) (S-11) | L5 Google | chưa | Lưu ý thư viện native Tesseract (APP.md) |
| P-08 | Phát hành Android | Xác minh nhà phát triển (từ 30/09/2026 tại Brazil, Indonesia, Singapore, Thái Lan; toàn cầu năm 2027) (S-15) | L5 Google | chưa | |
| P-09 | Tài khoản Play cá nhân mới | Closed test với ít nhất 12 người thử, liên tục tối thiểu 14 ngày (S-12) | L5 Google | chưa | Trang Play "App testing requirements…" đọc 2026-11-05: khớp. Kế hoạch + thư mời: `store/closed-test.md` |
| P-10 | Phát hành Android | Khai báo Data safety khớp với dữ liệu SDK thực sự thu thập; xếp hạng nội dung (S-13, S-14, S-42) | L5 Google | chưa | Đề xuất "No data collected / No data shared", bảng căn cứ từng hành vi (kể cả Auto Backup, WebView) và trả lời IARC (trình duyệt = Yes): `store/google-play.md` (2026-11-05). Đối chiếu `pubspec.lock` + manifest đã gộp ở #3 (AC-65) |
| P-11 | Bán hàng số trong app | Apple: quy tắc thanh toán trong app của App Store (mục 3.1.1, xem L5); Google: Play Billing trừ khi thuộc §3, 8, 9 | L5 | không áp dụng | Không bán hàng số (S-82 không bật), 2026-11-03 |
| P-12 | App cho trẻ em trên Play | Chương trình Families: khai báo đối tượng, chỉ SDK quảng cáo được chứng nhận cho Families, tuân thủ COPPA và GDPR (S-84) | L5 Google | không áp dụng | Đối tượng chọn 13–15, 16–17, 18+; không chọn nhóm dưới 13 → không vào Families (`store/google-play.md`), 2026-11-05 |
| P-13 | Mọi app phát hành | Tên app: tra trùng trên 2 store và tra nhãn hiệu (S-71) | L6 Sở hữu trí tuệ | chưa | Tra 2026-11-05: **"CookNote"/"Cooknote" đã có trên Play (2 app) và App Store (BECEN, thị trường VN)**; WIPO không có nhãn "cooknote". 3 tên đề xuất + link: `store/app-store.md`. **Phương quyết tên** |
| P-14 | Mọi app phát hành | Khác biệt rõ với đối thủ trong mô tả + ảnh; không crash, không placeholder; mô tả và ảnh đúng app thật (S-30, S-31) | L5 App Review | chưa | Mô tả 2 store mở đầu bằng khối "Vì sao chọn CookNote" (miễn phí toàn bộ, không tài khoản, định dạng mở đọc không cần app, tiếng Việt chuẩn). Đối chiếu tính năng thật + ảnh ở #3 |
| T-01 | Bán có thu phí | Thuế giá trị gia tăng theo nơi bán (Apple làm đại lý theo Schedule 2; xem L6) | L6 | không áp dụng | Miễn phí, 2026-11-03 |
| T-02 | Mọi app phát hành | Bản địa hóa và định dạng theo thị trường | L6 | chưa | Hồ sơ store vi + en đã có (2026-11-05); app vi/en (AC-58) |
| AI-01 | Có chatbot hoặc nội dung do AI tạo, bán ở EU | Nghĩa vụ minh bạch Điều 50 AI Act (từ 02/08/2026) | L7, Mốc | không áp dụng | Không có AI, 2026-11-03 |

## 3. Trước mỗi lần phát hành
- Kiểm lại trang Apple "Upcoming requirements" và bảng hạn chót của Google, vì đổi theo quý (L5 "Cách làm chung"); ghi ngày kiểm vào đây.
- Tài liệu tiêu chuẩn gốc cũ hơn 3 tháng so với ngày phát hành: kiểm lại các mốc ở bảng đầu tài liệu.
- Ngày kiểm lần cuối: **2026-11-05** — Apple Upcoming requirements, Age ratings values and definitions, App Privacy Details, App information, Platform version information, Screenshot specifications; Google Play Target API level, Data safety, App testing requirements for new personal developer accounts, Create and set up your app, Add preview assets (link ở cuối `store/google-play.md`, `store/app-store.md`). Khớp STANDARDS v1, trừ hai điểm cần ghi vào STANDARDS: keyword Apple tính **byte**; cỡ ảnh iPhone bắt buộc là "Dynamic Island (medium display)" (`store/screenshots-plan.md`).

## 4. Đối chiếu mã STANDARDS (S-xx) ↔ dòng hồ sơ
| S-xx | Dòng ở mục 2 | Trạng thái 2026-11-05 | Tài liệu |
|---|---|---|---|
| S-10 | P-06 | chưa | |
| S-11 | P-07 | chưa | |
| S-12 | P-09 | chưa | `store/closed-test.md` |
| S-13 | D-02, P-10 | chưa (bản nháp xong) | `docs/legal/privacy-policy.md`, `store/google-play.md` |
| S-14 | P-10, P-12 | chưa (trả lời đề xuất xong) | `store/google-play.md` |
| S-15 | P-08 | chưa | |
| S-20 | P-01 | chưa | |
| S-21 | P-02 | chưa (nhãn + `PrivacyInfo.xcprivacy` xong; chờ build đầu) | `store/app-store.md` |
| S-22 | P-03 | chưa (giá trị đúng, chờ commit) | `store/app-store.md` |
| S-23 | P-05 | chưa (chờ Phương quyết 16+ hay thu hẹp trình duyệt) | `store/app-store.md` |
| S-24 | P-01 | chưa | |
| S-30, S-31 | P-14 | chưa | `store/*.md` |
| S-40 | D-11 | chưa | |
| S-41 | D-02 | chưa (chờ đăng web) | `docs/legal/privacy-policy.md` |
| S-42 | P-10, P-02 | chưa (đối chiếu lại ở #3) | |
| S-50 | A-01 | chưa | |
| S-60 | S-01 | chưa | |
| S-61 | — | chưa | `docs/RELEASE.md` (khoá ký do Phương tạo) |
| S-70 | S-04 | chưa | |
| S-71 | P-13 | chưa (**trùng tên**) | `store/app-store.md` |
| S-84 | D-12, P-12, P-05 | chưa | `store/*.md` |
| S-80..S-83, S-85..S-89 | D-05, S-03, C-01, P-11, D-04, P-04, D-10, D-13, S-06, C-03, P-03 | không áp dụng (APP.md) | |
