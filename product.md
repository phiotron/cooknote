# CookNote — Product brief for Hi‑Fi UI design (v1)

> **What this file is for:** the brief to send to **Claude Design** to produce Hi‑Fi mockups (UX/UI optimised) for the
> whole mobile app **CookNote** on **Android + iOS**. It says *what* each screen must do and *why*; *how it looks* is
> Claude Design's proposal, within the limits in §2 and §11.
>
> **Starting point = a full redesign (D‑008).** The app already has working logic and a plain Material UI for part of
> it, but that UI is only a reference for flows. **Do not reuse its look.** Design every screen from scratch, in a new
> visual identity (§2.2).
>
> **Scope = exactly `docs/SPEC.md` F‑01..F‑14 (AC‑01..AC‑65).** Every screen lists the AC it serves. Ideas outside the
> SPEC go to §10 only, marked **Proposal**, in separate frames.
>
> Internal code `A004-cooknote` · Bundle ID `com.phiotron.cooknote` · Version 1.0 · Brief v1 · 2026‑11‑05.
> Glossary: `CONTEXT.md` (Recipe, Ingredient line, Structured ingredient, Scale factor, Cook mode, Meal slot, Aisle,
> Pantry item, Backup…). Copy marked with a key (`webSave`) is real copy from `lib/l10n/app_en.arb` / `app_vi.arb` or
> from the earlier draft UI. Copy marked **NEW:** does not exist yet; the developer adds it to both `.arb` files. You
> may improve any copy; keep the meaning and mark the change `COPY:` in the frame notes.

**Build status tag** on every screen heading (helps you judge risk, not priority — everything is redesigned):
- **[built]** — works in the app today with a plain UI (to be replaced).
- **[draft]** — logic exists; a rough UI was drafted on a side branch, never shipped.
- **[new]** — no UI yet; logic exists or will be built in the next phase.
- 🤖 Android‑specific behaviour · 🍏 iOS‑specific behaviour (§7).

---

## Contents
1. Product overview
2. Design constraints (platforms, visual identity, accessibility, kitchen use, copy length, formatting)
3. Business rules the designer must know
4. Information architecture and navigation
5. Screens (SCR‑00 … SCR‑57) and surfaces outside the app (EXT‑01 … EXT‑06)
6. Key flows (prototype these)
7. Android vs iOS differences
8. Sample data for mockups
9. Known UX risks → design opportunities
10. Out of scope / proposals
11. Deliverables requested from Claude Design

---

## 1. Product overview

### 1.1 One line
**CookNote** — a recipe notebook on your phone: save recipes from any website or from a photo of a cookbook page,
cook with big text and timers, scale servings, plan the week's meals, shop with one list, and keep it all **for life**
with automatic backups in an open format. Offline, no account, free with every feature.

### 1.2 Problem
Home cooks keep recipes everywhere: websites, photos of books, a mother's handwritten notes, chat messages, phone
notes. When cooking, the recipe is hard to find, the screen turns off halfway, quantities must be doubled by hand,
and the shopping list is copied out again. Many people keep one collection for decades and pass it on to their
children — losing the data means losing something that cannot be recovered.

### 1.3 Target users (personas) — everyone aged 13+, Vietnam and worldwide

| Persona | Situation | What they need from the UI |
|---|---|---|
| **Chị Thu, 38, family cook, Hà Nội, Android mid‑range (360 dp wide)** | Cooks for 4 every day. Plans the week on Sunday, shops at the wet market and the supermarket. Wants to digitise her mother's handwritten recipes | Fast weekly menu → one shopping list split by market / supermarket; scan a handwritten page; Vietnamese units (chén, muỗng, củ) shown as written |
| **Minh, 20, student in a dorm, HCMC, iPhone** | Small budget, one pan, finds dishes on YouTube / Facebook / food blogs | Share a link → saved in seconds; "What can I cook?" with the 6 things in his fridge; works with no data plan |
| **Hà, 29, home baker, Đà Nẵng, Android** | Bakes from US blogs in cups and °F, weighs in grams, runs 2–3 timers at once, flour on her hands | Convert a recipe to metric, scale a cake ½×, huge timer buttons, the screen stays on |
| **Bảo, 14, learning to cook, Vietnamese, Android** | Follows simple recipes with a parent; first phone; reads slowly | Plain words, big text, one clear step at a time, "Read step" aloud; nothing to sign up for; nothing to buy |
| **Sarah, 45, London, English, iPhone** | Has used a paid recipe app for years; wants to own her data | Import her old library from a file; US/metric switch; backups she can open in a browser without any app |
| **Cô Lan, 64, retired teacher, Huế, Android, system text 200 %** | Keeps the family recipe collection to hand down; worried about losing it when she changes phones | Readable at 200 % text; backup set up once and then visible as "safe"; print a PDF recipe book for her grandchildren |

### 1.4 Core jobs (priority order — the design must make these effortless)
1. **Save a recipe I found online** — Share → CookNote → preview → Save (AC‑17, AC‑20). The fastest flow in the app.
2. **Cook from a recipe** — Cook mode: screen on, big text, tap to cross off, timers, read aloud (AC‑26..30).
3. **Find a recipe** — search without Vietnamese accents ("pho bo" finds "Phở bò"), filter, sort (AC‑12, AC‑13).
4. **Plan the week → shop** — menu calendar → "Add to shopping" → one merged list by aisle (AC‑38..40, AC‑34..37).
5. **Keep my recipes for life** — automatic backup set up once, honest status, restore on a new phone (AC‑49..57).
6. **Digitise a paper recipe** — scan 1–10 pages, assign lines to name / ingredients / steps (AC‑23..25).
7. **Use what I have** — pantry with expiry, "What can I cook?" (AC‑42, AC‑43).

### 1.5 Design principles
1. **Kitchen‑proof.** In Cook mode the phone stands 0.5–1.5 m away and hands are wet or floury: huge targets, whole
   rows tappable, no precision gestures, nothing that needs a long press or a swipe to work (§2.4).
2. **Offline, private, no account.** No sign‑in anywhere, no avatars, no "sync", no network spinners except the web
   importer. Reassure quietly: "Your recipes live only on this phone."
3. **Your notebook for life.** Backup health is always visible and honest (never green when it isn't safe). The
   open format is a feature to show, not hide: "Backups open in any web browser, even without CookNote."
4. **Never lose work.** Undo after delete (5 s), Trash for 30 days, "Discard changes?" in the editor, imports keep
   what was already done, restore checks the file before touching anything.
5. **Everything is free.** No locks, no "Pro", no crowns, no upsell, no ads, ever. No screen may look like a paywall.
6. **Vietnamese‑first quality, global‑ready.** Accent‑insensitive search, Vietnamese units and fractions, Vietnamese
   strings ~30–60 % longer than English (§2.5).
7. **Never colour alone.** Crossed‑off, expired, expiring, failing backup, unscalable line: each has text or an icon too.
8. **Ask only when needed.** The only runtime permission is notifications, asked the first time a timer starts, after
   an explanation. No camera, photos, storage, location, contacts or microphone permission — the OS pickers do that.
9. **Same app on both platforms**, except OS‑owned behaviour (§7).

### 1.6 How CookNote differs (S‑30 — make it visible in identity and flows)
| Others in the category | CookNote |
|---|---|
| Paid per platform, or a free tier with locked features | **Every feature free**, no account, no ads, no in‑app purchase |
| Your library lives in their cloud account | **Data on your phone + automatic backups to a folder you choose**, in an open zip with readable HTML pages |
| English‑first; Vietnamese search and units are weak | **Accent‑free search**, Vietnamese units (chén, bát, muỗng, củ, tép…), Vietnamese OCR, natural Vietnamese copy |
| Import from their format only | Imports other apps' export files, schema.org JSON and its own `.cooknote` (AC‑44, AC‑45) |

**Do not imitate** any competitor's layout, iconography, colour scheme, logo or wording. Do not look at their
screenshots while designing. CookNote must be recognisable as its own product (Apple 4.3 / Play spam policy, S‑30).

---

## 2. Design constraints

### 2.1 Platforms, frames, orientation
- **Android** (Material 3, edge‑to‑edge, Android 8+) and **iOS 15+** (adaptive Material, iOS conventions where the OS
  owns the behaviour — §7). **One shared layout**, built in Flutter.
- **Base frames:** Android **360 × 800 dp** (smallest supported width — design here first) and iPhone 6.1" **393 ×
  852 pt** (iPhone 15/16). Must also hold at 412 × 915.
- **Portrait only.** Phones only — no tablet, no landscape (also not in Cook mode).
- **Safe areas:** status bar, Android gesture bar / 3‑button bar, Dynamic Island, Home indicator. Bottom bars, FAB,
  timer tray and sheets sit above them.

### 2.2 Visual identity (proposal requested — "a warm kitchen notebook")
There is **no brand yet** — design it. Direction, not a spec:
- **Feeling:** a well‑loved kitchen notebook — warm paper, ink, a ribbon bookmark, tabbed sections, a few stains of
  turmeric and herbs. Calm and homely, not a glossy food magazine, not a fintech dashboard, not childish.
- **Colour:** warm off‑white "paper" surfaces and warm ink (not pure #000 / #FFF); one primary accent (suggest a
  spice tone: turmeric, tamarind, chili‑ember, or a cinnamon brown — your call) and one supporting herb green.
  Semantic colours: success (backup OK, bought), warning (expiring soon, backup overdue), danger (expired, delete,
  backup failing), info. Dark theme = "kitchen at night": warm charcoal, not blue‑black; photos must still pop.
- **Type:** must render **full Vietnamese diacritics** (ă â đ ê ô ơ ư + 5 tones, stacked: "Phở", "Bánh xèo", "ướp")
  without clipping at 200 %. Body: **Noto Sans** is already bundled (OFL) — keep it or propose another OFL family with
  complete Vietnamese. Headings may use a warm serif or humanist face with Vietnamese support (e.g. a Noto Serif / Lora
  class). **No handwriting fonts for content** (legibility); a hand‑drawn touch is fine in illustrations only.
  **Tabular figures** for quantities and timers.
- **Motifs (use lightly):** ruled‑line dividers, notebook‑tab section headers, index‑card recipe tiles, a ribbon
  bookmark for "pinned / favourite". No heavy skeuomorphism, no fake paper textures that hurt contrast.
- **Icons:** one free, licence‑clear set (Material Symbols Rounded, Phosphor or Lucide — say which, licence noted for
  S‑70). Needed glyphs include timer, cook (pan/flame), scale, shopping basket, pantry jar, calendar, backup cloud‑off
  or shield, trash, drag handle, scan, globe, share, print, speaker.
- **Logo & icon:** propose an app icon (notebook + spoon/ribbon or similar). Avoid chef hats, chili peppers and
  generic fork‑and‑knife marks (too close to others in the category). The name "CookNote" is **not yet cleared as a
  trademark** and may change, so the icon must work **without the wordmark**.
- **Photos are the hero** on recipe tiles and detail; the UI around them stays quiet. Recipes without a photo need a
  beautiful placeholder (e.g. an index card with the recipe's initial and a category tint) — many scanned or typed
  recipes will have none.

### 2.3 Accessibility (WCAG 2.2 AA — S‑50, F‑13)
- **Touch targets ≥ 48 × 48 dp / 44 × 44 pt everywhere (AC‑60); ≥ 64 dp for primary controls in Cook mode.**
- **System text up to 200 % without clipping or overlap** on all main screens (AC‑61). Show reflow rules: at ≥ 150 %,
  meta chips wrap, two‑column rows stack, bottom‑nav labels may hide only if the OS does it, sheets scroll.
- **Contrast** ≥ 4.5:1 for text, ≥ 3:1 for large text, icons and control boundaries, in light **and** dark (AC‑61).
  Text over photos needs a scrim.
- **Screen readers (TalkBack, VoiceOver) — AC‑62:** every button has a spoken label (listed per screen); every
  ingredient and step is read on its own, with "crossed off" state in Cook mode; ratings read "4 of 5 stars"; timers
  read the remaining time ("Step 3, simmer, 12 minutes 40 seconds left"). Drag‑and‑drop always has an alternative
  (Move up / Move down / Move to…).
- **State is never colour‑only** — crossed‑off = strike‑through + check icon + dimmed; expired = icon + word.
- Respect **reduce motion**; no auto‑playing animation. Visible 2 px focus ring for keyboard / switch access.

### 2.4 Kitchen use (Cook mode and Shopping — design for real conditions)
- **Distance:** default step text in Cook mode must be readable at ~1 m (suggest ≥ 24 sp body, ≥ 28 sp current
  step), with an in‑app text size control on top of the system size (AC‑26).
- **Wet / floury hands, phone on a stand:** big hit areas; the whole ingredient row / step card is the target; the
  primary "next" action sits in the thumb zone at the bottom; no long‑press‑only or swipe‑only actions; accidental
  double taps must not cross off two lines (debounce is the dev's job — design a clear "undo cross‑off" by tapping again).
- **Glare and steam:** high contrast in Cook mode in both themes; no thin hairline type.
- **Shopping:** one hand, walking, weak signal (all offline anyway); check‑off by tapping anywhere on the row.

### 2.5 Languages and copy length
- **English and Vietnamese**, follows the device, switchable in Settings (AC‑58). "CookNote" stays the same.
- **Design in English, then check Vietnamese** on tight screens (VI frames listed in §11.2). Longest / riskiest
  strings (EN | VI):

| Key | EN | VI (longest) | Where it bites |
|---|---|---|---|
| `backupFolderHint` | Pick a folder once, on this phone or in Google Drive or OneDrive. CookNote writes backups there when you open or leave the app and keeps the latest few. If the cloud app does not allow automatic writes, use "Back up now and save elsewhere" below. | Chọn một lần một thư mục trên máy hoặc của Google Drive, OneDrive. CookNote tự ghi bản sao lưu vào đó khi bạn mở hoặc rời app, và giữ vài bản gần nhất. Nếu ứng dụng đám mây không cho ghi tự động, hãy dùng "Sao lưu ngay và lưu ở nơi khác" bên dưới. | Backup screen, 5–7 lines |
| `backupFailedVerify` | The written file failed the read-back check, so it does not count as a successful backup. Try again or pick another folder. | File ghi ra bị lỗi khi đọc lại nên chưa tính là sao lưu thành công. Thử lại hoặc chọn thư mục khác. | Error card |
| `notifRationaleBody` | CookNote needs notification permission to alert you when a timer ends, even when the screen is locked or the app is in the background. It is used only for cooking timers. | CookNote cần quyền thông báo để báo bạn khi hẹn giờ kết thúc, kể cả khi màn hình khóa hoặc app ở nền. Quyền này chỉ dùng cho hẹn giờ nấu. | Rationale dialog |
| `notifDeniedWarning` | Notifications are off: timers still run but will not alert while the app is in the background. | Chưa có quyền thông báo: hẹn giờ vẫn chạy nhưng sẽ không báo khi app ở nền. | Cook mode banner |
| `noVoiceBody` | Open the device Settings, find "Text-to-speech" (the name may differ by manufacturer), pick the language and download a voice. | Vào Cài đặt của máy, tìm "Chuyển văn bản thành giọng nói" (tên có thể khác tùy hãng), chọn ngôn ngữ rồi tải giọng đọc. | Dialog |
| `importUnverified` | The Paprika and Recipe Keeper formats are read from third-party documentation and are not yet verified against every real file. If a file cannot be read, your data stays unchanged. | Định dạng của Paprika và Recipe Keeper được đọc theo tài liệu của bên thứ ba và chưa thử với mọi file thật. Nếu file không đọc được, dữ liệu của bạn vẫn giữ nguyên. | Import screen note |
| `restoreReplaceWarning` | All current data will be replaced. CookNote saves a copy of the current data first. | Dữ liệu hiện tại sẽ bị thay thế toàn bộ. CookNote tự lưu một bản dữ liệu hiện tại trước khi thay. | Confirm dialog |
| `shareAsCooknote` | Send a .cooknote file (importable in CookNote) | Gửi file .cooknote (người nhận có CookNote nhập được) | Share sheet row (2 lines) |
| `restoreMerge` | Merge (only add missing recipes) | Gộp (chỉ thêm công thức chưa có) | Radio / button |
| `filterFavorite` | Favorites only | Chỉ công thức yêu thích | Filter switch |
| `sortLastCooked` | Last cooked | Lần nấu gần nhất | Sort menu |
| `cookPin` | Pin for quick access | Ghim để nấu nhanh | Cook mode action |
| `saveScaled` | Save at this scale | Lưu theo khẩu phần này | Button |
| `tabShopping` / `tabPantry` | Shopping / Pantry | Đi chợ / Tủ bếp | Bottom nav (5 items on 360 dp!) |
| `webDuplicateBody` | This address is already in your book. Open the old one or save a new copy? | Địa chỉ này đã có trong sổ. Mở bản cũ hay lưu thêm một bản mới? | Dialog |
| `cannotScale` | cannot be scaled automatically | không tự nhân được | Inline marker on a line |
| NEW: `canCookMissing` | Missing {n}: {items} | Còn thiếu {n} món: {items} | Can‑cook row, 2 lines |
| NEW: `basicsToggle` | Don't count basic seasonings as missing (salt, sugar, water, pepper, cooking oil, fish sauce) | Không tính gia vị cơ bản là thiếu (muối, đường, nước, tiêu, dầu ăn, nước mắm) | Switch with 3‑line label |

### 2.6 Numbers, quantities, dates
- **Quantities** come from recipes as written. Structured lines are shown in a tidy form: `1 1/2 cup`, `375 g`,
  `2–3 tép tỏi`; never `0.33333` (AC‑32). You may propose typographic fractions (`1½`) if they stay legible at 200 %
  and are spoken correctly ("one and a half"). Vietnamese decimals use a comma (`1,5 kg`), English a dot (`1.5 kg`).
- **Units** stay in the recipe's language (chén, muỗng canh, củ / cup, tbsp, clove). "Chén" and "bát" are never
  converted (AC‑33).
- **Times:** `45 min` / `45 phút`; `1 h 30 min` / `1 giờ 30 phút`. Timers `12:40`, `1:05:00`.
- **Temperatures** in steps: `180°C` ↔ `350°F` when converting (AC‑33).
- **Dates:** EN `Thu, Nov 5` / `Nov 5, 2026`; VI `Th 5, 5/11` / `5 thg 11, 2026`. Today = "Today" / "Hôm nay".
  First day of the week from Settings (Monday or Sunday — AC‑58).
- **Counts with plurals:** `{n} recipes` / `{n} công thức` (Vietnamese has no plural form).
- **Ratings:** 0–5 whole stars. 0 = "No rating" / "Chưa đánh giá".

---

## 3. Business rules the designer must know
(Exact definitions: `CONTEXT.md`. AC numbers point to `docs/SPEC.md`.)

**Recipes (F‑01, F‑02)**
1. A **Recipe** has: name (required, ≤ 200 chars), ingredients and steps (each a list of lines, optionally split into
   **groups** with a heading such as "For the broth:"), servings (number + unit text: "4 people"), prep / cook / total
   time, source text + source URL, notes, nutrition (free text), difficulty (Not set / Easy / Medium / Hard), rating
   0–5, favourite, up to **20 photos** with one **cover** (AC‑02).
2. In the editor, pasting a block of text makes **one line per item**; a line ending with `:` becomes a **group
   heading**. Lines can be **dragged to reorder** (AC‑03).
3. Save writes everything at once (AC‑04). Delete → confirm → **"Recipe deleted · Undo" for 5 s** → **Trash** for 30
   days → gone for good with its photos. Restorable from Trash (AC‑05). **Duplicate** makes "Name (copy)" (AC‑06).
4. Photos come from the OS photo picker or the OS camera app; **no permission dialog** (AC‑07, AC‑08). Photos are
   copied into the app, so deleting them from the gallery doesn't affect the recipe.
5. **Categories** nest up to **3 levels** ("Main dishes > Vietnamese > Noodle soups"); a recipe can be in 0..n
   categories; deleting a category never deletes recipes. Six default categories on first launch (Main dishes, Side
   dishes, Soups, Desserts, Drinks, Baking) (AC‑10). **Tags** are free words with type‑ahead (AC‑11).
6. **Search** covers name, ingredients, steps, notes, source; ignores case and Vietnamese accents (AC‑12).
7. **Filters** combine with each other and with search: categories (incl. sub‑categories), tags (must have all),
   minimum stars, favourites only, maximum total time, "has ingredient X". **Sort**: name, date added, date edited,
   rating, cooking time, last cooked (asc/desc). The result count is always shown (AC‑13). Grid / list choice is
   remembered (AC‑14).
8. **Mark as cooked** adds today to the recipe's **cooked log**; detail shows "Cooked 6 times · Last time: Nov 1"
   (AC‑15).

**Import (F‑03, F‑04, F‑10)**
9. Web pages with schema.org `Recipe` data fill in everything automatically; pages without it go to **Pick text**
   mode: select text on the page, then "Is the name" / "Is ingredients" / "Is the steps" (AC‑18, AC‑19).
10. **Always a preview before saving** (AC‑20). Same URL already saved → "You already have this recipe" → Open the
    old one / Save a new copy. Web photos are downloaded so they work offline (AC‑22).
11. Every page load has a **20‑second timeout**; no network / timeout / HTTP error → clear reason + **Try again**;
    nothing already picked is lost (AC‑21).
12. Shared **text that is not a URL** opens the editor with that text, ready to assign (AC‑17).
13. **Scan:** 1–10 images (gallery, OS camera) or a PDF; text recognition runs **on the phone**; Vietnamese with
    accents and English. The **assign** screen shows each recognised line; the user taps lines and assigns Name /
    Ingredients / Steps / Notes, edits text, optionally keeps the page photos as recipe photos. **Handwriting has no
    accuracy promise** and the screen says so (AC‑23..25). The app pre‑sorts lines (likely title / ingredient / step
    / heading / note / noise) — the user confirms or changes.
14. **Import a file:** other apps' exports (`.paprikarecipes`, Recipe Keeper `.zip`), schema.org JSON, `.cooknote`.
    Report: imported / already present / skipped with reasons. Re‑importing the same file creates no duplicates
    (AC‑44, AC‑45).

**Cooking (F‑05, F‑06)**
15. **Cook mode:** screen stays on; bigger adjustable text; the **current step** (= first step not crossed off) is
    highlighted; tap an ingredient or step to cross it off (tap again to undo). Leave and come back within **12 hours**
    → crossed‑off lines are kept (AC‑26).
16. Durations in steps become **timer buttons**: "nấu 15 phút", "1 tiếng 30 phút", "10‑15 phút" (uses the larger),
    "bake for 25 minutes", "1 hour" (AC‑27).
17. **Several timers at once**, each named after its step. Time up → sound + notification even when locked or in the
    background (±2 s). The notification permission is asked **the first time a timer starts**, after an explanation.
    Denied → timers still run and ring while the app is open, with the warning `notifDeniedWarning` (AC‑28).
18. **Pin up to 5 recipes** being cooked; switch between them from a bar at the top of Cook mode (AC‑29).
19. **Read step** uses the OS voice in the recipe's language; no voice for that language → explain how to install one
    (AC‑30).
20. **Scale:** pick servings, or a factor (½×, 2×, 3×, custom). All **structured** lines are multiplied and shown
    tidily; **unstructured** lines ("hành lá, rau thơm", "a pinch of salt") stay as written with a marker "cannot be
    scaled automatically". Scaling is **view‑only** until "Save at this scale" (AC‑31, AC‑32).
21. **Convert units:** Original / Metric / US. Volume ↔ volume, weight ↔ weight, °C ↔ °F in steps. Never volume ↔
    weight. Chén / bát never convert (AC‑33).

**Shopping (F‑07)**
22. Several **shopping lists** (e.g. "Supermarket", "Wet market"). Add by hand with type‑ahead from past items, or one
    tap from **Frequent items** (AC‑34).
23. **Add from a recipe** (at the servings being viewed) or **from the menu** (AC‑40): a picker shows every ingredient,
    **items already in the Pantry start unchecked**. Same name + same kind of unit → **merged and summed** ("200 g beef"
    + "300 g beef" = "500 g beef"); different unit kinds → two lines. Each item remembers **which recipe(s)** it came
    from (AC‑35).
24. Items sort themselves into **aisles** (Produce, Meat & fish, Dairy & eggs, Dry goods, Spices & sauces, Frozen,
    Drinks, Other) from a built‑in VI/EN dictionary. Move an item to another aisle → remembered next time. Aisles can
    be added, renamed and reordered to match the shop's path (AC‑36).
25. Tap to check off; checked items drop to the bottom. "Clear checked items", with the option **"Move bought items to
    the Pantry"**. Share a list as text via the OS share sheet (AC‑37).

**Menu (F‑08)**
26. Calendar by **day / week / month**. Each day has **meal slots** (default Breakfast, Lunch, Dinner, Snack — rename,
    add, remove). A slot holds **0..n items**: a recipe (with its own servings) or a free‑text line ("Eating out").
    **Drag** an item to another day or slot. Week starts on the day set in Settings (AC‑38).
27. **Menu templates** are named sets of items ("Family dinner, 4 dishes", "Birthday party") applied to a day or a
    week in one action (AC‑39).
28. **Add to shopping** for a date range sends every recipe's ingredients, at each item's servings, through the
    picker of rule 23 (AC‑40).
29. **Random suggestions** fill the **empty** slots of a week with recipes matching filters (categories, tags, max
    time), without repeating a recipe in the week while others match. **Preview first**, then apply (AC‑41).

**Pantry (F‑09)**
30. **Pantry items:** name, quantity (optional), aisle, purchase date, expiry date (optional). ≤ 3 days to expiry →
    **Expiring soon**; past expiry → **Expired**; filter by both (AC‑42).
31. **What can I cook?** lists recipes by the share of their ingredients you have (names matched ignoring accents and
    English plurals), with "Missing N". Optional switch: basic seasonings (salt, sugar, water, pepper, cooking oil, fish
    sauce) never count as missing (AC‑43).

**Share, export, print (F‑10)**
32. Share one recipe as **text**, **PDF** or a **`.cooknote` file** (AC‑46). Export a **Recipe book PDF** from
    selected recipes or a category: cover (title, photo), contents with page numbers, each recipe on a new page with
    its cover photo; Vietnamese renders correctly; print through the OS print dialog (AC‑47). No storage permission;
    temporary files are cleaned up (AC‑48).

**Backup (F‑11) — the heart of "for life"**
33. A **backup** is one `.cooknote` file (an open zip): data, photos, and **HTML pages readable in any browser without
    CookNote** (AC‑49).
34. **Automatic backup:** choose a target folder **once** with the OS folder picker (phone, Google Drive, OneDrive…
    if that app allows it). Daily (default) or weekly. Runs when the app opens or goes to the background, **only if the
    period has passed and data changed**, without slowing the user. Keeps the latest **5** copies (1–30); deletes only
    its own older files (AC‑50).
35. Every backup is **read back and verified**; a failed check is an error, not a success. Lost access to the folder →
    a warning on the Recipes tab with "choose the folder again" (AC‑51).
36. **Back up now and save elsewhere** creates a file and opens the share sheet / save dialog — the fallback when a
    cloud app refuses automatic writes (AC‑52).
37. The Backup screen shows the last **successful** backup (time, place, result, size). **> 7 days** (adjustable)
    without one → an in‑app reminder (no OS notification). At **10 recipes** the app suggests turning on automatic
    backup, **once** (AC‑53).
38. **Restore** from a file or from the list of copies in the automatic folder. The file is checked **before** any
    data is touched. **Replace everything** (confirm; the app first saves a copy of current data) or **Merge** (only
    add recipes you don't have). Bad file → error, data unchanged (AC‑54). Big restores show progress and can be
    cancelled (AC‑57).
39. The OS backup layer (Android Auto Backup / iOS iCloud backup) is a **secondary** layer: no guarantee for photos,
    not a replacement — the Backup screen says so (AC‑56).
40. Backup files are **not encrypted**: the Backup screen says so (SPEC §6).

**App, privacy (F‑12..F‑14)**
41. Theme Light / Dark / System; language EN / VI / System; first day of week; default unit system (Metric / US)
    (AC‑58).
42. **Onboarding:** ≤ 3 pages, skippable, asks **no permission**, says data lives only on the phone and that backup is
    needed to keep it, with a **"Turn on automatic backup"** button (AC‑59).
43. **About:** version, privacy policy link, security‑report email, open‑source licences, and a note that recipes
    imported from websites belong to their authors and are for personal use (AC‑63, S‑70).
44. **Delete all data** (Settings): asks first whether to back up, then **two confirmation steps**; deletes database,
    photos and settings, not backup files in outside folders; the app then starts as freshly installed (AC‑64).
45. **No data leaves the phone** except loading the web pages the user opens (AC‑65). No analytics, no crash SDK.

---

## 4. Information architecture and navigation

### 4.1 Global structure
```
First launch → SCR-01 Onboarding (3 pages, skippable)
Bottom navigation bar, 5 destinations (AC-01):
├── 1. Recipes   (SCR-02, default)  ── FAB "+" → SCR-03 Add sheet
│     ├── SCR-07 Recipe detail → SCR-08 Servings & units · SCR-09 Share · SCR-10 Photos · SCR-11 Edit
│     │                          → SCR-23 Cook mode · SCR-32 Add to shopping · SCR-37 Add to menu
│     ├── SCR-04 Filter sheet · SCR-05 Sort menu · SCR-06 Selection mode (share / JSON / PDF book / trash)
│     ├── SCR-51 Backup notice banner (when needed)
│     └── via "+": SCR-11 Write it myself · SCR-15 From a website · SCR-19 Scan a photo · SCR-22 Import a file
├── 2. Menu      (SCR-34 Week default · SCR-35 Day · SCR-36 Month)
│     └── SCR-37 Add to meal · SCR-38 Item actions · SCR-39 Templates · SCR-40 Random · SCR-41 Range → shopping
├── 3. Shopping  (SCR-27) → SCR-28 Lists · SCR-29 Add item · SCR-30 Item sheet · SCR-31 Aisles · SCR-33 Clear/share
├── 4. Pantry    (SCR-43) → SCR-44 Item sheet · SCR-45 What can I cook? → SCR-32 Add missing to shopping
└── 5. More      (SCR-46)
      ├── SCR-47 Backup → SCR-48 Auto-backup setup · SCR-49 Progress · SCR-50 Restore
      ├── SCR-14 Categories · SCR-13 Trash · SCR-52 Import & export (Recipe book PDF)
      ├── SCR-53 Settings → SCR-42 Meal slots · SCR-31 Aisles · SCR-54 Delete all data
      └── SCR-55 About → SCR-56 Open-source licences
Incoming share from another app (EXT-02) → SCR-18 → SCR-15/17 (URL) or SCR-11 (text)
Timer notification tap (EXT-01) → SCR-23 Cook mode of that recipe
```

### 4.2 Routes (for file naming; the developer finalises names)
Existing: `/` (tabs), `/recipe/new`, `/recipe/:id`, `/recipe/:id/edit`, `/recipe/:id/photos`, `/backup`,
`/categories`, `/trash`, `/settings`. Planned: `/onboarding`, `/web`, `/web/preview`, `/scan`, `/scan/assign`,
`/import`, `/recipe/:id/cook`, `/menu/templates`, `/menu/random`, `/shopping/aisles`, `/pantry/can-cook`,
`/exchange`, `/settings/meal-slots`, `/about`, `/licenses`.

### 4.3 Navigation rules
- Bottom bar visible on the 5 tab roots only; hidden in detail, editor, Cook mode, browser, scan.
- **5 labels on 360 dp** in Vietnamese ("Công thức · Thực đơn · Đi chợ · Tủ bếp · Thêm") must fit at 100 % text and
  degrade gracefully at 200 % (labels may truncate only as the OS bar does; icons stay distinct).
- Each tab keeps its own back stack and scroll position.
- The **FAB "+"** lives on Recipes, in the thumb zone (AC‑01). Other tabs have their own primary action (Add item,
  Add to meal, Add to pantry) in the same position for consistency.
- **Back** (Android button/gesture, iOS edge swipe or app‑bar back) — §7. The editor and the scan‑assign screen ask
  before discarding changes (AC‑03).
- **Cook mode** is a full‑screen mode (no bottom bar). Leaving it keeps timers running; a **running‑timers pill**
  appears above the bottom bar on every screen so the user can jump back (SCR‑24).

---

## 5. Screens

Per screen: **Purpose · Components · States · Interactions · Copy (EN | VI) · A11y · AC.**
Every screen in **light + dark**. Sample content in §8. "VI" shows the longest Vietnamese string when it matters.

### SCR‑00 · Launch / splash · [built]
App icon centred on the paper background (light) / warm charcoal (dark); no text, < 1 s. iOS launch screen static.
Android 12+ splash API (icon on solid colour).

### SCR‑01 · Onboarding (3 pages) · [new] · AC‑59
**Purpose:** say what CookNote is, that data stays on the phone, and get backup turned on — without asking any
permission.
**Components:** page indicator (3 dots + "1 of 3" for screen readers); **Skip** on every page (top‑right); illustration
per page; title + 1–2 lines; primary button.
1. **"Your recipes, one notebook"** — illustration: a notebook collecting a web page, a photo of a handwritten card and
   a typed recipe. Body: "Save recipes from websites, photos of cookbooks, or write your own." Button **Next**.
2. **"Made for the kitchen"** — big text, timers, scaling. Body: "Big text that stays on, timers for every step, and
   servings that scale themselves." Button **Next**.
3. **"Keep them for life"** — notebook in a safe/folder with a ribbon. Body: "Your recipes live only on this phone.
   No account, nothing sent anywhere. Turn on automatic backup to a folder you choose so you never lose them."
   Primary **Turn on automatic backup** (→ OS folder picker, SCR‑48) · secondary **Later**.
**States:** each page · page 3 after the folder was chosen ("Backup is on · Folder: CookNote Backups" + **Start
cooking**) · page 3 when the picker was cancelled (stays, nothing changed) · VI · 200 %.
**Interactions:** swipe or Next; Skip → Recipes (empty state). Finishing never shows again (AC‑59).
**Copy (all NEW):** "Your recipes, one notebook" / "Mọi công thức, một cuốn sổ" · "Made for the kitchen" / "Sinh ra
cho căn bếp" · "Keep them for life" / "Giữ trọn đời" · body texts above / "Công thức của bạn chỉ nằm trên điện thoại
này. Không tài khoản, không gửi đi đâu cả. Bật sao lưu tự động vào thư mục bạn chọn để không bao giờ bị mất." ·
Skip / Bỏ qua · Next / Tiếp · Turn on automatic backup / Bật sao lưu tự động · Later / Để sau · Start cooking / Bắt
đầu nấu.
**A11y:** illustration decorative; "Page 3 of 3"; Skip reachable first.

### SCR‑02 · Recipes tab (list) · [built] · AC‑01, 12, 13, 14, 51, 53
**Purpose:** find any recipe in seconds among hundreds or thousands; start adding one.
**Components (top → bottom):**
1. App bar: title "Recipes"; actions **View grid/list** toggle (`viewGrid`/`viewList`), overflow (Select, Trash).
2. **Search field** "Search recipes" (`searchHint`) with clear button; accent‑insensitive.
3. **Filter row:** button "Filter (3)" (`filterWithCount`) + active filter chips (each removable: "Main dishes ×",
   "≥ 4★ ×", "≤ 30 min ×", "Has: chicken ×") + **Sort** button showing the current sort ("Last cooked ↓").
4. **Result line:** "128 recipes" (`resultCount`), and "Clear filters" when filters are on.
5. **Backup notice** (SCR‑51) when needed — above the list, dismissible only where the rule allows.
6. **List:** **Grid** (2 columns at 360 dp; photo card, name 2 lines, small meta: total time, ★ rating, favourite
   ribbon) or **List** (64–72 dp rows: thumbnail 56, name, one meta line "45 min · ★★★★☆ · Main dishes").
   No‑photo placeholder per §2.2.
7. **FAB "+"** "Add recipe" (bottom‑right, thumb zone) → SCR‑03.
8. **Running‑timers pill** (SCR‑24) above the bottom bar when timers run.
**States:** first‑run empty ("No recipes yet" / "Tap + to add your first recipe" + 4 quick buttons mirroring
SCR‑03) · loaded grid · loaded list · **searching** (live results) · **no match** ("No recipes match" + Clear filters)
· filters active · 5,000 recipes (fast scroll / scroll thumb) · backup notice variants (SCR‑51) · selection mode
(SCR‑06) · VI · 200 % (grid becomes 1 column or list) · loading (local DB, no spinner; at most a skeleton for 300 ms).
**Interactions:** tap card → detail; long‑press card → selection mode (also reachable from overflow "Select" — never
long‑press‑only); pull‑to‑refresh not needed (local). Grid/list remembered (AC‑14).
**Copy:** Recipes/Công thức · Search recipes/Tìm công thức · Filter ({n})/Lọc ({n}) · Sort/Sắp xếp · {n}
recipes/{n} công thức · No recipes match/Không có công thức nào khớp · Clear filters/Xóa bộ lọc · Grid view/Xem dạng
lưới · List view/Xem dạng dòng · No recipes yet/Chưa có công thức nào · Tap + to add your first recipe/Bấm + để thêm
công thức đầu tiên.
**A11y:** card label "Phở bò Hà Nội, 3 hours 30 minutes, 5 of 5 stars, favourite"; result count is a live region
after search; filter chips "Remove filter Main dishes".

### SCR‑03 · Add‑recipe sheet · [built] · AC‑01
Bottom sheet from the FAB, 4 large rows (icon + title + one‑line hint), all in thumb reach:
- **Write it myself** (`addManual`) — "Type or paste a recipe" (NEW) → SCR‑11.
- **From a website** (`fromWeb`) — "Open a page or paste a link" (NEW) → SCR‑15. Badge "needs internet" (NEW: "Needs
  internet" / "Cần mạng").
- **Scan a photo** (`scanPhoto`) — "Cookbook page or handwritten card" (NEW) → SCR‑19.
- **Import a file** (`importFile`) — "From another app or a backup" (NEW) → SCR‑22.
Plus a tip line: "Tip: in your browser, tap Share → CookNote" (NEW / "Mẹo: trong trình duyệt, bấm Chia sẻ → CookNote").
**States:** default · offline (From a website still enabled; shows "You're offline" note — the browser screen handles it).
**VI:** Tự viết · Từ trang web · Quét từ ảnh · Nhập từ file.

### SCR‑04 · Filter sheet · [built] · AC‑13
Full‑height bottom sheet: **Categories** (tree with checkboxes, sub‑levels indented, "includes sub‑categories"),
**Tags** (chips, multi‑select, "must have all"), **Minimum stars** (0–5 selector), **Favourites only** (switch),
**Maximum total time** (Any / 15 / 30 / 45 / 60 / 90 / 120 min chips or slider), **Has ingredient** (text field with
chips, e.g. "gà", "chicken"). Sticky footer: **Clear filters** (text) + **Show 24 recipes** (NEW: live count on the
button) / `done`.
**States:** none set · several set · no categories/tags yet (helper text + link "Manage categories") · count 0 (button
"No recipes match" disabled‑looking but still closes) · 200 % (sections stack).
**Copy:** Categories/Danh mục · Tags/Thẻ · Minimum stars/Số sao tối thiểu · Favorites only/Chỉ công thức yêu thích ·
Maximum total time/Tổng thời gian tối đa · Has ingredient/Có nguyên liệu · Any/Bất kỳ · NEW: Show {n} recipes / Xem
{n} công thức.

### SCR‑05 · Sort menu · [built] · AC‑13
Menu or small sheet: Name · Date added · Date edited · Rating · Cooking time · Last cooked, with an Ascending /
Descending toggle; the current choice checked. Items missing a value (never cooked, no time) always sort last — add
a caption "Recipes without this info go last" (NEW / "Công thức chưa có thông tin này xếp cuối").

### SCR‑06 · Selection mode (bulk actions) · [draft] · AC‑46, 47, 45, 05
Entered by long‑press or overflow **Select**. App bar becomes "3 selected" (`selectedCount`) with **Select all**,
**Exit selection**. Bottom action bar: **Share** · **Export JSON** · **Recipe book (PDF)** → SCR‑52 · **Move to
trash** (confirm → "Moved 3 recipes to trash · Undo").
**States:** 1 selected · many · all · working "Creating file…" with Cancel · failure "Could not create the file."
**A11y:** each card announces "selected"/"not selected"; selection count is a live region.

### SCR‑07 · Recipe detail · [built] · AC‑09, 15, 05, 06, 29, 32, 35, 46
**Purpose:** read a recipe calmly; jump into cooking, scaling, shopping or the menu.
**Components (top → bottom):**
1. **Cover photo** header (collapses on scroll; tap → SCR‑10; photo count badge "1/4"). No photo → placeholder.
   App bar over it: back, **Favourite** toggle, **Share** (→ SCR‑09), overflow: Edit · Duplicate · Pin for cooking ·
   Print · Delete.
2. **Title** (up to 200 chars — wraps, no truncation), **rating** stars (read‑only here), categories & tags chips.
3. **Meta row:** Servings "4 people" · Prep 30 min · Cook 3 h · Total 3 h 30 min · Difficulty. Wraps at 200 %.
4. **Cooked stats:** "Cooked 6 times · Last time: Nov 1" (`cookedTimes`, `lastCooked`) + **Mark as cooked**
   (`markCooked`) → snackbar "Cooking recorded" (`cookedRecorded`).
5. **Primary action: Cook** (`cookButton`) — large, sticky at the bottom (thumb zone) → SCR‑23.
6. **Ingredients** section header with **Servings & units** control ("4 people · ×1 · Original" → SCR‑08), and
   **Add to shopping** (→ SCR‑32). Group headings ("For the broth") as sub‑headers. Unstructured lines show the
   "cannot be scaled automatically" marker **only while scaled/converted**.
7. **Steps**: numbered, group headings; durations in steps shown as subtle timer chips (they become real timers in
   Cook mode); **URLs in steps and notes are tappable** (AC‑09).
8. **Notes**, **Nutrition**, **Source** ("bepnhathu.example · Open source link").
9. **Add to menu** (→ SCR‑37) as a secondary action (overflow or row near the top — your call).
**States:** full recipe · no photo · no steps ("This recipe has no steps yet." — Cook still opens ingredients) · long
title (200 chars) · many groups · scaled ×2 with banner (SCR‑08) · converted to Metric · pinned (ribbon) · just
duplicated (snackbar "Duplicate created") · deleted (snackbar "Recipe deleted · Undo", back to list) · recipe no
longer exists ("This recipe no longer exists" — e.g. opened from a stale notification) · VI · 200 % · dark.
**Copy:** Cook/Nấu · Mark as cooked/Đánh dấu đã nấu · Cooked {n} times/Đã nấu {n} lần · Never cooked/Chưa nấu lần nào ·
Last time: {date}/Lần gần nhất: {date} · Ingredients/Nguyên liệu · Steps/Các bước · Notes/Ghi chú · Nutrition/Dinh
dưỡng · Source/Nguồn · Edit/Sửa · Duplicate/Nhân bản · Delete/Xóa · Delete this recipe?/Xóa công thức này? · It moves
to the trash and is removed for good after 30 days./Công thức vào thùng rác và bị xóa hẳn sau 30 ngày. · NEW: Add to
shopping/Thêm vào đi chợ · NEW: Add to menu/Thêm vào thực đơn.
**A11y:** each ingredient and step is its own node ("Ingredient: 500 g bánh phở"; "Step 3 of 6: …"); stars "5 of 5
stars"; favourite "Favourite, on".

### SCR‑08 · Servings & units sheet · [draft] · AC‑31, 32, 33
Bottom sheet opened from the Ingredients header (also inside Cook mode):
- **Servings stepper**: "− 4 people +" with direct entry (`scaleServingsButton` "Servings…").
- **Factor chips:** ½× · 1× · 2× · 3× · Custom… (`scaleCustomTitle` "Enter a multiplier (for example 1.5 or 1/2)";
  error `scaleInvalid`).
- **Units:** segmented **Original · Metric · US** (`unitOriginal/Metric/Us`).
- Live preview of 3–4 lines (optional).
After closing, the recipe shows a **view banner**: "Viewing ×2. The original recipe is unchanged." (`viewingScaled`)
or "Viewing converted units…" (`viewingUnitsOnly`) with **Reset** (`resetView`) and **Save at this scale**
(`saveScaled` → confirm "Overwrite the recipe?" / "The ingredients and servings you are viewing will replace the
original." → snackbar "Saved at the new scale").
**States:** original · ×2 · ½× · custom 1.5 · metric conversion with temperature changed in a step ("Preheat the oven to
175°C" with a small "converted" marker) · unscalable lines marked (icon + "cannot be scaled automatically") · chén/bát
line unchanged under conversion · recipe without servings (factor only) · invalid custom entry.
**A11y:** stepper "Servings, 4 people, decrease / increase"; banner announced when it appears.

### SCR‑09 · Share a recipe · [draft] · AC‑46, 47, 48
Sheet: **Share as text** · **Share as PDF file** · **Send a .cooknote file (importable in CookNote)** · **Print**
(OS print dialog, EXT‑03). Then the OS share sheet. Progress "Creating file…" with Cancel; error "Could not create the
file." No permission prompts.
**Copy:** Share/Chia sẻ · Share as text/Chia sẻ dạng chữ · Share as PDF file/Chia sẻ file PDF · Send a .cooknote file
(importable in CookNote)/Gửi file .cooknote (người nhận có CookNote nhập được) · Print/In.

### SCR‑10 · Photo viewer (full screen) · [built] · AC‑09
Black background (both themes), swipe between photos, pinch and double‑tap zoom, "2 / 4" counter, close button, cover
photo marked "Cover". Swipe down to close (plus a visible close button).
**A11y:** "Photo 2 of 4"; close button labelled; zoom not required to read content.

### SCR‑11 · Recipe editor (new / edit) · [built; drag reorder new] · AC‑02, 03, 04, 07, 08, 10, 11, 17, 24
**Purpose:** type, paste or fix a recipe quickly; never lose work.
**Components (top → bottom):**
1. App bar: close/back, title "New recipe"/"Edit recipe", **Save** (always visible; disabled‑looking state still
   tappable to show the "Enter a name" error).
2. **Photos strip:** add (+ "Add photos" → sheet "From gallery" / "Take a photo" — both OS UIs, no permission),
   thumbnails with cover badge, reorder by drag (and "Make cover" / "Remove photo" menu), counter "4/20".
3. **Name** (required, counter at 180+/200).
4. **Ingredients** — two modes of the same content, switchable with a small segmented control:
   - **Text** mode: one multi‑line field; hint "One per line. End a line with : for a group title." Pasting a block
     splits into lines.
   - **Lines** mode: each line a row with a **drag handle**, group headings visibly different (bold, tab‑style), row
     menu: Move up / Move down / Make heading / Delete. "Add line" at the end.
5. **Steps** — same two modes; steps numbered automatically.
6. **Details** (collapsible group): Servings (number + unit "people"), Prep / Cook / Total (min), Difficulty, Rating
   (5 tappable stars, 48 dp each), Favourite, Categories (→ SCR‑12), Tags (chips + type‑ahead, `tagsHint`), Source,
   Source link, Notes, Nutrition.
**States:** empty new · prefilled from shared text (banner "Text from another app — split it into ingredients and steps"
NEW) · prefilled from web preview / scan · editing existing · name missing error · name too long · 20 photos (add
disabled + `tooManyPhotos`) · photo can't be read (`imageError`) · photo processing (thumbnail shimmer) · dragging a
line · Lines mode with 3 groups · **Discard dialog** ("Discard changes?" / "Your changes to this recipe have not been
saved." / Keep editing · Discard) · keyboard open (Save still reachable) · VI · 200 %.
**A11y:** drag handle "Reorder Step 3"; custom actions Move up/down; star buttons "Rate 4 of 5 stars"; errors announced.
**Copy:** New recipe/Công thức mới · Edit recipe/Sửa công thức · Save/Lưu · Name/Tên · Enter a name/Hãy nhập tên ·
At most 200 characters/Tối đa 200 ký tự · Servings/Khẩu phần · Unit (e.g. people)/Đơn vị (ví dụ người) · Prep
(min)/Sơ chế (phút) · Cook (min)/Nấu (phút) · Total (min)/Tổng (phút) · Difficulty: Not set · Easy · Medium ·
Hard/Chưa đặt · Dễ · Vừa · Khó · Photos/Ảnh · Add photos/Thêm ảnh · From gallery/Từ thư viện · Take a photo/Chụp ảnh ·
Remove photo/Gỡ ảnh · Cover/Ảnh bìa · NEW: Text · Lines / Dạng chữ · Từng dòng · NEW: Make heading / Đặt làm tiêu đề
nhóm · NEW: Add line / Thêm dòng.

### SCR‑12 · Category picker & tags (inside editor) · [built] · AC‑10, 11
Sheet "Choose categories": tree with checkboxes (3 levels, indented), search if > 15, "Add category" inline; empty
"No categories yet". Tags: input chips with type‑ahead from existing tags, remove "×" (`removeTag` "Remove tag
{tag}"), limit 40 chars (`tagTooLong`).

### SCR‑13 · Trash · [built] · AC‑05
List of deleted recipes with "Removed for good in 27 days" (NEW / "Xóa hẳn sau 27 ngày") per row; info line "Recipes
are removed for good 30 days after deleting." Row actions **Restore** (snackbar "Recipe restored") and **Delete
forever** (confirm "This recipe and its photos will be removed for good."). Optional **Empty trash** (NEW, confirm).
**States:** empty ("The trash is empty") · items · last day ("Removed for good tomorrow" in warning style + icon).

### SCR‑14 · Categories manager · [built] · AC‑10
Tree list, up to 3 levels, with **drag handles** to reorder (siblings), per‑row menu: Add subcategory (hidden at
level 3, with `categoryDepthLimit` explanation if attempted), Rename, Delete ("Its subcategories are deleted too.
Recipes are not deleted."), **Recipe book (PDF)** from this category (→ SCR‑52). Row shows recipe count. FAB / button
"Add category". Name dialog 1–50 chars (`categoryNameInvalid`).
**States:** default 6 categories · nested 3 levels · empty · rename dialog · delete confirm · dragging.

### SCR‑15 · In‑app browser · [draft] · AC‑16, 21, 18, 65
**Purpose:** find a recipe page and save it, all inside CookNote.
**Components:** top **address bar** (`webAddressHint` "Address or search words"; typing words searches with the
default search engine), progress bar while loading; web content; bottom toolbar: **Back**, **Forward**, **Reload**, and
the always‑visible primary **Save recipe** (`webSave`, large, thumb zone).
**States:**
- **Start page** (no URL): hint `webStartHint` ("Type an address or search words (for example "pho bo"), open a page
  with a recipe, then tap Save recipe.") + recent sites (proposal, local only).
- **Loading** (progress), **loaded**.
- **Errors**, each with **Try again** (`webRetry`): no network (`webErrorNetwork`), timeout 20 s (`webErrorTimeout`),
  HTTP error (`webErrorHttp` "The page reported error {code}."), other (`webErrorOther`). Offline on open: same error.
- **Reading the page** after Save (short progress ≤ 5 s target) → SCR‑17 preview, or → SCR‑16 if no recipe data,
  or `webReadFailed`.
**Interactions:** Android Back = web back first, then leave (§7). Pages may set cookies — nothing extra is added by
CookNote.
**Copy:** Import from a website/Nhập từ trang web · Back/Trang trước · Forward/Trang sau · Reload/Tải lại · Save
recipe/Lưu công thức · Try again/Thử lại.
**A11y:** toolbar buttons labelled; error text announced; Save recipe always reachable by screen reader at the end.

### SCR‑16 · Pick‑text mode (page without recipe data) · [draft] · AC‑19
Banner over the page: "This page has no recipe data. Select text on the page, then choose below." (`webNoRecipe`).
Bottom panel (stays above the OS text‑selection toolbar): three big buttons **Is the name** · **Is ingredients** ·
**Is the steps**; summary "Picked: 12 ingredient lines, 7 step lines" (`webPartsSummary`) with **Clear picks** and
**Continue** (→ SCR‑17). Nothing selected → `webSelectionEmpty`.
**States:** nothing picked · name picked (show the picked name) · ingredients + steps picked · selection active ·
error on network while picking (picks kept).
**Design challenge:** the OS selection handles and copy menu must not cover the three buttons; propose placement.

### SCR‑17 · Import preview (web) + duplicate dialog + photo download · [draft] · AC‑18, 20, 22
**Purpose:** check and fix the imported recipe before it enters the notebook.
**Components:** same layout as SCR‑11 (editor) with a top card: source site name + URL, "Imported from a website"
(NEW), photo candidates (checkable, first = cover). Primary **Save**.
**States:** full schema data (all fields filled) · partial (only name + ingredients) · from pick‑text · **duplicate URL
dialog** ("You already have this recipe" / "This address is already in your book. Open the old one or save a new
copy?" / **Open the old one** · **Save a new copy**) · **downloading photos** "Downloading photos 2/5" with **Skip
photos** · some photos failed ("1 photo could not be downloaded", saved anyway) · network lost during save (recipe
saved without missing photos; message) · VI.
**A11y:** dialog focus on the safest option (Open the old one).

### SCR‑18 · Incoming share (from another app) · [draft] · AC‑17
No own screen needed — show the **transition**: shared URL → SCR‑15 opens that URL and immediately tries to read it →
SCR‑17 (or SCR‑16); shared plain text → SCR‑11 with the text in Ingredients **Text** mode and the banner from SCR‑11.
Also design the case **"app was closed"** (cold start straight into the import) and **"shared from YouTube/Facebook"**
(page with no recipe data → SCR‑16, or a short message "This page has no recipe data" with options **Pick text** /
**Write it myself** NEW).

### SCR‑19 · Scan: choose and review pages · [new] · AC‑23, 65
**Purpose:** turn 1–10 photos or a PDF into recipe text, all on the phone.
**Components:** intro card ("Text is recognised on this phone. Nothing is uploaded." NEW / "Chữ được nhận ngay trên
máy. Không gửi ảnh đi đâu." ) · three sources: **From gallery** (multi‑select, max 10) · **Take a photo** (OS camera,
repeatable) · **Choose a PDF** (NEW) · page thumbnails with order numbers, reorder by drag (+ Move left/right
actions), remove "×", rotate · counter "2/10" · **Recognise text** (NEW) primary.
**States:** empty · 2 pages · 10 pages (add disabled + "At most 10 pages" NEW) · PDF with many pages (first 10 taken +
note) · unreadable file · camera cancelled (nothing changes) · VI.
**Copy NEW:** Scan a photo/Quét từ ảnh · Choose a PDF/Chọn file PDF · Recognise text/Nhận chữ · At most 10 pages/Tối
đa 10 trang.

### SCR‑20 · Scan: recognising · [new] · AC‑23, 25
Full‑screen progress: page thumbnail being read, "Reading page 2 of 3…" (NEW / "Đang đọc trang 2/3…"), **Cancel**.
Target ≤ 10 s per page. Error per page ("Couldn't read page 2" + Skip / Try again).

### SCR‑21 · Scan: assign lines · [new] · AC‑24, 25
**Purpose:** sort recognised lines into a recipe with as few taps as possible.
**Components:**
1. Note: "Printed text works best. Handwriting may need more corrections." (NEW / "Chữ in nhận tốt nhất. Chữ viết tay
   có thể cần sửa nhiều hơn.") — always visible when lines look handwritten / low confidence (AC‑25).
2. **Line list**: each recognised line as a selectable row, with a coloured **role tag + text label** pre‑suggested by
   the app: Name · Ingredient · Step · Heading · Note · Ignore. Low‑confidence lines get an icon. Tap a row to select;
   multi‑select by tapping more rows; "Select from here to the end" shortcut (NEW).
3. **Assign bar** (bottom, thumb zone, sticky): **Name** · **Ingredients** · **Steps** · **Notes** · **Ignore**.
4. Tap the text of a line (or an edit icon) → inline edit; split / merge lines (proposal).
5. Toggle page image ↔ lines (to compare with the original); **Keep page photos as recipe photos** (switch).
6. **Continue** → SCR‑11 prefilled (or SCR‑17‑like preview) → Save.
**States:** fresh (suggested roles) · 3 lines selected · all assigned · line being edited · handwritten page with many
low‑confidence lines · nothing recognised ("No text found on these pages" NEW + Try other photos) · leaving with
changes → discard dialog · VI.
**A11y:** each line "Line 4: 2 muỗng canh nước mắm, suggested Ingredient, not selected"; the assign bar buttons
announce how many lines they will assign.

### SCR‑22 · Import from a file · [draft] · AC‑44, 45, 54
**Components:** intro `importIntro` ("Choose a file exported from Paprika (.paprikarecipes), Recipe Keeper (.zip),
schema.org JSON, or a .cooknote backup."), note `importUnverified` (muted, info icon), **Choose file** (OS file
picker) → progress "Importing recipes…" (count, Cancel) → **result card** "Imported 42 recipes. Already present: 3.
Skipped: 2." with **Details** (list of skipped items + reasons) and **Open recipes**.
**States:** intro · importing · cancelled (`importCancelled` "Recipes imported so far are kept.") · done · done with
skips · unknown format (`importUnknown`) · bad file (`importBadFile`) · `.cooknote` chosen → route to restore choice
(SCR‑50: Merge recommended).

### SCR‑23 · Cook mode · [draft] · AC‑26, 27, 28, 29, 30, 32, 62
**Purpose:** the recipe on a stand, across the kitchen, with wet hands. **The most important screen to get right.**
**Components:**
1. **Pinned bar** (top): up to 5 pinned recipes as large chips (thumbnail + short name), current one highlighted; "Pin"
   action for the current recipe (`cookPin` / `cookUnpin`); limit message `cookPinLimit` ("You can pin at most 5
   recipes. Unpin one first.").
2. **Header row:** recipe name (1–2 lines), **Servings & units** chip ("×2 · Metric" → SCR‑08), **Text size**
   (`cookFontSize`: A− / A+ or a 4–5 step control), **Read step** (`speakStep` / `stopSpeaking`), close (✕).
   A small "Screen stays on" indicator (NEW / "Màn hình luôn sáng").
3. **Two sections** — Ingredients and Steps — as **tabs or a segmented switch** at the top (one‑hand, no small
   targets) or one long scroll; your proposal. Ingredients are tappable rows; crossed = strike‑through + check +
   dimmed.
4. **Steps:** large cards; the **current step** (first not crossed) is emphasised (border/colour + "Now" label);
   tapping a step crosses it and the highlight moves to the next; tap again to undo. Group headings between steps.
   **Timer buttons** inside the step text ("⏱ 15 min" — `timerButtonTooltip` "Set timer for 15 min").
5. Bottom: big **Next step** / **Done** button (NEW) in the thumb zone (alternative to tapping the card), and the
   **timer tray** (SCR‑24).
6. Hint for first use: "Tap a line to cross it off." (`cookTapHint`).
**States:** fresh · halfway (3 of 6 steps crossed, 5 ingredients crossed) · returning within 12 h (state kept; small
note "Continuing where you left off" NEW) · all done (celebratory but calm: "All steps done" NEW + **Mark as cooked**
→ AC‑15) · no steps (`cookNoSteps`) · scaled ×2 + metric · text size max (current step fills the screen, scrolls) ·
system text 200 % + max in‑app size · 2 timers running · timer finished alert (SCR‑24) · notifications denied banner
(`notifDeniedWarning`) · reading aloud (speaker animated, Stop) · pinned bar with 5 recipes · dark (night kitchen).
**Interactions:** tap = cross/uncross; no swipe needed; leaving keeps timers; Android Back / iOS swipe leaves Cook mode
(no confirm — state is kept 12 h). The screen is kept on only while this screen is visible.
**A11y:** "Step 3 of 6, current: Simmer the bones for 3 hours. Not crossed off. Double‑tap to cross off."; crossed
state spoken; timer button "Start timer, 3 hours, for step 3"; text size control "Text size, 3 of 5".
**Copy:** Cooking mode/Chế độ nấu · Text size/Cỡ chữ · Pin for quick access/Ghim để nấu nhanh · Unpin/Bỏ ghim · Step
{n}/Bước {n} · Read step/Đọc bước · Stop reading/Dừng đọc · Tap a line to cross it off./Chạm một dòng để gạch đi. · NEW:
Next step/Bước tiếp · NEW: All steps done/Đã xong mọi bước.

### SCR‑24 · Timers: tray, running pill, time‑up alert · [draft] · AC‑28, 62
- **Tray** (in Cook mode, bottom): one chip per running timer: name "Step 3 · 3 h" (`timerName` "{step} · {label}")
  and remaining "2:47:12", tap → expanded list with **Cancel timer** each (`timerCancel`). Title "Running timers".
- **Running pill** on all other screens (above the bottom bar): "⏱ 2 timers · 4:51" → back to Cook mode of that recipe.
- **Time‑up alert** (app open): prominent full‑width card or dialog "Time is up: Step 3 · 15 min" (`timerDone`) with a
  big **Dismiss** (`timerDismiss`, ≥ 64 dp); sound plays; several can stack.
**States:** 1 timer · 3 timers from 2 recipes · one finished while another runs · finished while app was in the
background (notification EXT‑01, then the alert when opening).
**A11y:** remaining time readable on focus (not announced every second); time‑up is an assertive announcement.

### SCR‑25 · Notification permission (first timer) · [draft] · AC‑28, S‑40
1. First tap on any timer → dialog **"Alert when time is up"** (`notifRationaleTitle`) / `notifRationaleBody` /
   **Not now** · **Continue**. The timer **starts anyway** in both cases.
2. Continue → OS prompt (EXT‑03).
3. Denied (or Not now) → persistent but compact banner in Cook mode `notifDeniedWarning` with **Turn on** (opens OS
   settings, NEW "Open settings" / "Mở cài đặt").
**States:** rationale · OS prompt placeholder · allowed (no banner) · denied banner · iOS variant.

### SCR‑26 · Read step & no voice · [draft] · AC‑30
"Read step" reads the current step in the recipe's language; button turns into **Stop reading** while speaking. No voice
→ dialog "No Vietnamese voice on this device" (`noVoiceTitle`) / `noVoiceBody` / OK (+ "Open settings" on Android if
possible). Error `speakError`.

### SCR‑27 · Shopping tab (current list) · [new] · AC‑34, 36, 37
**Purpose:** buy everything, one hand, walking.
**Components:**
1. App bar: **list switcher** as the title ("Supermarket ▾", → SCR‑28), actions: Share list (text), overflow: Aisles
   (SCR‑31), Clear checked items (SCR‑33), Rename list, Delete list.
2. Progress line: "6 of 14 bought" (NEW / "Đã mua 6/14").
3. Items **grouped by aisle** in the list's aisle order (section headers styled as notebook tabs). Row: large checkbox,
   name, quantity ("500 g"), small source caption ("for Phở bò, Bún chả"). Tap anywhere on the row = check. Trailing
   ⋮ (or swipe, with menu alternative) → SCR‑30.
4. **Bought** section at the bottom (collapsed by default, count), checked rows struck through + dimmed.
5. Primary action (FAB position): **Add item** → SCR‑29.
**States:** no lists yet (create first list: suggested names "Supermarket", "Wet market") · empty list ("Nothing to buy"
NEW + Add item / Frequent items) · items in 4 aisles · all bought ("All done!" NEW + Clear checked items) · item merged
from two recipes · long item names · VI · 200 % · dark.
**A11y:** row "Thịt bò, 500 g, for Phở bò and Bún chả, not bought. Double‑tap to mark bought."; aisle headers are headings.

### SCR‑28 · Lists switcher & management · [new] · AC‑34
Sheet listing all lists with item counts ("Supermarket · 8 left"), current checked; **New list** (name dialog),
Rename, Delete (confirm "Delete the list "Chợ" and its 12 items?" NEW), drag to reorder.

### SCR‑29 · Add item · [new] · AC‑34, 36
Sheet with a text field (focused) and **type‑ahead** from items added before; parsing "2 kg gạo" into quantity + name
is shown as a preview chip; aisle auto‑assigned and shown ("→ Dry goods", tappable to change). **Frequent items** grid
of chips below (one tap = added, chip shows ✓ briefly; stays open for rapid adding). **Done**.
**States:** empty field with frequent items · typing with suggestions · item already on the list ("Already on the
list — add anyway?" or quantity merge note, NEW) · no frequent items yet.
**Copy NEW:** Add item/Thêm món · Frequent items/Món hay mua · Added/Đã thêm.

### SCR‑30 · Item sheet (edit / move aisle) · [new] · AC‑36, 35
Name, quantity, **Aisle** picker (list of aisles; changing it shows "CookNote will remember this aisle for "{item}"" NEW
/ "CookNote sẽ nhớ khu vực này cho "{item}""), source recipes (read‑only list, tap → recipe), Delete.

### SCR‑31 · Aisles manager · [new] · AC‑36
List of aisles with drag handles ("Order them like your shop's path" NEW / "Sắp theo đường đi trong cửa hàng"), Rename,
Add aisle, Delete (items move to "Other" — NEW explanatory line). Defaults: Produce · Meat & fish · Dairy & eggs · Dry
goods · Spices & sauces · Frozen · Drinks · Other / Rau củ · Thịt cá · Sữa trứng · Đồ khô · Gia vị · Đông lạnh · Đồ
uống · Khác. Move up/down actions for a11y.

### SCR‑32 · Add ingredients to shopping (picker) · [new] · AC‑35, 40, 43
**Opened from:** recipe detail (current servings), Menu range (SCR‑41), What can I cook? (missing items only).
**Components:** target list selector ("Add to: Supermarket ▾"); grouped by recipe when several ("Phở bò · 4 people",
"Canh chua · 4 people"); each ingredient with a checkbox; **items in the Pantry start unchecked** with a label "In
pantry" (NEW / "Có trong tủ bếp"); unstructured lines shown as written; a **merge preview** at the bottom ("3 items will
be merged with items already on the list" NEW); primary **Add 11 items** (NEW).
**States:** one recipe · a week (5 recipes, 38 lines) · all already in pantry · nothing checked (button disabled with
reason) · after adding (snackbar "Added 11 items to Supermarket · View" NEW).
**A11y:** checkbox rows read the line and the pantry state.

### SCR‑33 · Clear checked & share list · [new] · AC‑37
Confirm dialog "Clear 6 bought items?" (NEW) with a checkbox **"Move bought items to the Pantry"** (NEW / "Chuyển món
đã mua vào Tủ bếp") → snackbar "Cleared · 6 items moved to the Pantry · Undo" (NEW). Share → OS share sheet with plain
text grouped by aisle (show the text preview in the mockup).

### SCR‑34 · Menu tab — Week view (default) · [new] · AC‑38, 39, 40, 41
**Purpose:** plan a week of meals in a few minutes.
**Components:**
1. App bar "Menu"; **view switch** Day · Week · Month (segmented); period header "‹ Nov 2 – 8 ›" with **Today**.
2. **Week body (portrait, 360 dp):** 7 day blocks stacked vertically (today highlighted: "Thu, Nov 5 · Today"); each
   day shows its **meal slots** as rows; each slot shows its items as compact cards (thumbnail, name, servings "4") or
   a free‑text line in a different style ("Eating out"); empty slot = subtle "+" target (48 dp).
3. Action row / overflow: **Random suggestions** (SCR‑40) · **Apply a template** (SCR‑39) · **Save week as template** ·
   **Add to shopping** (SCR‑41) · Meal slots (SCR‑42).
4. Primary action: **Add to menu** (→ SCR‑37 with today preselected).
**Interactions:** tap empty slot → SCR‑37 for that slot; tap item → SCR‑38; **long‑press drag** an item to another
day/slot with drop‑target highlighting and auto‑scroll; a11y alternative "Move to…" in SCR‑38.
**States:** empty week ("Nothing planned this week" NEW + Random suggestions / Apply a template) · partly planned ·
full week · dragging · a slot with 4 dishes (Vietnamese family meal) · week starting Sunday · VI (long day names "Thứ
Năm, 5 thg 11") · 200 % · dark.
**A11y:** day headings; item "Dinner, Thursday: Phở bò, 4 servings"; drag has a non‑drag alternative.

### SCR‑35 · Menu — Day view · [new] · AC‑38
One day, slots as large sections with item cards (bigger photos), "Cook" shortcut per recipe item, "‹ ›" day
navigation, swipe left/right for next/previous day (plus the arrows).

### SCR‑36 · Menu — Month view · [new] · AC‑38
Month grid; each day shows up to 3 dots / mini thumbnails + "+2"; today marked; tap a day → Day view. Week‑start from
Settings. **A11y:** each day cell "Nov 5, 3 meals planned".

### SCR‑37 · Add to meal (sheet) · [new] · AC‑38
Tabs or segmented: **Recipe** (search field + recent/favourites list) · **Free text** (single line, e.g. "Eating out",
"Leftovers"). Fields: **Date** and **Slot** (prefilled when opened from a slot; editable when opened from a recipe
detail), **Servings** (default = recipe servings). Primary **Add**.
**States:** from empty slot · from recipe detail (choose date + slot) · search no results · free text.
**Copy NEW:** Add to menu/Thêm vào thực đơn · Recipe/Công thức · Free text/Ghi chữ · Servings/Khẩu phần · Eating
out/Ăn ngoài.

### SCR‑38 · Menu item actions · [new] · AC‑38
Sheet for an item: Open recipe · Cook · Servings (stepper) · **Move to…** (date + slot picker — the drag alternative) ·
Remove (with Undo).

### SCR‑39 · Menu templates · [new] · AC‑39
- **Templates list:** name, "4 items · 1 day" / "21 items · 1 week", preview thumbnails; **New template**, Edit, Rename,
  Delete.
- **Save as template** from a day or a week (name dialog: "Family dinner, 4 dishes").
- **Template editor:** like a Day/Week view without dates ("Day 1 … Day 7").
- **Apply:** choose the start date (a day, or the week) → items are **added** to the slots (existing items stay) →
  snackbar "Applied "Birthday party" to Sat, Nov 7 · Undo" (NEW).
**States:** no templates (explain + "Save this week as a template") · list · apply sheet · applied.

### SCR‑40 · Random suggestions · [new] · AC‑41
1. Filter sheet: categories, tags, max time (reuse SCR‑04 components); which slots to fill (e.g. only Lunch + Dinner —
   proposal; the rule is "empty slots of the week").
2. **Preview**: the week with suggested items marked "Suggested" (distinct style, not colour‑only), each with
   **Shuffle** (proposal) or remove; info "No recipe repeats this week" or, when the filter has too few recipes, "Not
   enough recipes for every slot — some repeat" (NEW).
3. **Apply** / Cancel.
**States:** filters · preview · too few matching recipes · zero matching ("No recipes match these filters").

### SCR‑41 · Add a date range to shopping · [new] · AC‑40
Range picker (defaults to the current week; quick chips This week / Next 3 days / Custom) → summary "5 recipes, 38
ingredient lines" → SCR‑32 picker.

### SCR‑42 · Meal slots · [new] · AC‑38
List of slots (Breakfast, Lunch, Dinner, Snack / Sáng, Trưa, Tối, Phụ) with drag order, Rename, Add, Delete (if items
exist: "Items in this slot will be removed from the menu" NEW, confirm).

### SCR‑43 · Pantry tab · [new] · AC‑42, 43
**Components:** app bar "Pantry"; prominent **What can I cook?** card/button at the top ("12 recipes you can almost
cook" NEW); filter chips **All · Expiring soon (2) · Expired (1)**; search; items grouped by aisle; row: name, quantity,
"Bought Nov 1", expiry status with **icon + text** ("Expires in 3 days", "Expired 1 day ago", "No expiry date");
primary **Add to pantry** → SCR‑44.
**States:** empty ("Your pantry is empty" + "Add what you have, or move bought items here from Shopping" NEW) ·
normal · filtered Expiring soon · filtered Expired · many items · VI · 200 %.
**Copy NEW:** Pantry/Tủ bếp · Expiring soon/Sắp hết hạn · Expired/Hết hạn · Expires in {n} days/Còn {n} ngày hết hạn ·
What can I cook?/Nấu được gì?

### SCR‑44 · Pantry item sheet · [new] · AC‑42
Name (type‑ahead), quantity (optional), aisle, **purchase date** (default today), **expiry date** (optional, date
picker with "None"), Delete. Validation: expiry before purchase → warning (NEW).

### SCR‑45 · What can I cook? · [new] · AC‑43, 35
List of recipes ranked by match: photo, name, a **match meter** (e.g. "8 of 10 ingredients" + bar — not colour‑only),
"Missing 2: sả, me chua" (`canCookMissing`). Switch at top: `basicsToggle` (basic seasonings don't count). Row action
**Add missing to shopping** (→ SCR‑32 with only missing items checked); tap → recipe detail.
**States:** empty pantry (explain) · results · nothing close ("No recipe uses what's in your pantry yet" NEW) · switch
on/off changes order.

### SCR‑46 · More tab · [built] · AC‑01, 53, 63
Grouped list:
- **Backup** with a **status line** ("Last backup: today 21:10" / "No successful backup yet" / "Automatic backup is
  failing" — success/warning/danger style with icon). This is the "for life" promise; make it feel solid.
- **Import & export** (SCR‑52) · **Categories** (SCR‑14) · **Trash** (SCR‑13, count).
- **Settings** (SCR‑53) · **About** (SCR‑55).
- Footer card: "🔒 Your recipes live only on this phone. CookNote collects nothing." (NEW / "Công thức của bạn chỉ nằm
  trên điện thoại này. CookNote không thu thập gì.").

### SCR‑47 · Backup screen · [built] · AC‑49..53, 56, 57
**Components (top → bottom):**
1. **Status card**: "Last successful backup" (`backupLast`) "Today, 21:10 · 48.6 MB" (`backupLastDetail`), where
   ("Folder: CookNote Backups"), result; or "No successful backup yet" (`backupNever`). Error variant with the reason
   and **Choose the folder again**.
2. **Automatic backup** (`backupAutoTitle`) section: explanation `backupFolderHint`; when off → **Choose automatic
   backup folder** (`backupChooseFolder`); when on → "Folder: {name}", **Change folder**, **Schedule** Daily / Weekly
   (`backupInterval`), **Copies to keep** 1–30 ("5 copies", stepper), **Back up to the folder now** (`backupRunNow`),
   **Turn off automatic backup** (`backupDisable`).
3. **Back up now and save elsewhere** (`backupSaveElsewhere`) + hint (`backupSaveElsewhereHint`).
4. **Reminder**: "Remind me after {n} days without a backup" (NEW / "Nhắc khi quá {n} ngày chưa sao lưu"), default 7.
5. **Restore** (`backupRestoreTitle`): **Restore from a file...** (`backupRestoreFile`) and **Backups in the automatic
   folder** (`backupRestoreFromFolder`) list (date, size) → SCR‑50.
6. **Honesty notes** (muted, info icon): `backupUnencrypted`, `backupSystemLayer` (Android) / iOS variant (NEW: "If
   iCloud Backup is on, your iPhone backup also includes CookNote's data. It does not replace the backups above." /
   "Nếu bật Sao lưu iCloud, bản sao lưu iPhone cũng chứa dữ liệu CookNote. Lớp này không thay được sao lưu ở trên."),
   and the open‑format promise (NEW: "Backups are open zip files with web pages you can read in any browser, even
   without CookNote." / "File sao lưu là file zip mở, có trang web đọc được bằng mọi trình duyệt, không cần CookNote.").
**States:** never set up · on + OK · on + **running** (progress, SCR‑49) · on + **folder lost** (`backupFailedTarget`)
· on + **verify failed** (`backupFailedVerify`) · other failure (`backupFailedOther`) · "Nothing changed since the last
backup" (`backupUnchanged`) after a manual run · overdue > 7 days · folder list loading / empty (`backupNoFiles`) /
error (`backupListError`) · VI (long hint) · 200 %.

### SCR‑48 · Automatic backup set‑up · [built] 🤖🍏 · AC‑50, 51, 59
Flow: **Choose automatic backup folder** → OS folder picker (EXT‑03; phone, Google Drive, OneDrive) → back with
"Folder: CookNote Backups" → **first backup runs immediately** with progress → success "Backed up (48.6 MB)"
(`backupDone`) **or** the cloud app refused → explain clearly and point to **Back up now and save elsewhere** (this is
a known risk on Android Google Drive — make the fallback feel normal, not like a failure). Picker cancelled → nothing
changes. Also reachable from Onboarding page 3 and the 10‑recipe suggestion.

### SCR‑49 · Backup / restore progress · [built] · AC‑57
Inline or modal progress: "Backing up..." / "Restoring..." with a determinate bar ("312 of 2,000 photos"), **Cancel**
→ "Backup cancelled". Must look calm for long runs (1,000 recipes, 2,000 photos). The app stays usable during
automatic backups (no modal for those — at most a small status in More/Backup).

### SCR‑50 · Restore flow · [built] · AC‑54, 55, 57
1. Choose a file (OS picker) or a copy from the folder list.
2. **Checking the file…** (NEW / "Đang kiểm tra file…") — nothing touched yet.
3. **Summary card:** "{recipes} recipes, {photos} photos, created {when}" (`restoreInfo`).
4. **How do you want to restore?** (`restoreChooseMode`): **Merge (only add missing recipes)** with `restoreMergeInfo`
   · **Replace everything** with `restoreReplaceWarning` → confirm dialog (destructive style).
5. Progress (SCR‑49) → result "Restored: 12 added, 30 already there" (`restoreDone`).
**Errors (data unchanged, said explicitly):** not a backup (`errBackupNotABackup`), made by a newer app
(`errBackupNewer`), damaged (`errBackupChecksum`), missing parts (`errBackupMissing`), malformed (`errBackupBad`).

### SCR‑51 · Backup notices on the Recipes tab · [built] · AC‑51, 53
A compact card above the list (not a modal, not an OS notification), with icon + text + action **Open Backup**
(`noticeOpen`):
- **Suggest** (once, at 10 recipes): "You have 10 recipes. Turn on automatic backup so you do not lose them."
  (`noticeSuggest`) + dismiss ✕.
- **Overdue** (> 7 days): `noticeOverdue` (warning).
- **Failing** (lost folder access / verify failed): `noticeError` (danger) — not dismissible until fixed; action
  "Choose the folder again".
Show all three variants, light/dark, VI.

### SCR‑52 · Import & export hub + Recipe book (PDF) · [draft] · AC‑44..48
**Hub** (`exchangeSection` "Import and export"): Import from file (SCR‑22) · Export all recipes (JSON)
(`exportAllJson`) · Recipe book from all recipes (`cookbookAll`) · tip "To export some recipes, select them in the
Recipes list" (NEW).
**Recipe book dialog/screen:** Book title (`cookbookTitleLabel`, default "My recipe book"), cover photo (pick from the
recipes' photos or the gallery), source (selected recipes / category name, count "24 recipes"), **Create book**
(`cookbookCreate`) → "Creating file…" with Cancel → **"The book is ready"** (`cookbookReady`) with **Share or save**
(`cookbookShare`) and **Print**. Empty: `cookbookNone`.
Also design the **PDF itself** in EXT‑05.

### SCR‑53 · Settings · [built: theme, language] · AC‑58, 64, 43
Groups:
- **Appearance:** Theme — System / Light / Dark (segmented, 3 options; "Theo hệ thống" is long).
- **Language:** System / English / Tiếng Việt.
- **Cooking:** Default unit system — Metric / US (NEW: "Default units" / "Hệ đơn vị mặc định"); (Cook mode text size is
  remembered from Cook mode).
- **Menu:** First day of the week — Monday / Sunday (NEW: "First day of the week" / "Ngày đầu tuần"); Meal slots →
  SCR‑42.
- **Shopping & pantry:** Aisles → SCR‑31; "Don't count basic seasonings as missing" switch (`basicsToggle`, same
  setting as in SCR‑45).
- **Danger zone:** **Delete all data** → SCR‑54.
States: default · VI · 200 %.

### SCR‑54 · Delete all data · [new] · AC‑64
1. Dialog **"Back up first?"** (NEW / "Sao lưu trước đã?"): "Deleted data cannot be recovered. Save a backup first?"
   (NEW / "Dữ liệu đã xóa không lấy lại được. Lưu một bản sao lưu trước nhé?") → **Back up now** (→ save elsewhere
   flow, then continue) · **Skip** · Cancel.
2. Confirm 1: **"Delete all data?"** — lists what goes (all recipes, photos, lists, menu, pantry, settings) and what
   stays ("Backup files in your folders are not deleted.") → Continue.
3. Confirm 2 (final, destructive style): "This cannot be undone." → **Delete everything** (NEW / "Xóa tất cả").
4. Progress → the app restarts at Onboarding (SCR‑01).
**Copy NEW:** Delete all data/Xóa toàn bộ dữ liệu · Backup files in your folders are not deleted./Các file sao lưu
trong thư mục của bạn không bị xóa.

### SCR‑55 · About · [new] · AC‑63, 65
App icon, "CookNote", version "1.0.0 (1)"; rows: **Privacy policy** (opens browser) · **Report a security issue**
(opens email to the security address) · **Open‑source licences** (→ SCR‑56); privacy summary "No account. No ads. No
tracking. Nothing leaves your phone except the web pages you open." (NEW); copyright note (NEW): "Recipes imported from
websites belong to their authors. CookNote keeps the source link. Use them for your own cooking only." / "Công thức
nhập từ trang web thuộc bản quyền của tác giả. CookNote giữ liên kết nguồn. Chỉ dùng cho việc nấu ăn cá nhân."
(Privacy URL and email are placeholders in the mockup — do not invent a domain.)

### SCR‑56 · Open‑source licences · [new] · S‑70
Flutter's standard licence page (`showLicensePage`), themed with CookNote tokens: package list → licence text. Also
lists fonts (OFL) and the icon set. Only theme it; don't redesign the structure.

### SCR‑57 · Shared components · AC‑05, 60..62
- **Confirm dialog** (normal / destructive), **snackbar** (with action, 5 s Undo; 2‑line VI variant; must not cover
  the FAB or the timer pill), **progress** (inline, button, modal with Cancel), **empty states** (illustration style for
  each tab), **error card** (icon + reason + action), **offline note** (web import only), **section header (notebook
  tab)**, **recipe card (grid) / row (list)**, **ingredient row** (normal / crossed / unscalable / heading),
  **step card** (normal / current / crossed / with timer chips), **timer chip**, **chips** (filter, input, choice),
  **stepper**, **segmented control** (2–3 options, wraps at 200 %), **switch row with long subtitle**, **date picker**
  (OS), **bottom sheet**, **drag handle** + reorder state, **status card** (backup OK / warning / danger), **star rating**
  (read‑only, input), **match meter**, **expiry badge** (soon / expired), **photo placeholder**.

### Surfaces outside the app

**EXT‑01 · Timer notifications** 🤖🍏 · AC‑28 — time‑up notification: title "Time is up: Step 3 · 15 min", body
"{recipe}: time is up" (`timerNotifBody`), app icon; tap → Cook mode. Android: channel "Cooking timers"; while timers
run, Android may show an **ongoing notification** "2 timers running · 4:51" (depends on the timer method decided in
the next phase — draw it as optional). iOS: standard banner + lock screen.

**EXT‑02 · CookNote in the OS share sheet** 🤖🍏 · AC‑17 — CookNote icon + name among share targets (Chrome/Safari,
YouTube, Facebook). Just icon legibility at small sizes.

**EXT‑03 · OS sheets and pickers (placeholders only)** — photo picker, OS camera, file picker, **folder picker**
(Android SAF / iOS Files), share sheet, print dialog, notification prompt, text‑to‑speech settings. Draw as greyed
placeholders in flows; don't design them.

**EXT‑04 · App icon & splash** — 1024 × 1024 master, Android adaptive (foreground/background) + **monochrome** (themed
icons), iOS icon (light/dark/tinted if you like). Must read at 48 px.

**EXT‑05 · Recipe book PDF** · AC‑47 — A4 portrait (and US Letter check): **cover** (book title, cover photo, "Made
with CookNote" small), **contents** with page numbers, **recipe page** (title, cover photo, meta row, ingredients with
groups, numbered steps, notes, source URL), page footer "Page 12". Print‑friendly (white background, ink saving),
Vietnamese diacritics correct. Also the **single‑recipe PDF** (AC‑46) = one recipe page.

**EXT‑06 · Backup HTML pages** · AC‑49 — `html/index.html` (list of recipes, grouped by category, search not needed)
and one page per recipe, readable in any desktop/mobile browser **without CookNote** and printable. Plain HTML + inline
CSS in the CookNote style; no scripts, no external fonts. Low priority, but it is our "for life" proof.

---

## 6. Key flows (prototype these)

**F1 · Share a link → saved (the fastest flow, AC‑17, 18, 20, 22)**
Chrome/Safari on a recipe page → Share → CookNote (EXT‑02) → SCR‑15 loads the URL → reading → SCR‑17 preview (all
fields filled, 3 photo candidates) → **Save** → downloading photos 3/3 → recipe detail SCR‑07 with snackbar "Saved".
Variant **F1b:** same URL already saved → duplicate dialog → Open the old one.
Variant **F1c:** page has no recipe data (blog) → SCR‑16 pick text → Is the name / Is ingredients / Is the steps →
Continue → SCR‑17 → Save.
Variant **F1d:** offline → SCR‑15 `webErrorNetwork` → turn on Wi‑Fi → Try again → continues.

**F2 · Cook with timers (AC‑26..30)**
Recipes → Phở bò → **Cook** → SCR‑23 (screen stays on) → tap 3 ingredients to cross off → step 1 card → tap timer "5
min" → first time: SCR‑25 rationale → Continue → OS prompt → Allow → timer runs in the tray → tap step 1 done → step 2
becomes current → start "3 h" timer → leave Cook mode to check another recipe (running pill visible) → back via pill →
step 1 timer ends → time‑up alert → Dismiss → … → all steps done → **Mark as cooked**.
Variant **F2b:** notifications denied → banner `notifDeniedWarning`; timer still rings in app.
Variant **F2c:** pin Banana bread too → switch between both via the pinned bar; timers of both in the tray.

**F3 · Plan the week → shopping (AC‑38..41, 35..37)**
Menu (Week, empty) → **Apply a template** "Family dinner, 4 dishes" to Monday → **Random suggestions** (Main dishes,
≤ 45 min) → preview → Apply → drag Thursday's dinner to Friday → **Add to shopping** → This week → SCR‑32 (pantry items
unchecked, 2 merged) → Add 23 items to "Supermarket" → Shopping tab grouped by aisle → in the shop: tap to check off →
Clear checked items + Move bought items to the Pantry → Pantry shows them.

**F4 · First backup (AC‑50..53, 59)**
Path A: Onboarding page 3 → Turn on automatic backup → OS folder picker → choose "CookNote Backups" on Google Drive →
first backup runs → "Backed up (2.1 MB)" → Recipes. Path B: 10th recipe saved → notice `noticeSuggest` → Open Backup
→ Choose folder → … → status card "Today, 21:10". Path C (cloud app refuses): folder chosen but write fails →
explanation → **Back up now and save elsewhere** → share sheet → Google Drive → Backup screen shows the result.

**F5 · Scan Mum's handwritten recipe (AC‑23..25)**
"+" → Scan a photo → Take a photo ×2 → Recognise text → assign screen (handwriting note shown) → fix 2 words → select
title line → Name → select 8 lines → Ingredients → rest → Steps → Keep page photos ✓ → Continue → editor → Save.

**F6 · New phone (AC‑54, 55)**
Fresh install → Onboarding → Skip → More → Backup → Restore from a file… → pick the latest `.cooknote` from Drive →
checking → summary "128 recipes, 240 photos, created Nov 4" → Replace everything → confirm → progress → "Restored".

**F7 · What can I cook? → shopping (AC‑43, 35)**
Pantry → What can I cook? → Thịt kho trứng "Missing 1: thịt ba chỉ" → Add missing to shopping → SCR‑32 → Add →
snackbar → View.

**F8 · Scale and convert a US recipe (AC‑32, 33)**
Banana bread → Servings & units → ½× + Metric → banner "Viewing ×0.5…" → unscalable "a pinch of cinnamon" marked →
oven step shows 175°C → Cook (keeps ×½ Metric).

**F9 · Delete and undo (AC‑05)**
Detail → Delete → confirm → list with "Recipe deleted · Undo" → (ignore) → More → Trash → Restore.

---

## 7. Android vs iOS differences

| Topic | Android 🤖 | iOS 🍏 |
|---|---|---|
| **Back** | System Back button/gesture (predictive back on 14+). In the browser: web history first, then leave. In editor/assign: discard dialog. | App‑bar back button + edge swipe. Edge swipe in the browser goes web‑back when possible (propose clear affordance). Editor/assign: swipe‑back blocked when there are changes → discard dialog. |
| **Receiving a share** | Share intent: CookNote appears in the share sheet for URLs and text; opens the app. | Share extension: CookNote in the share sheet for Safari URLs/text; opens the app (or a small "Saved to CookNote — open?" card — propose). |
| **Sharing out** | Android share sheet. | iOS share sheet (anchored, "Save to Files" available). |
| **Backup folder** | Storage Access Framework folder picker (phone storage, Google Drive, OneDrive — Drive may refuse automatic writes). | Files folder picker (On My iPhone, iCloud Drive, other providers). Copy says "a folder in Files" (NEW variant of `backupFolderHint`). |
| **OS backup layer** | Android Auto Backup (database, no photos) — `backupSystemLayer`. | iCloud Backup of the device — iOS copy variant (SCR‑47). |
| **Notifications** | Android 13+ runtime permission; "Cooking timers" channel; possible ongoing notification while timers run. | System permission prompt (asked once; afterwards only via Settings); banners and lock screen. |
| **Text‑to‑speech help** | "Settings → Text‑to‑speech" (name varies by maker). | "Settings → Accessibility → Spoken Content → Voices" (NEW iOS variant of `noVoiceBody`). |
| **Print** | Android print dialog / Save as PDF. | AirPrint dialog. |
| **Photo picker / camera** | Android photo picker; OS camera app. | PHPicker; OS camera. No permission dialog on either. |
| **Pickers & sheets** | Material date picker, bottom sheets. | Same Material components (adaptive), respecting iOS safe areas and the Home indicator. No Cupertino redesign needed. |

---

## 8. Sample data for mockups
Today = **Thursday, 2026‑11‑05**. Week starts Monday → week **Nov 2 – 8**. Language VI for Vietnamese recipes, EN for
English ones (a real user mixes both). Source domains use the reserved `.example` TLD — don't show real brands.

### 8.1 Recipes
| # | Name | Photo | Category › Tags | Servings · Prep/Cook/Total | ★ · Fav · Cooked | Source |
|---|---|---|---|---|---|---|
| R1 | **Phở bò Hà Nội** | yes (4) | Món chính › Món Việt › Món bún, phở · `cuối tuần` | 4 người · 30/180/210 phút | 5 · ♥ · 6 lần, gần nhất 1/11 | amthuc.example/pho-bo-ha-noi |
| R2 | **Canh chua cá lóc** | 1 (scanned page) | Canh/Súp · `miền Nam` | 4 người · 20/25/45 | 4 · – · 3 lần | "Sổ tay của mẹ" (scanned) |
| R3 | **Thịt kho trứng** | yes | Món chính › Món Việt · `Tết`, `nồi áp suất` | 6 người · 15/60/75 | 5 · ♥ · 12 lần | — |
| R4 | **Gỏi cuốn tôm thịt** | **none** (placeholder) | Món phụ · `không dầu mỡ` | 4 người · 40/15/55 | 0 | typed by hand |
| R5 | **Bánh flan caramel** | yes | Tráng miệng, Bánh | 8 cái · 20/25/45 (+4 h chill) | 4 | banhngot.example/flan |
| R6 | **Classic Banana Bread** | yes (3) | Baking › `freezer-friendly` | 1 loaf (8 slices) · 15/60/75 min | 4 · ♥ · 2 times | bakingdiary.example/banana-bread |
| R7 | **Weeknight Chicken Curry** | yes | Main dishes · `quick` | 4 servings · 15/30/45 | 4 | — |
| R8 | **Chocolate Chip Cookies** | yes | Baking | 24 cookies · 20/12/32 | 5 | sweetkitchen.example/cookies |
| R9 | **Greek Salad** | yes | Side dishes · `vegetarian`, `no-cook` | 2 servings · 15/0/15 | 3 | — |
| R10 | Overnight Oats | — | in **Trash** (deleted Nov 2 → "Removed for good in 27 days") | | | |

Also a **long name** for stress tests: "Bún bò Huế chuẩn vị cố đô với chả cua, giò heo và mắm ruốc nấu theo cách của
bà ngoại ở làng Kim Long" and a library of **1,284 recipes** for the list header.

**R1 Phở bò Hà Nội — ingredients**
- *Phần nước dùng:* 1,5 kg xương ống bò · 500 g thịt bò nạm · 1 củ hành tây · 1 nhánh gừng (khoảng 50 g) · 3 hoa hồi ·
  1 thanh quế · 2 muỗng canh nước mắm · 1 muỗng cà phê muối
- *Phần ăn kèm:* 500 g bánh phở · 300 g thịt bò thăn thái mỏng · hành lá, rau thơm *(unstructured)* · 1 quả chanh ·
  ớt tươi tùy thích *(unstructured)*
**R1 steps**
- *Nấu nước dùng:* 1. Chần xương ống bò trong nước sôi **5 phút**, rửa sạch. 2. Nướng hành tây và gừng cho thơm.
  3. Cho xương, nạm, hành, gừng vào nồi với 4 lít nước, ninh lửa nhỏ **3 tiếng**, thỉnh thoảng hớt bọt. 4. Rang hồi,
  quế rồi thả vào nồi **30 phút** cuối.
- *Hoàn thành:* 5. Nêm nước mắm, muối vừa ăn. 6. Trụng bánh phở 10–15 giây, xếp thịt thăn, chan nước dùng thật sôi.

**R2 Canh chua cá lóc — ingredients:** 500 g cá lóc cắt khúc · 2 quả cà chua · 1/4 quả thơm · 100 g giá đỗ · 2 cây bạc
hà (dọc mùng) · 30 g me chua · 1 muỗng canh đường · 2 muỗng canh nước mắm · ngò gai, rau om *(unstructured)*.
**Steps:** 1. Ngâm me với 200 ml nước ấm **10 phút**, lọc lấy nước. 2. Đun sôi 1,2 lít nước, cho nước me, thơm, cà
chua vào. 3. Thả cá, nấu **10‑15 phút** (timer = 15). 4. Cho bạc hà, giá; nêm đường, nước mắm; tắt bếp, rắc rau.

**R6 Classic Banana Bread — ingredients:** 2 cups (250 g) all-purpose flour · 1 tsp baking soda · 1/4 tsp salt ·
1/2 cup butter, melted · 3/4 cup brown sugar · 2 large eggs · 1 1/3 cups mashed ripe bananas (about 3) · 1 tsp vanilla
extract · a pinch of cinnamon *(unstructured)*.
**Steps:** 1. Preheat the oven to **350°F** and grease a loaf pan. 2. Whisk flour, baking soda and salt. 3. Mix butter
and sugar, beat in eggs, bananas and vanilla. 4. Fold in the dry ingredients. 5. **Bake for 60 minutes**, until a
toothpick comes out clean. 6. **Let cool for 10 minutes**, then turn out onto a rack.
Scaled **½× + Metric** (illustrative — the converter decides exact output): "1 tsp baking soda" → "2.5 ml baking
soda", "1/2 cup butter, melted" → "60 ml butter, melted" (volume stays volume, never grams), "350°F" → "175°C";
"a pinch of cinnamon" keeps the "cannot be scaled automatically" marker.

**R8 Chocolate Chip Cookies — step with a range:** "Bake for **10–12 minutes**, until golden at the edges." (timer = 12).

### 8.2 Categories (VI default + nesting)
Món chính (› Món Việt › Món bún, phở · › Món Âu) · Món phụ · Canh/Súp · Tráng miệng · Đồ uống · Bánh. EN: Main dishes ·
Side dishes · Soups · Desserts · Drinks · Baking.

### 8.3 Shopping
- **"Siêu thị"** (Supermarket) — 14 items, 6 bought:
  - Rau củ: hành tây 2 củ *(Phở bò)* · cà chua 4 quả *(Canh chua, Greek Salad)* · giá đỗ 100 g ✓ · chuối 3 quả
  - Thịt cá: **thịt bò 500 g** *(Phở bò 300 g + Bún chả 200 g — merged)* · cá lóc 500 g · thịt ba chỉ 800 g *(Thịt kho
    trứng)*
  - Sữa trứng: trứng gà 10 quả ✓ · bơ lạt 115 g
  - Đồ khô: bánh phở 500 g ✓ · bột mì 250 g
  - Gia vị: nước mắm ✓ · hoa hồi 3 ✓ · quế 1 thanh ✓
- **"Chợ"** (Wet market) — rau thơm, ngò gai, rau om, bạc hà, me chua 30 g.
- Frequent items: trứng gà, sữa tươi, gạo, hành lá, nước mắm, bánh mì.

### 8.4 Pantry (today Nov 5)
| Item | Qty | Aisle | Bought | Expiry | Status |
|---|---|---|---|---|---|
| Trứng gà | 10 quả | Sữa trứng | Nov 1 | Nov 8 | **Expiring soon** (3 days) |
| Sữa tươi | 1 l | Sữa trứng | Oct 30 | Nov 4 | **Expired** (1 day ago) |
| Bơ lạt | 200 g | Sữa trứng | Oct 28 | Nov 7 | **Expiring soon** |
| Gạo | 5 kg | Đồ khô | Oct 15 | — | No expiry |
| Hành tây | 3 củ | Rau củ | Nov 3 | — | |
| Bột mì | 1 kg | Đồ khô | Sep 20 | Mar 2027 | OK |
| Chuối | 4 quả | Rau củ | Nov 4 | Nov 9 | OK |
| Nước mắm, đường, muối, tiêu, dầu ăn | | Gia vị | | | basics |

**What can I cook?** (basics switch on): Classic Banana Bread 8/9 "Missing 1: baking soda" · Thịt kho trứng 5/6 "Missing
1: thịt ba chỉ" · Canh chua cá lóc 4/9 "Missing 5: cá lóc, cà chua, thơm, giá đỗ, me chua".

### 8.5 Menu, week Nov 2 – 8 (slots Sáng · Trưa · Tối · Phụ)
- Mon Tối: Canh chua cá lóc (4) · Thịt kho trứng (4) · "Cơm trắng" (free text) · Gỏi cuốn tôm thịt (4) ← template
  "Cơm gia đình 4 món"
- Tue Trưa: "Ăn ngoài" (free text) · Tue Tối: Weeknight Chicken Curry (4)
- Wed Tối: Phở bò Hà Nội (4)
- **Thu (today)** Sáng: "Bánh mì" (free text) · Tối: Thịt kho trứng (6)
- Sat Sáng: Classic Banana Bread (8) · Sat Tối: template "Tiệc sinh nhật" (Chocolate Chip Cookies 24, Greek Salad 6,
  Bánh flan 8)
- Sun: empty (target for Random suggestions)
Templates: "Cơm gia đình 4 món" (4 items, 1 day) · "Tiệc sinh nhật" (3 items, 1 day) · "Tuần ăn chay" (14 items, 1 week).

### 8.6 Cook mode snapshot
R1 Phở bò, scale ×1, 3 of 9 ingredients crossed, steps 1–2 crossed, **step 3 current**, timers: "Bước 3 · 3 tiếng"
2:47:12 left, and from pinned R6 "Step 5 · 60 min" 0:41:05. Pinned: Phở bò, Classic Banana Bread.

### 8.7 Backup
Folder "CookNote Backups" (Google Drive) · Daily · Keep 5 · Last successful: today 21:10 · 48.6 MB · copies in folder:
Nov 5 21:10 (48.6 MB), Nov 4 20:02, Nov 3 19:45, Nov 2 22:30, Nov 1 08:15. Error sample: "Could not write to the
backup folder. Check permissions or choose the folder again." Restore summary: "128 recipes, 240 photos, created Nov
4, 2026 20:02".

---

## 9. Known UX risks → design opportunities
1. **Five bottom‑nav items in Vietnamese on 360 dp** at large text — test early; propose icon set that stays clear when
   labels shrink.
2. **Cook mode at a distance** — a step‑focused layout vs a full scroll: show your recommendation and one alternative.
3. **Pick‑text mode vs the OS selection toolbar** (SCR‑16) — the three assign buttons must stay reachable.
4. **Automatic backup to Google Drive may be refused by Drive on Android** (unverified). The fallback "save elsewhere"
   + reminder must feel like a normal path, and the status must never look "safe" when it isn't.
5. **Scan accuracy** (on‑device, Tesseract‑class) is modest, handwriting worse — the assign screen must make fixing
   fast (pre‑suggested roles, inline edit, compare with the image).
6. **Thousands of recipes** — grid performance and scanning: a fast‑scroll thumb with initial letters for Name sort
   (proposal).
7. **Drag and drop** (editor lines, categories, aisles, menu items, scan pages) — consistent drag handle + a11y "Move
   up / Move down / Move to…" everywhere.
8. **Timers outside Cook mode** — users leave Cook mode; the running‑timers pill must be visible but not annoying.
9. **Teens (13+) and older users** — plain words, no jargon ("backup", "folder" explained once in context).
10. **Mixed languages** — a Vietnamese user with English recipes: units and read‑aloud follow the *recipe's* language,
    UI follows the app language. Show one such mixed frame.

## 10. Out of scope / proposals
**Not in v1 (don't draw in main frames):** accounts, cloud sync, sharing between users in the app, social features,
import from Instagram/TikTok video, nutrition calculation, volume ↔ weight per ingredient, AI anything (generation,
suggestions, chat, dish recognition), voice control / assistants, widgets, watch, rich text in steps, tablet /
landscape / desktop / web, premium / ads / in‑app purchase, app lock.
**Proposals welcome** (separate page, clearly marked, not wired into flows): recent sites on the browser start page,
"Shuffle" per suggested meal, split/merge lines in scan assign, fast‑scroll letters, a "Saved to CookNote" card in the
iOS share extension. The product owner decides before any of them enters the SPEC.

---

## 11. Deliverables requested from Claude Design

### 11.1 Priority
1. **P1 — identity + core:** design system page (§11.4), EXT‑04 icon, SCR‑02, 03, 07, 08, 11, 15, 16, 17, 23, 24, 25,
   27, 32, 34, 47, 51, 01.
2. **P2 — rest of the features:** SCR‑04..06, 09, 10, 12..14, 18..22, 26, 28..31, 33, 35..46, 48..50, 52..55, EXT‑01, 02,
   05.
3. **P3 — theming / outputs / proposals:** SCR‑00, 56, 57 sheet, EXT‑06, §10 proposals.

### 11.2 Frames
For **each platform** (Android 360 × 800 dp; iPhone 393 × 852 pt) × **light + dark**: every SCR with the states listed.
- **VI variants** (light, Android 360 dp): SCR‑01, 02, 03, 07, 08, 11, 15, 16, 21, 23, 27, 32, 34, 43, 45, 47, 50, 51, 53,
  54 and the bottom nav.
- **200 % text** (Android, light): SCR‑02, 07, 08, 11, 23, 27, 34, 43, 47, 53.
- **Stress:** 200‑char title (SCR‑07, 23); 1,284 recipes (SCR‑02); 5 pinned + 3 timers (SCR‑23); slot with 4 dishes
  (SCR‑34); 20 photos (SCR‑11); long VI backup hint (SCR‑47).
- **Cook mode "at a distance" check:** SCR‑23 rendered at 50 % scale next to 100 % to show readability.
- **Prototype links** for flows F1–F9 (§6).

### 11.3 File naming
`design/hifi/<platform>/<theme>/<NN>_<slug>__<state>.png` + matching HTML export.
`<platform>` = `android|ios`, `<theme>` = `light|dark`, `<NN>` = SCR/EXT number, `<state>` e.g.
`default|empty|loading|error|offline|denied|no-match|filtered|selecting|scaled|running|done|duplicate|vi|text-200|
long-text`. Overlays: `<slug>~<overlay>` (e.g. `07_recipe~share`, `23_cook~time-up`).

| No. | Slug | No. | Slug | No. | Slug |
|---|---|---|---|---|---|
| 00 | `splash` | 20 | `scan-reading` | 40 | `menu-random` |
| 01 | `onboarding-1/2/3` | 21 | `scan-assign` | 41 | `menu-range-shopping` |
| 02 | `recipes` | 22 | `import-file` | 42 | `meal-slots` |
| 03 | `recipes~add` | 23 | `cook` | 43 | `pantry` |
| 04 | `recipes~filter` | 24 | `cook~timers`, `timer-pill`, `cook~time-up` | 44 | `pantry~item` |
| 05 | `recipes~sort` | 25 | `cook~notif-rationale`, `cook~notif-denied` | 45 | `can-cook` |
| 06 | `recipes__selecting` | 26 | `cook~no-voice` | 46 | `more` |
| 07 | `recipe` | 27 | `shopping` | 47 | `backup` |
| 08 | `recipe~servings` | 28 | `shopping~lists` | 48 | `backup~setup` |
| 09 | `recipe~share` | 29 | `shopping~add` | 49 | `backup~progress` |
| 10 | `recipe-photos` | 30 | `shopping~item` | 50 | `restore` |
| 11 | `recipe-edit` | 31 | `aisles` | 51 | `recipes~backup-notice` |
| 12 | `recipe-edit~categories` | 32 | `add-to-shopping` | 52 | `exchange`, `cookbook` |
| 13 | `trash` | 33 | `shopping~clear`, `shopping~share` | 53 | `settings` |
| 14 | `categories` | 34 | `menu-week` | 54 | `delete-all-1/2/3` |
| 15 | `web` | 35 | `menu-day` | 55 | `about` |
| 16 | `web__pick-text` | 36 | `menu-month` | 56 | `licenses` |
| 17 | `web-preview` | 37 | `menu~add` | 57 | `components` |
| 18 | `share-in` | 38 | `menu~item` | EXT‑01..06 | `ext-timer-notif`, `ext-share-target`, `ext-os-pickers`, `ext-icon`, `ext-pdf-book`, `ext-backup-html` |
| 19 | `scan` | 39 | `menu-templates` | | |

### 11.4 Design system page
- **Tokens** as JSON + CSS variables, light and dark, with names that map 1:1 to Flutter: `ColorScheme` (primary,
  onPrimary, primaryContainer, onPrimaryContainer, secondary…, tertiary…, surface, surfaceContainerLowest…Highest,
  onSurface, onSurfaceVariant, outline, outlineVariant, error, onError, errorContainer, inverseSurface,
  onInverseSurface, inversePrimary, scrim) + a `ThemeExtension CookNoteColors` (success, onSuccess, warning,
  onWarning, info, crossedOff, currentStep, timerActive, expiringSoon, expired, suggested, photoPlaceholder 1..8,
  cookSurface/cookInk for Cook mode). Every pair listed with its contrast ratio (≥ 4.5:1 text, ≥ 3:1 icons/large).
- **Type scale** (font, size, weight, line height, tracking) mapped to `TextTheme` + Cook‑mode styles (`cookStep`,
  `cookStepCurrent`, `cookIngredient`, `timer`) with 4–5 in‑app size steps; tabular figures.
- **Spacing** (4/8 grid), **radius**, **elevation / borders** (dark theme uses tone, not shadow), **tap sizes**
  (`tapMin` 48, `tapCook` 64), **motion** (durations 150–250 ms, reduce‑motion behaviour).
- **Component sheet** (states: default, pressed, focused, disabled, selected, error; light + dark) — the list in SCR‑57.
- **Icon list** with licence; **illustrations** for onboarding and empty states (style guide + files, SVG).

### 11.5 Format and where to save
claude.ai link + **HTML and PNG export per frame** (so the developer can read exact colours, spacing, fonts) + tokens
JSON, saved into **`apps/A004-cooknote/design/hifi/`** with the §11.3 names. Keep a `design/hifi/README.md` listing the
link, the date, and any `COPY:` changes or token deviations.
