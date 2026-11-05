/// Danh sách đi chợ dạng chữ để chia sẻ qua bảng chia sẻ của hệ điều hành
/// (AC-37): tiêu đề, rồi từng khu vực, mỗi món một dòng "- ...". Bỏ khu vực
/// không có món.
String shoppingListToText({
  required String title,
  required List<({String aisle, List<String> lines})> groups,
}) {
  final out = StringBuffer('$title\n');
  for (final g in groups) {
    if (g.lines.isEmpty) continue;
    out.write('\n${g.aisle}\n');
    for (final l in g.lines) {
      out.write('- $l\n');
    }
  }
  return out.toString();
}
