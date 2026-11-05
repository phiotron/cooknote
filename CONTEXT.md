# A004-cooknote · Bepbook — CONTEXT (glossary)

> Chỉ là bảng thuật ngữ nghiệp vụ. Không ghi chi tiết cài đặt (bảng, cột, thư viện) ở đây — xem `docs/ARCHITECTURE.md`,
> `docs/BACKUP-FORMAT.md`. Nguồn sự thật về hành vi: `docs/SPEC.md` (mã AC ghi ở cột cuối).
> Thuật ngữ chuẩn dùng tiếng Anh trong code và trong `product.md`; cột VI là chữ hiển thị/tài liệu.
> Thêm thuật ngữ mới: phiên điều phối duyệt; phiên con ghi đề xuất vào `notes/`.

## Công thức và tổ chức

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **Recipe** | Công thức | Đơn vị chính của app: tên (bắt buộc, ≤ 200 ký tự), Ingredient lines, Steps, khẩu phần, thời gian sơ chế/nấu/tổng, nguồn + URL nguồn, ghi chú, dinh dưỡng (chữ tự do), độ khó, Rating, Favorite, tối đa 20 Photo. Thiếu tên thì không lưu được. | "món" (để chỉ món ăn nói chung), "note" | AC-02, AC-04 |
| **Ingredient line** | Dòng nguyên liệu | Một dòng trong phần nguyên liệu của Recipe, giữ đúng chữ người dùng nhập. Có thể là Structured ingredient hoặc không. | "item" (để dành cho Shopping item) | AC-02, AC-03 |
| **Step** | Bước | Một dòng trong phần các bước, được đánh số theo thứ tự. Có thể chứa thời lượng (thành Step timer) và URL chạm được (mở bằng In-app browser). | "instruction", "direction" | AC-02, AC-09, AC-27 |
| **Group** (Ingredient group / Step group) | Nhóm (tiêu đề nhóm) | Tiêu đề chia Ingredient lines hoặc Steps thành phần, ví dụ "Phần nước dùng". Khi soạn, dòng kết thúc bằng `:` thành tiêu đề nhóm. Group không bị nhân, không được gạch, không đánh số. | "section" (trong giao diện) | AC-02, AC-03 |
| **Structured ingredient** | Nguyên liệu có cấu trúc | Ingredient line đã tách được thành số lượng (số nguyên, thập phân, phân số `1/2`, `1 1/2`, `½`, khoảng `2-3`), đơn vị (g, kg, ml, l, muỗng canh/tbsp, muỗng cà phê/tsp, chén, bát, cup, oz, lb, fl oz, pint, quart, củ, quả, trái, tép, nhánh, lát, miếng, gói, lon, hộp, nhúm, chút…) và tên. Chỉ loại này được nhân khẩu phần và đổi đơn vị. | | AC-31 |
| **Unstructured line** | Dòng không có cấu trúc | Ingredient line không tách được ("hành lá, rau thơm", "a pinch of cinnamon"). Giữ nguyên chữ, không nhân, không đổi đơn vị; khi đang xem theo Scale factor hoặc Unit system khác thì có dấu "không tự nhân được". | "lỗi tách", "invalid line" | AC-32 |
| **Photo** / **Cover photo** | Ảnh / Ảnh bìa | Ảnh chép vào bộ nhớ riêng của app (thu nhỏ cạnh dài ≤ 2048 px), độc lập với ảnh gốc trong máy. Tối đa 20 ảnh mỗi Recipe; đúng một ảnh là ảnh bìa (ảnh đầu). Gỡ ảnh hoặc Recipe bị xoá hẳn thì file ảnh bị xoá theo. | "attachment" | AC-02, AC-07, AC-22 |
| **Rating** | Đánh giá | 0–5 sao nguyên; 0 nghĩa là chưa đánh giá. Đọc cho trình đọc màn hình: "4 trên 5 sao". | "score" | AC-02, AC-62 |
| **Favorite** | Yêu thích | Cờ bật/tắt trên Recipe, dùng để lọc. | "bookmark", "pin" (để dành cho Pinned recipe) | AC-02, AC-13 |
| **Duplicate** | Nhân bản | Tạo Recipe mới chép toàn bộ nội dung một Recipe có sẵn (để làm biến thể), tên thêm "(bản sao)". | "copy" trong nghĩa sao lưu | AC-06 |
| **Trash** | Thùng rác | Nơi giữ Recipe đã xoá trong 30 ngày kể từ lúc xoá; khôi phục được; quá 30 ngày thì xoá hẳn cùng ảnh. Ngay sau khi xoá có thanh "Đã xóa · Hoàn tác" 5 giây. **Dọn sạch thùng rác** (Empty trash, hỏi xác nhận) xoá hẳn ngay mọi Recipe trong đó cùng ảnh. | "archive" | AC-05 |
| **Category** | Danh mục | Nhóm do người dùng đặt, lồng nhau tối đa 3 cấp ("Món chính > Món Việt > Món bún"). Recipe thuộc 0..n Category. Xoá Category xoá cả danh mục con nhưng không xoá Recipe. Lần mở đầu có 6 danh mục mặc định theo ngôn ngữ máy. Lọc theo Category gồm cả danh mục con. | "folder", "collection" | AC-10, AC-13 |
| **Tag** | Thẻ | Từ tự do gắn vào Recipe ("chay", "nồi chiên không dầu"), ≤ 40 ký tự, gõ thì gợi ý Tag đã có. Lọc theo nhiều Tag thì phải có đủ mọi Tag. | "label", "keyword" | AC-11, AC-13 |
| **Search** | Tìm kiếm | Tìm trong tên, nguyên liệu, các bước, ghi chú, nguồn; không phân biệt hoa thường và dấu tiếng Việt ("pho bo" ra "Phở bò"); mọi từ gõ vào phải khớp. Kết hợp được với Filter. | | AC-12 |
| **Filter** | Bộ lọc | Điều kiện thu hẹp danh sách: Category, Tag, số sao tối thiểu, chỉ Favorite, tổng thời gian tối đa, "có nguyên liệu X". Các bộ lọc cộng dồn (và). | | AC-13 |
| **Sort** | Sắp xếp | Thứ tự danh sách: tên, ngày thêm, ngày sửa, đánh giá, thời gian nấu, lần nấu gần nhất; tăng/giảm. Recipe thiếu giá trị luôn xếp cuối. | | AC-13 |
| **View mode** | Kiểu xem | Lưới ảnh hoặc dòng; được nhớ sau khi tắt app. | | AC-14 |
| **Cooked log** | Lịch sử nấu | Danh sách ngày người dùng bấm "Đánh dấu đã nấu" cho một Recipe. Từ đó có "số lần nấu" và "lần nấu gần nhất" (dùng để sắp xếp). | "history" chung chung | AC-15 |

## Nhập công thức

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **In-app browser** | Trình duyệt trong app | Trình duyệt dựng sẵn để tìm và mở trang công thức: thanh địa chỉ (gõ chữ thì tìm bằng công cụ tìm kiếm mặc định), Back/Forward, nút "Lưu công thức" luôn hiện. Cũng là nơi mở URL trong bước, ghi chú và URL nguồn của Recipe (không mở trình duyệt ngoài). Là nơi duy nhất app dùng mạng. Mở được cả trang `http`; khi đó thanh địa chỉ hiện nhãn "Không mã hóa" (AC-66). "Xóa toàn bộ dữ liệu" xóa luôn cookie và dữ liệu của trình duyệt này (AC-64). | "WebView" (trong giao diện) | AC-09, AC-16, AC-64, AC-65, AC-66 |
| **Web import** | Nhập từ web | Việc tạo Recipe từ một trang web: đọc dữ liệu schema.org `Recipe` nếu có, không có thì vào Pick text. Luôn qua Import preview. Mỗi lần tải trang chờ tối đa 20 giây; lỗi thì báo lý do + "Thử lại", không mất phần đã nhập. | "scrape", "crawl" | AC-18, AC-21 |
| **Shared link / Shared text** | Link / chữ được chia sẻ | Thứ app khác gửi sang Bepbook qua bảng chia sẻ của hệ điều hành (Android: intent; iOS: Share Extension). URL → Web import; chữ không phải URL → mở Recipe editor với chữ đó. | | AC-17 |
| **Pick text** | Chọn đoạn | Chế độ của In-app browser khi trang không có dữ liệu `Recipe`: người dùng bôi đen chữ trên trang rồi gán "Là tên", "Là nguyên liệu" hoặc "Là các bước". | "manual import" | AC-19 |
| **Import preview** | Xem trước khi lưu | Màn sửa bắt buộc trước khi Recipe nhập (từ web, ảnh, chữ chia sẻ) được lưu. Recipe nhập từ web giữ URL nguồn và tên trang. | | AC-20 |
| **Duplicate URL** | Trùng URL | Trường hợp URL nguồn đang nhập đã có ở một Recipe trong sổ, **kể cả Recipe đang ở Thùng rác**. App báo "Đã có công thức này" và hỏi mở bản cũ hay lưu bản mới; nếu bản cũ đang ở Thùng rác thì báo điều đó và hỏi khôi phục hay lưu bản mới. | "duplicate" (để dành cho Duplicate recipe) | AC-20 |
| **Scan** | Quét ảnh | Nhận chữ từ 1–10 ảnh (thư viện, hoặc app camera của hệ điều hành — không xin quyền camera) hoặc file PDF, chạy hoàn toàn trên máy, đọc tiếng Việt có dấu và tiếng Anh. Không cam kết độ chính xác với chữ viết tay. | "OCR" (trong giao diện) | AC-23, AC-25 |
| **Line assignment** | Gán dòng | Bước sau Scan: mỗi dòng chữ nhận được hiện riêng; người dùng chọn dòng rồi gán Tên / Nguyên liệu / Các bước / Ghi chú (hoặc bỏ), sửa chữ trước khi lưu, tuỳ chọn giữ ảnh gốc làm Photo. App gợi ý sẵn vai trò của từng dòng. | | AC-24 |
| **File import** | Nhập từ file | Nhập Recipe từ file: Paprika (`.paprikarecipes`), Recipe Keeper (`.zip`), JSON schema.org `Recipe`, `.cooknote`. Báo số nhập được, số đã có, số bị bỏ qua + lý do. Nhập lại cùng file không tạo bản trùng. | "sync" | AC-44, AC-45 |

## Nấu ăn

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **Cook mode** | Chế độ nấu | Cách xem một Recipe khi đang nấu: màn hình không tắt (chỉ khi đang ở chế độ này), chữ lớn chỉnh được, Current step nổi bật, chạm một dòng để Cross off. Giữ View transform (khẩu phần/đơn vị) đang xem ở màn xem công thức và đổi được ngay trong chế độ nấu. | "kitchen mode", "hands-free" | AC-26, AC-32 |
| **Cross off** | Gạch (dòng) | Đánh dấu một Ingredient line hoặc Step là đã xong trong Cook mode; chạm lần nữa thì bỏ gạch. Không chỉ phân biệt bằng màu; trình đọc màn hình đọc "đã gạch". | "check" (để dành cho Shopping item) | AC-26, AC-62 |
| **Cook progress** | Tiến độ nấu | Tập các dòng đã gạch của một Recipe. Giữ nguyên nếu vào lại Cook mode trong 12 giờ kể từ lần đổi cuối; quá 12 giờ thì bắt đầu lại. Không đi theo Backup. | | AC-26 |
| **Current step** | Bước đang làm | Step đầu tiên chưa bị gạch; được làm nổi bật trong Cook mode và là bước "Đọc bước" đọc. | "active step" | AC-26, AC-30 |
| **Step timer** | Hẹn giờ của bước | Hẹn giờ tạo từ thời lượng nhận ra trong chữ của Step ("nấu 15 phút", "1 tiếng 30 phút", "10-15 phút" → số lớn, "bake for 25 minutes"). Mang tên theo bước. Nhiều Step timer chạy cùng lúc. Hết giờ: chuông + thông báo kể cả khi app ở nền/máy khoá (lệch ≤ 2 giây) nếu có quyền thông báo; không có quyền thì chỉ báo khi app đang mở. Chỉ huỷ được (không tạm dừng, không cộng thêm phút). | "alarm", "countdown" | AC-27, AC-28 |
| **Pinned recipe** | Công thức đã ghim | Recipe đang nấu được ghim vào thanh đầu Cook mode để chuyển qua lại nhanh. Tối đa 5. | "favorite" | AC-29 |
| **Read step** | Đọc bước | Đọc to Current step bằng giọng đọc của hệ điều hành, theo ngôn ngữ của Recipe (không phải ngôn ngữ giao diện). Máy thiếu giọng đọc thì báo và hướng dẫn cài. | "voice control" (ngoài phạm vi) | AC-30 |
| **Servings** | Khẩu phần | Số + chữ đơn vị của Recipe ("4 người", "1 loaf", "24 cái"). | "portion" | AC-02 |
| **Scale factor** | Hệ số (nhân khẩu phần) | Số nhân áp lên mọi Structured ingredient khi xem: ½×, 2×, 3×, tự nhập (1,5 hoặc 1/2), hoặc suy ra từ khẩu phần mới. Chỉ để xem; không sửa Recipe gốc trừ khi bấm "Lưu theo khẩu phần này". Số hiện gọn (`1 1/2 cup`, `375 g`). | "multiplier" trong tài liệu (giao diện EN vẫn dùng "Multiplier") | AC-32 |
| **Unit system** | Hệ đơn vị | Gốc / Hệ mét / Hệ Mỹ. Đổi thể tích ↔ thể tích, khối lượng ↔ khối lượng, °C ↔ °F trong các bước. Không bao giờ đổi thể tích ↔ khối lượng. "Chén", "bát" không đổi. Có Unit system mặc định trong Cài đặt. | | AC-33, AC-58 |
| **View transform** | Cách xem (đã nhân/đổi) | Trạng thái xem một Recipe theo Scale factor và/hoặc Unit system khác gốc; luôn có dải báo "Công thức gốc không đổi" và nút "Về gốc". | | AC-32, AC-33 |

## Đi chợ

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **Shopping list** | Danh sách đi chợ | Một danh sách có tên do người dùng đặt ("Siêu thị", "Chợ"). Có nhiều danh sách. | "cart", "basket" | AC-34 |
| **Shopping item** | Món (cần mua) | Một dòng trong Shopping list: tên, số lượng (nếu có), Aisle, trạng thái đã mua, và các Recipe nó đến từ. Chạm để Check off. | "ingredient" (để dành cho Ingredient line) | AC-34, AC-35, AC-37 |
| **Check off** | Gạch (đã mua) | Đánh dấu Shopping item đã mua; món đã gạch xuống cuối danh sách. "Xóa các món đã gạch" xoá chúng, tuỳ chọn chuyển vào Pantry. | "cross off" (để dành cho Cook mode) | AC-37 |
| **Frequent item** | Món hay mua | Món có sẵn để thêm vào danh sách bằng một chạm. Gõ tên thì gợi ý từ các món đã từng thêm. | "favorite item" | AC-34 |
| **Add to shopping** | Thêm vào đi chợ | Đẩy nguyên liệu của một Recipe (theo khẩu phần đang xem) hoặc của mọi Recipe trong một khoảng ngày của Meal plan (theo Servings của từng Meal item) qua một bước chọn. Món đang có trong Pantry mặc định bỏ chọn. | "export" | AC-35, AC-40 |
| **Merge** (shopping) | Gộp món | Khi thêm, Shopping item trùng tên và cùng loại đơn vị (khối lượng, thể tích, đếm…) được cộng số lượng ("200 g thịt bò" + "300 g thịt bò" = "500 g thịt bò"); khác loại đơn vị thì để hai dòng. Item giữ danh sách Recipe nguồn. | "Merge" của Restore (nghĩa khác) | AC-35 |
| **Aisle** | Khu vực | Nhóm xếp món theo đường đi trong cửa hàng: mặc định Rau củ, Thịt cá, Sữa trứng, Đồ khô, Gia vị, Đông lạnh, Đồ uống, Khác. Món tự xếp theo từ điển VI/EN có sẵn; người dùng chuyển món sang khu vực khác thì app nhớ cho lần sau. Thêm, đổi tên, sắp xếp được. Pantry dùng chung bộ Aisle này. | "category" (để dành cho Category công thức), "section" | AC-36 |

## Thực đơn

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **Meal plan** | Lịch thực đơn | Lịch các ngày, mỗi ngày gồm các Meal slot, xem theo ngày/tuần/tháng. Ngày đầu tuần theo Cài đặt (Thứ Hai hoặc Chủ nhật). | "calendar" (trong code nên rõ là meal plan) | AC-38, AC-58 |
| **Meal slot** | Bữa | Một bữa trong ngày; mặc định Sáng, Trưa, Tối, Phụ; đổi tên, thêm, bớt được. Một Meal slot của một ngày chứa 0..n Meal item. | "meal" (dễ lẫn với món), "time slot" | AC-38 |
| **Meal item** | Món trong thực đơn | Một mục đặt vào một Meal slot của một ngày: hoặc một Recipe (kèm Servings riêng cho mục đó), hoặc một dòng chữ tự do ("Ăn ngoài"). Kéo được sang ngày/bữa khác. | "entry", "dish" | AC-38, AC-40 |
| **Menu template** | Thực đơn mẫu | Một bộ Meal item đặt tên được ("Cơm gia đình 4 món", "Tiệc sinh nhật"), mỗi mục gắn với vị trí ngày (Ngày 1…7) và Meal slot. Áp vào một ngày hoặc một tuần bằng một thao tác; mục không có cả Recipe lẫn chữ thì bỏ. Ngày/bữa đích đã có món thì hỏi **Thay thế** (bỏ món cũ ở các bữa mẫu điền vào) hay **Thêm vào** (giữ món cũ, thêm món mẫu bên cạnh). | "preset" | AC-39 |
| **Random suggestion** | Gợi ý ngẫu nhiên | Điền các Meal slot còn trống của một tuần bằng Recipe chọn ngẫu nhiên theo bộ lọc (Category, Tag, thời gian tối đa); không lặp một Recipe trong tuần nếu còn Recipe khác thoả bộ lọc. Luôn xem trước rồi mới áp. | "AI suggestion" (app không có AI) | AC-41 |

## Tủ bếp

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **Pantry** | Tủ bếp | Danh sách nguyên liệu người dùng đang có ở nhà. | "inventory", "fridge" | AC-42 |
| **Pantry item** | Món trong tủ bếp | Một dòng của Pantry: tên, số lượng (tuỳ chọn), Aisle, ngày mua, hạn dùng (tuỳ chọn). | | AC-42 |
| **Expiring soon** | Sắp hết hạn | Trạng thái của Pantry item còn từ 0 đến 3 ngày nữa tới hạn dùng. | "warning" | AC-42 |
| **Expired** | Hết hạn | Trạng thái của Pantry item đã qua hạn dùng. | | AC-42 |
| **Pantry match** | Độ khớp tủ bếp | Tỉ lệ Ingredient lines của một Recipe có trong Pantry (khớp tên không phân biệt dấu và số ít/số nhiều tiếng Anh), kèm "còn thiếu N món". Dùng để xếp hạng "Nấu được gì?". | "score" | AC-43 |
| **What can I cook?** | Nấu được gì? | Danh sách Recipe xếp theo Pantry match giảm dần. | | AC-43 |
| **Basic seasonings** | Gia vị cơ bản | Muối, đường, nước, tiêu, dầu ăn, nước mắm. Khi người dùng bật tuỳ chọn, chúng không bị tính là "thiếu" trong Pantry match. | "staples" | AC-43 |

## Chia sẻ, xuất, in

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **Share recipe** | Chia sẻ công thức | Gửi một Recipe qua bảng chia sẻ của hệ điều hành dạng chữ, file PDF, hoặc file `.cooknote` (người nhận có Bepbook nhập được). | | AC-46 |
| **Recipe book** | Sách công thức | File PDF tạo từ các Recipe đã chọn hoặc từ một Category: trang bìa (tên sách, ảnh), mục lục có số trang, mỗi Recipe bắt đầu ở trang mới với ảnh bìa. In được qua hộp thoại in của hệ điều hành. | "cookbook" trong giao diện EN vẫn được | AC-47 |
| **Export** | Xuất | Tạo file từ dữ liệu (JSON schema.org, `.cooknote`, PDF) để mang ra ngoài; không xin quyền bộ nhớ; file tạm xoá sau khi chia sẻ xong hoặc ở lần mở app sau. | "backup" (Export không phải Backup) | AC-45, AC-48 |

## Sao lưu và khôi phục

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **Backup** | Bản sao lưu | Một file `.cooknote` (gói zip định dạng mở, có tài liệu) chứa toàn bộ dữ liệu, ảnh và các trang HTML đọc được bằng trình duyệt không cần Bepbook. Không mã hoá. Chỉ tính là thành công sau khi đọc lại và kiểm mã băm đạt. | "sync", "export" | AC-49, AC-51 |
| **Backup format version** | Phiên bản định dạng | Số phiên bản ghi trong file. Định dạng chỉ được mở rộng: mọi bản app sau đọc được file của mọi phiên bản cũ hơn. | | AC-55 |
| **Automatic backup** | Sao lưu tự động | Sao lưu tự ghi vào Auto-backup folder theo chu kỳ hằng ngày (mặc định) hoặc hằng tuần, chạy lúc mở app hoặc lúc app vào nền, chỉ khi đã quá chu kỳ VÀ dữ liệu có thay đổi; không làm chậm thao tác. | "cloud sync" | AC-50 |
| **Auto-backup folder** | Thư mục sao lưu tự động | Thư mục đích người dùng chọn MỘT lần qua trình chọn thư mục của hệ điều hành (trên máy, hoặc Google Drive/OneDrive/iCloud Drive nếu ứng dụng đó cho phép). Trên iPhone chọn bằng `UIDocumentPicker` và app giữ security-scoped bookmark. Mất quyền ghi hoặc bookmark hỏng/hết hạn thì hiện cảnh báo trên màn Công thức và nút chọn lại. | "cloud", "account" | AC-50, AC-51, AC-67 |
| **Rotation** (copies to keep) | Xoay vòng (số bản giữ lại) | Trong Auto-backup folder chỉ giữ N bản gần nhất (mặc định 5, đổi được 1–30); bản cũ hơn tự xoá. App chỉ xoá file do chính nó tạo. | | AC-50 |
| **Verification** | Kiểm tra sau sao lưu | Đọc lại file vừa ghi và kiểm mã băm từng phần. Sai thì báo lỗi và không tính là lần sao lưu thành công. | | AC-51 |
| **Back up now (save elsewhere)** | Sao lưu ngay (lưu ở nơi khác) | Tạo Backup rồi mở bảng chia sẻ/trình lưu file để lưu vào bất kỳ đâu. Đường dự phòng khi nơi lưu không cho sao lưu tự động. | | AC-52 |
| **Last successful backup** | Lần sao lưu thành công gần nhất | Thời điểm, nơi lưu, dung lượng của Backup gần nhất đã qua Verification (tự động hay bằng tay). Là căn cứ của Backup reminder. | "last backup attempt" (lần thử có thể lỗi) | AC-53 |
| **Backup reminder** | Nhắc sao lưu | Nhắc trong app (không dùng thông báo hệ thống) khi quá 7 ngày (đổi được ở màn Sao lưu) chưa có Last successful backup. Khác với **Backup suggestion**: gợi ý bật Automatic backup đúng một lần khi sổ đạt 10 công thức. | "notification" | AC-53 |
| **Restore** | Khôi phục | Đưa dữ liệu từ một Backup vào app. Kiểm định dạng, phiên bản, mã băm TRƯỚC khi đụng dữ liệu; file hỏng thì báo lỗi và giữ nguyên dữ liệu. Hai cách: **Replace** (Thay thế toàn bộ — hỏi xác nhận, app tự tạo một bản sao lưu dữ liệu hiện tại trước) và **Merge** (Gộp — chỉ thêm Recipe chưa có, không đụng Recipe đã có). | "import" (File import là việc khác) | AC-54 |
| **OS backup layer** | Lớp sao lưu của hệ điều hành | Android Auto Backup (cơ sở dữ liệu và cài đặt, không có ảnh) hoặc sao lưu iCloud của iPhone. Lớp phụ, không bảo đảm có ảnh, không thay được Backup. | "sao lưu chính" | AC-56 |

## App, quyền riêng tư

| Term (code) | VI | Định nghĩa | Tránh dùng | AC |
|---|---|---|---|---|
| **Onboarding** | Màn chào | Tối đa 3 trang ở lần mở đầu, bỏ qua được, không xin quyền nào; nói dữ liệu chỉ nằm trên máy và cần bật sao lưu, có nút "Bật sao lưu tự động". | "tutorial", "sign up" | AC-59 |
| **Settings** | Cài đặt | Giao diện (sáng/tối/hệ thống), ngôn ngữ (vi/en/hệ thống), ngày đầu tuần, Unit system mặc định, và "Xóa toàn bộ dữ liệu". | | AC-58, AC-64 |
| **Delete all data** | Xóa toàn bộ dữ liệu | Xoá cơ sở dữ liệu, ảnh và cài đặt sau khi hỏi có muốn sao lưu trước và hai bước xác nhận. Không xoá Backup ở thư mục ngoài. Mở lại app thì như mới cài. | "reset", "delete account" (không có tài khoản) | AC-64 |
| **About** | Giới thiệu | Màn có phiên bản, liên kết chính sách quyền riêng tư, email liên hệ và báo lỗi bảo mật (phamphuongphuongnd@gmail.com), danh sách giấy phép nguồn mở, và câu nhắc công thức nhập từ web thuộc bản quyền tác giả, chỉ dùng cá nhân. | | AC-63 |
