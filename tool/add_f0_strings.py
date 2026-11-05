"""F0: đổi "CookNote" -> "Bepbook" trong .arb (giữ đuôi .cooknote) và thêm chuỗi mới dùng chung
cùng chuỗi COPY của mockup Hi-Fi (design/hifi/README.md). Chạy lại được (không thêm trùng).
Chạy: python tool/add_f0_strings.py && flutter gen-l10n
"""
import json
import pathlib
import re

root = pathlib.Path(__file__).resolve().parent.parent
N = {"n": {"type": "int"}}

# (khóa, en, vi, placeholders hoặc None, ghi chú nhóm)
NEW = [
    # --- khung / dùng chung (F0) ---
    ("backupStatusSafe", "Safe", "An toàn", None),
    ("backupStatusOverdue", "Overdue", "Quá hạn", None),
    ("backupStatusFailing", "Failing", "Đang lỗi", None),
    ("backupStatusNotSetUp", "Not set up", "Chưa bật", None),
    ("dataUnchanged", "Your data is unchanged.", "Dữ liệu của bạn vẫn nguyên.", None),
    ("timerPillOne", "{name} · {time}", "{name} · {time}", {"name": {"type": "String"}, "time": {"type": "String"}}),
    ("timerPillMany", "{count} timers · {time}", "{count} hẹn giờ · {time}", {"count": {"type": "int"}, "time": {"type": "String"}}),
    ("timerPillSemantics", "Timer {name}, {time} left. Opens Cook mode.", "Hẹn giờ {name}, còn {time}. Mở Chế độ nấu.", {"name": {"type": "String"}, "time": {"type": "String"}}),
    ("timerPillManySemantics", "{count} timers running, next ends in {time}. Opens Cook mode.", "Đang chạy {count} hẹn giờ, cái gần nhất còn {time}. Mở Chế độ nấu.", {"count": {"type": "int"}, "time": {"type": "String"}}),
    ("errorRetry", "Try again", "Thử lại", None),
    ("ratingSemantics", "{n} of 5 stars", "{n} trên 5 sao", N),
    ("ratingUnset", "No rating", "Chưa đánh giá", None),
    # --- G1 Công thức ---
    ("sortMissingLast", "Recipes without this info go last", "Công thức chưa có thông tin này xếp cuối", None),
    ("showNRecipes", "Show {n} recipes", "Xem {n} công thức", N),
    ("emptyTrash", "Empty trash", "Dọn thùng rác", None),
    # --- G2 Đưa vào ---
    ("previewTitle", "Check before saving", "Xem trước khi lưu", None),
    ("scanAssignTitle", "Sort the lines", "Gán dòng", None),
    ("scanReading", "Reading the recipe…", "Đang đọc công thức…", None),
    ("pickText", "Pick text", "Chọn chữ", None),
    ("chooseAnotherFile", "Choose another file", "Chọn file khác", None),
    ("webStartNote", "Pages you open are the only thing Bepbook loads from the internet.", "Chỉ những trang bạn mở mới được Bepbook tải từ internet.", None),
    ("extShareSaved", "Saved to Bepbook — open?", "Đã gửi sang Bepbook — mở app?", None),
    # --- G3 Chế độ nấu ---
    ("cookStepsDoneShow", "{n, plural, =1{1 step done · Show} other{{n} steps done · Show}}", "Đã xong {n} bước · Xem", N),
    ("cookStartOver", "Start over", "Làm lại từ đầu", None),
    ("timerAlreadyStarted", "Your timer has already started", "Hẹn giờ đã bắt đầu chạy", None),
    ("cookReadStopShort", "Stop", "Dừng", None),
    # --- G4 Đi chợ ---
    ("shoppingMakeFirstList", "Make your first list", "Tạo danh sách đầu tiên", None),
    ("shoppingNothingToBuy", "Nothing to buy", "Chưa có món cần mua", None),
    ("shoppingAllDone", "All done!", "Xong hết rồi!", None),
    ("shoppingDeleteListConfirm", "Delete the list \"{name}\" and its {n, plural, =1{1 item} other{{n} items}}?", "Xóa danh sách \"{name}\" và {n} món trong đó?", {"name": {"type": "String"}, "n": {"type": "int"}}),
    # --- G5 Thực đơn ---
    ("menuDropHere", "Drop here", "Thả vào đây", None),
    ("menuDayHasMeals", "This day already has meals", "Ngày này đã có món", None),
    # --- G6 Thêm / hệ thống ---
    ("dangerZone", "Danger zone", "Vùng nguy hiểm", None),
    ("deleting", "Deleting…", "Đang xóa…", None),
]


def load(p):
    return json.loads(p.read_text(encoding="utf8"))


def dump(p, d):
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf8")


def rebrand(s):
    # "CookNote" -> "Bepbook"; đuôi .cooknote (chữ thường) giữ nguyên
    return s.replace("CookNote", "Bepbook")


for lang in ("en", "vi"):
    p = root / ("lib/l10n/app_%s.arb" % lang)
    d = load(p)
    for k, v in list(d.items()):
        if isinstance(v, str) and not k.startswith("@"):
            d[k] = rebrand(v)
    for key, en, vi, ph in NEW:
        if key in d:
            continue
        d[key] = en if lang == "en" else vi
        if lang == "en":
            meta = {"description": "F0/Hi-Fi v1"}
            if ph:
                meta["placeholders"] = ph
            d["@" + key] = meta
    dump(p, d)
    print(lang, len(d))
