/// Phần của công thức mà một dòng thuộc về.
enum LineSection { ingredient, step }

/// Một dòng nguyên liệu hoặc một bước; [isHeading] là tiêu đề nhóm (AC-02).
class RecipeLine {
  const RecipeLine(this.text, {this.isHeading = false});

  final String text;
  final bool isHeading;

  @override
  bool operator ==(Object other) =>
      other is RecipeLine && other.text == text && other.isHeading == isHeading;

  @override
  int get hashCode => Object.hash(text, isHeading);

  @override
  String toString() => isHeading ? 'RecipeLine($text:)' : 'RecipeLine($text)';
}

final _bullet = RegExp(r'^[-•*·–]\s+');
// "1." "2)" "Bước 3." "Step 4:" ở đầu bước; nguyên liệu giữ số vì đó là số lượng.
final _stepNumber = RegExp(
  r'^(?:(?:bước|step)\s*)?\d+\s*[.):]\s*',
  caseSensitive: false,
);

/// Tách một khối chữ thành các dòng (AC-03): mỗi dòng một mục, bỏ dòng trống,
/// dòng kết thúc bằng `:` là tiêu đề nhóm.
List<RecipeLine> parseLines(String text, LineSection section) {
  final result = <RecipeLine>[];
  for (final raw in text.split(RegExp(r'\r?\n'))) {
    var line = raw.trim().replaceFirst(_bullet, '');
    if (line.endsWith(':')) {
      final title = line.substring(0, line.length - 1).trim();
      if (title.isNotEmpty) result.add(RecipeLine(title, isHeading: true));
      continue;
    }
    if (section == LineSection.step) line = line.replaceFirst(_stepNumber, '');
    line = line.trim();
    if (line.isNotEmpty) result.add(RecipeLine(line));
  }
  return result;
}

/// Ngược lại của [parseLines]: tiêu đề nhóm viết thêm `:` ở cuối.
String serializeLines(List<RecipeLine> lines) =>
    lines.map((l) => l.isHeading ? '${l.text}:' : l.text).join('\n');
