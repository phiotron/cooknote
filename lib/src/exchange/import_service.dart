import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../data/category_repository.dart';
import '../data/database.dart';
import '../data/image_store.dart';
import '../data/recipe_repository.dart';
import '../data/text_normalize.dart';
import 'imported_recipe.dart';
import 'paprika_import.dart';
import 'recipe_keeper_import.dart';
import 'schema_org_json.dart';

/// Định dạng file nhận ra được (F-10, AC-44, AC-45).
enum ImportKind { paprika, recipeKeeper, schemaOrg, cooknote, unknown }

/// Nhận định dạng theo nội dung (trước) rồi theo đuôi file.
ImportKind detectImportKind(List<int> bytes, String fileName) {
  final ext = p.extension(fileName).toLowerCase();
  final isZip = bytes.length >= 4 && bytes[0] == 0x50 && bytes[1] == 0x4B;
  if (isZip) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      return ext == '.cooknote' ? ImportKind.cooknote : ImportKind.unknown;
    }
    final names = [
      for (final f in archive.files)
        if (f.isFile) f.name.replaceAll('\\', '/').toLowerCase(),
    ];
    if (names.contains('manifest.json') && names.contains('data.json')) {
      return ImportKind.cooknote;
    }
    if (names.any((n) => n.endsWith('.paprikarecipe'))) {
      return ImportKind.paprika;
    }
    if (names.any((n) => n == 'recipes.html' || n.endsWith('/recipes.html'))) {
      return ImportKind.recipeKeeper;
    }
    if (ext == '.cooknote') return ImportKind.cooknote;
    if (ext == '.paprikarecipes') return ImportKind.paprika;
    if (ext == '.zip') return ImportKind.recipeKeeper;
    return ImportKind.unknown;
  }
  if (ext == '.cooknote') return ImportKind.cooknote;
  // JSON: bỏ BOM và khoảng trắng đầu, rồi xem ký tự đầu.
  var i = 0;
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    i = 3;
  }
  while (i < bytes.length && bytes[i] <= 0x20) {
    i++;
  }
  if (i < bytes.length && (bytes[i] == 0x7B || bytes[i] == 0x5B)) {
    return ImportKind.schemaOrg;
  }
  return ImportKind.unknown;
}

/// Đọc [bytes] theo [kind] (chỉ các định dạng ngoài). Ném
/// [ImportFormatException] nếu không đọc được.
ImportResult parseImportBytes(ImportKind kind, Uint8List bytes) =>
    switch (kind) {
      ImportKind.paprika => readPaprikaBytes(bytes),
      ImportKind.recipeKeeper => readRecipeKeeperBytes(bytes),
      ImportKind.schemaOrg => importSchemaOrgJsonWithReport(
        utf8.decode(bytes, allowMalformed: true).replaceFirst('﻿', ''),
      ),
      _ => throw const ImportFormatException('Định dạng không hỗ trợ'),
    };

/// Kết quả hiển thị cho người dùng.
class ImportOutcome {
  const ImportOutcome({
    required this.imported,
    required this.duplicates,
    required this.skipped,
    required this.reasons,
    this.cancelled = false,
  });

  /// Số công thức đã ghi mới.
  final int imported;

  /// Số công thức đã có sẵn trong máy nên không ghi lại.
  final int duplicates;

  /// Số công thức bị bỏ vì lỗi (đọc không được, không hợp lệ).
  final int skipped;
  final List<String> reasons;
  final bool cancelled;
}

/// Ghi kết quả đọc từ file ngoài vào cơ sở dữ liệu và ImageStore. Từng công
/// thức được ghi trong một giao dịch riêng nên hủy giữa chừng hay lỗi một công
/// thức không làm hỏng dữ liệu hiện có.
class ImportService {
  ImportService({
    required this._db,
    required this._images,
    required this._recipes,
    required Directory tempDir,
    this.useIsolate = true,
  }) : _temp = tempDir;

  final AppDatabase _db;
  final ImageStore _images;
  final RecipeRepository _recipes;
  final Directory _temp;

  /// Đọc file lớn ở isolate khác để không treo giao diện; test tắt.
  final bool useIsolate;

  Future<ImportKind> detect(File file) async =>
      detectImportKind(await file.readAsBytes(), p.basename(file.path));

  /// Đọc và ghi cả file. [ImportKind.cooknote] không xử lý ở đây (đi qua màn
  /// Khôi phục). Ném [ImportFormatException] khi file không đọc được; dữ liệu
  /// hiện có không bị đụng.
  Future<ImportOutcome> importFile(
    File file, {
    void Function(double progress)? onProgress,
    bool Function()? cancelled,
  }) async {
    final bytes = await file.readAsBytes();
    final kind = detectImportKind(bytes, p.basename(file.path));
    if (kind == ImportKind.unknown || kind == ImportKind.cooknote) {
      throw const ImportFormatException('Định dạng không nhận ra');
    }
    final ImportResult result;
    try {
      result = useIsolate
          ? await Isolate.run(() => parseImportBytes(kind, bytes))
          : parseImportBytes(kind, bytes);
    } on ImportFormatException {
      rethrow;
    } on Object catch (e) {
      throw ImportFormatException('$e');
    }
    return save(result, onProgress: onProgress, cancelled: cancelled);
  }

  /// Ghi các công thức đã đọc. Trùng (cùng tên không dấu + thời điểm tạo; nếu
  /// file không có thời điểm tạo thì cùng tên không dấu + nguồn) thì bỏ qua.
  Future<ImportOutcome> save(
    ImportResult result, {
    void Function(double progress)? onProgress,
    bool Function()? cancelled,
  }) async {
    final have = await _recipes.importKeys();
    final categoryIds = await _topLevelCategories();
    final reasons = [...result.report.reasons];
    var imported = 0;
    var duplicates = 0;
    var skipped = result.report.skipped;
    var wasCancelled = false;
    final recipes = result.recipes;
    for (var i = 0; i < recipes.length; i++) {
      if (cancelled?.call() ?? false) {
        wasCancelled = true;
        break;
      }
      final r = recipes[i];
      final name = normalizeText(r.draft.name);
      final created = r.createdAt;
      final key = created == null
          ? '$name|src:${normalizeText(r.draft.source ?? '')}'
          : '$name|${created.millisecondsSinceEpoch ~/ 1000}';
      if (!have.add(key)) {
        duplicates++;
      } else {
        try {
          await _saveOne(r, categoryIds, reasons);
          imported++;
        } catch (e) {
          have.remove(key);
          skipped++;
          reasons.add('${r.draft.name}: không lưu được ($e)');
        }
      }
      onProgress?.call((i + 1) / recipes.length);
      // Nhường vòng lặp sự kiện để giao diện còn vẽ và nhận bấm Hủy.
      await Future<void>.delayed(Duration.zero);
    }
    return ImportOutcome(
      imported: imported,
      duplicates: duplicates,
      skipped: skipped,
      reasons: reasons,
      cancelled: wasCancelled,
    );
  }

  Future<Map<String, int>> _topLevelCategories() async => {
    for (final c in await CategoryRepository(_db).getAll())
      if (c.parentId == null) normalizeText(c.name): c.id,
  };

  Future<int> _categoryId(String name, Map<String, int> known) async {
    final clean = name.trim();
    final key = normalizeText(clean);
    final existing = known[key];
    if (existing != null) return existing;
    final id = await _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: clean.length > maxCategoryName
                ? clean.substring(0, maxCategoryName)
                : clean,
          ),
        );
    known[key] = id;
    return id;
  }

  Future<void> _saveOne(
    ImportedRecipe r,
    Map<String, int> categoryIds,
    List<String> reasons,
  ) async {
    final stored = <String>[];
    try {
      for (final photo in r.photos.take(maxRecipePhotos)) {
        try {
          stored.add(await _storePhoto(photo));
        } on Object {
          reasons.add('${r.draft.name}: bỏ qua ảnh ${photo.name} (hỏng)');
        }
      }
      final ids = <int>{};
      for (final name in r.categoryNames) {
        if (normalizeText(name).isEmpty) continue;
        ids.add(await _categoryId(name, categoryIds));
      }
      await _recipes.saveImported(
        r.draft.copyWith(photos: stored, categoryIds: ids.toList()),
        createdAt: r.createdAt,
      );
    } catch (_) {
      for (final f in stored) {
        await _images.delete(f);
      }
      rethrow;
    }
  }

  Future<String> _storePhoto(ImportedPhoto photo) async {
    await _temp.create(recursive: true);
    final tmp = File(
      p.join(_temp.path, 'imp_${DateTime.now().microsecondsSinceEpoch}.img'),
    );
    await tmp.writeAsBytes(photo.bytes, flush: true);
    try {
      return await _images.importImage(tmp.path);
    } finally {
      try {
        await tmp.delete();
      } on FileSystemException {
        // Lần mở app sau dọn thư mục tạm.
      }
    }
  }
}
