# BACKUP-FORMAT — định dạng file sao lưu `.cooknote`

Tài liệu này mô tả định dạng để dữ liệu còn đọc được dù CookNote không còn nữa (SPEC F-11, AC-49). Mã đọc và ghi nằm ở `lib/src/backup/`.

## Nguyên tắc (AC-55)
- Định dạng chỉ được MỞ RỘNG: thêm khóa mới, thêm file mới. Không đổi nghĩa, không xóa khóa đã phát hành.
- Mọi phiên bản app đọc được file của mọi phiên bản định dạng cũ hơn. `test/fixtures/` giữ một file mẫu cho mỗi phiên bản đã phát hành và `test/backup/format_compat_test.dart` khôi phục tất cả các file đó. KHÔNG sửa hay xóa file mẫu cũ.
- File do phiên bản định dạng MỚI hơn app đang chạy tạo ra thì app từ chối và báo cần cập nhật, không đọc dở.
- Phiên bản hiện tại: `formatVersion` = 1.

## Cấu trúc
File là một gói zip (đổi đuôi `.cooknote` thành `.zip` rồi giải nén là xem được):

| Đường dẫn | Nội dung |
|---|---|
| `manifest.json` | Phiên bản định dạng, phiên bản app, thời điểm tạo, số lượng, mã băm SHA-256 của từng file khác |
| `data.json` | Toàn bộ dữ liệu dạng JSON thuần |
| `images/<tên>.jpg` | Ảnh của công thức. Tên do app đặt, chỉ gồm chữ, số, `_`, `.`, `-` |
| `html/index.html`, `html/<id>.html` | Bản đọc được bằng trình duyệt bất kỳ, không cần CookNote. Chỉ gồm công thức chưa xóa |
| `README.txt` | Hướng dẫn hai ngôn ngữ |

### manifest.json
```json
{
  "app": "CookNote",
  "formatVersion": 1,
  "appVersion": "1.0.0+1",
  "createdAt": "2026-11-04T03:00:00.000Z",
  "counts": { "recipes": 2, "photos": 1, "categories": 2 },
  "files": { "data.json": "<sha256>", "images/<tên>.jpg": "<sha256>" }
}
```
`files` liệt kê mọi file cần kiểm (trừ chính manifest, README và html). Khi đọc: mọi file khai ở đây phải có trong gói và đúng mã băm.

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
- Chỉ ba khóa `settings` đi theo: `locale`, `themeMode`, `viewMode`. Cài đặt của chính tính năng sao lưu (thư mục, chu kỳ) KHÔNG đi theo: đổi máy thì chọn lại.
- Khi đọc, khóa lạ bị bỏ qua. Các giai đoạn sau thêm khóa mới (danh sách đi chợ, thực đơn, tủ bếp...) mà không đổi `formatVersion`, trừ khi đổi nghĩa khóa cũ (không được phép).

## Khôi phục
Thứ tự (AC-54): đọc lại và kiểm mã băm toàn bộ file TRƯỚC; chỉ khi tốt mới chép ảnh vào thư mục của app; nạp dữ liệu trong MỘT giao dịch cơ sở dữ liệu; dọn ảnh không còn công thức nào dùng.
- **Thay thế toàn bộ**: xóa dữ liệu hiện có rồi nạp, giữ nguyên `id`. CookNote tự lưu một bản dữ liệu hiện tại trước (giữ 2 bản gần nhất).
- **Gộp**: chỉ thêm công thức chưa có. "Đã có" nghĩa là cùng tên (không phân biệt hoa thường và dấu) và cùng thời điểm tạo (tính tới giây). Danh mục trùng đường dẫn tên (ví dụ `Món chính › Món Việt`) dùng lại, chưa có thì tạo.

## Mã hóa
File KHÔNG được mã hóa. Ai có file đều đọc được công thức và ảnh. Mã hóa bằng mật khẩu nằm trong Ý tưởng của BACKLOG.

## Tạo bằng tay (ví dụ không dùng CookNote)
Giải nén, mở `html/index.html` để đọc và in. Hoặc đọc `data.json` bằng bất kỳ công cụ JSON nào; ảnh nằm trong `images/`.
