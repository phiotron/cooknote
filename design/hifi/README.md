# Bepbook — Hi-Fi design v1

| | |
|---|---|
| Date | 2026-11-05 |
| Brief | `product.md` v1.2 (§11 deliverables), glossary `CONTEXT.md` |
| Canvas (Claude Design) | https://claude.ai/artifact/F8XGiDZWhg2moTY1GdAxwk |
| Design system | https://claude.ai/artifact/NudwEmUWcUgpNBzPsY2ZJt |
| Prototype F1–F9 | `prototype.html` (open locally; click the screen or press → ) |
| All frames | `index.html` (filter by platform / theme) |

Both links are private until shared from the page's Share menu.

## What is here

- **945 frames** (65 SCR/EXT numbers) as **HTML + PNG**: `<platform>/<theme>/<NN>_<slug>__<state>.html|png` (§11.3). Android 360×800 dp and iPhone 393×852 pt, light and dark; VI variants and 200 % text variants on Android light; stress states (200-char title, 1,284 recipes, 5 pins + 3 timers, 4-dish slot, 20 photos, long VI backup hint).
- PNGs are rendered at **1× = 1 px per dp/pt**, so distances can be measured directly. HTML frames carry exact colours, sizes and fonts (open DevTools); the side panel of each HTML lists the AC codes, notes and `COPY:` changes.
- `tokens/`: `bepbook-tokens.json` (ColorScheme + CookNoteColors light/dark, type scale, spacing, radius, tap sizes, motion), `bepbook-light.css` / `bepbook-dark.css`, `bepbook_theme.dart.txt` (paste-ready Flutter `ColorScheme` + `CookNoteColors`), `contrast.json` (92 pairs, 92 pass).
- `assets/`: fonts (Lora + Noto Sans, Vietnamese subsets, OFL), icons used (Material Symbols Rounded, Apache-2.0), `brand/` app icon (light, dark, square/adaptive, monochrome) + line illustrations (SVG).
- `_frames.json`: machine-readable list (file, SCR, state, AC, platform, theme, language, text scale, notes).

## Identity in one paragraph
"A warm kitchen notebook": paper `#FBF6EC` and ink `#2A2119`, one cinnamon accent (`primary #9A4518`), herb green (`secondary #3B6A45`), turmeric for stars and the current step. Dark = warm charcoal `#1C1814`. Lora for headings and recipe names, Noto Sans for UI, tabular figures for quantities and timers. Motifs used lightly: notebook-tab section headers, ruled lines, index-card photo placeholders, ribbon bookmark. Icon set: Material Symbols Rounded (Apache-2.0). App icon: notebook + spoon + turmeric ribbon, no wordmark.

## Decisions worth reviewing
1. **Cook mode (§9.2)** — recommended: Ingredients / Steps tabs, crossed steps collapse to "2 steps done · Show", the current step is a large card with **Now** + its timer button at the top, **Next step** 64 dp in the thumb zone, timer tray above it. Alternative drawn: one step at a time (`23_cook__alt-focus`). Readability check at 50 %: `23_cook__distance`.
2. **Pick-text (§9.3)** — assign panel docked at the bottom; the OS selection toolbar floats above the selection and never covers the three buttons.
3. **Google Drive refusal (§9.4)** — framed as a normal path ("That is common with cloud apps…") with Back up now and save elsewhere as the primary button; status is never green unless the last backup was verified.
4. **Bottom nav at 200 %** — labels capped at 1.3× and ellipsized like the OS bar; icons stay distinct; full label in tooltip and for screen readers (`57_components__bottom-nav`).
5. **Photos** — the sandbox has no licence-clear food photos, so recipe photos are illustrated stand-ins. Replace with real photos at implementation; layout and scrims are designed for real photos.
6. **Timers** — only Cancel (no pause / +1 min, D-009). Running pill shown on every screen outside Cook mode.

## Android vs iOS (§7) as drawn
- Back: Android system back; iOS chevron (`arrow_back_ios_new`) and centred small app-bar titles; editor/assign block swipe-back when dirty (discard dialog).
- Share in: Android share intent → in-app browser; iOS Share Extension card "Saved to Bepbook — open?" (`EXT-02 ~ios-card`).
- Backup folder: Android SAF picker (Drive may refuse automatic writes → `48_backup~setup__refused`); iOS Files picker + bookmark, "folder access expired" state (`ios/*/47_backup__access-expired`), iOS copy for the hint and the iCloud Backup note.
- Notifications: Android 13+ prompt + "Cooking timers" channel + optional ongoing notification; iOS banner/lock screen (`EXT-01`).
- Text-to-speech help: iOS copy points to Accessibility → Spoken Content → Voices.
- Share out: `ios_share` glyph on iOS, `share` on Android. Same Material components on both, respecting Dynamic Island, Home indicator and the gesture bar.

## COPY changes and new strings
- **App name**: every `.arb` string that says "CookNote" must read "Bepbook" (D-010): `notifRationaleBody`, `backupFolderHint`, `restoreReplaceWarning`, `errBackupNotABackup`, `errBackupNewer`, `importUnknown`, `shareAsCooknote`, `appTitle`. The `.cooknote` extension stays.
- Cook mode: the Read step chip shows the short "Stop" / "Dừng" while reading (full "Stop reading" kept as its spoken label).
- Onboarding page 2 (VI) adds "màn hình luôn sáng" to keep the "stays on" meaning.
- NEW strings used in frames (add to both `.arb`): "Check before saving / Xem trước khi lưu" (preview title), "Sort the lines / Gán dòng" (scan assign title), "Reading the recipe… / Đang đọc công thức…", "{n} steps done · Show / Đã xong {n} bước · Xem", "Start over / Làm lại từ đầu", "Your timer has already started / Hẹn giờ đã bắt đầu chạy", "Show {n} recipes / Xem {n} công thức", "Drop here / Thả vào đây", "Pick text / Chọn chữ", "Your data is unchanged. / Dữ liệu của bạn vẫn nguyên.", "Choose another file / Chọn file khác", backup status words "Safe · Overdue · Failing · Not set up / An toàn · Quá hạn · Đang lỗi · Chưa bật", "Make your first list / Tạo danh sách đầu tiên", "Nothing to buy / Chưa có món cần mua", "All done! / Xong hết rồi!", "Danger zone / Vùng nguy hiểm", "Deleting… / Đang xóa…", "Pages you open are the only thing Bepbook loads from the internet." (browser start page).
- SCR-01 onboarding-2: VI body adds "màn hình luôn sáng" to keep the "stays on" meaning explicit.
- SCR-05 recipes~sort: NEW caption kept: "Recipes without this info go last".
- SCR-13 trash~empty: NEW "Empty trash" set as in brief.
- SCR-15 web~http-info: webInsecureInfo kept as briefed.
- SCR-18 share-in: NEW "Pick text" / "Chọn chữ" and "Write it myself".
- SCR-28 shopping~delete-list: NEW: Delete the list "Chợ" and its 12 items?
- SCR-39 menu-templates~replace-or-add: NEW: "This day already has meals" set as briefed.
- SCR-EXT-02 ext-share-target~ios-card: NEW "Saved to Bepbook — open?" / "Đã gửi sang Bepbook — mở app?"

## Token deviations
None from §2.2/§11.4. Additions beyond the requested list: `successContainer`, `warningContainer`, `infoContainer` (+ on-colours), `currentStepEdge`, `onCurrentStep`, `onTimerActive`, `suggestedContainer`, `ribbon`, `onPhotoPlaceholder` — needed for icon + text + colour states.

## Out of scope / proposals
Only on the separate "Proposals" frame (`P_proposals__default`), marked PROPOSAL: recent sites on the browser start page, Shuffle per suggested meal, split/merge lines in scan assign, fast-scroll letter bubble. Not wired into flows.

## Regenerating
These files were generated from one source (shared components rendered per platform/theme/language/text scale). Ask Claude in the canvas or this repo to change a component and re-export the whole set.
