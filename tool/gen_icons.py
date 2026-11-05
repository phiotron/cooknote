"""Sinh icon app + splash (Android + iOS) từ design/hifi/assets/brand/app-icon-*.svg.
Không thêm dependency vào app: dùng Microsoft Edge headless (có sẵn trên Windows) để vẽ SVG
thành PNG 1024, rồi Pillow thu nhỏ (pip install pillow). Chạy: python tool/gen_icons.py
Đầu ra:
  Android  mipmap-*/ic_launcher.png (cũ) · drawable-*/ic_launcher_foreground.png +
           ic_launcher_monochrome.png (adaptive + biểu tượng chủ đề Android 13) ·
           drawable-nodpi/splash_icon.png (Android 12+ splash)
  iOS      AppIcon.appiconset/* (đặc, không alpha) · LaunchImage.imageset/*
Màu nền adaptive/splash nằm trong res/values*/colors.xml (file XML viết tay, không sinh ở đây).
"""
import json
import pathlib
import subprocess
import tempfile

from PIL import Image

root = pathlib.Path(__file__).resolve().parent.parent
brand = root / "design/hifi/assets/brand"
res = root / "android/app/src/main/res"
ios = root / "ios/Runner/Assets.xcassets"
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

PAPER = '<path d="M300 200h400a60 60 0 0 1 60 60v504a60 60 0 0 1-60 60H300a60 60 0 0 1-60-60V260a60 60 0 0 1 60-60z"'
RIBBON = '<path d="M590 160h96v520l-48-46-48 46z" fill="#F0C451"/><path d="M590 160h96v40h-96z" fill="#C99A1E"/>'
# glyph (muỗng + thìa) và gáy sổ của app-icon-full.svg
FG_ART = (
    PAPER + ' fill="#FBF6EC"/><rect x="300" y="200" width="44" height="624" fill="#E5D3BE"/>'
    '<g fill="#9A4518"><ellipse cx="490" cy="420" rx="62" ry="80"/><rect x="472" y="480" width="36" height="230" rx="18"/></g>'
    + RIBBON
)
# Adaptive: nội dung nằm trong vùng an toàn 66% (đường kính 626/1024) → thu 0.72, tâm sổ (500,492) về giữa.
FG_SVG = (
    '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">'
    '<g transform="translate(512 512) scale(0.72) translate(-500 -492)">' + FG_ART + "</g></svg>"
)
# Monochrome: hình sổ đặc, chi tiết bị khoét (mask) để hệ thống tô một màu.
MONO_SVG = (
    '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">'
    '<defs><mask id="m" maskUnits="userSpaceOnUse" x="0" y="0" width="1024" height="1024">'
    '<rect width="1024" height="1024" fill="#fff"/>'
    '<g fill="#000"><rect x="300" y="200" width="44" height="624"/><path d="M560 200h96v420l-48-44-48 44z"/>'
    '<ellipse cx="470" cy="420" rx="62" ry="80"/><rect x="452" y="480" width="36" height="230" rx="18"/></g></mask></defs>'
    '<g transform="translate(512 512) scale(0.72) translate(-500 -492)">'
    + PAPER + ' fill="#000" mask="url(#m)"/></g></svg>'
)
# Splash Android 12+: biểu tượng bo góc thu 0.66 giữa khung trong suốt (nằm trong vòng tròn 2/3).
SPLASH_SVG = (
    '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">'
    '<g transform="translate(512 512) scale(0.62) translate(-512 -512)">'
    + (brand / "app-icon-full.svg").read_text(encoding="utf8").split(">", 1)[1].replace("</svg>", "")
    + "</g></svg>"
)


def render(svg_text, out_png, size=1024):
    with tempfile.TemporaryDirectory() as td:
        td = pathlib.Path(td)
        (td / "a.svg").write_text(svg_text, encoding="utf8")
        (td / "a.html").write_text(
            '<html><body style="margin:0;background:transparent"><img src="a.svg" width="%d" height="%d" style="display:block"></body></html>' % (size, size),
            encoding="utf8",
        )
        subprocess.run(
            [EDGE, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--default-background-color=00000000",
             "--window-size=%d,%d" % (size, size), "--screenshot=" + str(out_png), (td / "a.html").as_uri()],
            check=True, capture_output=True,
        )


def save(im, path, px, flatten=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    out = im.resize((px, px), Image.LANCZOS)
    if flatten:
        bg = Image.new("RGB", out.size, (154, 69, 24))
        bg.paste(out, mask=out.split()[3])
        out = bg
    out.save(path, optimize=True)


work = pathlib.Path(tempfile.mkdtemp(prefix="icons_"))
srcs = {
    "full": (brand / "app-icon-full.svg").read_text(encoding="utf8"),
    "square": (brand / "app-icon-square.svg").read_text(encoding="utf8"),
    "fg": FG_SVG, "mono": MONO_SVG, "splash": SPLASH_SVG,
}
img = {}
for k, v in srcs.items():
    render(v, work / (k + ".png"))
    img[k] = Image.open(work / (k + ".png")).convert("RGBA")
    assert img[k].size == (1024, 1024), (k, img[k].size)

# Android
for d, px in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)):
    save(img["full"], res / ("mipmap-" + d) / "ic_launcher.png", px)
for d, px in (("mdpi", 108), ("hdpi", 162), ("xhdpi", 216), ("xxhdpi", 324), ("xxxhdpi", 432)):
    save(img["fg"], res / ("drawable-" + d) / "ic_launcher_foreground.png", px)
    save(img["mono"], res / ("drawable-" + d) / "ic_launcher_monochrome.png", px)
save(img["splash"], res / "drawable-nodpi" / "splash_icon.png", 512)

# iOS AppIcon: đặc, không alpha, không bo góc (hệ điều hành tự bo) → dùng bản vuông
icon_dir = ios / "AppIcon.appiconset"
contents = json.loads((icon_dir / "Contents.json").read_text(encoding="utf8"))
for it in contents["images"]:
    fn = it.get("filename")
    if not fn:
        continue
    w = float(it["size"].split("x")[0])
    scale = int(it["scale"].rstrip("x"))
    save(img["square"], icon_dir / fn, round(w * scale), flatten=True)
# iOS LaunchImage: biểu tượng bo góc 120 pt trên nền màu (nền do storyboard/colorset)
li = ios / "LaunchImage.imageset"
for fn, px in (("LaunchImage.png", 120), ("LaunchImage@2x.png", 240), ("LaunchImage@3x.png", 360)):
    save(img["full"], li / fn, px)
print("ok", work)
