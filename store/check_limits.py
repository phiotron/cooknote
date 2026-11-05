"""Check store listing field lengths in store/*.md.

Each field is a fenced ```text block preceded by a marker line:
    <!-- field: <name> limit=<n> [unit=bytes] -->
Characters are Unicode code points (Play and Apple count characters);
unit=bytes counts UTF-8 bytes (Apple keywords: "up to 100 bytes").
Keyword fields (name contains "keywords") also report duplicate terms.

Usage: python store/check_limits.py   (exit code 1 if any field is over)
"""
import pathlib
import re
import sys

MARK = re.compile(r"<!-- field: (\S+) limit=(\d+)(?: unit=(bytes))? -->\s*\n```text\n(.*?)\n```", re.S)


def main() -> int:
    root = pathlib.Path(__file__).resolve().parent
    over = 0
    for md in sorted(root.glob("*.md")):
        for name, limit, unit, body in MARK.findall(md.read_text(encoding="utf-8")):
            limit = int(limit)
            chars = len(body)
            size = len(body.encode("utf-8"))
            used = size if unit == "bytes" else chars
            ok = used <= limit
            over += 0 if ok else 1
            extra = ""
            if "keywords" in name:
                terms = [t.strip().lower() for t in body.split(",")]
                dups = sorted({t for t in terms if terms.count(t) > 1})
                short = [t for t in terms if len(t) <= 2]
                spaces = ", ".join(t for t in body.split(",") if t != t.strip())
                extra = f" terms={len(terms)} dups={dups or '-'} short={short or '-'}"
                if spaces:
                    extra += f" SPACE-AROUND-COMMA:{spaces}"
            print(f"{'OK  ' if ok else 'OVER'} {md.name}:{name} chars={chars} bytes={size} "
                  f"limit={limit}{' bytes' if unit else ' chars'}{extra}")
    return 1 if over else 0


if __name__ == "__main__":
    sys.exit(main())
