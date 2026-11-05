"""Sinh lib/src/ui/illustrations.g.dart từ design/hifi/assets/brand/illo-*.svg.
Không dùng flutter_svg: mỗi minh hoạ thành mã vẽ Canvas, màu theo vai trò (ink/accent/herb/
turmeric) để theo chủ đề sáng/tối. Chạy: python tool/gen_illustrations.py
Lưu ý: nguồn SVG có thuộc tính stroke trùng nhau (stroke="#5C5043" ... stroke="#9A4518");
ở đây lấy giá trị CUỐI (màu nhấn, đúng ý thiết kế).
"""
import pathlib
import re

root = pathlib.Path(__file__).resolve().parent.parent
src = root / "design/hifi/assets/brand"
out = root / "lib/src/ui/illustrations.g.dart"
ROLE = {"#5C5043": "ink", "#9A4518": "accent", "#3B6A45": "herb", "#7E5A00": "turmeric"}


def parse_attrs(raw):
    d = {}
    for k, v in re.findall(r'([\w-]+)="([^"]*)"', raw):
        d[k] = v  # trùng tên: giá trị cuối thắng
    return d


def num(v):
    v = float(v)
    return str(int(v)) if v == int(v) else repr(v)


def path_ops(d):
    toks = re.findall(r"[MmLlHhVvQqTtAaZz]|-?\d*\.?\d+", d)
    i = 0
    x = y = sx = sy = 0.0
    lcx = lcy = None
    cmd = None
    ops = []

    def nxt():
        nonlocal i
        v = float(toks[i])
        i += 1
        return v

    while i < len(toks):
        if re.match(r"[A-Za-z]", toks[i]):
            cmd = toks[i]
            i += 1
            if cmd in "Zz":
                ops.append("path.close();")
                x, y = sx, sy
                lcx = lcy = None
                continue
        rel = cmd.islower()
        c = cmd.upper()
        if c == "M":
            nx, ny = nxt(), nxt()
            if rel:
                nx += x
                ny += y
            x, y = nx, ny
            sx, sy = x, y
            ops.append("path.moveTo(%s, %s);" % (num(x), num(y)))
            cmd = "l" if rel else "L"
            lcx = lcy = None
        elif c == "L":
            nx, ny = nxt(), nxt()
            if rel:
                nx += x
                ny += y
            x, y = nx, ny
            ops.append("path.lineTo(%s, %s);" % (num(x), num(y)))
            lcx = lcy = None
        elif c == "H":
            nx = nxt()
            x = x + nx if rel else nx
            ops.append("path.lineTo(%s, %s);" % (num(x), num(y)))
            lcx = lcy = None
        elif c == "V":
            ny = nxt()
            y = y + ny if rel else ny
            ops.append("path.lineTo(%s, %s);" % (num(x), num(y)))
            lcx = lcy = None
        elif c == "Q":
            cx, cy, nx, ny = nxt(), nxt(), nxt(), nxt()
            if rel:
                cx += x
                cy += y
                nx += x
                ny += y
            ops.append("path.quadraticBezierTo(%s, %s, %s, %s);" % (num(cx), num(cy), num(nx), num(ny)))
            x, y = nx, ny
            lcx, lcy = cx, cy
        elif c == "T":
            nx, ny = nxt(), nxt()
            if rel:
                nx += x
                ny += y
            cx, cy = (2 * x - lcx, 2 * y - lcy) if lcx is not None else (x, y)
            ops.append("path.quadraticBezierTo(%s, %s, %s, %s);" % (num(cx), num(cy), num(nx), num(ny)))
            x, y = nx, ny
            lcx, lcy = cx, cy
        elif c == "A":
            rx, ry, rot, large, sweep, nx, ny = [nxt() for _ in range(7)]
            if rel:
                nx += x
                ny += y
            ops.append(
                "path.arcToPoint(Offset(%s, %s), radius: Radius.elliptical(%s, %s), rotation: %s, largeArc: %s, clockwise: %s);"
                % (num(nx), num(ny), num(rx), num(ry), num(rot), "true" if large else "false", "true" if sweep else "false")
            )
            x, y = nx, ny
            lcx = lcy = None
        else:
            raise SystemExit("cmd " + cmd)
    return ops


def paint_ops(a, drawable):
    fill = a.get("fill", "none")
    stroke = a.get("stroke", "none")
    w = a.get("stroke-width", "3")
    op = a.get("opacity")
    if op == "0":
        return []
    opacity = "" if op is None else ", opacity: " + op
    res = []
    if fill != "none":
        res.append("c.%s(%s, pal.fill(_Role.%s%s));" % (drawable[0], drawable[1], ROLE[fill], opacity))
    if stroke != "none":
        dash = a.get("stroke-dasharray")
        if dash and drawable[0] == "drawPath":
            on, off = dash.split()
            res.append("_dashed(c, %s, pal.stroke(_Role.%s, %s%s), %s, %s);" % (drawable[1], ROLE[stroke], w, opacity, on, off))
        else:
            res.append("c.%s(%s, pal.stroke(_Role.%s, %s%s));" % (drawable[0], drawable[1], ROLE[stroke], w, opacity))
    return res


funcs = []
for f in sorted(src.glob("illo-*.svg")):
    name = f.stem.split("-", 1)[1]
    s = f.read_text(encoding="utf8")
    vb = re.search(r'viewBox="0 0 (\d+) (\d+)"', s).groups()
    body = []
    for m in re.finditer(r"<(rect|line|circle|path|text)\b([^>]*?)(/>|>([^<]*)</text>)", s):
        tag, raw, _, inner = m.groups()
        a = parse_attrs(raw)
        lines = []
        if tag == "rect":
            x, y, w, h = [float(a[k]) for k in ("x", "y", "width", "height")]
            rx = float(a.get("rx", 0))
            dr = (
                "drawRRect",
                "RRect.fromRectAndRadius(Rect.fromLTWH(%s, %s, %s, %s), const Radius.circular(%s))"
                % (num(x), num(y), num(w), num(h), num(rx)),
            )
            lines = paint_ops(a, dr)
            t = a.get("transform")
            if t:
                r = re.match(r"rotate\(([\d.-]+) ([\d.-]+) ([\d.-]+)\)", t).groups()
                lines = (
                    ["c.save();", "c.translate(%s, %s);" % (r[1], r[2]), "c.rotate(%s * math.pi / 180);" % r[0],
                     "c.translate(-%s, -%s);" % (r[1], r[2])]
                    + lines
                    + ["c.restore();"]
                )
        elif tag == "line":
            x1, y1, x2, y2 = [float(a[k]) for k in ("x1", "y1", "x2", "y2")]
            lines = paint_ops(
                {**a, "fill": "none"},
                ("drawLine", "Offset(%s, %s), Offset(%s, %s)" % (num(x1), num(y1), num(x2), num(y2))),
            )
        elif tag == "circle":
            dr = ("drawCircle", "Offset(%s, %s), %s" % (num(a["cx"]), num(a["cy"]), num(a["r"])))
            lines = paint_ops(a, dr)
        elif tag == "path":
            lines = ["{", "final path = Path();"] + path_ops(a["d"]) + paint_ops(a, ("drawPath", "path")) + ["}"]
        elif tag == "text":
            lines = ["_text(c, '%s', %s, %s, _Role.%s, pal, %s);" % (inner, num(a["x"]), num(a["y"]), ROLE[a["fill"]], num(a["font-size"]))]
        body += lines
    funcs.append((name, vb, body))

names = [n for n, _, _ in funcs]
o = [
    "// GENERATED by tool/gen_illustrations.py from design/hifi/assets/brand/illo-*.svg — do not edit by hand.\n",
    "// ignore_for_file: lines_longer_than_80_chars, unnecessary_parenthesis\n",
    "part of 'illustrations.dart';\n\n",
    "/// Minh hoạ nét đường dùng cho trạng thái rỗng và màn chào.\n",
    "enum BepIllo { %s }\n\n" % ", ".join(names),
    "/// Kích thước gốc (viewBox) của minh hoạ.\nSize bepIlloSize(BepIllo i) => switch (i) {\n",
]
for name, vb, _ in funcs:
    o.append("  BepIllo.%s => const Size(%s, %s),\n" % (name, vb[0], vb[1]))
o.append("};\n\n")
o.append("void _paintIllo(BepIllo i, Canvas c, _Palette pal) {\n  switch (i) {\n")
for name in names:
    o.append("    case BepIllo.%s:\n      _%s(c, pal);\n" % (name, name))
o.append("  }\n}\n\n")
for name, vb, body in funcs:
    o.append("void _%s(Canvas c, _Palette pal) {\n" % name)
    o += ["  " + l + "\n" for l in body]
    o.append("}\n\n")
out.write_text("".join(o).rstrip() + "\n", encoding="utf8")
print("wrote", out, names)
