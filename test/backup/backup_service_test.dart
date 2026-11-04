import 'dart:io';

import 'package:cooknote/src/backup/backup_format.dart';
import 'package:cooknote/src/backup/backup_service.dart';
import 'package:cooknote/src/backup/backup_settings.dart';
import 'package:cooknote/src/backup/backup_target.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

/// Nơi lưu giả có thể hỏng theo ý muốn.
class FlakyTarget extends LocalDirTarget {
  FlakyTarget(super.directory);

  bool failPut = false;
  bool corruptOnPut = false;
  bool failList = false;

  @override
  Future<List<BackupFileInfo>> list() {
    if (failList) throw const FileSystemException('mất quyền');
    return super.list();
  }

  @override
  Future<void> put(File local, String name) async {
    if (failPut) throw const FileSystemException('hết dung lượng');
    await super.put(local, name);
    if (corruptOnPut) {
      final f = File('${directory.path}/$name');
      final bytes = f.readAsBytesSync();
      f.writeAsBytesSync(bytes.sublist(0, bytes.length ~/ 2));
    }
  }
}

void main() {
  late Directory temp;
  late AppDatabase db;
  late ImageStore images;
  late RecipeRepository recipes;
  late BackupSettingsRepository settings;
  late FlakyTarget target;
  late BackupService service;
  late DateTime now;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('cooknote_svc_');
    db = AppDatabase(NativeDatabase.memory());
    images = ImageStore(Directory('${temp.path}/photos'));
    now = DateTime(2026, 11, 4, 8, 0, 0);
    recipes = RecipeRepository(db, images, clock: () => now);
    settings = BackupSettingsRepository(db);
    target = FlakyTarget(Directory('${temp.path}/dest'));
    service = BackupService(
      db: db,
      images: images,
      settings: settings,
      tempDir: Directory('${temp.path}/tmp'),
      safetyDir: Directory('${temp.path}/safety'),
      appVersion: '1.0.0',
      targetFor: (c) => c.enabled ? target : null,
      clock: () => now,
    );
  });

  tearDown(() async {
    await db.close();
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException {
      // Không ảnh hưởng kết quả.
    }
  });

  Future<void> enable({int keep = 5}) async {
    await settings.setTarget('content://tree/1', 'Thư mục thử');
    await settings.setKeep(keep);
  }

  Future<void> addRecipe(String name) =>
      recipes.save(RecipeDraft(name: name)).then((_) {});

  List<String> names() {
    if (!target.directory.existsSync()) return [];
    return [
      for (final e in target.directory.listSync()) e.uri.pathSegments.last,
    ]..sort();
  }

  group('đặt tên và nhận diện file của app (AC-50)', () {
    test('tên theo thời gian, sắp theo tên là sắp theo thời gian', () {
      expect(
        backupFileName(DateTime(2026, 1, 2, 3, 4, 5)),
        'CookNote-2026-01-02-030405.cooknote',
      );
      expect(isOwnBackupName('CookNote-2026-01-02-030405.cooknote'), isTrue);
      for (final other in [
        'anh.jpg',
        'CookNote-2026-01-02.cooknote',
        'CookNote-2026-01-02-030405.zip',
        'my-CookNote-2026-01-02-030405.cooknote',
        'CookNote-2026-01-02-030405.cooknote.bak',
      ]) {
        expect(isOwnBackupName(other), isFalse, reason: other);
      }
    });
  });

  group('tới chu kỳ chưa (AC-50)', () {
    final t = DateTime(2026, 11, 4, 8);
    test('chưa từng kiểm thì tới hạn', () {
      expect(backupDue(now: t, interval: BackupInterval.daily), isTrue);
    });
    test('hằng ngày: sau 23 giờ thì tới hạn, trước đó chưa', () {
      expect(
        backupDue(
          now: t,
          interval: BackupInterval.daily,
          lastChecked: t.subtract(const Duration(hours: 22)),
        ),
        isFalse,
      );
      expect(
        backupDue(
          now: t,
          interval: BackupInterval.daily,
          lastChecked: t.subtract(const Duration(hours: 23)),
        ),
        isTrue,
      );
    });
    test('hằng tuần', () {
      expect(
        backupDue(
          now: t,
          interval: BackupInterval.weekly,
          lastChecked: t.subtract(const Duration(days: 6)),
        ),
        isFalse,
      );
      expect(
        backupDue(
          now: t,
          interval: BackupInterval.weekly,
          lastChecked: t.subtract(const Duration(days: 7)),
        ),
        isTrue,
      );
    });
  });

  group('tự sao lưu (AC-50, AC-51)', () {
    test('chưa chọn thư mục thì không làm gì', () async {
      await addRecipe('A');
      expect((await service.runIfDue()).outcome, BackupOutcome.disabled);
      expect(names(), isEmpty);
    });

    test('ghi file đúng tên, đọc lại được, ghi nhận kết quả', () async {
      await enable();
      await addRecipe('A');
      final r = await service.runIfDue();
      expect(r.outcome, BackupOutcome.success);
      expect(names(), ['CookNote-2026-11-04-080000.cooknote']);
      final info = await verifyBackupFile(
        File('${target.directory.path}/${names().single}'),
      );
      expect(info.recipes, 1);

      final c = await settings.read();
      expect(c.lastSuccess, now);
      expect(c.lastError, isNull);
      expect(c.lastBytes, info.bytes);
      expect(c.lastHash, info.dataHash);
      // Không để file tạm.
      expect(Directory('${temp.path}/tmp').listSync(), isEmpty);
    });

    test('chưa tới chu kỳ thì không chạy; tới chu kỳ mà dữ liệu không đổi thì không ghi mới', () async {
      await enable();
      await addRecipe('A');
      await service.runIfDue();
      now = now.add(const Duration(hours: 5));
      expect((await service.runIfDue()).outcome, BackupOutcome.notDue);

      now = now.add(const Duration(days: 1));
      expect((await service.runIfDue()).outcome, BackupOutcome.unchanged);
      expect(names().length, 1);
      expect((await settings.read()).lastChecked, now);
      expect((await settings.read()).lastSuccess, DateTime(2026, 11, 4, 8));

      // Có thay đổi thì lần tới ghi file mới.
      await addRecipe('B');
      now = now.add(const Duration(days: 1));
      expect((await service.runIfDue()).outcome, BackupOutcome.success);
      expect(names().length, 2);
    });

    test(
      'xoay vòng: giữ N bản mới nhất của app, không đụng file khác',
      () async {
        await enable(keep: 3);
        target.directory.createSync(recursive: true);
        File('${target.directory.path}/anh-cua-toi.jpg').writeAsStringSync('x');
        File('${target.directory.path}/CookNote-cua-ban-khac.cooknote')
            .writeAsStringSync('x');
        for (var i = 0; i < 5; i++) {
          await addRecipe('R$i');
          now = now.add(const Duration(days: 1));
          expect((await service.runNow()).outcome, BackupOutcome.success);
        }
        final own = names().where(isOwnBackupName).toList();
        expect(own, [
          'CookNote-2026-11-07-080000.cooknote',
          'CookNote-2026-11-08-080000.cooknote',
          'CookNote-2026-11-09-080000.cooknote',
        ]);
        expect(
          names(),
          containsAll(['anh-cua-toi.jpg', 'CookNote-cua-ban-khac.cooknote']),
        );
      },
    );

    test('keep = 1 vẫn giữ bản vừa ghi', () async {
      await enable(keep: 1);
      await addRecipe('A');
      await service.runNow();
      await addRecipe('B');
      now = now.add(const Duration(days: 1));
      await service.runNow();
      expect(names(), ['CookNote-2026-11-05-080000.cooknote']);
    });

    test('lỗi ghi thì báo, không tính thành công, giữ lần thành công cũ, thử lại được', () async {
      await enable();
      await addRecipe('A');
      await service.runNow();
      final lastOk = (await settings.read()).lastSuccess;

      await addRecipe('B');
      now = now.add(const Duration(days: 1));
      target.failPut = true;
      final r = await service.runNow();
      expect(r.outcome, BackupOutcome.failed);
      expect(r.error, startsWith('${BackupErrorKind.target}|'));
      var c = await settings.read();
      expect(c.lastError, r.error);
      expect(c.lastSuccess, lastOk);
      expect(names().length, 1);

      // Lỗi không làm chu kỳ trôi: lần mở app kế vẫn thử lại.
      target.failPut = false;
      final again = await service.runIfDue();
      expect(again.outcome, BackupOutcome.success);
      c = await settings.read();
      expect(c.lastError, isNull);
      expect(c.lastSuccess, now);
    });

    test('mất quyền đọc thư mục sau khi ghi cũng là lỗi nơi lưu', () async {
      await enable();
      await addRecipe('A');
      target.failList = true;
      final r = await service.runNow();
      expect(r.outcome, BackupOutcome.failed);
      expect(r.error, startsWith('${BackupErrorKind.target}|'));
    });

    test(
      'file ghi ra bị hỏng thì không tính thành công và xóa file hỏng',
      () async {
        await enable();
        await addRecipe('A');
        target.corruptOnPut = true;
        final r = await service.runNow();
        expect(r.outcome, BackupOutcome.failed);
        expect(r.error, startsWith('${BackupErrorKind.verify}|'));
        expect(names(), isEmpty);
        expect((await settings.read()).lastSuccess, isNull);
      },
    );

    test('force ghi file mới cả khi dữ liệu không đổi', () async {
      await enable();
      await addRecipe('A');
      await service.runNow();
      now = now.add(const Duration(minutes: 1));
      expect((await service.runNow()).outcome, BackupOutcome.unchanged);
      expect(
        (await service.runNow(force: true)).outcome,
        BackupOutcome.success,
      );
      expect(names().length, 2);
    });

    test('hai lần chạy cùng lúc thì lần sau báo bận', () async {
      await enable();
      await addRecipe('A');
      final first = service.runNow();
      final second = await service.runNow();
      expect(second.outcome, BackupOutcome.busy);
      expect((await first).outcome, BackupOutcome.success);
    });

    test(
      'đổi thư mục thì lần đầu sao lưu ngay và không lấy mã băm cũ',
      () async {
        await enable();
        await addRecipe('A');
        await service.runNow();
        await settings.setTarget('content://tree/2', 'Thư mục khác');
        final c = await settings.read();
        expect((c.lastHash, c.lastChecked, c.lastError), (null, null, null));
        expect((await service.runIfDue()).outcome, BackupOutcome.success);
      },
    );
  });

  group('khôi phục có bản an toàn (AC-54)', () {
    Future<File> makeBackup() async {
      final out = File('${temp.path}/b.cooknote');
      await service.createFile(out);
      return out;
    }

    test('thay thế: tự lưu bản trước khi thay, giữ 2 bản', () async {
      await addRecipe('Cũ');
      final backup = await makeBackup();
      await db.delete(db.recipes).go();
      await addRecipe('Dữ liệu hiện tại');

      for (var i = 0; i < 3; i++) {
        now = now.add(const Duration(minutes: 1));
        await service.restore(backup, RestoreMode.replace);
        // Sau khi thay, dữ liệu hiện tại là "Cũ"; đổi lại để bản an toàn khác nhau.
        await addRecipe('Lần $i');
      }
      final safety = Directory('${temp.path}/safety').listSync();
      expect(safety.length, 2);
      // Bản an toàn gần nhất chứa dữ liệu ngay trước lần thay cuối.
      final latest = safety.map((e) => e.path).toList()..sort();
      final info = await verifyBackupFile(File(latest.last));
      expect(info.recipes, 2);
    });

    test('file hỏng: không tạo bản an toàn, không đổi dữ liệu', () async {
      await addRecipe('Giữ');
      final bad = File('${temp.path}/bad.cooknote')
        ..writeAsBytesSync([1, 2, 3]);
      await expectLater(
        service.restore(bad, RestoreMode.replace),
        throwsA(isA<BackupException>()),
      );
      expect(Directory('${temp.path}/safety').existsSync(), isFalse);
      expect((await db.select(db.recipes).get()).single.name, 'Giữ');
    });

    test('gộp không tạo bản an toàn', () async {
      await addRecipe('A');
      final backup = await makeBackup();
      await service.restore(backup, RestoreMode.merge);
      expect(Directory('${temp.path}/safety').existsSync(), isFalse);
    });
  });

  group('nhắc nhở (AC-53)', () {
    final t = DateTime(2026, 11, 20);
    test('chưa bật: gợi ý khi có từ 10 công thức, dưới đó thì im', () {
      const none = BackupConfig();
      expect(
        backupNotice(config: none, recipeCount: 9, now: t),
        BackupNotice.none,
      );
      expect(
        backupNotice(config: none, recipeCount: 10, now: t),
        BackupNotice.suggestEnable,
      );
    });

    test(
      'quá 7 ngày chưa có lần thành công thì nhắc, đúng 7 ngày thì chưa',
      () {
        BackupConfig at(Duration ago) =>
            BackupConfig(treeUri: 'x', lastSuccess: t.subtract(ago));
        expect(
          backupNotice(
            config: at(const Duration(days: 7)),
            recipeCount: 3,
            now: t,
          ),
          BackupNotice.none,
        );
        expect(
          backupNotice(
            config: at(const Duration(days: 7, minutes: 1)),
            recipeCount: 3,
            now: t,
          ),
          BackupNotice.overdue,
        );
        expect(
          backupNotice(
            config: at(const Duration(days: 30)),
            recipeCount: 0,
            now: t,
          ),
          BackupNotice.none,
        );
      },
    );

    test('lỗi nơi lưu được báo trước nhắc quá hạn', () {
      final c = BackupConfig(
        treeUri: 'x',
        lastSuccess: t.subtract(const Duration(days: 30)),
        lastError: 'target|mất quyền',
      );
      expect(
        backupNotice(config: c, recipeCount: 5, now: t),
        BackupNotice.targetError,
      );
    });

    test('đã tắt sao lưu thì không báo lỗi nơi lưu cũ', () {
      const c = BackupConfig(lastError: 'target|x');
      expect(
        backupNotice(config: c, recipeCount: 5, now: DateTime(2026, 11, 20)),
        isNot(BackupNotice.targetError),
      );
    });
  });

  test('ảnh đi theo bản sao lưu tự động', () async {
    await enable();
    final f = File('${temp.path}/p.jpg')..writeAsBytesSync(jpegBytes(50, 50));
    final name = await images.importImage(f.path);
    await recipes.save(RecipeDraft(name: 'Có ảnh', photos: [name]));
    await service.runNow();
    final info = await verifyBackupFile(
      File('${target.directory.path}/${names().single}'),
    );
    expect(info.photos, 1);
  });
}
