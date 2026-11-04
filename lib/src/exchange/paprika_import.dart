// Đọc file `.paprikarecipes` của Paprika Recipe Manager (SPEC F-10, AC-44).
//
// NGUỒN ĐÃ TRA (2026-11-04), đều là tài liệu của bên thứ ba, KHÔNG phải đặc tả
// chính thức của Paprika:
//  - https://vanilla-cookbook.readthedocs.io/en/latest/manual/import/
//    (nhận `.paprikarecipes` hoặc zip chứa các `*.paprikarecipe`; ảnh nhập nếu có)
//  - https://docs.rs/libpaprika/0.4.0/src/libpaprika/recipe.rs.html
//    (danh sách khóa JSON: name, ingredients, directions, notes, description,
//    servings, prep_time, cook_time, total_time, source, source_url, rating,
//    categories, difficulty, nutritional_info, uid, created, photo, photo_large,
//    photo_data (base64), photo_hash, image_url, photos[{data, filename, name,
//    hash}])
//
// Cấu trúc dùng ở đây: file là zip; mỗi công thức là một tệp `*.paprikarecipe`
// chứa JSON nén gzip (không nén gzip thì thử đọc JSON thẳng).
//
// CHƯA kiểm chứng với file Paprika thật (chỉ có mẫu tổng hợp trong test):
//  - định dạng chuỗi `created` (đang đọc "YYYY-MM-DD HH:MM:SS" hoặc ISO);
//  - các giá trị `difficulty` thật (đang nhận Easy/Medium/Hard và Dễ/Vừa/Khó);
//  - việc ảnh người dùng thêm nằm ở `photos[].data` còn ảnh nguồn ở `photo_data`
//    (theo ghi chú của một nhà phát triển, chưa tự xác nhận);
//  - Paprika bản mới có thể thêm khóa; khóa lạ bị bỏ qua.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../data/database.dart';
import '../data/recipe_lines.dart';
import '../data/recipe_repository.dart';
import 'imported_recipe.dart';

ImportResult readPaprikaFile(File file) =>
    readPaprikaBytes(file.readAsBytesSync());

/// Đọc cả file; một công thức hỏng chỉ bị bỏ và ghi lý do. Không phải zip thì
/// ném [ImportFormatException].
ImportResult readPaprikaBytes(List<int> bytes) {
  final Archive archive;
  try {
    // ZipDecoder của archive không báo lỗi với dữ liệu rác: kiểm chữ ký "PK".
    if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) {
      throw const FormatException('PK');
    }
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    throw const ImportFormatException('Không phải file zip (.paprikarecipes)');
  }
  final out = ImportCollector();
  final entries = archive.files.where(
    (f) => f.isFile && f.name.toLowerCase().endsWith('.paprikarecipe'),
  );
  if (entries.isEmpty) {
    out.warn('Không có công thức .paprikarecipe nào trong file');
    return out.build();
  }
  for (final entry in entries) {
    try {
      final recipe = _convert(entry.name, _decodeJson(entry.content), out);
      if (recipe != null) out.recipes.add(recipe);
    } catch (e) {
      out.skip('${entry.name}: không đọc được ($e)');
    }
  }
  return out.build();
}

Map<String, dynamic> _decodeJson(List<int> raw) {
  final bytes = Uint8List.fromList(raw);
  final isGzip = bytes.length > 2 && bytes[0] == 0x1F && bytes[1] == 0x8B;
  final text = utf8.decode(
    isGzip ? GZipDecoder().decodeBytes(bytes) : bytes,
    allowMalformed: false,
  );
  final json = jsonDecode(text);
  if (json is! Map<String, dynamic>) throw const FormatException('JSON');
  return json;
}

ImportedRecipe? _convert(
  String entryName,
  Map<String, dynamic> j,
  ImportCollector out,
) {
  final name = blankToNull(j['name']);
  if (name == null) {
    out.skip('$entryName: công thức không có tên');
    return null;
  }
  final (servings, unit) = parseServings(blankToNull(j['servings']));
  final source = blankToNull(j['source']);
  final uid = blankToNull(j['uid']);
  final notes = [
    blankToNull(j['description']),
    blankToNull(j['notes']),
  ].whereType<String>().join('\n\n');

  final photos = <ImportedPhoto>[];
  void addPhoto(String label, Object? b64, String fileName) {
    final text = blankToNull(b64);
    if (text == null) return;
    try {
      final data = base64Decode(text.replaceAll(RegExp(r'\s'), ''));
      if (!looksLikeImage(data)) {
        out.warn('$name: ảnh "$label" không phải JPEG/PNG, đã bỏ');
        return;
      }
      if (photos.any((p) => _sameBytes(p.bytes, data))) return;
      photos.add(ImportedPhoto(fileName, Uint8List.fromList(data)));
    } on FormatException {
      out.warn('$name: ảnh "$label" hỏng (base64), đã bỏ');
    }
  }

  addPhoto(
    'photo_data',
    j['photo_data'],
    blankToNull(j['photo']) ?? 'photo.jpg',
  );
  final extra = j['photos'];
  if (extra is List) {
    for (var i = 0; i < extra.length; i++) {
      final p = extra[i];
      if (p is! Map) continue;
      final label = blankToNull(p['filename']) ?? blankToNull(p['name']);
      addPhoto(label ?? 'photos[$i]', p['data'], label ?? 'photo_$i.jpg');
    }
  }

  final categories = j['categories'];
  final draft = RecipeDraft(
    name: name,
    servings: servings,
    servingsUnit: unit,
    prepMinutes: parseMinutes(blankToNull(j['prep_time'])),
    cookMinutes: parseMinutes(blankToNull(j['cook_time'])),
    totalMinutes: parseMinutes(blankToNull(j['total_time'])),
    source: source,
    sourceUrl: blankToNull(j['source_url']),
    notes: notes.isEmpty ? null : notes,
    nutrition: blankToNull(j['nutritional_info']),
    difficulty: _difficulty(blankToNull(j['difficulty'])),
    rating: _rating(j['rating']),
    ingredients: parseLines(
      (j['ingredients'] ?? '').toString(),
      LineSection.ingredient,
    ),
    steps: parseLines((j['directions'] ?? '').toString(), LineSection.step),
  );
  return ImportedRecipe(
    draft: draft,
    photos: photos,
    categoryNames: [
      if (categories is List)
        for (final c in categories)
          if (blankToNull(c) != null) blankToNull(c)!,
    ],
    sourceUid: uid,
    createdAt: _date(blankToNull(j['created'])),
    dedupeKey: buildDedupeKey('paprika', name: name, source: source, uid: uid),
  );
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _rating(Object? v) {
  final n = v is num ? v.round() : int.tryParse(v?.toString() ?? '') ?? 0;
  return n.clamp(0, 5);
}

Difficulty? _difficulty(String? v) {
  switch (v?.toLowerCase()) {
    case 'easy' || 'dễ':
      return Difficulty.easy;
    case 'medium' || 'vừa' || 'trung bình':
      return Difficulty.medium;
    case 'hard' || 'khó':
      return Difficulty.hard;
  }
  return null;
}

DateTime? _date(String? v) {
  if (v == null) return null;
  return DateTime.tryParse(v.replaceFirst(' ', 'T'));
}
