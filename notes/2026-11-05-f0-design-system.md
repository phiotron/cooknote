# [A004-cooknote] F0 — design system + khung 5 tab (phiên con, 2026-11-05)

> Người đọc chính: phiên điều phối #2 và các phiên G1..G6. **Mỗi nhóm chỉ cần đọc §1 (nền chung) + phần của mình ở §3.**
> Quyết định đã chốt ở F0 nằm ở §6.

## 1. Nền chung (ai cũng dùng)

### 1.1 Cách dùng design system
```dart
import '../../ui/ui.dart';   // MỘT cửa vào: theme + token + component + minh hoạ + helper hộp thoại
```
| Cần | Dùng |
|---|---|
| Màu ngữ nghĩa (success/warning/info, crossedOff, currentStep, timerActive, expiring, ribbon, cookSurface, ảnh thay thế…) | `context.bep.success` … (`CookNoteColors`, ThemeExtension — **giữ tên `CookNoteColors`**, khớp 1:1 token/mockup) |
| Màu chung | `Theme.of(context).colorScheme` (đã là token Hi-Fi; **không** `Colors.xxx` / `fromSeed` nữa) |
| Kiểu chữ | `Theme.of(context).textTheme` (Lora = display/headline/titleLarge; Noto Sans còn lại). Chữ nấu: `CookTextStyles.of(context).cookStep / cookStepCurrent / cookIngredient / timer / timerLarge`; nhân cỡ trong app: `CookTextStyles.scaled(style, CookTextStyles.sizeSteps[i])` |
| Số cùng bề rộng (lượng, giờ) | `style.tabular` |
| Khoảng cách/bo/vùng chạm/chuyển động | `BepSpace.s1..s12`, `BepRadius.xs..full`, `BepTap.min(48)/ios(44)/cook(64)`, `BepMotion.short/medium/long`, `BepMotion.of(context)` (=0 khi giảm chuyển động) |
| Nút | `BepButton(label, onPressed, kind: filled\|tonal\|outlined\|text\|danger\|dangerText, size: standard(48)\|big(56)\|cook(64), icon, block)` — hoặc Material trực tiếp, đã cấu hình trong theme (≥ 48 dp) |
| Thẻ trạng thái nhỏ (hạn dùng, gợi ý, "Không mã hóa") | `BepTag(label, tone: ok\|warn\|bad\|info\|neutral\|suggested)` — luôn có icon + chữ |
| Ảnh công thức / chưa có ảnh | `PhotoPlaceholder(title, categoryLabel)` (index-card, 8 màu theo tên); `PhotoFrame(photo, overlay)` + `PhotoScrim` (chữ trên ảnh phải có scrim); `RibbonBookmark` (ghim/yêu thích). `RecipePhoto` cũ vẫn dùng được (ô xám) — G1 nên thay bằng `PhotoPlaceholder` |
| Thẻ lưới / dòng danh sách | `RecipeCard(cover, title, meta, bookmarked, selected, onTap, onLongPress)`, `RecipeRow(...)` (ảnh 72 dp, cao ≥ 72, 2 dòng tên); `StarRating(value, size, onChanged)` (đọc "4 trên 5 sao") |
| Tiêu đề nhóm kiểu tab sổ tay | `NotebookTabHeader(title, count)` |
| Trạng thái rỗng | `EmptyState(illustration: BepIllo.empty\|collect\|keep\|basket\|calendar\|jar\|kitchen, title, body, actions)` — cuộn được, ổn ở 200% |
| Hộp thoại xác nhận | `await showConfirmDialog(context, title, body, confirmLabel, cancelLabel, destructive)` → bool |
| Thanh thông báo | `showBepSnackBar(msg, actionLabel, onAction)`; `showUndoSnackBar` / `showMessage` (messenger.dart cũ) — cả ba tự **nâng lên** khi có pill hẹn giờ (`snackBarLift`) |
| Bảng đáy | `showBepSheet(context, builder:)` (bo 28, tay nắm, cuộn được, né bàn phím) |
| Hộp trạng thái sao lưu | `BackupStatusCard(status: safe\|overdue\|failing\|notSetUp, body, actions)` (từ + icon + màu; "An toàn" chỉ khi bản gần nhất đã kiểm lại) |
| Thanh dưới 5 mục | `BepNavigationBar` (đã gắn trong khung — màn **không** tự dựng) |
| Màn giữ chỗ | `StubScreen` (chỉ stub của F0) |

**Luật cho nhóm:** không viết `Scaffold` chứa thanh dưới; gốc tab trả về `Scaffold(appBar, body, floatingActionButton)` bình thường — khung tự đặt thanh dưới bên ngoài. Màu/cỡ cứng (`Color(0x…)`, `fontSize: 17`) chỉ khi token không có; ưu tiên `context.bep`/textTheme.

### 1.2 Pill hẹn giờ + snackbar
`app.dart` bọc cả app bằng `TimerAlertHost` (đã có) + `RunningTimerPill`: hiện khi `timersProvider.running` không rỗng, ở **mọi** màn trừ `/cook/*`; trên gốc tab thì nằm trên thanh dưới, màn khác thì sát đáy. Chạm → `router.push('/cook/<recipeId của hẹn giờ gần nhất>')`. Một hẹn giờ: "tên · mm:ss"; nhiều: "N hẹn giờ · mm:ss". **G3 không cần dựng lại pill**; chỉ cần Chế độ nấu có khay hẹn giờ riêng (SCR-24) và đừng hiện pill bên trong (đã ẩn theo đường dẫn `/cook/`).

## 2. Bảng route (đã khai đủ SCR 00–56 — `lib/src/router.dart`, nhóm KHÔNG sửa file này; cần route/provider mới → báo điều phối)

Back: hệ thống/iOS chevron; màn con của tab khai `parentNavigatorKey = navigator gốc` nên **phủ kín, không có thanh dưới** (§4.3). Gốc tab giữ ngăn xếp riêng (StatefulShellRoute); Back hệ thống ở tab khác → về tab Công thức.

| Route | SCR | Lớp (file) | Nhóm | Trạng thái | Tham số |
|---|---|---|---|---|---|
| `/` (tab 1) | 02 | `HomeScreen` (features/home) | G1 | **màn cũ** (đã bỏ thanh dưới + tab giả; còn danh sách + FAB + bảng "Thêm") | — |
| `/menu` (tab 2) | 34/35/36 | `MenuScreen` (features/menu/menu_screen.dart) | G5 | STUB | `?view=week\|day\|month&date=YYYY-MM-DD` (G5 tự đọc `GoRouterState`) |
| `/shopping` (tab 3) | 27 (+28/29/30/33 là bảng/hộp thoại) | `ShoppingScreen` (features/shopping) | G4 | STUB | — |
| `/pantry` (tab 4) | 43 (+44 bảng) | `PantryScreen` (features/pantry) | G5 | STUB | — |
| `/more` (tab 5) | 46 | `MoreScreen` (features/more/more_screen.dart) | G6 | **chạy được**: danh sách cũ chuyển từ HomeScreen | — |
| `/onboarding` | 01 | `OnboardingScreen` (features/onboarding) | G6 | STUB, ngoài khung 5 tab | — (logic "lần đầu mở" + redirect do G6; cần sửa router thì báo điều phối) |
| `/recipe/new` | 11 | `RecipeEditorScreen` | G1 | cũ | `extra: RecipeDraft?` |
| `/recipe/:id` | 07 | `RecipeDetailScreen` | G1 | cũ | `id:int` |
| `/recipe/:id/edit` | 11 | `RecipeEditorScreen(id)` | G1 | cũ | |
| `/recipe/:id/photos` | 10 | `PhotoViewerScreen` | G1 | cũ | `?index=` |
| `/categories` | 14 | `CategoriesScreen` | G1 | cũ | |
| `/trash` | 13 | `TrashScreen` | G1 | cũ | |
| `/web` | 15 | `WebBrowserScreen(initialUrl)` | G2 | cũ | `?url=` |
| `/web/preview` | 17 | `ImportPreviewScreen({Object? source})` (features/web_import) | G2 | STUB | `extra`→`source` (kiểu thật do G2 quyết, giữ tên tham số) |
| `/web/pick` | 16 | `PickTextScreen({Object? source})` | G2 | STUB | `extra`→`source` |
| `/share` | 18 | `ShareInScreen({String? text})` | G2 | STUB | `?text=` hoặc `extra` String |
| `/scan` | 19/20 | `ScanScreen()` (features/scan) | G2 | STUB | |
| `/scan/assign` | 21 | `ScanAssignScreen({Object? pages})` | G2 | STUB | `extra`→`pages` |
| `/import` | 22 | `ImportScreen` | G2 | cũ | |
| `/cook/:recipeId` | 23 (+24/25/26 bảng) | `CookScreen({required int recipeId})` (features/cook) | G3 | STUB, ngoài khung (không thanh dưới, không pill) | `recipeId:int` |
| `/menu/templates` | 39 | `MenuTemplatesScreen()` | G5 | STUB | |
| `/menu/random` | 40 | `MenuRandomScreen()` | G5 | STUB | |
| `/settings/meal-slots` | 42 | `MealSlotsScreen()` (features/menu) | G5 | STUB | |
| `/shopping/aisles` | 31 | `AislesScreen()` (features/shopping) | G4 | STUB | |
| `/pantry/can-cook` | 45 | `CanCookScreen()` (features/pantry) | G5 | STUB | |
| `/backup` | 47 (+48/49/50 trong màn) | `BackupScreen` | G6 | cũ | `extra: String?` (đường dẫn khôi phục) |
| `/settings` | 53 | `SettingsScreen` | G6 | cũ | |
| `/settings/delete-all` | 54 | `DeleteAllDataScreen()` (features/more) | G6 | STUB | |
| `/exchange` | 52 | `ExchangeHubScreen()` (features/more) | G6 | STUB | |
| `/about` | 55 | `AboutScreen()` (features/more) | G6 | STUB | |
| `/licenses` | 56 | `LicensesScreen()` (features/more) | G6 | STUB | |
| (không là route) | 03,04,05,06,08,09,12,29,30,32,33,37,38,41,44,49,50 | bảng/hộp thoại/chế độ **bên trong** màn của nhóm | — | — | |

Khác biệt với product.md §4.2: Chế độ nấu là **`/cook/:recipeId`** (theo brief F0), không phải `/recipe/:id/cook`; `/web/preview`, `/web/pick` là **anh em** của `/web` (không lồng trong nó, để mở được mà không dựng WebView).

## 3. Phần của từng nhóm

**Quy tắc chung khi thay ruột stub:** giữ nguyên **tên lớp, hàm khởi tạo, tên tham số, đường dẫn file** ghi ở §2/§4; bỏ `StubScreen`. Test mới đặt trong `test/<nhóm>/`. Chuỗi mới: thêm vào `.arb` với **tiền tố nhóm** (xem §5), rồi `flutter gen-l10n`.

### G1 Công thức (`features/home`, `recipes`, `editor`, `categories`)
- Gốc tab `HomeScreen` đã chỉ còn `Scaffold(AppBar + RecipeListTab + FAB + bảng Thêm)`; làm lại theo 02–06, nhớ `route '/scan'` đã bật trong bảng Thêm (SCR-03) tới stub G2.
- **Điểm nối ra** (gọi từ chi tiết công thức SCR-07 — chữ ký CỐ ĐỊNH):
  - Chế độ nấu: `context.push('/cook/$id')`
  - `showAddToShoppingSheet(context, recipeId)` → `features/shopping/add_to_shopping_sheet.dart` (G4 làm ruột)
  - `showAddToMenuSheet(context, recipeId, {String? date, int? slotId})` → `features/menu/add_to_menu_sheet.dart` (G5 làm ruột)
- Component dùng: `RecipeCard`, `RecipeRow`, `PhotoPlaceholder/PhotoFrame`, `RibbonBookmark`, `StarRating`, `BepTag`, `NotebookTabHeader`, `EmptyState` (`BepIllo.empty`), `showConfirmDialog`, `showUndoSnackBar`, `showBepSheet`.
- Chuỗi đã có sẵn cho G1: `sortMissingLast`, `showNRecipes`, `emptyTrash`, `ratingSemantics`, `ratingUnset`.
- Ảnh thật: `RecipePhoto` hiện chỉ có ô xám khi thiếu ảnh → G1 thay bằng `PhotoPlaceholder(title:…)` (một chỗ).

### G2 Đưa công thức vào (`features/web_import`, `exchange` (nhập), `features/scan`)
- Stub cần làm ruột: `ImportPreviewScreen`, `PickTextScreen`, `ShareInScreen`, `ScanScreen`, `ScanAssignScreen` (route §2). `ShareIntentListener` (cũ) vẫn `router.push('/web?url=…')`/`/recipe/new` — nếu muốn chuyển sang `/share` thì sửa trong `share_listener.dart` (thư mục của G2), không cần đụng router.
- Component: `BepTag(tone: warn)` cho "Không mã hóa" (AC-66), `BackupStatusCard` không dùng. Chuỗi sẵn: `previewTitle`, `scanAssignTitle`, `scanReading`, `pickText`, `chooseAnotherFile`, `webStartNote`, `extShareSaved`.
- Cảnh báo test: `WebBrowserScreen` dựng WebView → widget test cần `WebViewPlatform` giả (xem `test/g2_test.dart` hiện có), vì vậy `web/preview` và `web/pick` đã tách khỏi route `web`.

### G3 Chế độ nấu (`lib/src/cook/`, `features/cook`)
- Thay ruột `CookScreen({required int recipeId})` — toàn màn hình, không thanh dưới, không pill (tự ẩn theo `/cook/`). Mở từ: chi tiết công thức (G1), pill hẹn giờ (đã nối), thông báo hết giờ (G3 nối payload → `router.push('/cook/$id')`; có thể dùng `createRouter()` toàn cục hoặc `GoRouter.of`).
- Token riêng: `CookTextStyles` (đã có cỡ `cookStep` 24, `cookStepCurrent` 28, `cookIngredient` 22, `timer` 22 tabular, `timerLarge` 44) + `CookTextStyles.sizeSteps` (5 bước 0.85–1.75); màu `context.bep.cookSurface/cookInk/currentStep/onCurrentStep/currentStepEdge/crossedOff/timerActive/onTimerActive`; nút ≥ `BepTap.cook` = 64 (`BepButton(size: BepButtonSize.cook)`).
- Hẹn giờ: engine `timersProvider` có sẵn; pill toàn cục F0 đã làm; `TimerAlertHost` (cũ) đã được bọc quanh app (trước đó chưa nối) — G3 kiểm lại hành vi snackbar "Time is up" nếu muốn đổi sang `showBepSnackBar`.
- Chuỗi sẵn: `cookStepsDoneShow`, `cookStartOver`, `timerAlreadyStarted`, `cookReadStopShort`, và nhóm `timer*` cũ + `timerPill*` mới.

### G4 Đi chợ (`features/shopping`)
- Ruột: `ShoppingScreen` (gốc tab, tự có Scaffold + FAB "Thêm món"), `AislesScreen` (`/shopping/aisles`), và hàm CỐ ĐỊNH:
  ```dart
  Future<void> showAddToShoppingSheet(BuildContext context, int recipeId);          // SCR-32 từ chi tiết công thức
  Future<void> showAddIngredientsToShoppingSheet(BuildContext context,
      {required List<ShoppingSourceRecipe> recipes});                              // dùng chung cho G5 (khoảng ngày SCR-41, "Nấu được gì?" SCR-45)
  class ShoppingSourceRecipe { final int recipeId; final double? servings; final Set<int>? onlyLineIds; }
  ```
  (`servings` null = khẩu phần đang xem `recipeViewProvider(recipeId)`; `onlyLineIds` = chỉ các dòng còn thiếu.) **Giữ chữ ký** — G1 và G5 gọi song song với bạn.
- Chuỗi sẵn: `shoppingMakeFirstList`, `shoppingNothingToBuy`, `shoppingAllDone`, `shoppingDeleteListConfirm(name, n)`; `EmptyState(BepIllo.basket)`, `showConfirmDialog(destructive)`, undo snackbar.

### G5 Thực đơn + Tủ bếp (`features/menu`, `features/pantry`)
- Ruột: `MenuScreen` (tuần/ngày/tháng qua query, §2), `MenuTemplatesScreen`, `MenuRandomScreen`, `MealSlotsScreen` (`/settings/meal-slots`), `PantryScreen`, `CanCookScreen`, và hàm CỐ ĐỊNH:
  ```dart
  Future<void> showAddToMenuSheet(BuildContext context, int recipeId, {String? date, int? slotId});  // SCR-37; date = 'YYYY-MM-DD'
  ```
- Gọi G4: `showAddIngredientsToShoppingSheet(...)` (xem G4).
- Chuỗi sẵn: `menuDropHere`, `menuDayHasMeals`. Component: `BepTag` (hạn dùng soon=warn / expired=bad), `EmptyState(BepIllo.calendar / BepIllo.jar)`, `RecipeRow`.

### G6 Thêm + sao lưu + hệ thống (`features/backup`, `settings`, `onboarding`, `more`, `exchange` (xuất), `cookbook`)
- Ruột: `MoreScreen` (đang là danh sách cũ chạy được), `OnboardingScreen`, `ExchangeHubScreen`, `DeleteAllDataScreen`, `AboutScreen`, `LicensesScreen`; cũ cần làm lại: `BackupScreen`, `SettingsScreen`.
- `BackupStatusCard(status: BackupStatus.…)` dựng sẵn (4 trạng thái + chữ "An toàn/Quá hạn/Đang lỗi/Chưa bật" vi/en). Chuỗi sẵn: `backupStatus*`, `dataUnchanged`, `dangerZone`, `deleting`. `EmptyState(BepIllo.keep / kitchen / collect)` cho màn chào.
- **Onboarding**: route `/onboarding` đã có nhưng chưa có redirect "lần đầu mở" — G6 báo điều phối cách nối (cần sửa `router.dart` hoặc `startupProvider`).
- Tên app: "CookNote" → "Bepbook" đã đổi ở `.arb`, `android:label`, `CFBundleDisplayName`/`CFBundleName` (Runner + ShareExtension + vi.lproj + chuỗi quyền iOS). **Đuôi `.cooknote` và tên gói/thư mục `cooknote` giữ nguyên.** "Liên hệ", "About" vẫn nguyên văn của brief.

## 4. Component đã có test (`test/ui/`, `test/shell_test.dart`)
Mỗi component có widget test: kích thước vùng chạm, 200% chữ không tràn, sáng/tối, nhãn đọc màn hình. Theme có test tương phản (24 cặp chữ mỗi chủ đề ≥ 4.5:1, biên ≥ 3:1) và test khớp token JSON.

## 5. Chuỗi / l10n
- `tool/add_f0_strings.py` đã: đổi "CookNote"→"Bepbook" trong mọi giá trị `.arb` (8 chuỗi theo README COPY; `shareAsCooknote` giữ `.cooknote`), thêm **toàn bộ chuỗi mới của README COPY** (gom theo nhóm trong script) để các nhóm KHÔNG phải sửa `.arb` cho chúng. Chạy lại được (không thêm trùng).
- **Chuỗi riêng của nhóm**: thêm cuối file `.arb` với tiền tố nhóm (`shopping…`, `menu…`, `pantry…`, `cook…`, `scan…`, `web…`, `more…`, `onboarding…`, `backup…`). Rủi ro: 6 phiên cùng sửa `app_en.arb/app_vi.arb` + file sinh `app_localizations*.dart`. Đề nghị điều phối: nhóm chỉ **commit hai file .arb + file sinh sau khi `flutter gen-l10n` ngay trước khi commit**, và mở nhóm theo đợt ≤ 3 phiên như kế hoạch; nếu xung đột thì chạy lại `flutter gen-l10n` (file sinh không merge tay).
- Chưa làm (thuộc G6): nội dung onboarding trang 2 VI "màn hình luôn sáng" (chưa có chuỗi onboarding), các chuỗi dài từng màn trong COPY ngoài danh sách README.

## 6. Quyết định F0 (không bàn lại nếu không có lý do mới)
1. **Giữ tên `CookNoteColors`** (không đổi `BepbookColors`): khớp 1:1 token JSON, README và product §11.4; "Bepbook" là tên hiển thị, `cooknote` là mã/gói.
2. **Mã màu sinh từ JSON**: `lib/src/ui/theme/color_tokens.dart` do `tool/gen_theme.py` sinh (không sửa tay; sửa token → xuất lại JSON → chạy script).
3. **Font Flutter không đọc woff2**: `tool/build_fonts.py` gộp 3 tập con (latin + latin-ext + vietnamese) của mockup thành **8 file TTF** (Lora 500/500i/600/700, Noto Sans 400/500/600/700) trong `assets/fonts/`; thêm giấy phép OFL. File `NotoSans-Regular/Bold.ttf` cũ giữ cho PDF (`exchange_providers.dart`). Lora thiếu `₫` → `fontFamilyFallback: NotoSans`.
4. **Không thêm `flutter_svg`**: 7 minh hoạ trạng thái rỗng sinh ra mã vẽ Canvas bằng `tool/gen_illustrations.py` (`lib/src/ui/illustrations.g.dart`), màu theo chủ đề sáng/tối.
5. **Khung = `StatefulShellRoute.indexedStack`** + `AppShell` (Column: nội dung + `BepNavigationBar`), **không** Scaffold ngoài → snackbar của từng tab nổi trên FAB của tab đó.
6. **Thanh dưới**: nhãn bị chặn 1.3× (`MediaQuery.withClampedTextScaling`), 1 dòng ellipsis, tooltip + nhãn đọc màn hình là tên đầy đủ.
7. **Pill hẹn giờ** là lớp phủ toàn cục trong `MaterialApp.builder` (vị trí theo đường dẫn hiện tại).
8. **Icon**: Material Icons (SDK) outlined/rounded làm gần nhất với Material Symbols Rounded của mockup — xem rủi ro §8.

## 7. Kiểm tra thế nào
- `flutter analyze` → **No issues found**.
- `flutter test` → kết quả ở cuối file (390 test cũ giữ nguyên + test mới `test/ui/theme_test.dart`, `test/ui/components_test.dart`, `test/shell_test.dart`).
- `flutter build apk --release` → kết quả ở cuối file.
- Nhìn bằng mắt **một lần** (ảnh dựng từ widget test có nạp font thật, 360×800 dp, sáng + tối, thu nhỏ): thẻ công thức index-card + ruy-băng, nút, tag, thẻ sao lưu, thanh dưới 5 mục, header tab sổ tay; font Lora/Noto Sans hiện đúng dấu Việt ("Công thức", "Phở bò Hà Nội"). Icon app: xem lưới 5 ô (launcher, adaptive foreground, monochrome, splash, iOS). Ảnh nằm trong scratchpad của phiên (không commit): `…\scratchpad\sampler2.png`, `…\scratchpad\ic\sheet.png`.
- Chưa chạy trên máy/emulator (không dùng adb theo brief): các việc chỉ nhìn được trên thiết bị — splash Android 12+ sáng/tối, icon themed Android 13, LaunchScreen iOS — để phiên H.

## 8. Việc dở / rủi ro
1. **iOS chưa thử cục bộ** (máy Windows): LaunchScreen dùng `namedColor` + `LaunchBackground.colorset` (sáng/tối); icon AppIcon.appiconset thay toàn bộ PNG (đặc, không alpha). CI iOS là phép thử duy nhất → xem mục CI dưới.
2. **Icon**: mockup dùng *Material Symbols Rounded* (weight 400, fill 1 khi chọn). SDK chỉ có *Material Icons* (outlined/rounded) → gần giống, không trùng từng nét. Nếu muốn giống 100%: thêm dependency `material_symbols_icons` (Apache-2.0, ~ vài MB font) — **chưa thêm, chờ quyết định**.
3. **SVG minh hoạ lỗi nguồn**: nhiều thẻ có thuộc tính `stroke` khai hai lần (`#5C5043` rồi màu nhấn). Trình phân tích HTML giữ cái đầu, XML báo lỗi. F0 lấy **giá trị cuối** (màu nhấn: cinnamon/herb/turmeric) — nếu mockup thực sự hiện nét xám thì chỉ cần đảo trong `tool/gen_illustrations.py`.
4. **Pill nổi trên bảng đáy/hộp thoại** (lớp phủ nằm trên Navigator). Chấp nhận được; sửa tận gốc cần `Overlay`/`BepScaffold` cho mọi màn.
5. **`dart format` đã tự đổi 7 file ngoài phạm vi** lúc chạy `dart format lib` — đã hoàn nguyên bằng `git checkout`. **Nhóm đừng chạy `dart format lib`**; chỉ `dart format <file mình sửa>`.
6. **Pill + snackbar**: nâng snackbar bằng `margin` (56 dp) khi có hẹn giờ — chỉ áp cho snackbar qua `showBepSnackBar/showUndoSnackBar/showMessage`; `SnackBar` tự dựng (vd `TimerAlertHost`) không tự nâng.
7. **ARCHITECTURE.md đã lỗi thời** ở mục "Màn hình và điều hướng" (nói `/` Home có thanh 5 mục) — F0 không sửa `docs/` (ngoài phạm vi); điều phối cập nhật.
8. **`HomeScreen` đã bị F0 động vào** (bỏ tab giả + thanh dưới + `_MoreTab` → `features/more/more_screen.dart`): G1/G6 nên đọc trước khi làm lại.
9. **Cook mode trong product §4.2 là `/recipe/:id/cook`**; brief F0 yêu cầu `/cook/:recipeId` — đã theo brief. Nếu điều phối muốn alias: thêm `redirect` trong `router.dart` (1 dòng).
10. **Token vs mockup**: không thấy mâu thuẫn ở màu/chữ (24 cặp chữ mỗi chủ đề kiểm tương phản đạt). Mockup chip cao 34 dp (thấp hơn 48): theme giữ vùng chạm 48 bằng `MaterialTapTargetSize.padded` mặc định của Chip. FAB 56×56 bo 18 theo `.fab`. Thanh dưới: mockup `.nav` cao ≈ 54 + chỉ báo 60×32; Flutter `NavigationBar` cao 72 — hơn một chút, chấp nhận.
11. **Trợ năng chưa kiểm trên thiết bị** (TalkBack/VoiceOver): chỉ kiểm bằng cây Semantics trong test.
12. **S-11 (trang 16 KB)**: F0 không thêm thư viện native; chỉ thêm font/asset. Không ảnh hưởng.

## 9. Đề xuất cải tiến xưởng (đưa vào PLAYBOOK nếu đồng ý)
1. **Script "token JSON → Dart"** (`tool/gen_theme.py`) tái dùng được cho mọi app có Claude Design xuất token cùng định dạng; kèm test "khớp token JSON" (đã có). Nên chuyển thành `playbook/templates/tool/` dùng chung.
2. **Script gộp font woff2 → TTF** (`tool/build_fonts.py`) và **SVG → mã Canvas** (`tool/gen_illustrations.py`): tránh thêm `flutter_svg` cho app chỉ có vài minh hoạ nét. Điều kiện: SVG đơn giản (rect/line/circle/path M L H V Q T A Z).
3. **Script icon/splash từ SVG bằng Edge headless + Pillow** (`tool/gen_icons.py`) — Windows không cần cài thêm công cụ; sinh luôn adaptive + monochrome + iOS.
4. **Brief cho phiên chạy song song nên khoá bảng route + chữ ký stub từ đầu** (F0 đã làm) — điều này làm cho 6 nhóm gần như không đụng `app.dart`. Nên đưa vào `templates/BRIEF-phien-con.md`: "Điểm nối cố định".
5. **Test mẫu cho design system** (`test/ui/components_test.dart` có hàm `pumpUi(scale, dark, locale)`): các nhóm dùng lại để thử nhanh ở chữ 200%/tối.
6. **Cảnh báo `dart format` toàn thư mục** trong WORKFLOW (đụng file ngoài phạm vi phiên con).
7. Ảnh kiểm UI: dựng ảnh từ widget test **có nạp font thật** (cách trong §7) rẻ hơn mở PNG mockup và so sánh được.

---
## 10. Kết quả kiểm trên máy (2026-11-05, sau commit adb5e7b)
- `flutter analyze` → No issues found.
- `flutter test` → **460 đạt, 3 bỏ qua** (390 cũ + 70 mới: `test/ui/theme_test.dart`, `test/ui/components_test.dart`, `test/shell_test.dart`).
- `flutter build apk --release` (đủ kiến trúc, không `--target-platform`) → thành công, `app-release.apk` 100.7 MB (phần lớn là dữ liệu OCR tessdata; font mới thêm ≈ 1.2 MB TTF).
- CI: theo luật xưởng §7 mới (nhánh `dev`, CI không chạy), thay bằng analyze + test + build APK xanh trên máy; đã push `dev`. **CI iOS chưa chạy cho F0** — LaunchScreen/AppIcon iOS chưa được biên dịch ở đâu cả; phiên H hoặc lần merge vào main cần chạy iOS workflow thủ công trước khi tin.
- Lưu ý: `.github/workflows/ci.yml`, `ios.yml` đang có thay đổi chưa commit do phiên khác (không phải F0) — F0 không commit chúng.
