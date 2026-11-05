# BACKUP-FORMAT — định dạng file sao lưu `.cooknote`

> Từ 2026-11-05 (D-010) app tên **Bepbook**, nhưng định dạng, đuôi `.cooknote`, trường `"app": "CookNote"` trong `manifest.json` và mẫu tên `CookNote-YYYY-MM-DD-HHmmss.cooknote` GIỮ NGUYÊN để mọi file sao lưu cũ vẫn đọc được (AC-55). Định dạng giống hệt nhau trên Android và iPhone; chỉ cách chọn nơi lưu khác nhau (AC-50, AC-67).

Tài liệu này mô tả định dạng để dữ liệu còn đọc được dù Bepbook không còn nữa (SPEC F-11, AC-49). Mã đọc và ghi nằm ở `lib/src/backup/`.

## Nguyên tắc (AC-55)
- Định dạng chỉ được MỞ RỘNG: thêm khóa mới, thêm file mới. Không đổi nghĩa, không xóa khóa đã phát hành.
- Mọi phiên bản app đọc được file của mọi phiên bản định dạng cũ hơn. `test/fixtures/` giữ một file mẫu cho mỗi phiên bản đã phát hành và `test/backup/format_compat_test.dart` khôi phục tất cả các file đó. KHÔNG sửa hay xóa file mẫu cũ.
- File do phiên bản định dạng MỚI hơn app đang chạy tạo ra thì app từ chối và báo cần cập nhật, không đọc dở.
- Phiên bản hiện tại: `formatVersion` = 2 (2026-11-05). File mẫu: `test/fixtures/backup_v1.cooknote`, `test/fixtures/backup_v2.cooknote`.
- Khi nào tăng `formatVersion`: khi thêm một NHÓM dữ liệu mà app cũ đọc file mới sẽ làm mất âm thầm lúc "Thay thế toàn bộ" (app cũ bỏ qua khóa lạ, rồi xóa dữ liệu đó trên máy). Tăng số thì app cũ từ chối file và báo cần cập nhật thay vì làm mất. Thêm một khóa phụ trong nhóm đã có thì không cần tăng.

| `formatVersion` | Ngày | Thêm gì |
|---|---|---|
| 1 | 2026-11-04 | Công thức, danh mục, thẻ, lịch sử nấu, ảnh, 3 khóa cài đặt |
| 2 | 2026-11-05 | Khu vực, danh sách đi chợ, món đã biết, tủ bếp, bữa, lịch thực đơn, thực đơn mẫu, 4 khóa cài đặt (F-07, F-08, F-09, AC-58) |

## Cấu trúc
File là một gói zip (đổi đuôi `.cooknote` thành `.zip` rồi giải nén là xem được):

| Đường dẫn | Nội dung |
|---|---|
| `manifest.json` | Phiên bản định dạng, phiên bản app, thời điểm tạo, số lượng, mã băm SHA-256 của từng file khác |
| `data.json` | Toàn bộ dữ liệu dạng JSON thuần |
| `images/<tên>.jpg` | Ảnh của công thức. Tên do app đặt, chỉ gồm chữ, số, `_`, `.`, `-` |
| `html/index.html`, `html/<id>.html` | Bản đọc được bằng trình duyệt bất kỳ, không cần Bepbook. Chỉ gồm công thức chưa xóa |
| `README.txt` | Hướng dẫn hai ngôn ngữ |

### manifest.json
```json
{
  "app": "CookNote",
  "formatVersion": 2,
  "appVersion": "1.0.0+1",
  "createdAt": "2026-11-05T03:00:00.000Z",
  "counts": { "recipes": 2, "photos": 1, "categories": 2,
              "shoppingItems": 3, "pantry": 2, "mealPlan": 2, "menuTemplates": 1 },
  "files": { "data.json": "<sha256>", "images/<tên>.jpg": "<sha256>" }
}
```
`files` liệt kê mọi file cần kiểm (trừ chính manifest, README và html). Khi đọc: mọi file khai ở đây phải có trong gói và đúng mã băm. Bốn số đếm cuối có từ định dạng 2, chỉ để người đọc biết; app không dựa vào chúng.

### data.json (formatVersion 1)
```json
{
  "recipes": [{
    "id": 1, "name": "...", "servings": 4.0, "servingsUnit": "người",
    "prepMinutes": null, "cookMinutes": null, "totalMinutes": 240,
    "source": null, "sourceUrl": null, "notes": null, "nutrition": null,
    "difficulty": "hard",
    "rating": 5, "favorite": true,
    "createdAt": "ISO 8601 UTC", "updatedAt": "ISO 8601 UTC", "deletedAt": null,
    "ingredients": [{ "text": "Nước dùng", "heading": true }, { "text": "2 kg xương bò", "heading": false }],
    "steps": [{ "text": "Chần xương", "heading": false }],
    "photos": ["tên-file.jpg"],
    "categoryIds": [3],
    "tags": ["bò", "Nước dùng"],
    "cooked": ["ISO 8601 UTC"]
  }],
  "categories": [{ "id": 3, "name": "Món Việt", "parentId": 2, "position": 0 }],
  "settings": { "locale": "vi", "themeMode": "dark", "viewMode": "grid" }
}
```
- `difficulty`: `easy`, `medium`, `hard` hoặc `null`. `deletedAt` khác null là công thức trong thùng rác.
- Thứ tự `ingredients`, `steps`, `photos` là thứ tự hiển thị; ảnh đầu tiên là ảnh bìa.
- `categories.parentId` null là cấp đầu; tối đa 3 cấp.
- Chỉ ba khóa `settings` đi theo: `locale`, `themeMode`, `viewMode`. Cài đặt của chính tính năng sao lưu (thư mục, chu kỳ) KHÔNG đi theo: đổi máy thì chọn lại. Trên iPhone điều này gồm cả security-scoped bookmark của thư mục (D-010, AC-67): bookmark chỉ có nghĩa trên chính máy đã tạo ra nó nên không bao giờ được ghi vào file sao lưu.
- Khi đọc, khóa lạ bị bỏ qua.

### data.json — phần thêm ở formatVersion 2
Mọi khóa của định dạng 1 giữ nguyên nghĩa. Thêm 7 khóa cấp đầu và 4 khóa `settings`:
```json
{
  "aisles": [{ "id": 1, "key": "produce", "name": "Rau củ", "position": 0 }],
  "shoppingLists": [{
    "id": 1, "name": "Đi chợ", "position": 0, "createdAt": "ISO 8601 UTC",
    "items": [{
      "name": "xương bò", "quantity": 1.0, "unit": "kg", "unitText": "kg",
      "amountText": null, "note": null, "aisleId": 2,
      "checked": false, "checkedAt": null, "position": 0,
      "sources": [{ "recipeId": 1, "recipeName": "Phở bò" }]
    }]
  }],
  "knownItems": [{ "name": "đậu hũ", "aisleId": 4, "useCount": 1, "lastUsedAt": "ISO 8601 UTC",
                   "favorite": false, "favoritePosition": 0 }],
  "pantry": [{ "name": "gạo", "quantity": 5.0, "unit": "kg", "unitText": "kg", "amountText": null,
               "aisleId": 4, "purchasedOn": "2026-11-05", "expiresOn": null, "createdAt": "ISO 8601 UTC" }],
  "mealSlots": [{ "id": 1, "key": "breakfast", "name": "Sáng", "position": 0 }],
  "mealPlan": [{ "date": "2026-11-05", "slotId": 2, "recipeId": 1, "text": null, "servings": 2.0, "position": 0 }],
  "menuTemplates": [{
    "id": 1, "name": "Cơm nhà", "position": 0, "createdAt": "ISO 8601 UTC",
    "entries": [{ "dayOffset": 0, "slotId": 3, "recipeId": 1, "text": null, "servings": null, "position": 0 }]
  }],
  "settings": { "...": "...", "weekStart": "sunday", "unitSystem": "us", "ignoreBasics": "1", "shoppingToPantry": "0" }
}
```
- `aisles`: khu vực trong cửa hàng, theo `position` (đường đi trong cửa hàng). `key` là khóa khu vực mặc định (`produce`, `meat`, `dairy`, `dry`, `spice`, `frozen`, `drink`, `other`) hoặc `null` với khu vực người dùng thêm; đổi tên không đổi `key`.
- Món đi chợ và tủ bếp: số lượng có cấu trúc là `quantity` + `unit` (tên đơn vị chuẩn của Bepbook: `g`, `kg`, `mg`, `ml`, `l`, `tbsp`, `tsp`, `spoon`, `cup`, `oz`, `lb`, `flOz`, `pint`, `quart`, `chen`, `bat`, `cu`, `qua`, `trai`, `tep`, `nhanh`, `lat`, `mieng`, `goi`, `lon`, `hop`, `nhum`, `chut`, `nam`, `bo`; `null` là đếm không đơn vị) + `unitText` (chữ đơn vị người dùng viết, để hiện). Không tách được số lượng thì `quantity` null và `amountText` là chữ tự do ("1 bó nhỏ"). Cả hai null là không ghi số lượng. `aisleId` null là không khu vực.
- `sources`: công thức mà món đi chợ đến từ; `recipeId` null khi công thức đã bị xóa hẳn (tên vẫn giữ).
- `knownItems`: mỗi tên món đã từng thêm vào đi chợ (khóa so khớp tính lại từ `name` khi đọc): gợi ý khi gõ, "Món hay mua" (`favorite`), và khu vực người dùng đã chọn cho tên đó (`aisleId`; null là theo từ điển).
- Ngày lịch (`purchasedOn`, `expiresOn`, `mealPlan.date`) là chữ `YYYY-MM-DD` theo giờ địa phương, không phải thời điểm, để không lệch ngày khi đổi múi giờ. Sai dạng thì file bị coi là hỏng.
- `mealPlan` và `menuTemplates.entries`: có `recipeId` HOẶC `text` (chữ tự do như "Ăn ngoài"). `servings` null là khẩu phần gốc của công thức. `dayOffset` 0 là ngày áp mẫu.
- `settings.weekStart`: `monday`, `saturday`, `sunday`. `unitSystem`: `metric`, `us`. `ignoreBasics`, `shoppingToPantry`: `"1"` hoặc `"0"`.

## Khôi phục
Thứ tự (AC-54): đọc lại và kiểm mã băm toàn bộ file TRƯỚC; chỉ khi tốt mới chép ảnh vào thư mục của app; nạp dữ liệu trong MỘT giao dịch cơ sở dữ liệu; dọn ảnh không còn công thức nào dùng.
- **Thay thế toàn bộ**: xóa dữ liệu hiện có rồi nạp, giữ nguyên `id`. Bepbook tự lưu một bản dữ liệu hiện tại trước (giữ 2 bản gần nhất).
  - Danh sách đi chợ, món đã biết, tủ bếp, lịch thực đơn, thực đơn mẫu trên máy LUÔN bị xóa, kể cả khi file là định dạng 1 (không có các khóa đó).
  - Khu vực và bữa là cấu hình: file có khóa `aisles`/`mealSlots` thì thay bằng của file; file định dạng 1 không có thì giữ khu vực và bữa đang có.
  - Tham chiếu tới khu vực không có thì món thành "không khu vực"; món lịch/mẫu trỏ tới bữa hoặc công thức không có thì bị bỏ (không làm hỏng cả lần khôi phục).
- **Gộp**: chỉ thêm công thức chưa có. "Đã có" nghĩa là cùng tên (không phân biệt hoa thường và dấu) và cùng thời điểm tạo (tính tới giây). Danh mục trùng đường dẫn tên (ví dụ `Món chính › Món Việt`) dùng lại, chưa có thì tạo. Đi chợ, tủ bếp, lịch, mẫu, khu vực, bữa trên máy giữ nguyên; phần đó trong file bị bỏ qua.

## Mã hóa
File KHÔNG được mã hóa. Ai có file đều đọc được công thức và ảnh. Mã hóa bằng mật khẩu nằm trong mục Ý tưởng của `MANUAL-TESTS.md`.

## Tạo bằng tay (ví dụ không dùng Bepbook)
Giải nén, mở `html/index.html` để đọc và in. Hoặc đọc `data.json` bằng bất kỳ công cụ JSON nào; ảnh nằm trong `images/`.
