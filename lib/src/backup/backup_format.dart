import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../data/database.dart';
import '../data/image_store.dart';
import '../data/text_normalize.dart';
import 'backup_data.dart';
import 'backup_errors.dart';

export 'backup_errors.dart';

/// Phiên bản định dạng cao nhất app này đọc được. Định dạng chỉ được mở rộng
/// (thêm khóa), không đổi nghĩa; mọi phiên bản cũ phải đọc được mãi (AC-55).
const supportedFormatVersion = 1;

final _imageEntry = RegExp(r'^images/[A-Za-z0-9_.-]+$');

String _sha256(List<int> bytes) => sha256.convert(bytes).toString();

/// Nhường cho vòng lặp giao diện để thanh tiến độ vẽ lại và nút Hủy bấm được.
Future<void> _yield() => Future<void>.delayed(Duration.zero);

const _readme = '''CookNote - file sao luu / backup file
======================================

Day la file zip. Doi duoi .cooknote thanh .zip roi giai nen la doc duoc.
This is a zip file. Rename .cooknote to .zip and extract it.

html/index.html   Mo bang trinh duyet bat ky: doc va in cong thuc, khong can CookNote.
                  Open in any browser: read and print recipes, no CookNote needed.
data.json         Toan bo du lieu dang JSON (cong thuc, danh muc, the, lich su nau).
                  All data as JSON.
images/           Anh cua cong thuc / recipe photos.
manifest.json     Phien ban dinh dang va ma bam SHA-256 cua tung file.
                  Format version and SHA-256 of every file.

Tai lieu dinh dang / format documentation: docs/BACKUP-FORMAT.md trong ma nguon CookNote.
File sao luu KHONG duoc ma hoa: ai co file deu doc duoc.
The backup is NOT encrypted: anyone with the file can read it.
''';

String _esc(String? s) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(s ?? '');

const _css =
    'body{font-family:system-ui,sans-serif;max-width:46rem;margin:1rem auto;padding:0 1rem;line-height:1.5}'
    'img{max-width:100%;height:auto;border-radius:8px}h2{margin-top:1.5rem}';

String _page(String title, String body) =>
    '<!doctype html>\n<html lang="vi"><head><meta charset="utf-8">'
    '<meta name="viewport" content="width=device-width,initial-scale=1">'
    '<title>${_esc(title)}</title><style>$_css</style></head><body>$body</body></html>\n';

String _lines(Object? v, {required bool numbered}) {
  final list = (v as List? ?? const []).cast<Map<String, Object?>>();
  if (list.isEmpty) return '';
  final b = StringBuffer();
  var open = false;
  void close() {
    if (open) b.write(numbered ? '</ol>' : '</ul>');
    open = false;
  }

  for (final l in list) {
    if (l['heading'] == true) {
      close();
      b.write('<h3>${_esc(l['text'] as String?)}</h3>');
    } else {
      if (!open) b.write(numbered ? '<ol>' : '<ul>');
      open = true;
      b.write('<li>${_esc(l['text'] as String?)}</li>');
    }
  }
  close();
  return b.toString();
}

String _recipeHtml(Map<String, Object?> r) {
  final b = StringBuffer('<p><a href="index.html">&larr; CookNote</a></p>')
    ..write('<h1>${_esc(r['name'] as String?)}</h1>');
  final facts = <String>[
    if (r['servings'] != null)
      '${r['servings']}${r['servingsUnit'] == null ? '' : ' ${r['servingsUnit']}'}',
    if (r['prepMinutes'] != null) 'Prep ${r['prepMinutes']} min',
    if (r['cookMinutes'] != null) 'Cook ${r['cookMinutes']} min',
    if (r['totalMinutes'] != null) 'Total ${r['totalMinutes']} min',
    if ((r['rating'] as int? ?? 0) > 0) '★' * (r['rating'] as int),
  ];
  if (facts.isNotEmpty) b.write('<p>${facts.map(_esc).join(' · ')}</p>');
  for (final f in (r['photos'] as List? ?? const [])) {
    b.write('<p><img src="../images/${_esc(f as String)}" alt=""></p>');
  }
  final ingredients = _lines(r['ingredients'], numbered: false);
  if (ingredients.isNotEmpty) {
    b.write('<h2>Nguyên liệu / Ingredients</h2>$ingredients');
  }
  final steps = _lines(r['steps'], numbered: true);
  if (steps.isNotEmpty) b.write('<h2>Các bước / Steps</h2>$steps');
  if ((r['notes'] as String?)?.isNotEmpty ?? false) {
    b.write('<h2>Ghi chú / Notes</h2><p>${_esc(r['notes'] as String)}</p>');
  }
  if ((r['nutrition'] as String?)?.isNotEmpty ?? false) {
    b.write(
      '<h2>Dinh dưỡng / Nutrition</h2><p>${_esc(r['nutrition'] as String)}</p>',
    );
  }
  final source = [
    r['source'],
    r['sourceUrl'],
  ].whereType<String>().where((s) => s.isNotEmpty);
  if (source.isNotEmpty) b.write('<p>${source.map(_esc).join(' · ')}</p>');
  return _page(r['name'] as String, b.toString());
}

/// Tạo file sao lưu `.cooknote` tại [out] (AC-49). Ghi ra file tạm rồi đổi
/// tên, nên [out] không bao giờ ở trạng thái dở. [cancelled] được hỏi giữa
/// các bước; trả về true thì dừng, xóa file tạm và ném [BackupCancelled]
/// (AC-57).
Future<BackupInfo> createBackupFile({
  required AppDatabase db,
  required ImageStore images,
  required File out,
  required String appVersion,
  DateTime? now,
  void Function(double progress)? onProgress,
  bool Function()? cancelled,
}) async {
  void check() {
    if (cancelled?.call() ?? false) throw const BackupCancelled();
  }

  final part = File('${out.path}.part');
  await out.parent.create(recursive: true);
  if (await part.exists()) await part.delete();
  ZipFileEncoder? encoder;
  try {
    check();
    final data = await exportData(db);
    final recipes = (data['recipes'] as List).cast<Map<String, Object?>>();
    final categories = data['categories'] as List;
    final wanted = <String>{
      for (final r in recipes) ...(r['photos'] as List).cast<String>(),
    };
    final photoNames = [
      for (final n in wanted)
        if (_imageEntry.hasMatch('images/$n') && await images.file(n).exists())
          n,
    ]..sort();
    final dataBytes = utf8.encode(jsonEncode(data));
    final total = photoNames.length + 3;
    var done = 0;
    void step() => onProgress?.call(++done / total);

    final enc = encoder = ZipFileEncoder()..create(part.path);
    final hashes = <String, String>{};
    void addText(String name, String text) {
      final bytes = utf8.encode(text);
      enc.addArchiveFile(ArchiveFile.bytes(name, bytes));
    }

    enc.addArchiveFile(ArchiveFile.bytes('data.json', dataBytes));
    hashes['data.json'] = _sha256(dataBytes);
    addText('README.txt', _readme);

    final alive = recipes.where((r) => r['deletedAt'] == null).toList()
      ..sort(
        (a, b) =>
            normalizeText(a['name'] as String)
                .compareTo(normalizeText(b['name'] as String)),
      );
    for (final r in alive) {
      addText('html/${r['id']}.html', _recipeHtml(r));
    }
    final index = StringBuffer(
      '<h1>CookNote</h1><p>${alive.length} recipes</p><ul>',
    );
    for (final r in alive) {
      index.write(
        '<li><a href="${r['id']}.html">${_esc(r['name'] as String)}</a></li>',
      );
    }
    index.write('</ul>');
    addText('html/index.html', _page('CookNote', index.toString()));
    step();

    for (final name in photoNames) {
      check();
      final bytes = await images.file(name).readAsBytes();
      hashes['images/$name'] = _sha256(bytes);
      enc.addArchiveFile(
        ArchiveFile.noCompress('images/$name', bytes.length, bytes),
      );
      step();
      await _yield();
    }

    check();
    final created = (now ?? DateTime.now());
    final manifest = {
      'app': 'CookNote',
      'formatVersion': supportedFormatVersion,
      'appVersion': appVersion,
      'createdAt': created.toUtc().toIso8601String(),
      'counts': {
        'recipes': recipes.length,
        'photos': photoNames.length,
        'categories': categories.length,
      },
      'files': hashes,
    };
    enc.addArchiveFile(
      ArchiveFile.bytes('manifest.json', utf8.encode(jsonEncode(manifest))),
    );
    await enc.close();
    step();
    if (await out.exists()) await out.delete();
    await part.rename(out.path);
    onProgress?.call(1);
    return BackupInfo(
      formatVersion: supportedFormatVersion,
      appVersion: appVersion,
      createdAt: created,
      recipes: recipes.length,
      photos: photoNames.length,
      categories: categories.length,
      bytes: await out.length(),
      dataHash: hashes['data.json']!,
    );
  } catch (_) {
    // Phải đóng bộ ghi trước khi xóa file tạm (Windows giữ khóa file đang mở).
    try {
      await encoder?.close();
    } catch (_) {
      // Đang dọn lỗi cũ; bỏ qua lỗi đóng.
    }
    if (await part.exists()) await part.delete();
    rethrow;
  }
}

/// Mở [file] zip để đọc rồi LUÔN đóng luồng đọc (Windows giữ khóa file nếu
/// còn mở, và không xóa được file tạm).
Future<T> _withArchive<T>(File file, Future<T> Function(Archive) body) async {
  final input = InputFileStream(file.path);
  try {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeStream(input);
    } catch (e) {
      throw BackupException(BackupProblem.notABackup, '$e');
    }
    return await body(archive);
  } finally {
    await input.close();
  }
}

({BackupInfo info, Map<String, String> files}) _readManifest(
  Archive archive,
  int bytes,
) {
  final entry = archive.findFile('manifest.json');
  if (entry == null) {
    throw const BackupException(BackupProblem.notABackup, 'thiếu manifest');
  }
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(entry.readBytes()!));
  } catch (e) {
    throw BackupException(BackupProblem.notABackup, '$e');
  }
  if (json is! Map<String, Object?> || json['app'] != 'CookNote') {
    throw const BackupException(
      BackupProblem.notABackup,
      'không phải file của CookNote',
    );
  }
  final version = json['formatVersion'];
  if (version is! int) {
    throw const BackupException(BackupProblem.notABackup, 'thiếu phiên bản');
  }
  if (version > supportedFormatVersion) {
    throw BackupException(BackupProblem.newerFormat, 'định dạng $version');
  }
  final files = (json['files'] as Map?)?.cast<String, String>() ?? const {};
  if (!files.containsKey('data.json')) {
    throw const BackupException(BackupProblem.notABackup, 'thiếu data.json');
  }
  final counts = (json['counts'] as Map?) ?? const {};
  return (
    info: BackupInfo(
      formatVersion: version,
      appVersion: '${json['appVersion'] ?? ''}',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      recipes: (counts['recipes'] as int?) ?? 0,
      photos: (counts['photos'] as int?) ?? 0,
      categories: (counts['categories'] as int?) ?? 0,
      bytes: bytes,
      dataHash: files['data.json']!,
    ),
    files: files,
  );
}

/// Đọc lại toàn bộ [file] và đối chiếu mã băm từng phần với manifest (AC-51,
/// AC-54). Không đụng vào dữ liệu của app.
Future<BackupInfo> verifyBackupFile(File file) async {
  final size = await file.length();
  return _withArchive(file, (archive) async {
    final m = _readManifest(archive, size);
    for (final e in m.files.entries) {
      final entry = archive.findFile(e.key);
      if (entry == null) {
        throw BackupException(BackupProblem.missingFile, e.key);
      }
      final bytes = entry.readBytes();
      if (bytes == null || _sha256(bytes) != e.value) {
        throw BackupException(BackupProblem.checksumMismatch, e.key);
      }
      await _yield();
    }
    return m.info;
  });
}

/// Khôi phục từ [file] (AC-54). Kiểm tra trọn vẹn TRƯỚC; chỉ khi file tốt mới
/// chép ảnh và nạp dữ liệu (một giao dịch). Lỗi thì dữ liệu hiện có còn nguyên.
Future<ImportSummary> restoreBackupFile({
  required AppDatabase db,
  required ImageStore images,
  required File file,
  required RestoreMode mode,
  void Function(double progress)? onProgress,
}) async {
  await verifyBackupFile(file);
  final size = await file.length();

  // Đọc và chép ảnh trong lúc file zip còn mở; nạp cơ sở dữ liệu sau khi đóng.
  final data = await _withArchive(file, (archive) async {
    final m = _readManifest(archive, size);
    final entries = m.files.keys.where((n) => n.startsWith('images/')).toList();
    for (final name in entries) {
      if (!_imageEntry.hasMatch(name)) {
        throw BackupException(
          BackupProblem.badData,
          'tên ảnh không hợp lệ: $name',
        );
      }
    }
    final Map<String, Object?> parsed;
    try {
      parsed = jsonDecode(
        utf8.decode(archive.findFile('data.json')!.readBytes()!),
      ) as Map<String, Object?>;
    } catch (e) {
      throw BackupException(BackupProblem.badData, '$e');
    }
    await images.directory.create(recursive: true);
    for (var i = 0; i < entries.length; i++) {
      final target = images.file(p.basename(entries[i]));
      if (!await target.exists()) {
        await target.writeAsBytes(
          archive.findFile(entries[i])!.readBytes()!,
          flush: true,
        );
      }
      onProgress?.call((i + 1) / (entries.length + 1));
      await _yield();
    }
    return parsed;
  });

  final summary = await importData(
    db,
    data,
    replace: mode == RestoreMode.replace,
  );
  // Ảnh của công thức không được nạp (hoặc dữ liệu cũ bị thay) thì dọn đi.
  final used = {
    for (final r in await db.select(db.recipePhotos).get()) r.fileName,
  };
  await images.sweep(used);
  onProgress?.call(1);
  return summary;
}
