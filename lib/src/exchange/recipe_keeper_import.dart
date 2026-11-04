// Đọc file xuất của Recipe Keeper (SPEC F-10, AC-44).
//
// CHƯA kiểm chứng với file thật. Recipe Keeper KHÔNG công bố đặc tả. Cấu trúc
// dưới đây suy ra (2026-11-04) từ mô tả bộ nhập mã nguồn mở:
//  - https://docs.tandoor.dev/features/import_export  (Tandoor nhập zip Recipe Keeper)
//  - https://raw.githubusercontent.com/TandoorRecipes/recipes/develop/cookbook/integration/recipekeeper.py
//    (zip có `recipes.html` ở gốc; mỗi công thức là `div.recipe-details`;
//    `h2[itemprop=name]`, `meta[itemprop=recipeCategory]@content`,
//    `span[itemprop=recipeCourse]`, `span[itemprop=recipeYield]`, thời gian
//    prepTime/cookTime, `div[itemprop=recipeIngredients] > p`,
//    `div[itemprop=recipeDirections] > p`, `div[itemprop=recipeNotes]`,
//    `span[itemprop=recipeSource]`, `img.recipe-photo@src`)
//  - https://vanilla-cookbook.readthedocs.io/en/latest/manual/import/
//    (ảnh nằm ở `images/<uid>_*.jpg`)
// Không có nguồn nào cho biết chắc: dạng chuỗi thời gian (đang nhận cả
// "PT1H30M" lẫn "1 hr 30 min", ở thuộc tính `content` hoặc nội dung chữ), cách
// đánh dấu tiêu đề nhóm nguyên liệu (đang coi dòng kết thúc bằng ":" là tiêu đề),
// mã công thức (không dùng uid, khóa nhập lại là băm tên + nguồn), và các
// itemprop `recipeRating` / `recipeIsFavourite` (đoán, đọc nếu có).
//
// Muốn sửa cho khớp file thật: chỉ cần đổi các hằng `_prop*` và hàm `_convert`.
// Không dùng thư viện HTML: bộ tách thẻ bên dưới chỉ đủ cho cấu trúc phẳng này.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../data/recipe_lines.dart';
import '../data/recipe_repository.dart';
import 'imported_recipe.dart';

const _propName = 'name';
const _propCategory = 'recipeCategory';
const _propCourse = 'recipeCourse';
const _propYield = 'recipeYield';
const _propPrep = 'prepTime';
const _propCook = 'cookTime';
const _propSource = 'recipeSource';
const _propIngredients = 'recipeIngredients';
const _propDirections = 'recipeDirections';
const _propNotes = 'recipeNotes';
const _propRating = 'recipeRating'; // đoán
const _propFavourite = 'recipeIsFavourite'; // đoán
const _recipeDivMarker = 'class="recipe-details"';

ImportResult readRecipeKeeperFile(File file) =>
    readRecipeKeeperBytes(file.readAsBytesSync());

ImportResult readRecipeKeeperBytes(List<int> bytes) {
  final Archive archive;
  try {
    if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) {
      throw const FormatException('PK');
    }
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    throw const ImportFormatException('Không phải file zip của Recipe Keeper');
  }
  final files = {
    for (final f in archive.files)
      if (f.isFile) f.name.replaceAll('\\', '/'): f,
  };
  final htmlName = files.keys.firstWhere(
    (n) => n == 'recipes.html' || n.endsWith('/recipes.html'),
    orElse: () => '',
  );
  if (htmlName.isEmpty) {
    throw const ImportFormatException('Thiếu recipes.html trong file zip');
  }
  // recipes.html là UTF-8; chịu được byte lỗi.
  final html = utf8.decode(files[htmlName]!.content, allowMalformed: true);
  final base = htmlName.substring(0, htmlName.length - 'recipes.html'.length);
  return parseRecipeKeeperHtml(
    html,
    readImage: (src) {
      final key = '$base${src.replaceAll('\\', '/')}';
      final f = files[key] ?? files[src];
      return f == null ? null : Uint8List.fromList(f.content);
    },
  );
}

/// Đọc HTML `recipes.html`; [readImage] trả byte của đường dẫn ảnh (null nếu
/// không có).
ImportResult parseRecipeKeeperHtml(
  String html, {
  Uint8List? Function(String src)? readImage,
}) {
  final out = ImportCollector();
  final parts = html.split(_recipeDivMarker);
  if (parts.length < 2) {
    out.warn(
      'Không thấy công thức nào (div.recipe-details) trong recipes.html',
    );
    return out.build();
  }
  for (var i = 1; i < parts.length; i++) {
    try {
      final r = _convert(parts[i], i, readImage, out);
      if (r != null) out.recipes.add(r);
    } catch (e) {
      out.skip('Công thức #$i: không đọc được ($e)');
    }
  }
  return out.build();
}

ImportedRecipe? _convert(
  String block,
  int index,
  Uint8List? Function(String src)? readImage,
  ImportCollector out,
) {
  final name = blankToNull(_text(block, _propName));
  if (name == null) {
    out.skip('Công thức #$index: không có tên');
    return null;
  }
  final (servings, unit) = parseServings(_text(block, _propYield));
  final source = blankToNull(_text(block, _propSource));
  final notes = _paragraphs(block, _propNotes).join('\n');
  final categories = <String>[
    for (final p in [_propCategory, _propCourse])
      for (final v in _all(block, p))
        if (v.isNotEmpty) v,
  ];

  final photos = <ImportedPhoto>[];
  final img = RegExp(
    r'<img\b[^>]*class="[^"]*recipe-photo[^"]*"[^>]*>',
    caseSensitive: false,
  ).firstMatch(block);
  final src = img == null ? null : _attr(img.group(0)!, 'src');
  if (src != null && readImage != null) {
    final data = readImage(_decode(src));
    if (data == null) {
      out.warn('$name: không thấy ảnh $src trong file, đã bỏ');
    } else if (!looksLikeImage(data)) {
      out.warn('$name: ảnh $src không phải JPEG/PNG, đã bỏ');
    } else {
      photos.add(ImportedPhoto(src.split('/').last, data));
    }
  }

  final ingredients = <RecipeLine>[
    for (final p in _paragraphs(block, _propIngredients))
      ...parseLines(p, LineSection.ingredient),
  ];
  final steps = <RecipeLine>[
    for (final p in _paragraphs(block, _propDirections))
      ...parseLines(p, LineSection.step),
  ];
  final ratingText = _text(block, _propRating);
  final rating = (int.tryParse(ratingText ?? '') ?? 0).clamp(0, 5);
  final fav = (_text(block, _propFavourite) ?? '').toLowerCase();

  return ImportedRecipe(
    draft: RecipeDraft(
      name: name,
      servings: servings,
      servingsUnit: unit,
      prepMinutes: parseMinutes(_text(block, _propPrep)),
      cookMinutes: parseMinutes(_text(block, _propCook)),
      source: source,
      sourceUrl: source != null && source.startsWith(RegExp('https?://'))
          ? source
          : null,
      notes: notes.isEmpty ? null : notes,
      rating: rating,
      favorite: fav == 'true' || fav == '1' || fav == 'yes',
      ingredients: ingredients,
      steps: steps,
    ),
    photos: photos,
    categoryNames: categories,
    dedupeKey: buildDedupeKey('recipekeeper', name: name, source: source),
  );
}

// --- Bộ tách thẻ tối giản --------------------------------------------------

String? _attr(String tag, String attr) {
  final m = RegExp(
    '$attr\\s*=\\s*(?:"([^"]*)"|\'([^\']*)\')',
    caseSensitive: false,
  ).firstMatch(tag);
  return m == null ? null : (m.group(1) ?? m.group(2));
}

/// Mọi phần tử có `itemprop="prop"`: meta lấy `content`, còn lại lấy chữ bên
/// trong (đã bỏ thẻ, giải mã ký tự đặc biệt).
List<String> _all(String block, String prop) {
  final result = <String>[];
  final open = RegExp(
    '<(\\w+)\\b[^>]*itemprop\\s*=\\s*["\']$prop["\'][^>]*>',
    caseSensitive: false,
  );
  for (final m in open.allMatches(block)) {
    final tagName = m.group(1)!.toLowerCase();
    if (tagName == 'meta') {
      final c = _attr(m.group(0)!, 'content');
      if (c != null) result.add(_decode(c).trim());
      continue;
    }
    final inner = _inner(block, m.end, tagName);
    result.add(_decode(_stripTags(inner)).trim());
  }
  return result;
}

String? _text(String block, String prop) {
  final all = _all(block, prop);
  return all.isEmpty ? null : all.first;
}

/// Các đoạn `<p>` bên trong phần tử itemprop; không có `<p>` thì cả khối là
/// một đoạn (tách dòng theo `<br>`).
List<String> _paragraphs(String block, String prop) {
  final open = RegExp(
    '<(\\w+)\\b[^>]*itemprop\\s*=\\s*["\']$prop["\'][^>]*>',
    caseSensitive: false,
  ).firstMatch(block);
  if (open == null) return const [];
  final inner = _inner(block, open.end, open.group(1)!.toLowerCase());
  final ps = RegExp(
    r'<p\b[^>]*>(.*?)</p>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(inner);
  final raw = ps.isEmpty
      ? inner.split(RegExp(r'<br\s*/?>', caseSensitive: false))
      : [for (final p in ps) p.group(1)!];
  return [
    for (final r in raw)
      if (_decode(_stripTags(r)).trim().isNotEmpty)
        _decode(_stripTags(r)).trim(),
  ];
}

/// Nội dung từ [start] đến thẻ đóng cùng loại, có tính lồng nhau.
String _inner(String s, int start, String tag) {
  final re = RegExp('<(/?)$tag\\b[^>]*>', caseSensitive: false);
  var depth = 1;
  for (final m in re.allMatches(s, start)) {
    depth += m.group(1)!.isEmpty ? 1 : -1;
    if (depth == 0) return s.substring(start, m.start);
  }
  // Thiếu thẻ đóng: lấy đến hết khối (khối đã bị cắt ở công thức kế tiếp).
  return s.substring(start);
}

String _stripTags(String s) => s.replaceAll(RegExp(r'<[^>]*>'), '');

String _decode(String s) => s
    .replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      return String.fromCharCode(int.parse(m.group(1)!));
    })
    .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
      return String.fromCharCode(int.parse(m.group(1)!, radix: 16));
    })
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');
