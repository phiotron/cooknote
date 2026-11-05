# SPEC — Bepbook (A004-cooknote)

Đã duyệt: 2026-11-03
<!-- Khi người dùng duyệt, đổi thành: "Đã duyệt: YYYY-MM-DD". Chưa có dòng này thì Claude không viết code. -->

## 1. Vấn đề cần giải quyết
Người nấu ăn ở nhà có công thức nằm rải rác: trang web, ảnh chụp sách hay giấy viết tay, tin nhắn, ghi chú điện thoại. Lúc nấu khó tìm, màn hình tắt giữa chừng, phải tự nhân đôi lượng nguyên liệu, tự chép ra danh sách đi chợ. Nhiều người giữ một bộ công thức cả đời rồi truyền cho con cháu, nên mất dữ liệu là mất thứ không lấy lại được.

Bepbook là sổ tay công thức trên điện thoại. App nhập công thức từ web hoặc từ ảnh, có chế độ nấu, danh sách đi chợ, lịch thực đơn và tủ bếp. Dữ liệu được giữ bền lâu nhờ sao lưu tự động bằng định dạng mở. Chức năng tương đương Paprika Recipe Manager 3, Recipe Keeper và CookBook – Recipe Manager (tra trang giới thiệu của các app ngày 2026-11-03). App miễn phí, mọi tính năng đều mở, không có máy chủ. Tên, biểu tượng, giao diện, chữ trong app và mô tả store do mình tự làm. Không sao chép chữ, hình hay mô tả store của các app đó.

## 2. Người dùng và tình huống sử dụng trên điện thoại
- Người nấu ăn gia đình, sinh viên ở trọ, người thích làm bánh, cả thiếu niên từ 13 tuổi. Ở Việt Nam và nước khác, dùng tiếng Việt hoặc tiếng Anh, trên điện thoại Android và iPhone (D-008).
- Lúc rảnh, thường có mạng: lướt web thấy món ngon thì "Chia sẻ" sang Bepbook hoặc mở trình duyệt trong app để lưu. Chụp trang sách hay công thức viết tay của mẹ để số hóa.
- Trong bếp, tay ướt hoặc dính bột, điện thoại dựng trên kệ, có thể không có mạng: mở chế độ nấu, chữ lớn, màn hình không tắt, chạm một lần để gạch bước đã làm, bật hẹn giờ.
- Cuối tuần: xếp thực đơn cho tuần, đẩy nguyên liệu sang danh sách đi chợ. Ở chợ hoặc siêu thị (sóng yếu, cầm máy một tay): gạch dần từng món.
- Dùng nhiều năm, có thể tới hàng nghìn công thức. Đổi điện thoại vài lần mà không được mất công thức.

## 3. Tính năng bản đầu (MVP) và tiêu chí chấp nhận
Quy ước kiểm chứng:
- **[T]**: test tự động (`flutter test`; lệnh chốt ở G1).
- **[M]**: thử tay trên máy Android thật, ghi biên bản vào `docs/MANUAL-TESTS.md`.

"Nguyên liệu có cấu trúc" là một dòng nguyên liệu đã tách thành số lượng (có thể là phân số như `1/2`, `1 1/2`, `½`, hoặc khoảng như `2-3`), đơn vị và tên. Dòng không tách được thì giữ nguyên chữ và không được nhân hay đổi đơn vị.

### F-01 · Công thức
- AC-01: Thanh điều hướng dưới có 5 mục: Công thức, Thực đơn, Đi chợ, Tủ bếp, Thêm (Cài đặt, Sao lưu, Giới thiệu). Màn Công thức có nút "+" trong vùng ngón cái, mở bảng chọn: Nhập tay, Từ web, Quét ảnh, Nhập file. [M]
- AC-02: Một công thức có:
  - Tên (bắt buộc, tối đa 200 ký tự).
  - Nguyên liệu: danh sách dòng, chia được thành nhóm có tiêu đề (ví dụ "Phần nước dùng").
  - Các bước: danh sách đánh số, chia được thành nhóm có tiêu đề.
  - Khẩu phần (số và chữ, ví dụ "4 người"), thời gian sơ chế, thời gian nấu, tổng thời gian.
  - Nguồn (chữ) và URL nguồn, ghi chú, dinh dưỡng (chữ tự do), độ khó.
  - Đánh giá 0–5 sao, đánh dấu yêu thích.
  - Tối đa 20 ảnh, trong đó một ảnh làm ảnh bìa.

  Thiếu tên thì không lưu được. [T]
- AC-03: Màn soạn có ô nhập nguyên liệu và các bước dạng nhiều dòng: dán một khối chữ thì mỗi dòng thành một mục, dòng kết thúc bằng `:` thành tiêu đề nhóm. Kéo để sắp xếp dòng. Đang soạn mà bấm Back thì hỏi "Bỏ thay đổi?" (nếu đã có thay đổi). [T cho tách dòng; M cho kéo thả và Back]
- AC-04: Bấm "Lưu" thì ghi xuống máy trong một giao dịch. Tắt app ngay sau đó, mở lại vẫn còn công thức. [T]
- AC-05: Sửa được mọi trường. Xóa thì hỏi xác nhận, sau đó có thanh "Đã xóa · Hoàn tác" trong 5 giây. Công thức đã xóa vào "Thùng rác", giữ 30 ngày rồi mới xóa hẳn cùng ảnh của nó. Khôi phục được từ thùng rác. Màn Thùng rác có "Dọn sạch thùng rác" (hỏi xác nhận) xóa hẳn mọi công thức trong đó cùng ảnh (D-009). [T]
- AC-06: Nhân bản được một công thức (để làm biến thể). [T]
- AC-07: Ảnh chọn bằng trình chọn ảnh của hệ điều hành (không xin quyền bộ nhớ hay thư viện ảnh) hoặc chụp bằng camera. Ảnh được chép vào bộ nhớ riêng của app và thu nhỏ để cạnh dài nhất không quá 2048 px. Xóa ảnh gốc trong máy không làm mất ảnh trong công thức. Gỡ ảnh hoặc xóa hẳn công thức thì file ảnh bị xóa theo, không để lại file thừa. [T]
- AC-08: Chụp ảnh bằng ứng dụng camera của hệ điều hành (qua trình chọn ảnh), nên Bepbook không khai và không xin quyền camera. Người dùng hủy việc chụp thì không có gì thay đổi, vẫn chọn được ảnh từ thư viện. Người dùng đã duyệt thay đổi này ngày 2026-11-04 (D-005). [M]
- AC-09: Màn xem công thức hiện ảnh bìa, thông tin chung, nguyên liệu, các bước, ghi chú. URL trong ghi chú, trong bước và URL nguồn chạm được để mở bằng trình duyệt trong app (F-03, có nút "Lưu công thức") (D-009). Chạm ảnh thì xem toàn màn hình, vuốt để chuyển, chụm hai ngón để phóng to. [M]

### F-02 · Tổ chức, tìm kiếm, lọc
- AC-10: Danh mục lồng nhau tối đa 3 cấp (ví dụ "Món chính > Món Việt > Món bún"). Một công thức thuộc 0 hoặc nhiều danh mục. Thêm, đổi tên, xóa, kéo sắp xếp danh mục; xóa danh mục không xóa công thức. Lần mở đầu có sẵn vài danh mục mặc định theo ngôn ngữ máy (Món chính, Món phụ, Canh/Súp, Tráng miệng, Đồ uống, Bánh). [T]
- AC-11: Thẻ tự do (ví dụ "chay", "nồi chiên không dầu"), gõ để gợi ý thẻ đã có. [T]
- AC-12: Tìm theo tên, nguyên liệu, các bước, ghi chú, nguồn, không phân biệt hoa thường và không phân biệt dấu tiếng Việt: gõ "pho bo" thì thấy "Phở bò". [T]
- AC-13: Lọc theo danh mục, thẻ, số sao tối thiểu, yêu thích, tổng thời gian tối đa, "có nguyên liệu X". Các bộ lọc kết hợp được với nhau và với ô tìm. Sắp xếp theo tên, ngày thêm, ngày sửa, đánh giá, thời gian nấu, lần nấu gần nhất. Màn kết quả hiện số công thức khớp. [T]
- AC-14: Danh sách xem được dạng lưới ảnh hoặc dạng dòng; lựa chọn được giữ sau khi tắt app. [M]
- AC-15: Đánh dấu "Đã nấu" ghi ngày nấu vào lịch sử của công thức; màn xem hiện số lần nấu và lần gần nhất. [T]

### F-03 · Nhập công thức từ web
- AC-16: Có trình duyệt trong app: thanh địa chỉ, tìm bằng công cụ tìm kiếm mặc định, Back và Forward, nút "Lưu công thức" luôn hiện. [M]
- AC-17: Từ app khác (trình duyệt, YouTube, Facebook...) chọn "Chia sẻ" rồi chọn Bepbook thì app mở màn nhập với URL đó. Chữ được chia sẻ không phải URL thì mở màn soạn với chữ đó để tự gán vào nguyên liệu và các bước. [M]
- AC-18: Trang có dữ liệu schema.org `Recipe` (JSON-LD, gồm cả dạng `@graph` và mảng, hoặc microdata) thì tự điền: tên, nguyên liệu, các bước (gồm cả `HowToSection`), khẩu phần, thời gian (định dạng ISO 8601 như `PT1H30M`), ảnh, nguồn, URL, dinh dưỡng. Có bộ trang mẫu lưu sẵn trong `test/` (tối thiểu 10 trang của các web nấu ăn phổ biến tiếng Việt và tiếng Anh) để test không cần mạng. [T]
- AC-19: Trang không có dữ liệu `Recipe` thì vào chế độ "Chọn đoạn": người dùng bôi đen chữ trên trang rồi bấm "Là nguyên liệu", "Là các bước" hoặc "Là tên". [M]
- AC-20: Trước khi lưu luôn có màn xem trước để sửa. Công thức nhập từ web giữ URL nguồn và tên trang. URL đã có trong sổ thì báo "Đã có công thức này" và hỏi mở bản cũ hay lưu bản mới; nếu bản cũ đang ở Thùng rác thì báo điều đó và hỏi khôi phục hay lưu bản mới (D-009). [T cho phát hiện trùng; M cho giao diện]
- AC-21: Mỗi lần tải trang có thời gian chờ 20 giây. Mất mạng, hết giờ hoặc trang lỗi thì báo rõ lý do và có nút "Thử lại". Đã nhập tới đâu cũng không mất, và không treo app. [T cho xử lý lỗi; M cho chế độ máy bay]
- AC-66: Trình duyệt trong app mở được cả trang `http` (không mã hóa) — quyết định D-010, ngoại lệ ghi ở `docs/COMPLIANCE.md` S-01/S-60. Khi trang đang mở dùng `http` (kể cả khi trang `https` chuyển hướng sang `http`), thanh địa chỉ hiện nhãn "Không mã hóa" kèm biểu tượng ổ khóa mở (không chỉ phân biệt bằng màu; TalkBack/VoiceOver đọc được); chạm vào nhãn thì hiện giải thích ngắn: người khác trên cùng mạng có thể đọc nội dung trang, đừng nhập mật khẩu hay số thẻ. Trang `https` không có nhãn. Ngoại lệ chỉ áp cho trình duyệt nhập công thức (WebView); app không gửi dữ liệu nào của người dùng tới trang đó ngoài yêu cầu tải trang (AC-65). [T cho hàm nhận biết `http`/`https`/chuyển hướng; M cho giao diện và đọc màn hình]
- AC-22: Ảnh của công thức nhập từ web được tải về máy (AC-07 áp dụng), nên xem lại khi không có mạng vẫn có ảnh. [T]

### F-04 · Quét công thức từ ảnh
- AC-23: Chọn một hoặc nhiều ảnh (tối đa 10, ví dụ hai trang sách) từ thư viện, chụp bằng camera, hoặc chọn file PDF. App nhận chữ ngay trên máy, không gửi ảnh hay chữ ra ngoài (D-003), đọc được tiếng Việt có dấu và tiếng Anh. [M]
- AC-24: Sau khi nhận chữ, màn gán hiện từng dòng chữ. Chạm chọn các dòng rồi gán "Tên", "Nguyên liệu", "Các bước", "Ghi chú"; sửa được chữ trước khi lưu. Ảnh gốc được giữ làm ảnh của công thức nếu người dùng chọn. [M]
- AC-25: Với bộ ảnh mẫu trong `test/` (tối thiểu 5 trang in tiếng Việt, 5 trang in tiếng Anh, chụp đủ sáng), tỉ lệ ký tự đúng từ 90% trở lên với chữ in. Chữ viết tay không có cam kết độ chính xác, và màn gán nói rõ điều đó. [T đo trên bộ mẫu; ngưỡng chốt lại ở G8 sau khi đo thật]

### F-05 · Chế độ nấu
- AC-26: Nút "Nấu" mở chế độ nấu:
  - Màn hình không tắt khi đang ở chế độ này; thoát thì trở lại như cũ.
  - Chữ lớn hơn màn xem thường, chỉnh được cỡ chữ.
  - Bước đang làm được làm nổi bật.
  - Chạm một nguyên liệu hoặc một bước thì gạch nó đi.

  Thoát rồi vào lại trong 12 giờ thì giữ nguyên các dòng đã gạch. [T cho trạng thái; M cho màn hình sáng]
- AC-27: Thời gian ghi trong bước được nhận ra và hiện thành nút hẹn giờ, ví dụ "nấu 15 phút", "1 tiếng 30 phút", "10-15 phút" (lấy số lớn), "bake for 25 minutes", "1 hour". [T]
- AC-28: Chạy được nhiều hẹn giờ cùng lúc, mỗi cái có tên theo bước. Hết giờ thì đổ chuông và hiện thông báo, kể cả khi app ở nền hoặc máy khóa màn hình, lệch không quá 2 giây. Quyền thông báo xin lần đầu bấm hẹn giờ, có giải thích trước. Từ chối thì hẹn giờ vẫn chạy và đổ chuông khi app đang mở, kèm cảnh báo "sẽ không báo khi app ở nền". [T cho đếm giờ; M cho thông báo]
- AC-29: Ghim được tối đa 5 công thức đang nấu để chuyển qua lại nhanh từ thanh ở đầu chế độ nấu. [M]
- AC-30: Có nút "Đọc bước" dùng giọng đọc của hệ điều hành, đọc bước hiện tại bằng ngôn ngữ của công thức. Máy không có giọng đọc cho ngôn ngữ đó thì báo và hướng dẫn cài. [M]

### F-06 · Nhân khẩu phần và đổi đơn vị
- AC-31: Tách được nguyên liệu có cấu trúc cho các đơn vị tiếng Việt và tiếng Anh thường gặp: g, kg, mg, ml, l, muỗng canh/thìa canh (tbsp), muỗng cà phê/thìa cà phê (tsp), chén, bát, cup, oz, lb, fl oz, pint, quart, củ, quả, trái, tép, nhánh, lát, miếng, gói, lon, hộp, nhúm, chút. Bộ test có tối thiểu 100 dòng nguyên liệu thật, tỉ lệ tách đúng từ 95% trở lên. [T]
- AC-32: Chọn khẩu phần mới hoặc hệ số (½×, 2×, 3×, tự nhập) thì mọi dòng có cấu trúc được nhân, hiện số gọn (ví dụ `1 1/2 cup`, `375 g`, không hiện `0.33333`). Dòng không có cấu trúc giữ nguyên và có dấu báo "không tự nhân được". Thay đổi chỉ để xem, không sửa công thức gốc trừ khi bấm "Lưu theo khẩu phần này". [T]
- AC-33: Đổi cả công thức sang hệ mét hoặc hệ Mỹ: thể tích ↔ thể tích, khối lượng ↔ khối lượng, nhiệt độ °C ↔ °F trong các bước. Không tự đổi thể tích sang khối lượng (cần khối lượng riêng của từng nguyên liệu, ngoài phạm vi). "Chén" và "bát" không có chuẩn thống nhất nên không đổi, hiện đúng như gốc. [T]

### F-07 · Danh sách đi chợ
- AC-34: Có nhiều danh sách (ví dụ "Siêu thị", "Chợ"). Thêm món bằng tay, gõ để gợi ý từ các món đã từng thêm, và có danh sách "Món hay mua" để thêm bằng một chạm. [T]
- AC-35: Từ một công thức (theo khẩu phần đang chọn) hoặc từ thực đơn (F-08), chọn các nguyên liệu cần thêm vào danh sách. Mặc định bỏ chọn những món đang có trong Tủ bếp (F-09). Món trùng tên và cùng loại đơn vị thì được gộp và cộng số lượng (ví dụ "200 g thịt bò" + "300 g thịt bò" = "500 g thịt bò"). Khác loại đơn vị thì để hai dòng. Mỗi món ghi nó đến từ công thức nào. [T]
- AC-36: Món tự xếp vào khu vực (Rau củ, Thịt cá, Sữa trứng, Đồ khô, Gia vị, Đông lạnh, Đồ uống, Khác) theo từ điển có sẵn bằng tiếng Việt và tiếng Anh. Người dùng chuyển một món sang khu vực khác thì lần sau app nhớ. Thêm, đổi tên, sắp xếp được khu vực theo đường đi trong cửa hàng. [T]
- AC-37: Chạm để gạch món đã mua, món đã gạch xuống cuối. Có "Xóa các món đã gạch" và tùy chọn "chuyển món đã mua vào Tủ bếp". Chia sẻ danh sách dạng chữ qua bảng chia sẻ của hệ điều hành. [T cho gộp và gạch; M cho chia sẻ]

### F-08 · Lịch thực đơn và thực đơn mẫu
- AC-38: Xem lịch theo ngày, tuần, tháng. Mỗi ngày có các bữa (mặc định: Sáng, Trưa, Tối, Phụ; đổi tên, thêm, bớt được). Thêm vào một bữa: công thức có sẵn hoặc một dòng chữ tự do (ví dụ "Ăn ngoài"). Kéo để chuyển món sang ngày hay bữa khác. Ngày đầu tuần theo cài đặt. [T cho dữ liệu; M cho kéo thả]
- AC-39: "Thực đơn mẫu" là một bộ món đặt tên được (ví dụ "Cơm gia đình 4 món", "Tiệc sinh nhật"). Áp một thực đơn mẫu vào một ngày hoặc một tuần bằng một thao tác. Ngày hoặc bữa đích đã có món thì hỏi "Thay thế" hay "Thêm vào" (D-009). [T]
- AC-40: Từ một khoảng ngày trong lịch, "Thêm vào đi chợ" đẩy toàn bộ nguyên liệu của các công thức trong khoảng đó, theo khẩu phần đặt cho từng món, qua bước chọn của AC-35. [T]
- AC-41: "Gợi ý ngẫu nhiên" điền các bữa còn trống của một tuần bằng công thức chọn ngẫu nhiên theo bộ lọc (danh mục, thẻ, thời gian tối đa). Không lặp một món trong cùng tuần nếu còn món khác thỏa bộ lọc. Xem trước rồi mới áp. [T]

### F-09 · Tủ bếp
- AC-42: Danh sách nguyên liệu đang có: tên, số lượng (tùy chọn), khu vực, ngày mua, hạn dùng (tùy chọn). Món còn 3 ngày hoặc ít hơn tới hạn được đánh dấu "Sắp hết hạn", món quá hạn đánh dấu "Hết hạn". Lọc được theo hai trạng thái này. [T]
- AC-43: "Nấu được gì?" liệt kê công thức xếp theo tỉ lệ nguyên liệu đang có trong Tủ bếp (khớp tên không phân biệt dấu và số ít/số nhiều tiếng Anh), kèm "còn thiếu N món". Gia vị cơ bản (muối, đường, nước, tiêu, dầu ăn, nước mắm) không tính là thiếu nếu người dùng bật tùy chọn này. [T]

### F-10 · Nhập, xuất, chia sẻ, in
- AC-44: Nhập file sao lưu của Paprika (`.paprikarecipes`) và của Recipe Keeper (file `.zip` xuất từ app đó): lấy tên, nguyên liệu, các bước, ghi chú, khẩu phần, thời gian, nguồn, đánh giá, danh mục, ảnh. Báo số công thức nhập được, số bị bỏ qua và lý do. Nhập lại cùng file thì không tạo bản trùng. [T với file mẫu thật, cần người dùng cung cấp hoặc tự tạo bằng bản miễn phí của các app đó (mục 7)]
- AC-45: Nhập và xuất định dạng CookNote — file `.cooknote`, tên định dạng giữ nguyên dù app đã đổi tên Bepbook (D-010), để file sao lưu cũ vẫn đọc được (F-11) và JSON schema.org `Recipe` (một hoặc nhiều công thức). [T]
- AC-46: Chia sẻ một công thức qua bảng chia sẻ của hệ điều hành dưới dạng chữ, file PDF, hoặc file `.cooknote` để người nhận có Bepbook nhập vào được. [M]
- AC-47: Xuất "Sách công thức" PDF từ các công thức đã chọn hoặc từ một danh mục: trang bìa (tên sách, ảnh), mục lục có số trang, mỗi công thức bắt đầu ở trang mới, có ảnh bìa của công thức. Tiếng Việt hiển thị đúng. In qua hộp thoại in của hệ điều hành. [T cho số trang và mục lục; M cho in]
- AC-48: Khi xuất không xin quyền bộ nhớ. File tạm được xóa sau khi chia sẻ xong hoặc lần mở app kế tiếp. [M]

### F-11 · Sao lưu bền lâu và khôi phục
- AC-49: File sao lưu `.cooknote` là gói zip, định dạng mở, có tài liệu (`docs/BACKUP-FORMAT.md` trong repo, và một file `README.txt` nằm trong gói):
  - `manifest.json`: số phiên bản định dạng, phiên bản app, thời điểm tạo, số lượng từng loại dữ liệu, mã băm SHA-256 của từng file trong gói.
  - `data.json`: toàn bộ công thức, danh mục, thẻ, lịch sử nấu, danh sách đi chợ, thực đơn, tủ bếp, cài đặt.
  - `images/`: ảnh gốc của app.
  - `html/index.html` và mỗi công thức một trang HTML: mở bằng trình duyệt bất kỳ, không cần Bepbook, đọc được và in được.

  [T]
- AC-50: "Sao lưu tự động" chọn một thư mục đích MỘT lần qua trình chọn thư mục của hệ điều hành; có thể là thư mục trên máy hoặc của Google Drive, OneDrive nếu ứng dụng đó cho phép (iPhone: AC-67). Chu kỳ: hằng ngày (mặc định) hoặc hằng tuần. App sao lưu khi mở app hoặc khi chuyển vào nền, nếu đã quá chu kỳ VÀ dữ liệu có thay đổi. Việc này không làm chậm thao tác của người dùng. Trong thư mục đích giữ 5 bản gần nhất (đổi được từ 1 tới 30), bản cũ hơn tự xóa. App chỉ xóa file do chính nó tạo, nhận ra bằng tên và `manifest.json`. [T cho chu kỳ và xoay vòng; M cho từng nơi lưu]
- AC-51: Sau mỗi lần sao lưu (tự động hay bằng tay), app đọc lại file vừa ghi và kiểm mã băm từng phần. Sai thì báo lỗi và không tính là lần sao lưu thành công. Mất quyền ghi vào thư mục đích (bị gỡ quyền, ứng dụng đám mây bị gỡ, hết dung lượng) thì hiện cảnh báo trên màn Công thức và nút chọn lại thư mục. [T cho kiểm tra; M cho mất quyền]
- AC-52: "Sao lưu ngay" tạo file rồi mở bảng chia sẻ hoặc trình lưu file của hệ điều hành, lưu được vào bất kỳ đâu (Tệp, Google Drive, email). Đây là đường dự phòng khi nơi lưu không hỗ trợ sao lưu tự động (mục 7). [M]
- AC-53: Màn Sao lưu hiện: thời điểm, nơi lưu và kết quả của lần sao lưu thành công gần nhất; dung lượng file. Quá 7 ngày (đổi được) chưa có lần sao lưu thành công nào thì hiện nhắc trong app (không dùng thông báo hệ thống). Lần đầu có 10 công thức thì app gợi ý bật sao lưu tự động một lần. [T cho điều kiện nhắc; M cho giao diện]
- AC-54: "Khôi phục" chọn file qua trình chọn file, hoặc chọn từ danh sách các bản trong thư mục sao lưu tự động. App kiểm định dạng, phiên bản và mã băm TRƯỚC khi đụng vào dữ liệu hiện có. Có hai cách: "Thay thế toàn bộ" (hỏi xác nhận) hoặc "Gộp" (thêm công thức chưa có, không đụng công thức đã có). Trước khi thay thế, app tự tạo một bản sao lưu của dữ liệu hiện tại. File hỏng hoặc sai định dạng thì báo lỗi và giữ nguyên dữ liệu. [T]
- AC-55: Định dạng chỉ được mở rộng, không phá vỡ: mọi phiên bản app sau này đọc được file của mọi phiên bản định dạng cũ hơn. `test/` giữ file mẫu của từng phiên bản định dạng đã phát hành, và test khôi phục chạy trên tất cả các file đó. [T]
- AC-56: Lớp phụ là Android Auto Backup: bật cho cơ sở dữ liệu và cài đặt, giới hạn dung lượng theo tài liệu Android (tra lại ở G3). Màn Sao lưu nói rõ lớp này không bảo đảm có ảnh và không thay được sao lưu chính. Đổi máy Android cùng tài khoản Google thì công thức (không ảnh) về lại sau khi cài app. [M]
- AC-57: Sao lưu và khôi phục 1.000 công thức có 2.000 ảnh thì không làm app treo: có thanh tiến độ, hủy được, và chạy tới cuối không lỗi trên máy đo chuẩn (thời gian đo ghi vào TESTING). [M]
- AC-67: Trên iPhone, "Sao lưu tự động" (AC-50) hoạt động bằng thư mục do người dùng chọn MỘT lần qua `UIDocumentPicker` (chế độ chọn thư mục của hệ điều hành; gồm "Trên iPhone", iCloud Drive và thư mục của các ứng dụng lưu trữ khác trong Tệp). App lưu quyền truy cập dưới dạng security-scoped bookmark trong cài đặt cục bộ, mở lại bằng bookmark ở mỗi lần cần ghi, và gọi bắt đầu/kết thúc truy cập đúng cặp. Lịch ghi, xoay vòng và đọc lại kiểm mã băm y như Android: ghi khi mở app hoặc khi chuyển vào nền nếu đã quá chu kỳ VÀ dữ liệu có thay đổi (AC-50, AC-51). Bookmark hỏng hoặc hết hạn (thư mục bị xóa, đổi tài khoản iCloud, khôi phục sang máy khác, hệ điều hành không giải được bookmark) thì app KHÔNG ghi vào chỗ khác, hiện cảnh báo trên màn Công thức và nút "Chọn lại thư mục" như AC-51, rồi lần chọn lại tạo bookmark mới. "Sao lưu ngay" (AC-52) vẫn có trên iPhone như đường dự phòng. Nếu thư mục ở iCloud Drive mà file chưa tải về máy thì việc đọc lại để kiểm (AC-51) phải đợi hoặc báo lỗi rõ ràng, không được tính là thành công. [T cho logic chu kỳ, xoay vòng và trạng thái hỏng bookmark (qua giao diện giả); M trên iPhone thật cho từng nơi lưu: Trên iPhone, iCloud Drive]

### F-12 · Giao diện, ngôn ngữ, màn chào
- AC-58: Giao diện sáng, tối và theo hệ thống. Tiếng Việt và tiếng Anh, mặc định theo ngôn ngữ máy, đổi được trong Cài đặt; mọi chuỗi giao diện nằm trong file dịch. Chọn được ngày đầu tuần và hệ đơn vị mặc định (mét hoặc Mỹ). [T]
- AC-59: Lần mở đầu có màn chào tối đa 3 trang, bỏ qua được, không xin quyền nào. Màn chào nói rằng dữ liệu chỉ nằm trên máy và cần bật sao lưu để giữ lâu dài, kèm nút "Bật sao lưu tự động". [M]

### F-13 · Khả năng tiếp cận
- AC-60: Mọi vùng chạm tối thiểu 48×48 dp. [M]
- AC-61: Ở cỡ chữ hệ thống 200%, các màn chính không bị cắt chữ hay chồng chữ. Tương phản chữ tối thiểu 4,5:1 với chữ thường và 3:1 với chữ lớn và biểu tượng, ở cả giao diện sáng và tối. [M]
- AC-62: Bật TalkBack thì đọc được tên mọi nút, từng nguyên liệu và từng bước (kèm trạng thái "đã gạch" trong chế độ nấu), đánh giá sao ("4 trên 5 sao"), và thời gian còn lại của hẹn giờ. Trạng thái không chỉ phân biệt bằng màu. [M]

### F-14 · Quyền riêng tư và thông tin pháp lý trong app
- AC-63: Màn "Giới thiệu" có: phiên bản, liên kết chính sách quyền riêng tư, email báo lỗi bảo mật, danh sách giấy phép nguồn mở. Có câu nhắc rằng công thức nhập từ web thuộc bản quyền của tác giả, chỉ dùng cá nhân. [M]
- AC-64: "Xóa toàn bộ dữ liệu" trong Cài đặt xóa cơ sở dữ liệu, ảnh và cài đặt sau xác nhận hai bước, và hỏi trước có muốn sao lưu không. Đồng thời xóa mọi dữ liệu của trình duyệt trong app: cookie, bộ nhớ đệm (cache), bộ nhớ cục bộ của trang (localStorage, IndexedDB) và lịch sử duyệt (D-010). Không xóa các file sao lưu ở thư mục ngoài. Mở lại app thì như mới cài, và trình duyệt không còn đăng nhập hay cookie của trang nào. [T cho dữ liệu của app; M cho dữ liệu WebView: mở một trang đặt cookie, xóa toàn bộ, mở lại thì cookie mất]
- AC-65: App không gửi dữ liệu của người dùng tới bất kỳ máy chủ nào của nhà phát triển hay bên thứ ba:
  - Không có thư viện analytics, quảng cáo, báo crash; không dùng ML Kit hay SDK gửi số liệu sử dụng (D-002, D-003).
  - Lưu lượng mạng chỉ có ở F-03: tải trang người dùng mở (kể cả trang `http`, có nhãn cảnh báo AC-66) và ảnh của công thức. Cho phép `http` chỉ để WebView mở được trang người dùng chọn; không nới cho phần khác của app (COMPLIANCE S-01/S-60).
  - Manifest đã build chỉ có các quyền nêu ở mục 5.

  [T: kiểm manifest đã build, rà `pubspec.lock`]

## 4. Ngoài phạm vi (cố ý KHÔNG làm ở bản đầu)
- Đồng bộ tự động nhiều máy qua tài khoản (máy chủ riêng, hoặc Google Drive bằng đăng nhập Google). Bản đầu thay bằng sao lưu tự động vào thư mục người dùng chọn (F-11). Ghi ở `docs/MANUAL-TESTS.md` mục "Ý tưởng".
- Tài khoản, máy chủ, chia sẻ công thức giữa người dùng trong app, mạng xã hội.
- Nhập từ Instagram, TikTok hay video: cần API hay cào dữ liệu trái điều khoản của các nền tảng đó. Bản đầu chỉ nhận URL hoặc chữ được chia sẻ (AC-17).
- Tự tính dinh dưỡng từ cơ sở dữ liệu thực phẩm, đổi thể tích sang khối lượng theo từng nguyên liệu.
- AI: tạo công thức, gợi ý món, chatbot, nhận dạng món từ ảnh.
- Trợ lý giọng nói (Alexa, Google Assistant), điều khiển rảnh tay bằng giọng nói, widget, đồng hồ thông minh.
- Định dạng chữ phong phú (đậm, nghiêng) trong các bước. Bản đầu dùng chữ thường, URL chạm được.
- Nhập file của CookBook – Recipe Manager (chưa có định dạng công khai; xem lại khi có file mẫu).
- Máy tính bảng, desktop, web. (iPhone đã đưa vào bản đầu theo D-008.)
- Gói Premium, quảng cáo, mua trong app.

## 5. Ràng buộc mobile
- Hệ điều hành:
  - Android và iOS, Flutter, một codebase (D-001, D-008). iOS build và test trên GitHub Actions macOS runner.
  - minSdk và targetSdk theo phiên bản Flutter chốt ở G1; targetSdk phải đạt yêu cầu hiện hành của Google Play (COMPLIANCE P-06).
- Offline:
  - Mọi tính năng trừ F-03 chạy không cần mạng.
  - F-03 cần mạng, có thời gian chờ, báo lỗi và thử lại (AC-21).
  - Dữ liệu ghi xuống máy ngay khi bấm Lưu.
  - Sao lưu tự động vào thư mục đám mây: hệ điều hành và ứng dụng đám mây tự đẩy lên khi có mạng; app chỉ ghi file (mục 7).
- Quyền thiết bị (chỉ xin khi người dùng dùng tính năng cần quyền đó, có giải thích trước; L-010):
  - Internet (`INTERNET`, không cần hỏi người dùng): chỉ cho F-03.
  - Camera: G1 chụp ảnh món bằng ứng dụng camera của hệ điều hành nên KHÔNG cần quyền `CAMERA` (AC-08, D-005). Quét công thức ở G8 chỉ xin `CAMERA` nếu tự mở camera, và phải hỏi lại người dùng trước khi thêm.
  - Thông báo (`POST_NOTIFICATIONS`, Android 13 trở lên): báo hết giờ nấu. Xin khi bấm hẹn giờ lần đầu.
  - Báo giờ chính xác cho hẹn giờ nấu: cách làm (dịch vụ chạy nền có thông báo trong lúc đếm giờ, hoặc `SCHEDULE_EXACT_ALARM`) chốt ở G5 theo chính sách Google Play hiện hành, ghi D-xxx và hỏi người dùng trước khi thêm quyền.
  - Giữ màn hình sáng ở chế độ nấu: dùng cờ của cửa sổ, không cần quyền `WAKE_LOCK` nếu thư viện cho phép (kiểm ở G5).
  - KHÔNG xin quyền bộ nhớ, thư viện ảnh, vị trí, danh bạ, micro. Thư viện nào tự thêm quyền ngoài danh sách này thì bỏ đi bằng cấu hình manifest. Không bỏ được thì ghi D-xxx và hỏi người dùng.
- Màn hình: chiều rộng nhỏ nhất 360 dp, chỉ màn hình dọc.
- Pin: không có tác vụ chạy nền định kỳ. Sao lưu tự động chạy lúc mở app hoặc chuyển vào nền (AC-50). Hẹn giờ chỉ chạy khi người dùng bật.

## 5b. Yêu cầu phi chức năng
Ngưỡng dưới đây là đề xuất của Claude; người dùng chỉnh khi duyệt. Máy đo chuẩn: Galaxy A13 (SM-A135F, Android 14, chạy 32-bit; L-011), máy đã dùng cho APP-001.

- Hiệu năng:
  - Mở nguội tới màn Công thức không quá 2,5 giây (trung vị 5 lần, bản release).
  - Với 5.000 công thức: kết quả tìm kiếm hiện không quá 300 ms sau khi ngừng gõ; cuộn lưới ảnh không tụt dưới 50 khung hình/giây theo Flutter DevTools.
  - Nhập từ web (mạng 4G): từ lúc bấm "Lưu công thức" tới màn xem trước không quá 5 giây với trang có dữ liệu `Recipe`, chưa tính tải ảnh.
  - Quét một trang ảnh: nhận chữ xong không quá 10 giây.
- Hẹn giờ: thử 20 lần, máy khóa màn hình, lệch không quá 2 giây (AC-28).
- Pin và bộ nhớ: 30 phút ở chế độ nấu với màn hình sáng và một hẹn giờ thì app tiêu hao không quá 3% pin, chưa tính màn hình (đo bằng màn pin của hệ điều hành). Bộ nhớ khi dùng không quá 300 MB.
- Dung lượng: APK release đủ kiến trúc (L-011) không quá 80 MB; bản tải về từ Google Play cho một kiến trúc không quá 45 MB, gồm dữ liệu nhận chữ tiếng Việt và tiếng Anh, chưa tính dữ liệu của người dùng.
- Khả năng truy cập: mục tiêu WCAG 2.2 AA (F-13).
- Ổn định: tỉ lệ người dùng không gặp crash từ 99,5% trở lên theo Android vitals của Play Console, xem mỗi tuần trong tháng đầu sau phát hành.
- Toàn vẹn và độ bền dữ liệu:
  - Mọi lần ghi nằm trong một giao dịch cơ sở dữ liệu (AC-04).
  - Khôi phục file hỏng không làm mất dữ liệu hiện có (AC-54).
  - Mọi phiên bản app đọc được mọi file sao lưu cũ hơn (AC-55).

## 5c. Thị trường và tiêu chuẩn bán app
Đã điền mục 1 của `docs/COMPLIANCE.md`: Việt Nam và toàn cầu (nhóm A và B, chưa mở nhóm C), Google Play, miễn phí, không tài khoản, không SDK bên thứ ba, nhà phát triển không thu thập dữ liệu, không có dữ liệu nhạy cảm.

Các mục tuân thủ cần xây thành tính năng:
- AC-08, AC-28 và D-11: xin quyền đúng lúc.
- F-12, F-13 và A-01: ngôn ngữ, khả năng tiếp cận.
- F-14: chính sách quyền riêng tư, xóa dữ liệu, kênh báo lỗ hổng, giấy phép nguồn mở, không gửi dữ liệu ra ngoài.
- F-11 và D-06: người dùng mang dữ liệu đi được bằng định dạng mở.

## 6. Dữ liệu
- Lưu ở đâu:
  - Cơ sở dữ liệu SQLite và thư mục ảnh trong bộ nhớ riêng của app (thư viện chốt ở G1).
  - Không có máy chủ.
  - Bản sao nằm ở thư mục sao lưu người dùng chọn (F-11) và ở Android Auto Backup (cơ sở dữ liệu, không có ảnh).
- Dữ liệu nhạy cảm:
  - Không chủ ý thu thập. Công thức, ảnh món, ghi chú có thể chứa thông tin cá nhân người dùng tự ghi (ví dụ "công thức của bà ngoại", ảnh có người).
  - Lớp bảo vệ: bộ nhớ riêng của app. Màn Sao lưu nói rõ file sao lưu không được mã hóa (ai có file đều đọc được).
  - Không có khóa app, vì công thức không phải dữ liệu nhạy cảm (ghi vào Ý tưởng).
- Thu thập dữ liệu:
  - Nhà phát triển KHÔNG thu thập gì. Data safety của Google khai "không thu thập, không chia sẻ".
  - Trang web người dùng mở trong trình duyệt của app có thể tự đặt cookie và thu thập theo chính sách của trang đó. Chính sách quyền riêng tư nói rõ điều này. App dùng WebView của hệ điều hành và không thêm mã theo dõi.
  - Vẫn cần chính sách quyền riêng tư công khai.

## 7. Rủi ro và điều chưa biết
- Pháp lý về thương hiệu và bản quyền:
  - Làm chức năng giống ba app tham khảo là được, nhưng tên, giao diện, chữ và mô tả store phải tự làm. Rà lại trước khi phát hành.
  - Tên hiển thị **Bepbook** (D-010, 2026-11-05; tên cũ "CookNote" trùng app cùng loại nên đã bỏ). Tra Play, web, WIPO không có kết quả; còn phải tra trực tiếp App Store và Cục SHTT trước khi phát hành.
  - Công thức nhập từ web thuộc bản quyền của tác giả. App giữ URL nguồn, chỉ phục vụ dùng cá nhân, không có kho công thức chung.
- Sao lưu tự động vào thư mục đám mây (CHƯA kiểm chứng):
  - Trên iPhone (D-010, AC-67): thư mục chọn qua `UIDocumentPicker` và giữ bằng security-scoped bookmark. Rủi ro: bookmark hết hiệu lực sau khi thư mục bị xóa/di chuyển, đổi tài khoản iCloud hoặc khôi phục sang máy khác (đã có cảnh báo + chọn lại); thư mục iCloud Drive có thể chỉ có bản giữ chỗ chưa tải về nên đọc lại để kiểm mã băm chậm hoặc lỗi; nhà cung cấp ngoài (Drive, OneDrive) có thể không cho ghi lâu dài. Phải thử trên iPhone thật ở #2 với "Trên iPhone" và iCloud Drive rồi ghi vào biên bản.
  - Trên Android, ứng dụng Google Drive có thể không cho app khác chọn và ghi định kỳ vào một THƯ MỤC trên Drive (quyền thư mục lâu dài). Ghi từng file qua "Sao lưu ngay" thì được.
  - OneDrive và các ứng dụng khác chưa biết.
  - Phải thử thật ở G3 với Google Drive, OneDrive và thư mục trên máy, rồi ghi D-xxx.
  - Nếu Drive không cho thì sao lưu tự động chỉ ghi vào thư mục trên máy (vẫn mất khi mất máy). Khi đó nhắc sao lưu (AC-53) cùng "Sao lưu ngay" lên Drive là lớp chính, và đồng bộ Drive bằng đăng nhập Google được đưa lên làm ưu tiên ở bản sau.
- Dung lượng sao lưu: ảnh làm file lớn (ước tính khoảng 300 KB mỗi ảnh, nên 2.000 ảnh khoảng 600 MB). Giữ 5 bản là khoảng 3 GB trên Drive. Phải đo ở G3. Phương án nếu quá lớn: sao lưu tăng dần (ảnh không đổi thì không ghi lại), ghi D-xxx.
- Nhận chữ từ ảnh (D-003):
  - ML Kit của Google gửi số liệu chẩn đoán và sử dụng về Google (trang "ML Kit Android data disclosure", tra ngày 2026-11-03), trái với cam kết không gửi dữ liệu.
  - Đề xuất mặc định: Tesseract nguồn mở chạy trên máy, có dữ liệu tiếng Việt. Đổi lại độ chính xác thấp hơn, app nặng thêm vài MB, và thư viện Flutter cho Tesseract cần được đánh giá mức bảo trì ở G8.
  - Ngưỡng AC-25 chốt lại sau khi đo thật.
- Nhập từ web:
  - Một số trang chặn trình duyệt nhúng, đòi đăng nhập, hoặc không có dữ liệu `Recipe` (nhất là blog và trang tiếng Việt). Khi đó chỉ còn chế độ "Chọn đoạn" (AC-19).
  - Cấu trúc trang thay đổi theo thời gian, nên test dùng trang mẫu lưu sẵn.
- Định dạng file của Paprika và Recipe Keeper không có tài liệu chính thức. Phải làm theo file mẫu thật: người dùng cung cấp file xuất từ các app đó, hoặc Claude tạo bằng bản dùng thử. Không có file mẫu thì AC-44 không kiểm chứng được và sẽ được tách ra.
- Hẹn giờ nấu chính xác khi máy khóa: chính sách Google Play với quyền báo giờ chính xác và dịch vụ chạy nền thay đổi theo năm. Một số hãng (Samsung, Xiaomi, Oppo) tiết kiệm pin mạnh. Phải tra chính sách hiện hành ở G5.
- Tách nguyên liệu tiếng Việt: cách viết rất đa dạng ("2 muỗng canh nước mắm", "nước mắm 2 thìa", "1 ít hành", "hành lá: 1 nắm"). Ngưỡng 95% ở AC-31 có thể phải chỉnh sau khi có bộ mẫu thật.
- Phạm vi rất lớn: 14 tính năng, 67 AC, làm theo phiên điều phối (`APP.md`). Người dùng có thể cắt bớt cho bản phát hành đầu (ví dụ dời F-04, F-09, AC-30, AC-47 sang bản sau).
- Chờ người dùng quyết:
  - Phát hành dưới tên cá nhân hay công ty.
  - Có tích hợp Play Age Signals không (COMPLIANCE D-12).
  - App miễn phí của cá nhân có thuộc phạm vi CRA ở EU không (S-06).
  - Tên gói Android (ví dụ `com.<tên>.cooknote`).
- Tài khoản Google Play cá nhân mới phải closed test với 12 người trong 14 ngày (P-09).

## 8. Tiêu chí hoàn thành bản đầu
- F-01 tới F-14 đạt toàn bộ AC, có biên bản thử trên máy Android thật (Galaxy A13).
- Lint, typecheck và test (lệnh chốt ở G1) chạy thật và đạt.
- Khôi phục thành công từ file sao lưu trên một máy Android KHÁC (hoặc sau khi gỡ và cài lại app), cả công thức lẫn ảnh, có biên bản.
- `docs/COMPLIANCE.md` không còn dòng "chưa" ở các mục áp dụng cho Android và các thị trường mở bán.
- Đã closed test theo P-09 và đã sửa xong lỗi chặn trước khi mở bán.
