# ARCHITECTURE — CookNote (APP-005)

Mô tả app HIỆN ĐANG như thế nào (DECISIONS.md ghi VÌ SAO chọn). Cập nhật khi cấu trúc đổi. Giữ ngắn.

## Tổng quan
Flutter, Android, chạy hoàn toàn trên máy. Màn hình đọc dữ liệu qua Riverpod từ các kho (`RecipeRepository`, `SettingsRepository`) bọc cơ sở dữ liệu drift/SQLite; ảnh nằm ở `ImageStore` (thư mục `photos/` trong bộ nhớ riêng của app). Chưa có mạng (F-03 ở G4). Tình trạng: xong G3.

## Màn hình và điều hướng
`/` Home (5 mục dưới: Công thức, Thực đơn, Đi chợ, Tủ bếp, Thêm; ba mục giữa là chỗ giữ chỗ tới G6, G7) → `/categories` quản lý danh mục → `/recipe/new` soạn mới → `/recipe/:id` xem → `/recipe/:id/edit` sửa, `/recipe/:id/photos?index=` xem ảnh toàn màn hình. Từ mục Thêm: `/backup` (sao lưu và khôi phục), `/trash`, `/settings`.

## Dữ liệu
SQLite qua drift, `schemaVersion` 2: `recipes` (có `searchKey`, `ingredientsKey`), `recipe_lines`, `recipe_photos`, `categories`, `recipe_categories`, `recipe_tags`, `cook_log`, `settings` (D-005, D-006). Thùng rác là `deletedAt`. Ảnh là file JPEG, bảng chỉ giữ tên. Migration 1→2 có test.

## Tích hợp ngoài
`image_picker` (thư viện ảnh và ứng dụng camera của hệ điều hành), `url_launcher` (mở liên kết), `saf_util` và `saf_stream` (thư mục sao lưu qua Storage Access Framework), `file_picker`, `share_plus`, `archive`, `crypto`. Không khóa, không biến môi trường, không dịch vụ.

## Cấu trúc thư mục code
`lib/src/data/` (database, recipe_repository, recipe_query, category_repository, text_normalize, recipe_lines, image_store, settings_repository), `lib/src/backup/` (backup_format: tạo, kiểm, khôi phục file; backup_data: xuất/nhập JSON; backup_target: nơi lưu; backup_settings: cấu hình và nhắc; backup_service: tự sao lưu, xoay vòng, khôi phục có bản an toàn), `lib/src/features/{home,recipes,editor,categories,backup,settings}/`, `lib/src/ui/` (recipe_photo, linkified_text, messenger), `lib/src/providers.dart`, `lib/src/app.dart`, `lib/l10n/`. Test ở `test/` phản chiếu cấu trúc đó.

## Điểm cần cẩn thận
- `imageStoreProvider` không có giá trị mặc định: `main()` và test phải ghi đè.
- Lưu công thức xóa và ghi lại toàn bộ dòng và ảnh trong một giao dịch; file ảnh bị gỡ chỉ xóa sau khi giao dịch xong.
- Soạn công thức: ảnh vừa thêm đã vào thư mục ngay; bỏ thay đổi thì xóa chúng, bị kill giữa chừng thì `startupProvider` dọn ở lần mở sau.
- Định dạng sao lưu chỉ được mở rộng (docs/BACKUP-FORMAT.md). Bảng hoặc cột mới phải vào `exportData`/`importData` và có file mẫu mới trong `test/fixtures/`.
- Widget test có sao lưu: hàm chờ phải `pump(Duration)` (thời gian giả); đặt cấu hình sao lưu trong cơ sở dữ liệu TRƯỚC khi dựng app (nhiều lần ghi liền nhau trong một `runAsync` khi widget đang theo dõi luồng sẽ treo).
- Chỉ mục tìm kiếm chỉ có khi công thức đi qua `RecipeRepository.save`; ghi thẳng bảng `recipes` thì tìm không ra (D-006).
- Đổi bảng: tăng `schemaVersion`, viết `onUpgrade`, thêm test như `migration_test.dart`.
- `*.g.dart` sinh bằng build_runner và được commit; hook chặn sửa tay.
