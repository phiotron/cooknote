// Trích văn bản từng trang từ PDF do package:pdf tạo (chỉ dùng cho test).
// Giới hạn: chỉ đọc đúng kiểu PDF này (tạo với compress: false, font Type0
// Identity-H có ToUnicode, nội dung trang là các toán tử TJ với chuỗi hex 4
// chữ số). Không phải bộ đọc PDF tổng quát.
import 'dart:convert';
import 'dart:typed_data';

class PdfText {
  PdfText(this.pages);

  /// Văn bản mỗi trang, các khối chữ (BT..ET) cách nhau bằng '\n'.
  final List<String> pages;
}

Map<int, String> _parseCmap(String cmap) {
  final maps = <int, String>{};
  for (final m in RegExp(
    r'beginbfrange(.*?)endbfrange',
    dotAll: true,
  ).allMatches(cmap)) {
    for (final r in RegExp(
      r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>',
    ).allMatches(m.group(1)!)) {
      final lo = int.parse(r.group(1)!, radix: 16);
      final hi = int.parse(r.group(2)!, radix: 16);
      final dst = int.parse(r.group(3)!, radix: 16);
      for (var g = lo; g <= hi; g++) {
        maps[g] = String.fromCharCode(dst + g - lo);
      }
    }
  }
  for (final m in RegExp(
    r'beginbfchar(.*?)endbfchar',
    dotAll: true,
  ).allMatches(cmap)) {
    for (final r in RegExp(
      r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>',
    ).allMatches(m.group(1)!)) {
      final g = int.parse(r.group(1)!, radix: 16);
      final hex = r.group(2)!;
      maps[g] = String.fromCharCodes([
        for (var i = 0; i + 4 <= hex.length; i += 4)
          int.parse(hex.substring(i, i + 4), radix: 16),
      ]);
    }
  }
  return maps;
}

PdfText readPdf(Uint8List bytes) {
  final s = latin1.decode(bytes);
  final objects = <int, String>{};
  for (final m in RegExp(
    r'(\d+) 0 obj(.*?)endobj',
    dotAll: true,
  ).allMatches(s)) {
    objects[int.parse(m.group(1)!)] = m.group(2)!;
  }

  // Mỗi font có bảng glyph -> ký tự riêng (font con tạo theo từng tài liệu).
  final cmaps = <int, Map<int, String>>{};
  Map<int, String> cmapOfFont(int fontObj) => cmaps.putIfAbsent(fontObj, () {
    final tu = RegExp(r'/ToUnicode\s*(\d+) 0 R')
        .firstMatch(objects[fontObj] ?? '');
    if (tu == null) return const {};
    return _parseCmap(objects[int.parse(tu.group(1)!)] ?? '');
  });

  final pagesObj = objects.values.firstWhere(
    (o) => RegExp(r'/Type\s*/Pages\b').hasMatch(o),
  );
  final kids = RegExp(r'(\d+) 0 R')
      .allMatches(
        RegExp(
          r'/Kids\s*\[(.*?)\]',
          dotAll: true,
        ).firstMatch(pagesObj)!.group(1)!,
      )
      .map((m) => int.parse(m.group(1)!))
      .toList();

  final pages = <String>[];
  for (final id in kids) {
    final page = objects[id]!;
    final fontRes = <String, int>{
      for (final f in RegExp(r'/(F\d+)\s*(\d+) 0 R').allMatches(page))
        f.group(1)!: int.parse(f.group(2)!),
    };
    final contents = RegExp(r'/Contents\s*(?:\[\s*)?(\d+) 0 R')
        .firstMatch(page);
    final lines = <String>[];
    if (contents != null) {
      final stream = objects[int.parse(contents.group(1)!)] ?? '';
      var cmap = const <int, String>{};
      final b = StringBuffer();
      // Duyệt theo thứ tự: đổi font (Tf) và chuỗi hex trong TJ; ET kết thúc khối.
      final token = RegExp(r'/(F\d+)\s+[\d.]+\s+Tf|<([0-9a-fA-F]+)>|\bET\b');
      for (final t in token.allMatches(stream)) {
        if (t.group(1) != null) {
          cmap = cmapOfFont(fontRes[t.group(1)!] ?? -1);
        } else if (t.group(2) != null) {
          final hex = t.group(2)!;
          for (var i = 0; i + 4 <= hex.length; i += 4) {
            b.write(cmap[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '?');
          }
        } else if (b.isNotEmpty) {
          lines.add(b.toString());
          b.clear();
        }
      }
    }
    pages.add(lines.join(' '));
  }
  return PdfText(pages);
}
