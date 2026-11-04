import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../data/recipe_lines.dart';
import '../data/recipe_repository.dart';

/// Công thức đọc được từ một trang web (F-03): bản nháp để người dùng xem lại
/// rồi lưu, cùng địa chỉ các ảnh ứng viên (chưa tải về).
class WebRecipe {
  const WebRecipe({required this.draft, this.imageUrls = const []});

  final RecipeDraft draft;
  final List<String> imageUrls;
}

/// Trích công thức từ HTML của một trang web (F-03, AC-18). Ưu tiên schema.org
/// Recipe trong JSON-LD, sau đó microdata. Trả null nếu trang không có dữ liệu
/// Recipe (hoặc có nhưng không có tên). Khối JSON-LD hỏng bị bỏ qua, không làm
/// hỏng cả trang. [pageUrl] dùng làm `sourceUrl` và để tuyệt đối hóa địa chỉ ảnh.
/// Hàm thuần: không gọi mạng, không ném lỗi với HTML bất kỳ.
WebRecipe? extractRecipeFromHtml(String html, {Uri? pageUrl}) {
  final Document doc;
  try {
    doc = html_parser.parse(html);
  } catch (_) {
    return null;
  }
  final ctx = _Context(doc, pageUrl);
  final recipe = ctx.findJsonLdRecipe() ?? ctx.findMicrodataRecipe();
  if (recipe == null) return null;
  return ctx.build(recipe);
}

// Nhãn dinh dưỡng theo thứ tự hiển thị.
const _nutritionLabels = <String, String>{
  'calories': 'Năng lượng',
  'servingSize': 'Khẩu phần',
  'fatContent': 'Chất béo',
  'saturatedFatContent': 'Chất béo bão hòa',
  'carbohydrateContent': 'Tinh bột',
  'sugarContent': 'Đường',
  'fiberContent': 'Chất xơ',
  'proteinContent': 'Đạm',
  'cholesterolContent': 'Cholesterol',
  'sodiumContent': 'Natri',
};

final _ws = RegExp(r'\s+');

final _duration = RegExp(
  r'^P(?:(\d+(?:[.,]\d+)?)W)?(?:(\d+(?:[.,]\d+)?)D)?'
  r'(?:T(?:(\d+(?:[.,]\d+)?)H)?(?:(\d+(?:[.,]\d+)?)M)?(?:(\d+(?:[.,]\d+)?)S)?)?$',
  caseSensitive: false,
);

/// Đổi HTML nhỏ trong chuỗi thành chữ: ngắt dòng ở `<br>`, `</p>`, `</li>`...,
/// bỏ thẻ, giải mã thực thể. Giữ ký tự xuống dòng.
String _htmlToText(String s) {
  if (!s.contains('<') && !s.contains('&')) return s;
  final broken = s
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(
        RegExp(r'</(?:p|li|div|tr|h[1-6])\s*>', caseSensitive: false),
        '\n',
      );
  return html_parser.parseFragment(broken).text ?? '';
}

/// Chữ một dòng: bỏ thẻ, giải mã thực thể, gộp mọi khoảng trắng (kể cả nbsp).
String _clean(String s) => _htmlToText(s).replaceAll(_ws, ' ').trim();

/// Các dòng không rỗng, mỗi dòng đã gộp khoảng trắng.
List<String> _cleanLines(String s) => [
  for (final l in _htmlToText(s).split(RegExp(r'\r?\n|\r')))
    if (_clean(l).isNotEmpty) _clean(l),
];

String _truncate(String s, int max) {
  if (s.length <= max) return s;
  var cut = s.substring(0, max);
  final last = cut.codeUnitAt(cut.length - 1);
  if (last >= 0xD800 && last <= 0xDBFF) cut = cut.substring(0, cut.length - 1);
  return cut;
}

List<dynamic> _asList(dynamic v) =>
    v == null ? const [] : (v is List ? v : [v]);

/// Số phút từ khoảng thời gian ISO 8601; null nếu sai định dạng hoặc bằng 0.
int? _minutes(dynamic v) {
  if (v is! String) return null;
  final m = _duration.firstMatch(v.trim());
  if (m == null) return null;
  double g(int i) => double.parse((m.group(i) ?? '0').replaceAll(',', '.'));
  final total = g(1) * 7 * 1440 + g(2) * 1440 + g(3) * 60 + g(4) + g(5) / 60;
  final rounded = total.round();
  return rounded > 0 ? rounded : null;
}

final _number = RegExp(r'\d+(?:[.,]\d+)?');
final _rangeTail = RegExp(r'^\s*(?:[-–—]|to|đến)\s*\d+(?:[.,]\d+)?');
final _edgePunct = RegExp(r'^[\s().,:;/\-–—]+|[\s().,:;/\-–—]+$');

({double servings, String? unit})? _parseYield(String raw) {
  final s = _clean(raw);
  final m = _number.firstMatch(s);
  if (m == null) return null;
  final n = double.tryParse(m.group(0)!.replaceAll(',', '.'));
  if (n == null || n <= 0) return null;
  var after = s.substring(m.end).replaceFirst(_rangeTail, '');
  after = after.replaceAll(_edgePunct, '');
  return (servings: n, unit: after.isEmpty ? null : after);
}

class _Context {
  _Context(this.doc, this.pageUrl);

  final Document doc;
  final Uri? pageUrl;

  /// Các nút JSON-LD có `@id`, để theo tham chiếu `{"@id": ...}` trong @graph.
  final Map<String, Map> _byId = {};

  // ---- tìm công thức ----

  Map? findJsonLdRecipe() {
    final roots = <dynamic>[];
    for (final s in doc.querySelectorAll('script')) {
      final type = (s.attributes['type'] ?? '').toLowerCase();
      if (!type.contains('ld+json')) continue;
      final text = s.text.trim();
      if (text.isEmpty) continue;
      try {
        roots.add(jsonDecode(text));
      } catch (_) {
        continue; // khối hỏng: bỏ qua riêng khối này
      }
    }
    for (final r in roots) {
      _indexIds(r);
    }
    final found = <Map>[];
    for (final r in roots) {
      _collectRecipes(r, found);
    }
    return found.isEmpty ? null : found.first;
  }

  void _indexIds(dynamic n) {
    if (n is List) {
      n.forEach(_indexIds);
    } else if (n is Map) {
      final id = n['@id'];
      if (id is String && n.length > 1) _byId.putIfAbsent(id, () => n);
      n.values.forEach(_indexIds);
    }
  }

  bool _isRecipe(Map m) => _asList(
    m['@type'],
  ).any((t) => t is String && RegExp(r'(?:^|[/:#])Recipe$').hasMatch(t.trim()));

  void _collectRecipes(dynamic n, List<Map> out) {
    if (n is List) {
      for (final e in n) {
        _collectRecipes(e, out);
      }
    } else if (n is Map) {
      if (_isRecipe(n)) {
        out.add(n);
      } else {
        for (final v in n.values) {
          if (v is Map || v is List) _collectRecipes(v, out);
        }
      }
    }
  }

  Map? findMicrodataRecipe() {
    for (final e in doc.querySelectorAll('[itemscope][itemtype]')) {
      final isRecipe = (e.attributes['itemtype'] ?? '')
          .split(_ws)
          .any(
            (t) => RegExp(
              r'schema\.org/Recipe$',
              caseSensitive: false,
            ).hasMatch(t),
          );
      if (isRecipe) return _microItem(e);
    }
    return null;
  }

  /// Đổi một phần tử microdata thành bản đồ giống JSON-LD để dùng chung mã đọc.
  Map _microItem(Element scope) {
    final props = <String, List<dynamic>>{};
    void walk(Element parent) {
      for (final child in parent.children) {
        final names = (child.attributes['itemprop'] ?? '')
            .split(_ws)
            .where((n) => n.isNotEmpty);
        final isScope = child.attributes.containsKey('itemscope');
        for (final n in names) {
          props
              .putIfAbsent(n, () => [])
              .add(isScope ? _microItem(child) : _microValue(child));
        }
        if (!isScope) walk(child);
      }
    }

    walk(scope);
    final type = (scope.attributes['itemtype'] ?? '').split(_ws).first;
    return {
      '@type': type.split('/').last,
      for (final e in props.entries)
        e.key: e.value.length == 1 ? e.value.first : e.value,
    };
  }

  String _microValue(Element e) {
    final a = e.attributes;
    switch (e.localName) {
      case 'meta':
        return a['content'] ?? '';
      case 'a' || 'link' || 'area':
        return a['href'] ?? '';
      case 'img' || 'source' || 'audio' || 'video' || 'embed' || 'iframe':
        return a['src'] ?? '';
      case 'time':
        return a['datetime'] ?? e.innerHtml;
      case 'data' || 'meter':
        return a['value'] ?? e.innerHtml;
      default:
        return e.innerHtml;
    }
  }

  // ---- đọc từng trường ----

  dynamic _deref(dynamic v) {
    if (v is Map && v.length == 1 && v['@id'] is String) {
      return _byId[v['@id']] ?? v;
    }
    return v;
  }

  String? _meta(String property) {
    for (final m in doc.querySelectorAll('meta')) {
      final key = m.attributes['property'] ?? m.attributes['name'];
      if (key == property) {
        final c = _clean(m.attributes['content'] ?? '');
        if (c.isNotEmpty) return c;
      }
    }
    return null;
  }

  String? _text(dynamic v) {
    v = _deref(v);
    if (v is String) {
      final c = _clean(v);
      return c.isEmpty ? null : c;
    }
    if (v is num) return v.toString();
    if (v is Map) return _text(v['name'] ?? v['text']);
    if (v is List) {
      for (final e in v) {
        final t = _text(e);
        if (t != null) return t;
      }
    }
    return null;
  }

  List<String> _strings(dynamic v) {
    v = _deref(v);
    if (v is String) return _cleanLines(v);
    if (v is num) return [v.toString()];
    if (v is Map) return _strings(v['text'] ?? v['name']);
    if (v is List) return [for (final e in v) ..._strings(e)];
    return const [];
  }

  List<RecipeLine> _ingredients(dynamic v) =>
      parseLines(_strings(v).join('\n'), LineSection.ingredient);

  void _steps(dynamic v, List<RecipeLine> out) {
    v = _deref(v);
    if (v is String) {
      out.addAll(parseLines(_cleanLines(v).join('\n'), LineSection.step));
    } else if (v is List) {
      for (final e in v) {
        _steps(e, out);
      }
    } else if (v is Map) {
      final children = v['itemListElement'] ?? v['steps'];
      if (children != null) {
        final title = _text(v['name']);
        if (title != null) out.add(RecipeLine(title, isHeading: true));
        _steps(children, out);
      } else if (v['item'] != null) {
        _steps(v['item'], out);
      } else {
        final text = _strings(v['text']);
        _steps(
          text.isNotEmpty ? text.join('\n') : (_text(v['name']) ?? ''),
          out,
        );
      }
    }
  }

  ({double servings, String? unit})? _servings(dynamic v) {
    final cands = <({double servings, String? unit})>[];
    for (final s in _strings(v)) {
      final p = _parseYield(s);
      if (p != null) cands.add(p);
    }
    if (cands.isEmpty) return null;
    return cands.firstWhere((c) => c.unit != null, orElse: () => cands.first);
  }

  String? _nutrition(dynamic v) {
    v = _deref(v);
    if (v is String) return _text(v);
    if (v is! Map) return null;
    final parts = <String>[];
    for (final e in _nutritionLabels.entries) {
      final t = _text(v[e.key]);
      if (t != null) parts.add('${e.value}: $t');
    }
    return parts.isEmpty ? null : parts.join(', ');
  }

  void _images(dynamic v, List<String> out) {
    v = _deref(v);
    if (v is String) {
      out.add(v);
    } else if (v is List) {
      for (final e in v) {
        _images(e, out);
      }
    } else if (v is Map) {
      _images(v['url'] ?? v['contentUrl'], out);
    }
  }

  String? _absolute(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final u = Uri.tryParse(s);
    if (u == null) return null;
    final Uri r;
    if (u.hasScheme) {
      r = u;
    } else if (pageUrl != null && pageUrl!.hasScheme) {
      r = pageUrl!.resolveUri(u);
    } else {
      return null;
    }
    if (r.scheme != 'http' && r.scheme != 'https') return null;
    if (r.host.isEmpty) return null;
    return r.toString();
  }

  WebRecipe? build(Map r) {
    var name = _text(r['name']) ?? _text(r['headline']);
    name ??= _meta('og:title');
    if (name == null) {
      final t = doc.querySelector('title');
      final c = t == null ? '' : _clean(t.text);
      if (c.isNotEmpty) name = c;
    }
    if (name == null) return null;

    final y = _servings(r['recipeYield']);
    final raw = <String>[];
    _images(r['image'], raw);
    for (final m in doc.querySelectorAll('meta')) {
      if (m.attributes['property'] == 'og:image') {
        raw.add(m.attributes['content'] ?? '');
      }
    }
    final images = <String>[];
    for (final s in raw) {
      final a = _absolute(s);
      if (a != null && !images.contains(a)) images.add(a);
    }

    final steps = <RecipeLine>[];
    _steps(r['recipeInstructions'], steps);

    final draft = RecipeDraft(
      name: _truncate(name, maxRecipeName),
      servings: y?.servings,
      servingsUnit: y?.unit,
      prepMinutes: _minutes(r['prepTime']),
      cookMinutes: _minutes(r['cookTime']),
      totalMinutes: _minutes(r['totalTime']),
      source:
          _text(r['publisher']) ?? _meta('og:site_name') ?? _text(r['author']),
      sourceUrl: pageUrl?.toString(),
      notes: _text(r['description']),
      nutrition: _nutrition(r['nutrition']),
      ingredients: _ingredients(r['recipeIngredient'] ?? r['ingredients']),
      steps: steps,
    );
    return WebRecipe(
      draft: draft,
      imageUrls: images.take(maxRecipePhotos).toList(),
    );
  }
}
