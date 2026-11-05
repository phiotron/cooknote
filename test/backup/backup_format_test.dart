import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:cooknote/src/backup/backup_format.dart';
import 'package:cooknote/src/data/category_repository.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_query.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

/// Một "máy": cơ sở dữ liệu, thư mục ảnh và các kho trên đó.
class Device {
  Device(Directory root)
    : db = AppDatabase(NativeDatabase.memory()),
      images = ImageStore(Directory('${root.path}/photos')) {
    recipes = RecipeRepository(
      db,
      images,
      clock: () => DateTime(2026, 11, 3, 9),
    );
    categories = CategoryRepository(db);
  }

  final AppDatabase db;
  final ImageStore images;
  late final RecipeRepository recipes;
  late final CategoryRepository categories;

  Future<String> photo(Directory temp, int w) async {
    final f = File('${temp.path}/src$w.jpg')
      ..writeAsBytesSync(jpegBytes(w, 40));
    return images.importImage(f.path);
  }
}

void main() {
  late Directory temp;
  late Device a;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('cooknote_bk_');
    a = Device(Directory('${temp.path}/a'));
  });

  tearDown(() async {
    await a.db.close();
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows có thể còn giữ file; không ảnh hưởng kết quả.
    }
  });

  /// Dữ liệu mẫu có đủ loại: danh mục lồng, thẻ, ảnh, lịch sử nấu, thùng rác.
  Future<void> seed() async {
    final main = await a.categories.add('Món chính');
    final viet = await a.categories.add('Món Việt', parentId: main);
    final p1 = await a.photo(temp, 60);
    final p2 = await a.photo(temp, 80);
    final pho = await a.recipes.save(
      RecipeDraft(
        name: 'Phở bò <đặc biệt> & "ngon"',
        servings: 4,
        servingsUnit: 'người',
        totalMinutes: 240,
        notes: 'Xem https://example.com/pho',
        sourceUrl: 'https://example.com/pho',
        rating: 5,
        favorite: true,
        difficulty: Difficulty.hard,
        ingredients: const [
          RecipeLine('Nước dùng', isHeading: true),
          RecipeLine('2 kg xương bò'),
        ],
        steps: const [RecipeLine('Chần xương'), RecipeLine('Ninh 3 tiếng')],
        photos: [p1, p2],
        categoryIds: [viet],
        tags: ['bò', 'Nước dùng'],
      ),
    );
    await a.recipes.markCooked(pho);
    final flan = await a.recipes.save(const RecipeDraft(name: 'Bánh flan'));
    await a.recipes.moveToTrash(flan);
  }

  Future<File> backup({
    void Function(double)? onProgress,
    bool Function()? cancelled,
  }) async {
    final out = File('${temp.path}/out.cooknote');
    await createBackupFile(
      db: a.db,
      images: a.images,
      out: out,
      appVersion: '1.2.3',
      now: DateTime(2026, 11, 4, 10, 30),
      onProgress: onProgress,
      cancelled: cancelled,
    );
    return out;
  }

  /// Giải nén, sửa, nén lại một file sao lưu để mô phỏng file hỏng.
  File tamper(File src, void Function(Archive) change) {
    final archive = ZipDecoder().decodeBytes(src.readAsBytesSync());
    change(archive);
    final out = File('${temp.path}/tampered.cooknote');
    out.writeAsBytesSync(ZipEncoder().encode(archive));
    return out;
  }

  Future<void> expectProblem(Future<Object?> f, BackupProblem p) => expectLater(
    f,
    throwsA(isA<BackupException>().having((e) => e.problem, 'problem', p)),
  );

  group('tạo và kiểm tra file (AC-49)', () {
    test('gói zip có đủ manifest, data, ảnh, README, HTML', () async {
      await seed();
      final out = await backup();
      final archive = ZipDecoder().decodeBytes(out.readAsBytesSync());
      final names = archive.files.map((f) => f.name).toSet();
      expect(names, containsAll(['manifest.json', 'data.json', 'README.txt']));
      expect(names.where((n) => n.startsWith('images/')).length, 2);
      expect(names, contains('html/index.html'));
      expect(
        names.where((n) => RegExp(r'^html/\d+\.html$').hasMatch(n)).length,
        1, // công thức trong thùng rác không có trang HTML
      );

      final manifest = jsonDecode(
        utf8.decode(archive.findFile('manifest.json')!.readBytes()!),
      ) as Map<String, Object?>;
      expect(manifest['app'], 'CookNote');
      expect(manifest['formatVersion'], 2);
      expect(manifest['appVersion'], '1.2.3');
      expect(manifest['counts'], {
        'recipes': 2,
        'photos': 2,
        'categories': 2,
        'shoppingItems': 0,
        'pantry': 0,
        'mealPlan': 0,
        'menuTemplates': 0,
      });
      final files = manifest['files'] as Map<String, Object?>;
      expect(
        files.keys.toSet(),
        containsAll([
          'data.json',
          ...names.where((n) => n.startsWith('images/')),
        ]),
      );
      expect(
        files.values.every((h) => RegExp(r'^[0-9a-f]{64}$').hasMatch('$h')),
        isTrue,
      );
    });

    test('verify đọc lại và báo số liệu', () async {
      await seed();
      final info = await verifyBackupFile(await backup());
      expect(info.recipes, 2);
      expect(info.photos, 2);
      expect(info.formatVersion, 2);
      expect(info.appVersion, '1.2.3');
      expect(info.createdAt, DateTime(2026, 11, 4, 10, 30));
    });

    test('sao lưu dữ liệu rỗng vẫn hợp lệ', () async {
      final info = await verifyBackupFile(await backup());
      expect((info.recipes, info.photos), (0, 0));
    });

    test(
      'trang HTML đọc được không cần app, đã thoát ký tự đặc biệt',
      () async {
        await seed();
        final archive = ZipDecoder().decodeBytes(
          (await backup()).readAsBytesSync(),
        );
        final index = utf8.decode(
          archive.findFile('html/index.html')!.readBytes()!,
        );
        expect(
          index,
          contains('Phở bò &lt;đặc biệt&gt; &amp; &quot;ngon&quot;'),
        );
        expect(index, isNot(contains('<đặc biệt>')));
        final page = archive.files
            .where((f) => RegExp(r'^html/\d+\.html$').hasMatch(f.name))
            .map((f) => utf8.decode(f.readBytes()!))
            .firstWhere((h) => h.contains('xương bò'));
        expect(page, contains('2 kg xương bò'));
        expect(page, contains('Ninh 3 tiếng'));
        expect(page, contains('../images/'));
        expect(page, contains('charset="utf-8"'));
        expect(page, isNot(contains('<script')));
      },
    );

    test(
      'báo tiến độ tăng dần tới 1 và hủy được, không để lại file dở',
      () async {
        await seed();
        final values = <double>[];
        await backup(onProgress: values.add);
        expect(values.last, 1.0);
        for (var i = 1; i < values.length; i++) {
          expect(values[i], greaterThanOrEqualTo(values[i - 1]));
        }

        var calls = 0;
        final out = File('${temp.path}/cancel.cooknote');
        await expectLater(
          createBackupFile(
            db: a.db,
            images: a.images,
            out: out,
            appVersion: '1',
            cancelled: () => ++calls > 2,
          ),
          throwsA(isA<BackupCancelled>()),
        );
        expect(out.existsSync(), isFalse);
      },
    );
  });

  group('phát hiện file hỏng trước khi đụng vào dữ liệu (AC-54)', () {
    test('không phải file zip', () async {
      final f = File('${temp.path}/x.cooknote')..writeAsBytesSync([1, 2, 3, 4]);
      await expectProblem(verifyBackupFile(f), BackupProblem.notABackup);
    });

    test('thiếu manifest', () async {
      await seed();
      final f = tamper(
        await backup(),
        (z) => z.removeFile(z.findFile('manifest.json')!),
      );
      await expectProblem(verifyBackupFile(f), BackupProblem.notABackup);
    });

    test('mã băm ảnh không khớp', () async {
      await seed();
      final f = tamper(await backup(), (z) {
        final img = z.files.firstWhere((e) => e.name.startsWith('images/'));
        final bytes = img.readBytes()!..[10] ^= 0xFF;
        z.removeFile(img);
        z.addFile(ArchiveFile.bytes(img.name, bytes));
      });
      await expectProblem(verifyBackupFile(f), BackupProblem.checksumMismatch);
    });

    test('data.json bị sửa', () async {
      await seed();
      final f = tamper(await backup(), (z) {
        final d = z.findFile('data.json')!;
        z.removeFile(d);
        z.addFile(
          ArchiveFile.bytes('data.json', utf8.encode('{"recipes":[]}')),
        );
      });
      await expectProblem(verifyBackupFile(f), BackupProblem.checksumMismatch);
    });

    test('thiếu ảnh khai trong manifest', () async {
      await seed();
      final f = tamper(await backup(), (z) {
        z.removeFile(z.files.firstWhere((e) => e.name.startsWith('images/')));
      });
      await expectProblem(verifyBackupFile(f), BackupProblem.missingFile);
    });

    test('định dạng mới hơn app này hiểu thì báo cần cập nhật app', () async {
      await seed();
      final f = tamper(await backup(), (z) {
        final m = z.findFile('manifest.json')!;
        final json =
            jsonDecode(utf8.decode(m.readBytes()!)) as Map<String, Object?>;
        json['formatVersion'] = 99;
        z.removeFile(m);
        z.addFile(
          ArchiveFile.bytes('manifest.json', utf8.encode(jsonEncode(json))),
        );
      });
      await expectProblem(verifyBackupFile(f), BackupProblem.newerFormat);
    });
  });

  group('khôi phục (AC-54)', () {
    test('thay thế toàn bộ: mọi thứ giống hệt, ảnh còn nguyên byte', () async {
      await seed();
      final out = await backup();
      final before = {
        for (final s in await a.recipes.search(const RecipeQuery()))
          s.id: await a.recipes.getRecipe(s.id),
      };
      expect(
        before.length,
        1,
      ); // công thức trong thùng rác không nằm trong danh sách

      final b = Device(Directory('${temp.path}/b'));
      addTearDown(b.db.close);
      // Máy B đã có dữ liệu khác, sẽ bị thay thế.
      await b.categories.add('Rác cũ');
      await b.recipes.save(const RecipeDraft(name: 'Sẽ bị thay'));

      final summary = await restoreBackupFile(
        db: b.db,
        images: b.images,
        file: out,
        mode: RestoreMode.replace,
      );
      expect(summary.recipesAdded, 2);

      expect((await b.categories.getAll()).map((c) => (c.name, c.depth)), [
        ('Món chính', 1),
        ('Món Việt', 2),
      ]);
      final all = await b.db.select(b.db.recipes).get();
      expect(all.map((r) => r.name).toSet(), {
        'Phở bò <đặc biệt> & "ngon"',
        'Bánh flan',
      });
      final pho = all.firstWhere((r) => r.name.startsWith('Phở'));
      final restored = (await b.recipes.getRecipe(pho.id))!;
      final original = before.values.single!;
      expect(restored.draft, original.draft);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
      expect(restored.cookCount, 1);
      expect(restored.lastCookedAt, original.lastCookedAt);
      // Công thức trong thùng rác vẫn nằm trong thùng rác.
      final flan = all.firstWhere((r) => r.name == 'Bánh flan');
      expect(flan.deletedAt, isNotNull);
      // Ảnh giống từng byte.
      for (final name in original.draft.photos) {
        expect(
          b.images.file(name).readAsBytesSync(),
          a.images.file(name).readAsBytesSync(),
        );
      }
    });

    test('giữ id để liên kết danh mục không lệch', () async {
      await seed();
      final out = await backup();
      final b = Device(Directory('${temp.path}/b'));
      addTearDown(b.db.close);
      await restoreBackupFile(
        db: b.db,
        images: b.images,
        file: out,
        mode: RestoreMode.replace,
      );
      final ids = (await a.db.select(a.db.recipes).get())
          .map((r) => r.id)
          .toSet();
      expect(
        (await b.db.select(b.db.recipes).get()).map((r) => r.id).toSet(),
        ids,
      );
    });

    test('file hỏng thì báo lỗi và dữ liệu hiện có còn nguyên', () async {
      await seed();
      final bad = tamper(await backup(), (z) {
        final img = z.files.firstWhere((e) => e.name.startsWith('images/'));
        z.removeFile(img);
        z.addFile(ArchiveFile.bytes(img.name, [1, 2, 3]));
      });
      final b = Device(Directory('${temp.path}/b'));
      addTearDown(b.db.close);
      await b.recipes.save(const RecipeDraft(name: 'Giữ lại'));

      await expectProblem(
        restoreBackupFile(
          db: b.db,
          images: b.images,
          file: bad,
          mode: RestoreMode.replace,
        ),
        BackupProblem.checksumMismatch,
      );
      expect((await b.db.select(b.db.recipes).get()).single.name, 'Giữ lại');
    });

    test(
      'gộp: chỉ thêm công thức chưa có, không đụng công thức đã có',
      () async {
        await seed();
        final out = await backup();
        final b = Device(Directory('${temp.path}/b'));
        addTearDown(b.db.close);

        // Máy B đã có "Phở bò..." (cùng tên, cùng thời điểm tạo) và công thức khác.
        final pho = await a.recipes.search(const RecipeQuery());
        final phoDetail = (await a.recipes.getRecipe(pho.single.id))!;
        await b.recipes.save(
          phoDetail.draft.copyWith(
            photos: [],
            categoryIds: [],
            tags: [],
            rating: 1,
          ),
        );
        await b.recipes.save(const RecipeDraft(name: 'Món riêng của B'));

        final summary = await restoreBackupFile(
          db: b.db,
          images: b.images,
          file: out,
          mode: RestoreMode.merge,
        );
        expect(summary.recipesAdded, 1); // Bánh flan
        expect(summary.recipesSkipped, 1); // Phở đã có

        final names = (await b.db.select(b.db.recipes).get())
            .map((r) => r.name)
            .toSet();
        expect(names, {
          'Phở bò <đặc biệt> & "ngon"',
          'Bánh flan',
          'Món riêng của B',
        });
        final phoB = (await b.db.select(b.db.recipes).get()).firstWhere(
          (r) => r.name.startsWith('Phở'),
        );
        expect(phoB.rating, 1); // bản đã có giữ nguyên
      },
    );

    test('gộp: danh mục trùng đường dẫn dùng lại, chưa có thì tạo', () async {
      await seed();
      final out = await backup();
      final b = Device(Directory('${temp.path}/b'));
      addTearDown(b.db.close);
      await b.categories.add('Món chính'); // đã có cấp 1, chưa có "Món Việt"
      await b.categories.add('Món phụ');

      await restoreBackupFile(
        db: b.db,
        images: b.images,
        file: out,
        mode: RestoreMode.merge,
      );
      final cats = await b.categories.getAll();
      expect(cats.map((c) => c.name), ['Món chính', 'Món Việt', 'Món phụ']);
      final pho = (await b.db.select(b.db.recipes).get()).firstWhere(
        (r) => r.name.startsWith('Phở'),
      );
      final detail = (await b.recipes.getRecipe(pho.id))!;
      final viet = cats.firstWhere((c) => c.name == 'Món Việt');
      expect(detail.draft.categoryIds, [viet.id]);
    });
  });

  test('định dạng không phụ thuộc phiên bản cơ sở dữ liệu: data.json là JSON thuần', () async {
    await seed();
    final archive = ZipDecoder().decodeBytes(
      (await backup()).readAsBytesSync(),
    );
    final data = jsonDecode(
      utf8.decode(archive.findFile('data.json')!.readBytes()!),
    ) as Map<String, Object?>;
    expect(data.keys, containsAll(['recipes', 'categories']));
    final r = (data['recipes'] as List).cast<Map<String, Object?>>().firstWhere(
      (m) => (m['name'] as String).startsWith('Phở'),
    );
    expect(r['ingredients'], [
      {'text': 'Nước dùng', 'heading': true},
      {'text': '2 kg xương bò', 'heading': false},
    ]);
    expect(r['tags'], ['bò', 'Nước dùng']);
    expect((r['photos'] as List).length, 2);
    expect(r['cooked'], hasLength(1));
  });
}
