# CI và phát hành — CookNote (A004-cooknote)

> Viết 2026-11-05 (phiên con "Nền iOS + CI + dependency"). Máy làm việc là Windows, không Mac, không iPhone:
> mọi bản iOS build trên GitHub Actions macOS runner (D-008). Repo `phiotron/cooknote` (private, nhánh `main`).
>
> **Luật xưởng (S-61, WORKFLOW §3 luật 6):** khoá ký, chứng chỉ, API key, mật khẩu và GitHub secrets do **Phương tự tạo**.
> Claude chỉ viết workflow đọc secrets và hướng dẫn dưới đây. Không bao giờ chép các file khoá vào repo
> (`.gitignore` đã chặn `*.jks`, `*.keystore`, `*.p12`, `*.p8`, `*.cer`, `*.mobileprovision`, `key.properties`).

## 1. Bốn workflow

| File | Chạy khi | Máy | Làm gì | Cần secrets |
|---|---|---|---|---|
| `.github/workflows/ci.yml` | mọi push/PR (trừ khi chỉ đổi `*.md`, `docs/`, `notes/`, `design/`, `store/`) + chạy tay | Ubuntu | `pub get` → `analyze` → `test` → `flutter build apk --release` (đủ 3 kiến trúc) → kiểm: đủ `arm64-v8a`/`armeabi-v7a`/`x86_64`, `.so` 64-bit căn trang 16 KB (S-11), quyền trong APK so với SPEC mục 5 (cảnh báo) | không |
| `.github/workflows/ios.yml` | push `main` có đổi code (bỏ qua tài liệu, `android/`, `test/`) + chạy tay | macOS 26 | kiểm Xcode ≥ 26 (S-20) → kiểm `Info.plist`/`PrivacyInfo`/entitlements → `flutter build ios --simulator --debug` → mở app trên iPhone Simulator, chụp màn hình, thử URL của Share Extension. Chạy tay: thêm `flutter build ios --release --no-codesign` | không |
| `.github/workflows/release-android.yml` | chỉ chạy tay | Ubuntu | build AAB ký bằng khoá upload → artefact `android-release-<số>` (tải lên Play Console bằng tay) | 4 secrets Android (mục 3) |
| `.github/workflows/release-ios.yml` | chỉ chạy tay | macOS 26 | archive ký tự động bằng API key → `.ipa` → kiểm → tải lên TestFlight | 4 secrets Apple (mục 4) |

**Xem kết quả:** github.com/phiotron/cooknote › tab **Actions** › chọn lần chạy. Ảnh chụp app trên simulator và log nằm ở
mục **Artifacts** cuối trang (`ios-simulator-logs` › `launch.png`). Bằng dòng lệnh (Git Bash):

```bash
gh run list -L 5
```

```bash
gh run view <số-run> --log-failed
```

**Chạy tay một workflow:** tab Actions › chọn workflow bên trái › **Run workflow** › chọn nhánh `main` › điền ô (nếu có) › Run.

### Chi phí phút (repo private)
Gói Free: 2.000 phút/tháng; **phút macOS tính ×10**. Một lần `ios.yml` ≈ 6–9 phút thật ≈ 60–90 phút quota; thêm bản Release khi chạy tay
≈ +4 phút thật. Vì vậy `ios.yml` chỉ chạy trên `main` và bỏ qua thay đổi tài liệu. Xem phút đã dùng: github.com › Settings (tài khoản) ›
Billing and plans. Sắp hết thì gộp nhiều commit rồi mới push `main`.

## 2. Cách lưu file khoá và mã hoá base64 (Windows)

Tạo một thư mục **ngoài repo**, ví dụ `D:\keys\cooknote\`, và sao lưu thư mục đó vào nơi an toàn (USB, trình quản lý mật khẩu).
GitHub secrets chỉ nhận chữ, nên file nhị phân phải đổi sang base64. Trong **Git Bash**:

```bash
base64 -w0 /d/keys/cooknote/upload-keystore.jks > /d/keys/cooknote/upload-keystore.jks.b64
```

Đặt secret từ file (không dán nội dung vào cửa sổ chat hay vào repo):

```bash
gh secret set ANDROID_KEYSTORE_BASE64 --repo phiotron/cooknote < /d/keys/cooknote/upload-keystore.jks.b64
```

Secret dạng chữ ngắn (mật khẩu, ID): chạy lệnh dưới, gh sẽ hỏi giá trị và **không** hiện lên màn hình:

```bash
gh secret set ANDROID_KEYSTORE_PASSWORD --repo phiotron/cooknote
```

Hoặc làm trên web: repo › **Settings** › **Secrets and variables** › **Actions** › **New repository secret**.
Xoá các file `.b64` sau khi đặt xong secret.

## 3. Android — khoá upload và secrets

Play App Signing: Google giữ khoá ký app thật; mình chỉ giữ **khoá upload** (mất thì xin Google đặt lại được, nhưng mất vài ngày).

1. Tạo khoá upload bằng `keytool` của JDK 17 (đã có trên máy). Git Bash:
   ```bash
   keytool -genkeypair -v -keystore /d/keys/cooknote/upload-keystore.jks -keyalg RSA -keysize 4096 -validity 10000 -alias upload
   ```
   `keytool` hỏi mật khẩu keystore và tên/tổ chức (điền tên cá nhân). Ghi mật khẩu vào trình quản lý mật khẩu.
2. Đổi sang base64 và đặt 4 secrets (mục 2):

   | Secret | Giá trị |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | nội dung file `upload-keystore.jks.b64` |
   | `ANDROID_KEYSTORE_PASSWORD` | mật khẩu keystore |
   | `ANDROID_KEY_ALIAS` | `upload` |
   | `ANDROID_KEY_PASSWORD` | mật khẩu khoá (mặc định keytool dùng chung mật khẩu keystore) |
3. **Điều kiện trước khi chạy `release-android.yml`:** `android/app/build.gradle.kts` phải đọc `android/key.properties` để ký bản release
   (hiện vẫn ký bằng khoá debug). Việc này do phiên điều phối giao (ghi trong `notes/2026-11-05-ios-ci.md`). Nếu chưa sửa, workflow tự
   dừng ở bước "Kiểm chữ ký AAB không phải khoá debug".
4. Chạy tay **Release Android** › tải artefact `android-release-<số>` › giải nén lấy `app-release.aab` › Play Console › CookNote ›
   Testing › Closed testing › Create new release › tải lên. Số build (`versionCode`) = số lần chạy workflow, tự tăng.
5. Bản phát hành đầu tiên trên Play Console luôn phải tải lên bằng tay (Play chưa cho API tải lên trước lần đầu). Tự động tải lên
   (service account) để sau, khi cần.

## 4. iOS — Apple Developer, App Store Connect, secrets

Workflow `release-ios.yml` **ký tự động**: Xcode trên runner dùng App Store Connect API key để tự tạo chứng chỉ và provisioning profile cho
cả app lẫn Share Extension. Không cần Mac, không cần tạo CSR hay file `.p12`.

1. **Đăng ký Apple Developer Program** (cá nhân, 99 USD/năm): developer.apple.com/programs › Enroll, đăng nhập Apple ID có bật xác thực
   hai lớp. Chờ Apple duyệt (thường 1–2 ngày).
2. **Team ID:** developer.apple.com/account › Membership details › Team ID (10 ký tự) → secret `IOS_TEAM_ID`.
3. **App Group:** developer.apple.com/account › Certificates, Identifiers & Profiles › Identifiers › nút **+** › **App Groups** ›
   Identifier `group.com.phiotron.cooknote`, Description `CookNote`.
4. **Hai App ID** (Identifiers › **+** › App IDs › App):
   - `com.phiotron.cooknote` (Description `CookNote`) — tick capability **App Groups**.
   - `com.phiotron.cooknote.ShareExtension` (Description `CookNote Share`) — tick **App Groups**.
   Sau khi lưu, mở từng App ID › App Groups › **Configure** › chọn `group.com.phiotron.cooknote` › Save.
   *(Đây là bước Share Extension cần; thiếu thì archive báo lỗi provisioning hoặc chia sẻ vào app không chạy.)*
5. **Tạo app trên App Store Connect:** appstoreconnect.apple.com › Apps › **+** › New App › iOS, tên `CookNote`, ngôn ngữ chính
   Vietnamese (hoặc English), Bundle ID `com.phiotron.cooknote`, SKU `cooknote`. (Nếu tên đã có người dùng thì báo phiên điều phối.)
6. **API key:** App Store Connect › Users and Access › **Integrations** › App Store Connect API › Team Keys › **+**:
   tên `github-actions-cooknote`, quyền **Admin** (cần để Xcode tạo chứng chỉ phân phối được quản lý trên đám mây).
   - **Issuer ID** (dòng trên cùng của trang) → secret `ASC_ISSUER_ID`.
   - **Key ID** của key vừa tạo → secret `ASC_KEY_ID`.
   - **Download API Key** → file `AuthKey_<KeyID>.p8`. **Chỉ tải được MỘT lần** — lưu vào `D:\keys\cooknote\` ngay.
   - Base64 file `.p8` (mục 2) → secret `ASC_KEY_P8_BASE64`.
7. Chạy tay **Release iOS** (ô `upload` để tick) › chờ ~15–20 phút › bản build hiện trong App Store Connect › TestFlight sau vài phút xử lý.
   Lần đầu App Store Connect hỏi **Export Compliance**: app đã khai `ITSAppUsesNonExemptEncryption = NO` (S-22) nên không phải trả lời.
8. Thử trên máy thật: cần mượn iPhone, cài **TestFlight**, thêm Apple ID của người thử vào Internal Testing.

| Secret | Lấy ở đâu |
|---|---|
| `IOS_TEAM_ID` | Membership details › Team ID |
| `ASC_ISSUER_ID` | App Store Connect › Users and Access › Integrations › Issuer ID |
| `ASC_KEY_ID` | cột Key ID của API key |
| `ASC_KEY_P8_BASE64` | file `AuthKey_<KeyID>.p8` → base64 |

**Nếu ký tự động lỗi** (ví dụ "No signing certificate" hay "requires a provisioning profile"): đọc `ci-logs/archive.log` trong artefact
`ios-release-<số>`. Kiểm lại bước 3–4 (App Group gán cho CẢ HAI App ID) và quyền Admin của API key. Phương án dự phòng (ký thủ công bằng
chứng chỉ Apple Distribution `.p12` + 2 provisioning profile) cần sửa workflow — nhờ phiên phát hành (#3) làm.

## 5. Những điều cần biết khi sửa iOS

- **Swift Package Manager + CocoaPods:** Flutter 3.47.8 dùng SPM cho plugin; riêng `flutter_tts` 4.2.5 chưa hỗ trợ SPM nên còn
  `ios/Podfile` (CocoaPods có sẵn trên runner). Runner tự chạy `pod install`, sinh `ios/Podfile.lock` và sửa `project.pbxproj` lúc build —
  thay đổi đó chỉ ở runner, không commit. Bỏ `flutter_tts` thì xoá luôn `ios/Podfile` và hai dòng `#include? "Pods/..."` trong
  `ios/Flutter/Debug.xcconfig`, `Release.xcconfig`.
- **Share Extension** (`ios/ShareExtension/`): Swift thuần, KHÔNG kéo Flutter hay plugin vào (extension có giới hạn bộ nhớ). Nó ghi link/chữ
  vào App Group theo đúng định dạng của `receive_sharing_intent` rồi mở app bằng URL `ShareMedia-com.phiotron.cooknote:share`; plugin
  đưa dữ liệu lên Dart (`ReceiveSharingIntent.instance.getInitialMedia()` và `getMediaStream()`, kiểu `SharedMediaType.url` hoặc `.text`).
- **Mở file `.cooknote`** từ app Tệp, Mail, AirDrop: iOS chép file vào `Documents/Inbox/` rồi gọi app. Kênh
  `com.phiotron.cooknote/open_file` (`ios/Runner/OpenFilePlugin.swift`): Dart gọi `getInitialFile` (đường dẫn hoặc null) và nghe
  `fileOpened(path)`. Dart xoá bản chép sau khi nhập.
- `FlutterDeepLinkingEnabled = NO`: URL lạ không bị đẩy vào go_router.
- Quyền iOS chỉ có camera và thư viện ảnh (image_picker); chữ tiếng Việt ở `ios/Runner/vi.lproj/InfoPlist.strings`. `ios.yml` báo lỗi
  nếu ai thêm khoá `NS…UsageDescription` khác.
- Sao lưu iCloud của iOS **giữ bật** (APP.md "Tiêu chuẩn áp dụng"): không có mã loại DB khỏi sao lưu.
- Không có Mac: mọi thay đổi trong `ios/` chỉ kiểm được bằng `ios.yml`. Sửa `project.pbxproj` bằng tay phải giữ ID 24 ký tự hex
  duy nhất; kiểm bằng cách chạy tay workflow iOS.
