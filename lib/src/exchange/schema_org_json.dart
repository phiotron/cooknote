// Xuất và nhập công thức dạng JSON schema.org `Recipe` (SPEC F-10, AC-45).
//
// Đối chiếu với https://schema.org/Recipe (kiến thức sẵn có, CHƯA tra lại ngày
// làm; các thuộc tính dùng đều là thuộc tính chuẩn của Recipe/HowTo/Rating).
// Cách ánh xạ (ghi rõ vì schema.org không có chỗ cho vài thứ):
//  - ghi chú -> `description`; nguồn -> `publisher.name`; liên kết nguồn -> `url`
//  - đánh giá 1-5 -> `aggregateRating {ratingValue, bestRating: 5}`
//  - nhóm bước -> `HowToSection`; tiêu đề nhóm nguyên liệu -> một chuỗi kết
//    thúc bằng ":" trong `recipeIngredient` (schema.org không có nhóm nguyên liệu)
//  - thẻ -> `keywords` (cách nhau dấu phẩy); danh mục -> `recipeCategory`
//  - ảnh -> `image` dạng data URI (chỉ khi `includePhotos`); khi nhập chỉ đọc
//    data URI, bỏ qua http(s) vì app không tải ảnh về ở bước này
// Khi nhập chấp nhận cả dạng của trang web: chuỗi/mảng/đối tượng cho tác giả,
// `recipeYield` là số, chuỗi hoặc mảng, `recipeInstructions` là chuỗi nhiều
// dòng, mảng chuỗi, HowToStep hoặc HowToSection lồng nhau.
import 'dart:convert';
import 'dart:typed_data';

import '../data/recipe_lines.dart';
import '../data/recipe_repository.dart';
import 'imported_recipe.dart';

const _context = 'https://schema.org';

/// Xuất một hoặc nhiều công thức. Một công thức thì ra một đối tượng, nhiều
/// thì ra mảng, không có thì "[]".
String exportRecipesAsSchemaOrg(
  List<ImportedRecipe> recipes, {
  bool includePhotos = false,
}) {
  final maps = [for (final r in recipes) _toMap(r, includePhotos)];
  final Object body = maps.length == 1 ? maps.first : maps;
  return const JsonEncoder.withIndent('  ').convert(body);
}

Map<String, Object?> _toMap(ImportedRecipe r, bool includePhotos) {
  final d = r.draft;
  final m = <String, Object?>{
    '@context': _context,
    '@type': 'Recipe',
    'name': d.name,
  };
  void put(String k, Object? v) {
    if (v == null) return;
    if (v is String && v.isEmpty) return;
    if (v is List && v.isEmpty) return;
    m[k] = v;
  }

  put('identifier', r.sourceUid);
  put('dateCreated', r.createdAt?.toUtc().toIso8601String());
  if (d.servings != null) {
    final s = d.servings!;
    final n = s == s.roundToDouble() ? s.round().toString() : s.toString();
    final unit = d.servingsUnit?.trim() ?? '';
    m['recipeYield'] = unit.isEmpty ? n : '$n $unit';
  }
  put('prepTime', formatIsoDuration(d.prepMinutes));
  put('cookTime', formatIsoDuration(d.cookMinutes));
  put('totalTime', formatIsoDuration(d.totalMinutes));
  put('description', d.notes);
  if (d.source != null && d.source!.trim().isNotEmpty) {
    m['publisher'] = {'@type': 'Organization', 'name': d.source};
  }
  put('url', d.sourceUrl);
  if (d.rating > 0) {
    m['aggregateRating'] = {
      '@type': 'AggregateRating',
      'ratingValue': d.rating,
      'bestRating': 5,
      'ratingCount': 1,
    };
  }
  put('recipeCategory', r.categoryNames);
  put('keywords', d.tags.isEmpty ? null : d.tags.join(', '));
  put('recipeIngredient', [
    for (final l in d.ingredients) l.isHeading ? '${l.text}:' : l.text,
  ]);
  put('recipeInstructions', _instructions(d.steps));
  if (d.nutrition != null && d.nutrition!.trim().isNotEmpty) {
    m['nutrition'] = {
      '@type': 'NutritionInformation',
      'description': d.nutrition,
    };
  }
  if (includePhotos && r.photos.isNotEmpty) {
    m['image'] = [
      for (final p in r.photos)
        'data:${_mime(p.bytes)};base64,${base64Encode(p.bytes)}',
    ];
  }
  return m;
}

List<Object?> _instructions(List<RecipeLine> steps) {
  final result = <Object?>[];
  List<Object?>? section;
  for (final l in steps) {
    if (l.isHeading) {
      section = <Object?>[];
      result.add({
        '@type': 'HowToSection',
        'name': l.text,
        'itemListElement': section,
      });
    } else {
      final step = {'@type': 'HowToStep', 'text': l.text};
      (section ?? result).add(step);
    }
  }
  return result;
}

String _mime(List<int> b) =>
    b.length >= 2 && b[0] == 0xFF ? 'image/jpeg' : 'image/png';

// --- Nhập ------------------------------------------------------------------

List<ImportedRecipe> importSchemaOrgJson(String json) =>
    importSchemaOrgJsonWithReport(json).recipes;

/// Như [importSchemaOrgJson] nhưng kèm báo cáo. JSON hỏng thì ném
/// [ImportFormatException]. Mục không phải Recipe bị bỏ qua im lặng (trang web
/// hay kèm WebSite, Person...), công thức thiếu tên được tính là "bỏ".
ImportResult importSchemaOrgJsonWithReport(String json) {
  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException {
    throw const ImportFormatException('Không phải JSON hợp lệ');
  }
  final nodes = <Map<String, dynamic>>[];
  _collect(decoded, nodes);
  final out = ImportCollector();
  if (nodes.isEmpty) out.warn('Không thấy đối tượng Recipe nào trong JSON');
  for (var i = 0; i < nodes.length; i++) {
    try {
      final r = _convert(nodes[i], i + 1, out);
      if (r != null) out.recipes.add(r);
    } catch (e) {
      out.skip('Công thức #${i + 1}: không đọc được ($e)');
    }
  }
  return out.build();
}

bool _isRecipe(Map<String, dynamic> m) {
  final t = m['@type'];
  return t == 'Recipe' || (t is List && t.contains('Recipe'));
}

void _collect(Object? v, List<Map<String, dynamic>> out) {
  if (v is List) {
    for (final e in v) {
      _collect(e, out);
    }
  } else if (v is Map<String, dynamic>) {
    if (_isRecipe(v)) {
      out.add(v);
    } else if (v['@graph'] != null) {
      _collect(v['@graph'], out);
    }
  }
}

ImportedRecipe? _convert(
  Map<String, dynamic> j,
  int index,
  ImportCollector out,
) {
  final name = blankToNull(_str(j['name']));
  if (name == null) {
    out.skip('Công thức #$index: không có tên');
    return null;
  }
  final (servings, unit) = _yield(j['recipeYield']);
  final source =
      blankToNull(_nameOf(j['publisher'])) ?? blankToNull(_nameOf(j['author']));
  final uid = blankToNull(_str(j['identifier']));

  final ingredients = <RecipeLine>[];
  final ing = j['recipeIngredient'] ?? j['ingredients'];
  for (final s in ing is List ? ing : [ing]) {
    final t = _str(s);
    if (t != null) ingredients.addAll(parseLines(t, LineSection.ingredient));
  }

  final tags = _splitList(j['keywords']);
  final cats = _splitList(j['recipeCategory']);

  return ImportedRecipe(
    draft: RecipeDraft(
      name: name,
      servings: servings,
      servingsUnit: unit,
      prepMinutes: parseMinutes(_str(j['prepTime'])),
      cookMinutes: parseMinutes(_str(j['cookTime'])),
      totalMinutes: parseMinutes(_str(j['totalTime'])),
      source: source,
      sourceUrl: blankToNull(_str(j['url'])),
      notes: blankToNull(_str(j['description'])),
      nutrition: _nutrition(j['nutrition']),
      rating: _rating(j['aggregateRating']),
      ingredients: ingredients,
      steps: _steps(j['recipeInstructions']),
      tags: tags,
    ),
    photos: _photos(j['image'], name, out),
    categoryNames: cats,
    sourceUid: uid,
    createdAt: DateTime.tryParse(
      _str(j['dateCreated']) ?? _str(j['datePublished']) ?? '',
    ),
    dedupeKey: buildDedupeKey('schema', name: name, source: source, uid: uid),
  );
}

/// Chuỗi từ chuỗi/số; null cho kiểu khác.
String? _str(Object? v) => v is String ? v : (v is num ? v.toString() : null);

String? _nameOf(Object? v) {
  if (v is List) return v.isEmpty ? null : _nameOf(v.first);
  if (v is Map) return _str(v['name']);
  return _str(v);
}

(double?, String?) _yield(Object? v) {
  if (v is List) {
    (double?, String?)? first;
    for (final e in v) {
      final p = parseServings(_str(e));
      if (p.$1 == null) continue;
      if (p.$2 != null) return p;
      first ??= p;
    }
    return first ?? (null, null);
  }
  return parseServings(_str(v));
}

List<String> _splitList(Object? v) {
  final parts = <String>[];
  if (v is List) {
    for (final e in v) {
      final s = _str(e);
      if (s != null) parts.add(s);
    }
  } else {
    parts.addAll((_str(v) ?? '').split(','));
  }
  return [
    for (final p in parts)
      if (p.trim().isNotEmpty) p.trim(),
  ];
}

String? _nutrition(Object? v) {
  if (v is String) return blankToNull(v);
  if (v is! Map) return null;
  final d = blankToNull(_str(v['description']));
  if (d != null) return d;
  final parts = [
    for (final e in v.entries)
      if (!e.key.toString().startsWith('@') && _str(e.value) != null)
        '${e.key}: ${e.value}',
  ];
  return parts.isEmpty ? null : parts.join(', ');
}

int _rating(Object? v) {
  if (v is! Map) return 0;
  final value = double.tryParse(_str(v['ratingValue']) ?? '');
  if (value == null) return 0;
  final best = double.tryParse(_str(v['bestRating']) ?? '') ?? 5;
  if (best <= 0) return 0;
  return (value / best * 5).round().clamp(0, 5);
}

List<RecipeLine> _steps(Object? v) {
  final result = <RecipeLine>[];
  void walk(Object? node) {
    if (node is String) {
      result.addAll(parseLines(node, LineSection.step));
    } else if (node is List) {
      node.forEach(walk);
    } else if (node is Map) {
      final type = node['@type'];
      final isSection =
          type == 'HowToSection' ||
          (type is List && type.contains('HowToSection')) ||
          node['itemListElement'] != null;
      if (isSection) {
        final title = blankToNull(_str(node['name']));
        if (title != null) result.add(RecipeLine(title, isHeading: true));
        walk(node['itemListElement']);
      } else {
        final text =
            blankToNull(_str(node['text'])) ?? blankToNull(_str(node['name']));
        if (text != null) result.add(RecipeLine(text));
      }
    }
  }

  walk(v);
  return result;
}

final _dataUri = RegExp(r'^data:image/[a-z+.-]+;base64,(.*)$', dotAll: true);

List<ImportedPhoto> _photos(Object? v, String name, ImportCollector out) {
  final photos = <ImportedPhoto>[];
  void walk(Object? node) {
    if (node is List) {
      node.forEach(walk);
    } else if (node is Map) {
      walk(node['url'] ?? node['contentUrl']);
    } else if (node is String) {
      final m = _dataUri.firstMatch(node);
      if (m == null) return; // http(s): không tải ở bước này
      try {
        final bytes = base64Decode(m.group(1)!);
        if (!looksLikeImage(bytes)) {
          out.warn('$name: ảnh không phải JPEG/PNG, đã bỏ');
          return;
        }
        final png = bytes[0] == 0x89;
        photos.add(
          ImportedPhoto(
            'photo_${photos.length + 1}.${png ? 'png' : 'jpg'}',
            Uint8List.fromList(bytes),
          ),
        );
      } on FormatException {
        out.warn('$name: ảnh hỏng (base64), đã bỏ');
      }
    }
  }

  walk(v);
  return photos;
}
