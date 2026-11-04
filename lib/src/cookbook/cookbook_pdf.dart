import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/recipe_lines.dart';

/// Font Unicode nhúng vào PDF (SPEC F-10). Lớp logic không đọc `rootBundle`:
/// nơi gọi nạp byte TTF từ asset (hoặc từ file khi test) rồi truyền vào.
class CookbookFonts {
  const CookbookFonts({required this.regular, required this.bold});

  final Uint8List regular;
  final Uint8List bold;
}

/// Nhãn hiển thị trong PDF, mặc định tiếng Việt; nơi gọi có thể thay theo ngôn ngữ.
class CookbookLabels {
  const CookbookLabels({
    this.contents = 'Mục lục',
    this.ingredients = 'Nguyên liệu',
    this.steps = 'Cách làm',
    this.notes = 'Ghi chú',
    this.source = 'Nguồn',
    this.servings = 'Khẩu phần',
    this.prep = 'Chuẩn bị',
    this.cook = 'Nấu',
    this.total = 'Tổng',
    this.minutes = 'phút',
    this.page = 'Trang',
  });

  final String contents;
  final String ingredients;
  final String steps;
  final String notes;
  final String source;
  final String servings;
  final String prep;
  final String cook;
  final String total;
  final String minutes;
  final String page;
}

/// Một công thức đưa vào PDF. [coverImage] là byte JPEG đã thu nhỏ (lớp này
/// không đọc file); byte hỏng thì bỏ qua ảnh, không làm sập.
class CookbookRecipe {
  const CookbookRecipe({
    required this.name,
    this.servings,
    this.servingsUnit,
    this.prepMinutes,
    this.cookMinutes,
    this.totalMinutes,
    this.source,
    this.notes,
    this.ingredients = const [],
    this.steps = const [],
    this.coverImage,
  });

  final String name;
  final double? servings;
  final String? servingsUnit;
  final int? prepMinutes;
  final int? cookMinutes;
  final int? totalMinutes;
  final String? source;
  final String? notes;
  final List<RecipeLine> ingredients;
  final List<RecipeLine> steps;
  final Uint8List? coverImage;
}

/// Toàn bộ nội dung Sách công thức.
class CookbookInput {
  const CookbookInput({
    required this.title,
    required this.recipes,
    required this.fonts,
    this.coverImage,
    this.labels = const CookbookLabels(),
  });

  final String title;
  final List<CookbookRecipe> recipes;
  final CookbookFonts fonts;
  final Uint8List? coverImage;
  final CookbookLabels labels;
}

/// Tính trang bắt đầu (đếm từ 1) của từng công thức. [pagesBeforeRecipes] là số
/// trang đứng trước công thức đầu tiên (bìa + mục lục), [recipePageCounts] là
/// số trang mỗi công thức chiếm. Hàm thuần để test.
List<int> computeStartPages({
  required int pagesBeforeRecipes,
  required List<int> recipePageCounts,
}) {
  final starts = <int>[];
  var next = pagesBeforeRecipes + 1;
  for (final count in recipePageCounts) {
    starts.add(next);
    next += count;
  }
  return starts;
}

/// Dựng PDF Sách công thức: bìa, mục lục (số trang đúng), mỗi công thức một
/// trang mới. [compress] chỉ tắt khi test cần đọc nội dung PDF.
Future<Uint8List> buildCookbookPdf(
  CookbookInput input, {
  bool compress = true,
}) async {
  final theme = _theme(input.fonts);
  // Lượt 1 đo số trang (mục lục điền số tạm), lượt sau điền số thật; lặp đến
  // khi số trang mục lục điền vào khớp số trang đo được.
  var starts = List<int>.filled(input.recipes.length, 1);
  var built = await _assemble(input, theme, starts, compress);
  for (var i = 0; i < 4; i++) {
    final real = computeStartPages(
      pagesBeforeRecipes: built.pagesBeforeRecipes,
      recipePageCounts: built.recipePageCounts,
    );
    if (_sameList(real, starts) && i > 0) return built.bytes;
    starts = real;
    built = await _assemble(input, theme, starts, compress);
  }
  return built.bytes;
}

/// PDF một công thức để chia sẻ hoặc in (không bìa, không mục lục).
Future<Uint8List> buildRecipePdf(
  CookbookRecipe recipe,
  CookbookFonts fonts, {
  CookbookLabels labels = const CookbookLabels(),
  bool compress = true,
}) async {
  final doc = pw.Document(compress: compress, title: recipe.name);
  _addRecipe(doc, _theme(fonts), recipe, labels);
  return doc.save();
}

class _Assembled {
  _Assembled(this.bytes, this.pagesBeforeRecipes, this.recipePageCounts);

  final Uint8List bytes;
  final int pagesBeforeRecipes;
  final List<int> recipePageCounts;
}

bool _sameList(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

pw.ThemeData _theme(CookbookFonts fonts) {
  final regular = pw.Font.ttf(ByteData.sublistView(fonts.regular));
  final bold = pw.Font.ttf(ByteData.sublistView(fonts.bold));
  return pw.ThemeData.withFont(
    base: regular,
    bold: bold,
    italic: regular,
    boldItalic: bold,
  );
}

int _pageCount(pw.Document doc) => doc.document.pdfPageList.pages.length;

const _margin = pw.EdgeInsets.all(40);
const _maxPages = 5000;

Future<_Assembled> _assemble(
  CookbookInput input,
  pw.ThemeData theme,
  List<int> startPages,
  bool compress,
) async {
  final labels = input.labels;
  final doc = pw.Document(compress: compress, title: input.title);

  // Bìa.
  final cover = _image(input.coverImage);
  doc.addPage(
    pw.Page(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: _margin,
      build: (_) => pw.Center(
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            if (cover != null)
              pw.ConstrainedBox(
                constraints: const pw.BoxConstraints(maxHeight: 420),
                child: pw.Image(cover, fit: pw.BoxFit.contain),
              ),
            if (cover != null) pw.SizedBox(height: 32),
            pw.Text(
              input.title,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );

  // Mục lục (có thể dài hơn một trang). Chân trang dùng số trang tuyệt đối
  // của tài liệu (ctx.pageNumber).
  doc.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: _margin,
      maxPages: _maxPages,
      footer: (ctx) => _footer(labels, ctx.pageNumber),
      build: (_) => [
        pw.Text(
          labels.contents,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        for (var i = 0; i < input.recipes.length; i++)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    input.recipes[i].name,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.SizedBox(
                  width: 48,
                  child: pw.Text(
                    '${startPages[i]}',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
  final pagesBefore = _pageCount(doc);

  final counts = <int>[];
  for (final recipe in input.recipes) {
    final before = _pageCount(doc);
    _addRecipe(doc, theme, recipe, labels);
    counts.add(_pageCount(doc) - before);
  }
  return _Assembled(await doc.save(), pagesBefore, counts);
}

pw.Widget _footer(CookbookLabels labels, int absolutePage) => pw.Align(
  alignment: pw.Alignment.centerRight,
  child: pw.Text(
    '${labels.page} $absolutePage',
    style: const pw.TextStyle(fontSize: 9),
  ),
);

pw.MemoryImage? _image(Uint8List? bytes) {
  if (bytes == null || bytes.isEmpty) return null;
  try {
    return pw.MemoryImage(bytes);
  } catch (_) {
    return null; // Ảnh hỏng: bỏ ảnh, giữ phần còn lại.
  }
}

String _number(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

pw.Widget _subHeading(String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 6, bottom: 2),
  child: pw.Text(
    text,
    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
  ),
);

/// Thêm công thức bắt đầu ở trang mới. Dòng dài dùng `Text` (tách được qua
/// trang), không dùng `Row` để một bước rất dài không làm tràn.
void _addRecipe(
  pw.Document doc,
  pw.ThemeData theme,
  CookbookRecipe r,
  CookbookLabels l,
) {
  final image = _image(r.coverImage);
  final unit = _clean(r.servingsUnit);
  final meta = <String>[
    if (r.servings != null)
      '${l.servings}: ${_number(r.servings!)}${unit != null ? ' $unit' : ''}',
    if (r.prepMinutes != null) '${l.prep}: ${r.prepMinutes} ${l.minutes}',
    if (r.cookMinutes != null) '${l.cook}: ${r.cookMinutes} ${l.minutes}',
    if (r.totalMinutes != null) '${l.total}: ${r.totalMinutes} ${l.minutes}',
  ];
  final source = _clean(r.source);
  final notes = _clean(r.notes);

  pw.Widget heading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
    ),
  );

  // Số bước tính trước (không phụ thuộc số lần `build` được gọi).
  final numbers = <int>[];
  var n = 0;
  for (final s in r.steps) {
    numbers.add(s.isHeading ? 0 : ++n);
  }
  doc.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: _margin,
      maxPages: _maxPages,
      footer: (ctx) => _footer(l, ctx.pageNumber),
      build: (_) => [
        pw.Text(
          r.name,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        if (image != null)
          pw.Center(
            child: pw.ConstrainedBox(
              constraints: const pw.BoxConstraints(maxHeight: 220),
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        if (meta.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              meta.join('   |   '),
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        if (source != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              '${l.source}: $source',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        if (r.ingredients.isNotEmpty) heading(l.ingredients),
        for (final line in r.ingredients)
          if (line.isHeading)
            _subHeading(line.text)
          else
            pw.Text('•  ${line.text}', style: const pw.TextStyle(fontSize: 12)),
        if (r.steps.isNotEmpty) heading(l.steps),
        for (var i = 0; i < r.steps.length; i++)
          if (r.steps[i].isHeading)
            _subHeading(r.steps[i].text)
          else
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                '${numbers[i]}.  ${r.steps[i].text}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
        if (notes != null) heading(l.notes),
        if (notes != null)
          pw.Text(notes, style: const pw.TextStyle(fontSize: 12)),
      ],
    ),
  );
}
