import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../backup/backup_format.dart';
import '../cookbook/cookbook_pdf.dart';
import '../data/category_repository.dart';
import '../data/database.dart';
import '../data/image_store.dart';
import '../data/recipe_repository.dart';
import '../data/text_normalize.dart';
import 'imported_recipe.dart';
import 'schema_org_json.dart';

/// Người dùng bấm Hủy khi đang tạo file xuất.
class ExportCancelled implements Exception {
  const ExportCancelled();
}

String _stamp(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}${t.month.toString().padLeft(2, '0')}'
    '${t.day.toString().padLeft(2, '0')}';

/// Tên file an toàn (không dấu, chỉ chữ số, chữ cái, gạch).
String safeFileName(String name, {String fallback = 'cooknote'}) {
  final s = normalizeText(name)
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final cut = s.length > 40 ? s.substring(0, 40) : s;
  return cut.isEmpty ? fallback : cut;
}

/// Chữ chia sẻ một công thức (AC-46).
String recipeShareText(CookbookRecipe r, CookbookLabels l) {
  final b = StringBuffer(r.name)..writeln();
  final facts = <String>[
    if (r.servings != null)
      '${l.servings}: ${r.servings == r.servings!.roundToDouble() ? r.servings!.toInt() : r.servings}'
          '${r.servingsUnit == null ? '' : ' ${r.servingsUnit}'}',
    if (r.prepMinutes != null) '${l.prep}: ${r.prepMinutes} ${l.minutes}',
    if (r.cookMinutes != null) '${l.cook}: ${r.cookMinutes} ${l.minutes}',
    if (r.totalMinutes != null) '${l.total}: ${r.totalMinutes} ${l.minutes}',
  ];
  if (facts.isNotEmpty) b.writeln(facts.join(' · '));
  if (r.ingredients.isNotEmpty) {
    b
      ..writeln()
      ..writeln(l.ingredients.toUpperCase());
    for (final line in r.ingredients) {
      b.writeln(line.isHeading ? '${line.text}:' : '- ${line.text}');
    }
  }
  if (r.steps.isNotEmpty) {
    b
      ..writeln()
      ..writeln(l.steps.toUpperCase());
    var n = 0;
    for (final line in r.steps) {
      b.writeln(line.isHeading ? '${line.text}:' : '${++n}. ${line.text}');
    }
  }
  if ((r.notes ?? '').trim().isNotEmpty) {
    b
      ..writeln()
      ..writeln('${l.notes}: ${r.notes}');
  }
  if ((r.source ?? '').trim().isNotEmpty) {
    b
      ..writeln()
      ..writeln('${l.source}: ${r.source}');
  }
  return b.toString().trimRight();
}

/// Tạo file để xuất, chia sẻ (F-10): JSON schema.org, `.cooknote`, PDF. Mọi
/// file nằm trong [exportDir]; nơi gọi xóa sau khi chia sẻ xong, phần sót lại
/// bị dọn ở lần mở app kế tiếp (AC-48).
class ExportService {
  ExportService({
    required this._db,
    required this._images,
    required this._recipes,
    required this.exportDir,
    required this.appVersion,
    required this._loadFonts,
    this.useIsolate = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final ImageStore _images;
  final RecipeRepository _recipes;
  final Directory exportDir;
  final String appVersion;
  final Future<CookbookFonts> Function() _loadFonts;
  final bool useIsolate;
  final DateTime Function() _clock;

  Future<File> _newFile(String name) async {
    await exportDir.create(recursive: true);
    return File(p.join(exportDir.path, name));
  }

  /// Xóa mọi file tạm xuất còn sót (gọi khi mở app).
  Future<void> cleanTemp() async {
    try {
      if (await exportDir.exists()) await exportDir.delete(recursive: true);
    } on FileSystemException {
      // Lần sau dọn tiếp.
    }
  }

  Future<List<RecipeDetail>> _details(Iterable<int> ids) async {
    final out = <RecipeDetail>[];
    for (final id in ids) {
      final d = await _recipes.getRecipe(id);
      if (d != null && d.deletedAt == null) out.add(d);
    }
    return out;
  }

  /// JSON schema.org cho các công thức [ids], kèm ảnh (AC-45).
  Future<File> exportSchemaOrg(
    List<int> ids, {
    void Function(double)? onProgress,
    bool Function()? cancelled,
  }) async {
    final details = await _details(ids);
    final names = {
      for (final c in await CategoryRepository(_db).getAll()) c.id: c.name,
    };
    final list = <ImportedRecipe>[];
    for (var i = 0; i < details.length; i++) {
      if (cancelled?.call() ?? false) throw const ExportCancelled();
      final d = details[i];
      final photos = <ImportedPhoto>[];
      for (final f in d.draft.photos) {
        final file = _images.file(f);
        if (await file.exists()) {
          photos.add(ImportedPhoto(f, await file.readAsBytes()));
        }
      }
      list.add(
        ImportedRecipe(
          draft: d.draft.copyWith(photos: const [], categoryIds: const []),
          photos: photos,
          categoryNames: [
            for (final id in d.draft.categoryIds)
              if (names[id] != null) names[id]!,
          ],
          dedupeKey: 'cooknote:${d.id}',
          createdAt: d.createdAt,
        ),
      );
      onProgress?.call((i + 1) / details.length);
      await Future<void>.delayed(Duration.zero);
    }
    if (cancelled?.call() ?? false) throw const ExportCancelled();
    final json = exportRecipesAsSchemaOrg(list, includePhotos: true);
    final out = await _newFile('cooknote-recipes-${_stamp(_clock())}.json');
    await out.writeAsString(json, flush: true);
    return out;
  }

  /// File `.cooknote` chỉ chứa các công thức [ids] (AC-46).
  Future<File> createCooknote(
    List<int> ids, {
    String? name,
    void Function(double)? onProgress,
    bool Function()? cancelled,
  }) async {
    final out = await _newFile(
      '${safeFileName(name ?? 'cooknote')}-${_stamp(_clock())}.cooknote',
    );
    await createBackupFile(
      db: _db,
      images: _images,
      out: out,
      appVersion: appVersion,
      now: _clock(),
      onProgress: onProgress,
      cancelled: cancelled,
      recipeIds: ids.toSet(),
    );
    return out;
  }

  /// Công thức dạng đưa vào PDF; ảnh bìa thu nhỏ để PDF không phình to.
  Future<CookbookRecipe> toCookbookRecipe(RecipeDetail d) async {
    final dr = d.draft;
    Uint8List? cover;
    if (dr.photos.isNotEmpty) {
      final file = _images.file(dr.photos.first);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        try {
          cover = useIsolate
              ? await Isolate.run(() => processImage(bytes, maxSide: 900))
              : processImage(bytes, maxSide: 900);
        } on Object {
          cover = null;
        }
      }
    }
    return CookbookRecipe(
      name: dr.name,
      servings: dr.servings,
      servingsUnit: dr.servingsUnit,
      prepMinutes: dr.prepMinutes,
      cookMinutes: dr.cookMinutes,
      totalMinutes: dr.totalMinutes,
      source: dr.source,
      notes: dr.notes,
      ingredients: dr.ingredients,
      steps: dr.steps,
      coverImage: cover,
    );
  }

  Future<CookbookRecipe?> cookbookRecipe(int id) async {
    final d = await _recipes.getRecipe(id);
    return d == null || d.deletedAt != null ? null : toCookbookRecipe(d);
  }

  /// PDF một công thức (AC-46).
  Future<File> recipePdf(int id, CookbookLabels labels) async {
    final r = await cookbookRecipe(id);
    if (r == null) throw StateError('Không có công thức $id');
    final fonts = await _loadFonts();
    final bytes = await (useIsolate
        ? Isolate.run(() => buildRecipePdf(r, fonts, labels: labels))
        : buildRecipePdf(r, fonts, labels: labels));
    final out = await _newFile('${safeFileName(r.name)}.pdf');
    await out.writeAsBytes(bytes, flush: true);
    return out;
  }

  /// Sách công thức PDF (AC-47): bìa, mục lục, mỗi công thức một trang mới.
  /// Việc nặng chạy ở isolate khác nên giao diện không treo.
  Future<File> cookbookPdf(
    List<int> ids,
    String title,
    CookbookLabels labels, {
    void Function(double)? onProgress,
    bool Function()? cancelled,
  }) async {
    final details = await _details(ids);
    details.sort(
      (a, b) =>
          normalizeText(a.draft.name).compareTo(normalizeText(b.draft.name)),
    );
    final recipes = <CookbookRecipe>[];
    for (var i = 0; i < details.length; i++) {
      if (cancelled?.call() ?? false) throw const ExportCancelled();
      recipes.add(await toCookbookRecipe(details[i]));
      onProgress?.call((i + 1) / (details.length + 1));
      await Future<void>.delayed(Duration.zero);
    }
    final fonts = await _loadFonts();
    final cover = recipes
        .map((r) => r.coverImage)
        .firstWhere((c) => c != null, orElse: () => null);
    final input = CookbookInput(
      title: title,
      recipes: recipes,
      fonts: fonts,
      coverImage: cover,
      labels: labels,
    );
    final bytes = await (useIsolate
        ? Isolate.run(() => buildCookbookPdf(input))
        : buildCookbookPdf(input));
    if (cancelled?.call() ?? false) throw const ExportCancelled();
    onProgress?.call(1);
    final out = await _newFile(
      '${safeFileName(title, fallback: 'cookbook')}.pdf',
    );
    await out.writeAsBytes(bytes, flush: true);
    return out;
  }

  /// Chữ chia sẻ cho một công thức.
  Future<String?> recipeText(int id, CookbookLabels labels) async {
    final d = await _recipes.getRecipe(id);
    if (d == null) return null;
    final r = CookbookRecipe(
      name: d.draft.name,
      servings: d.draft.servings,
      servingsUnit: d.draft.servingsUnit,
      prepMinutes: d.draft.prepMinutes,
      cookMinutes: d.draft.cookMinutes,
      totalMinutes: d.draft.totalMinutes,
      source: d.draft.source,
      notes: d.draft.notes,
      ingredients: d.draft.ingredients,
      steps: d.draft.steps,
    );
    return recipeShareText(r, labels);
  }
}
