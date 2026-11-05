"""Gộp các tập con woff2 (latin + latin-ext + vietnamese) của design/hifi/assets/fonts
thành một file TTF mỗi kiểu chữ trong assets/fonts/ (Flutter không đọc woff2 và không có
unicode-range). Chạy: python tool/build_fonts.py  (cần fonttools + brotli).
"""
import pathlib
from fontTools.ttLib import TTFont
from fontTools.merge import Merger

root = pathlib.Path(__file__).resolve().parent.parent
src = root / "design/hifi/assets/fonts"
out = root / "assets/fonts"

# (tên ra, tiền tố nguồn, trọng số-kiểu nguồn)
JOBS = [
    ("NotoSans-Regular-400", "noto-sans", "400-normal"),
    ("NotoSans-Medium", "noto-sans", "500-normal"),
    ("NotoSans-SemiBold", "noto-sans", "600-normal"),
    ("NotoSans-Bold-700", "noto-sans", "700-normal"),
    ("Lora-Medium", "lora", "500-normal"),
    ("Lora-MediumItalic", "lora", "500-italic"),
    ("Lora-SemiBold", "lora", "600-normal"),
    ("Lora-Bold", "lora", "700-normal"),
]
SUBSETS = ["latin", "latin-ext", "vietnamese"]

for name, prefix, style in JOBS:
    parts = []
    for sub in SUBSETS:
        f = src / f"{prefix}-{sub}-{style}.woff2"
        font = TTFont(str(f))
        font.flavor = None  # lưu ra TTF thường
        tmp = out / f"_tmp_{sub}.ttf"
        font.save(str(tmp))
        parts.append(str(tmp))
    merged = Merger().merge(parts)
    merged.save(str(out / f"{name}.ttf"))
    for p in parts:
        pathlib.Path(p).unlink()
    print(name, (out / f"{name}.ttf").stat().st_size)
