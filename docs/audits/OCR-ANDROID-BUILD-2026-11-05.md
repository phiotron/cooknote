# Đo build OCR Android (Tesseract4Android) — 2026-11-05

Phiên con "[A004-cooknote] OCR Android (Tesseract)", phiên điều phối #1. Tiếp nối `OCR-RESEARCH-2026-11.md` (phương án D).
Mọi số dưới đây là số đo thật trên máy Windows ngày 2026-11-05, trừ chỗ ghi "CHƯA kiểm chứng".

## 1. Nguồn phát hành Tesseract4Android 4.9.0 (khảo sát ghi CHƯA kiểm chứng)
- **Chỉ có trên JitPack.** Maven Central: `search.maven.org` trả 0 kết quả cho `a:tesseract4android*`,
  `repo1.maven.org/maven2/cz/adaptech/tesseract4android/…/4.9.0/` trả 404. README chính thức chỉ hướng dẫn JitPack.
- JitPack: `https://jitpack.io/cz/adaptech/tesseract4android/tesseract4android{,-openmp}/4.9.0/*.pom` trả 200; API build
  JitPack: tag `4.9.0`, commit `15c534717b1cb58261b58d4e4c1200c7f81f668c`, status `ok`, hai module.
- Gradle: JitPack khai bằng `exclusiveContent` chỉ cho group `cz.adaptech.tesseract4android` (`android/build.gradle.kts`),
  nên không gói nào khác lấy được từ JitPack (giảm rủi ro chuỗi cung ứng).
- SHA-256 AAR tải ngày 2026-11-05: standard `bce5d641…cb2a` (12 848 454 B), openmp `02b5968c…ab2b` (14 081 889 B).
- POM: chỉ phụ thuộc `androidx.annotation:annotation:1.3.0` (runtime). Manifest AAR: chỉ `uses-sdk minSdk 21`, **không quyền**.
- AAR **không có quy tắc ProGuard/R8** → thêm `android/app/proguard-rules.pro` giữ `com.googlecode.tesseract.android.**`
  và `com.googlecode.leptonica.android.**` (JNI đọc trường private `mNativeData`, gọi ngược `onProgressValues`).

## 2. Biến thể: openmp
| | standard | openmp |
|---|---|---|
| `libtesseract.so` armeabi-v7a | 3 004 948 B | 3 640 196 B |
| `libtesseract.so` arm64-v8a | 4 164 360 B | 4 965 376 B |
| Các `.so` khác (leptonica, jpeg, pngx) | giống nhau | giống nhau |

Chọn **openmp**: app chỉ dùng MỘT instance Tesseract, Galaxy A13 (Exynos 850) có 8 lõi Cortex-A55 chậm, NFR đòi ≤ 10 s/trang;
README thư viện khuyên openmp đúng cho trường hợp "multi-core, single instance". Giá: +0,6 MB/ABI (chưa nén).
libomp liên kết tĩnh (`-static-openmp`; `NEEDED` của `libtesseract.so` không có `libomp.so`).
Rủi ro: OpenMP có thể làm nóng máy/tốn pin hơn mà không nhanh hơn trên lõi A55 — **CHƯA kiểm chứng**; đổi về standard chỉ cần
sửa một dòng trong `android/app/build.gradle.kts` (tên artifact bỏ `-openmp`).

## 3. Căn trang 16 KB (S-11) — trên AAR
`llvm-readelf -lW` (NDK 28.2) trên từng `.so` trong AAR, cột Align của mọi segment LOAD:
- arm64-v8a, x86_64: `libtesseract.so`, `libleptonica.so`, `libjpeg.so`, `libpngx.so` → **0x4000 (16 KB)** ở mọi LOAD. Đạt.
- armeabi-v7a, x86: 0x1000 (4 KB). Không áp dụng: yêu cầu 16 KB của Google Play chỉ cho máy 64-bit.
Kết quả trên APK cuối: mục 5.

## 4. Dữ liệu ngôn ngữ (tessdata_fast)
| File | Kích thước | SHA-256 | Phiên bản trong file |
|---|---|---|---|
| `assets/tessdata/vie.traineddata` | 531 275 B | `79df64ca…5bfa1` | `4.00.00alpha:vie:synth20170629:[1,36,0,1…` |
| `assets/tessdata/eng.traineddata` | 4 113 088 B | `7d4322bd…70b2` | `4.00.00alpha:eng:synth20170629` |

- Nguồn: `https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/main/<lang>.traineddata`, commit `main` =
  `87416418657359cb625c412a48b6e1d6d41c29bd` (2026-11-05). Giấy phép kho: Apache-2.0 (GitHub API `license.spdx_id`).
- **`vie` fast nhỏ bất thường? Không hỏng.** Đọc bảng thành phần trong file: cả hai chỉ có thành phần LSTM (không có dữ liệu
  engine cũ). Mạng LSTM `vie` 433 394 B, `eng` 401 636 B — tương đương nhau. Khác biệt nằm ở từ điển: `lstm-word-dawg` của `vie`
  67 282 B, của `eng` 3 694 794 B. Hệ quả: (a) phải khởi tạo `OEM_LSTM_ONLY`; (b) từ điển tiếng Việt nhỏ nên Tesseract ít được
  "sửa theo từ điển" với chữ Việt → lỗi dấu có thể nhiều hơn; đo bằng cột "bỏ dấu" của test AC-25.

## 5. APK release (đủ kiến trúc, không `--target-platform`)
Cách đo: hai bản build trong worktree tách rời (`git worktree add --detach` ở scratchpad) để không bị lẫn thay đổi chưa commit của
phiên song song khác: **trước** = HEAD `bbc5b8d`; **sau** = HEAD + đúng các file của phiên này. `flutter build apk --release` rồi
`--split-per-abi`, Flutter 3.47.8, ký debug. Byte thật (`ls -l`).

| APK | Trước | Sau | Tăng |
|---|---|---|---|
| Đủ kiến trúc (`app-release.apk`) | 71 576 158 B (68,3 MiB) | 97 357 938 B (92,8 MiB) | +25 779 780 B (+24,6 MiB) |
| armeabi-v7a | 23 034 002 B | 31 630 190 B | +8 596 188 B (+8,2 MiB) |
| arm64-v8a | 24 641 862 B | 35 412 954 B | +10 771 092 B (+10,3 MiB) |
| x86_64 | 26 191 902 B | 37 440 482 B | +11 248 580 B (+10,7 MiB) |

Thành phần phần tăng: `.so` lưu KHÔNG nén trong APK (mặc định AGP khi minSdk ≥ 23, để nạp thẳng từ APK):
armeabi-v7a 6 150 120 B, arm64-v8a 8 315 384 B, x86_64 8 775 240 B; tessdata nén deflate trong APK: `eng` 1 977 229 B, `vie` 422 419 B
(file thật 4 644 363 B, chép ra máy lần đầu); `LICENSES-ocr.txt` 9 351 B.

**So với NFR (SPEC 5b):**
- Bản Play một kiến trúc ≤ 45 MB: split arm64 35,4 MB, armeabi-v7a 31,6 MB → **đạt** (split APK xấp xỉ bản Play tải về; số thật của AAB
  đo ở #3).
- APK đủ kiến trúc ≤ 80 MB: **KHÔNG đạt** (97,4 MB; riêng phần `.so` đã vượt). Mốc trước đã 71,6 MB. Phương án: xem mục 7.

**Vấp khi đo:** build tăng dần của Flutter KHÔNG đưa file mới thêm vào thư mục asset đã khai (`assets/tessdata/`) vào APK — lần build
đầu sau khi chép tessdata, APK chỉ có `.gitkeep`. Sau `flutter clean` thì có. Nguyên nhân chính xác CHƯA rõ. Hệ quả: thêm/đổi file
trong `assets/tessdata/` thì phải `flutter clean` trước khi build bản phát hành, và kiểm bằng `unzip -l … | grep tessdata`.

## 6. Quyền (aapt2), `.so` 32-bit, 16 KB trên APK cuối
`aapt2 dump permissions` — giống hệt trước và sau (APK đủ kiến trúc và split armeabi-v7a):
```
package: com.phiotron.cooknote
permission: com.phiotron.cooknote.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
uses-permission: name='com.phiotron.cooknote.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
```
→ OCR **không thêm quyền nào** (S-40). (Quyền duy nhất là quyền nội bộ do androidx tự sinh cho receiver động, có từ trước.)
Ghi chú: bản HEAD chưa có `INTERNET` dù D-002 cho F-03 dùng mạng — việc của phiên làm F-03, không phải OCR.

`.so` trong APK đủ kiến trúc (`llvm-readelf -h/-lW`, căn của segment LOAD):
| ABI | ELF | libtesseract / libleptonica / libjpeg / libpngx | libflutter / libapp / libsqlite3 / libdartjni |
|---|---|---|---|
| arm64-v8a | ELF64 | 0x4000 | 0x10000 / 0x10000 / 0x4000 / 0x4000 |
| x86_64 | ELF64 | 0x4000 | 0x10000 / 0x10000 / 0x4000 / 0x4000 |
| armeabi-v7a | **ELF32 (có)** | 0x1000 | 0x10000 / 0x4000 / 0x4000 / 0x4000 |

`zipalign -c -P 16 -v 4` trên APK đủ kiến trúc: mọi `lib/*/*.so` "(OK)", **Verification successful**; split arm64: Verification successful.
→ **S-11 đạt** cho mọi `.so` 64-bit (cả căn ELF lẫn căn trong file zip).

R8: `dexdump` cho thấy `TessBaseAPI` giữ nguyên `mNativeData`, `onProgressValues`, `nativeGetHOCRText`, `nativeStop` → quy tắc keep có hiệu lực.

## 7. NFR "APK đủ kiến trúc ≤ 80 MB": phương án (cần phiên điều phối chốt)
Thử trong worktree tách rời (KHÔNG commit): thêm `packaging { jniLibs { useLegacyPackaging = true } }` vào `android/app/build.gradle.kts`
→ APK đủ kiến trúc **45 070 706 B** (thay vì 97 357 938 B); `libtesseract.so` arm64 4 965 376 → 1 964 460 B trong APK.
| Phương án | APK đủ kiến trúc | Đánh đổi |
|---|---|---|
| A. Giữ mặc định (`.so` không nén) | 97,4 MB, không đạt | Cài nhanh, không tốn chỗ giải nén; Play tự nén khi tải nên bản Play không bị ảnh hưởng |
| B. `useLegacyPackaging = true` | 45,1 MB, đạt | Lúc cài, Android giải nén `.so` ra đĩa (máy tốn thêm ≈ dung lượng `.so` một ABI, ~25 MB với armeabi-v7a); áp cho cả AAB (bundletool đọc cùng cờ) |
| C. Sửa NFR: chỉ đo bản Play một kiến trúc (≤ 45 MB, đang đạt) và split APK cho thử máy | — | APK đủ kiến trúc chỉ dùng thử nội bộ |
Đề xuất: **C** (APK đủ kiến trúc chỉ để Phương cài thử; người dùng thật nhận bản theo kiến trúc từ Play), hoặc B nếu muốn giữ đúng chữ NFR.
Đổi sang biến thể standard chỉ bớt ~2,2 MB, không đủ.
