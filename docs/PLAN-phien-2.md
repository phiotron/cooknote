# A004 Bepbook — kế hoạch phiên điều phối #2 (áp UI Hi-Fi + đủ tính năng)

> Lập 2026-11-05. Nguồn UI: `design/hifi/` (945 khung, 65 số SCR/EXT, `_frames.json` có AC + ghi chú + `COPY:` từng khung; HTML mở
> bằng trình duyệt cho màu/cỡ chính xác, PNG chỉ ở máy). Hành vi: `docs/SPEC.md`, mô tả màn: `product.md`. Đọc file chữ trước, KHÔNG mở ảnh.

## Hiện trạng code (đã đo 2026-11-05)
- **Có UI cũ (Material mặc định):** danh sách/lọc, xem/soạn công thức, ảnh, thùng rác, danh mục, trình duyệt web + chia sẻ vào, nhập file,
  sao lưu, cài đặt. 5 tab dưới chưa có (router hiện chỉ có `/` + các trang con).
- **Có data + logic, CHƯA có UI:** Chế độ nấu (`lib/src/cook/`, `cooking/`), Đi chợ (`shopping/` + `data/shopping_repository.dart`),
  Thực đơn (`menu/`, `meal_plan_repository.dart`), Tủ bếp + "Nấu được gì?" (`pantry/`), Quét ảnh (`scan/` + engine Android).
- DB v3 + sao lưu v2 đã đủ bảng. Nên mỗi nhóm màn mới chỉ là UI + provider mỏng trên repository có sẵn.

## Phiên con (F0 chạy một mình, sau đó các nhóm song song theo ngân sách)
| Mã | Việc | Màn (SCR/EXT) | Thư mục được sửa |
|---|---|---|---|
| **F0** | Design system: token → `ThemeData` sáng/tối, font Lora + Noto Sans, icon, component dùng chung, **khung 5 tab + router khai sẵn mọi route (stub từng màn)**, đổi tên Bepbook trong `.arb`/manifest/Info.plist + chuỗi mới, icon app + splash | 00, 57, nền của mọi màn | `lib/src/ui/`, `lib/src/app.dart`, `lib/l10n/`, `pubspec.yaml` (font/asset), `assets/`, `android/…/res`, `ios/Runner` |
| **G1** Công thức | danh sách, thêm, lọc, sắp xếp, chọn nhiều, xem, khẩu phần/đơn vị, chia sẻ ra, ảnh, soạn, danh mục, thùng rác, nhắc sao lưu | 02–14, 51 | `features/home`, `recipes`, `editor`, `categories` |
| **G2** Đưa công thức vào | trình duyệt web + xem trước, chia sẻ vào, quét ảnh + gán dòng, nhập file; AC-64 xoá dữ liệu WebView, AC-66 cảnh báo http | 15–22, EXT-02 | `features/web_import`, `exchange` (nhập), `features/scan` (mới) |
| **G3** Chế độ nấu | tab Nguyên liệu/Các bước, hẹn giờ + khay, ghim, đọc bước, thông báo, pill hẹn giờ | 23–26, EXT-01 | `lib/src/cook/`, `features/cook` (mới) |
| **G4** Đi chợ | danh sách, khu vực, thêm từ công thức, mục, dọn xong, chia sẻ | 27–33 | `features/shopping` (mới) |
| **G5** Thực đơn + Tủ bếp | tuần/ngày/tháng, ô bữa, mẫu, ngẫu nhiên, đi chợ theo khoảng; tủ bếp, "Nấu được gì?" | 34–45 | `features/menu`, `features/pantry` (mới) |
| **G6** Thêm + sao lưu + hệ thống | màn chào, tab Thêm, sao lưu/khôi phục (+ **AC-67 iOS thư mục + bookmark**), xuất/PDF sách, cài đặt, xoá toàn bộ, giới thiệu, giấy phép | 01, 46–56, EXT-04..06 | `features/backup`, `settings`, `onboarding`, `more` (mới), `exchange` (xuất), `cookbook` |
| **H** | so với mockup, thử trợ năng (S-50), build Android + iOS xanh, ảnh store | — | `notes/`, `store/`, lỗi nhỏ |

- Điểm nối giữa nhóm (chi tiết công thức → nấu / đi chợ / thêm vào thực đơn): F0 khai sẵn **stub có chữ ký cố định**; nhóm chỉ thay
  ruột trong thư mục của mình, không sửa `app.dart`. Nhóm cần route/provider mới → báo điều phối.
- **Thứ tự cắt sang v1.1 nếu thiếu hạn mức (D-008):** (1) nhập Paprika/RK → (2) OCR → (3) Tủ bếp → (4) Thực đơn.
- Hạn mức (2026-11-05): 5 giờ 72%, tuần 78% → F0 chạy một mình; mở G theo từng đợt ≤ 3 phiên cùng lúc.
