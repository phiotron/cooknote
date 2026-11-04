import 'dart:io';

import 'package:cooknote/src/backup/backup_settings.dart';
import 'package:cooknote/src/backup/backup_target.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:cooknote/src/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

RecipeRepository _repo(TestApp app) =>
    RecipeRepository(app.db, app.images, clock: () => testNow);

/// Lưu từng công thức rồi chờ giao diện: nhiều lần ghi liền nhau trong một
/// `runAsync` bị treo vì các luồng truy vấn của widget chỉ chạy khi `pump`.
Future<void> _addRecipes(WidgetTester tester, TestApp app, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.runAsync(
      () => _repo(app).save(
        RecipeDraft(name: 'Món ${DateTime.now().microsecondsSinceEpoch}$i'),
      ),
    );
    await settle(tester);
  }
}

/// Cơ sở dữ liệu đã có sẵn dữ liệu, tạo TRƯỚC khi dựng app (chưa có luồng nào
/// theo dõi nên ghi nhiều lần liền nhau không bị treo).
Future<AppDatabase> _prepared(
  WidgetTester tester,
  Future<void> Function(AppDatabase db) fill,
) async {
  final db = memoryDatabase();
  await tester.runAsync(() => fill(db));
  return db;
}

Future<void> _openBackup(WidgetTester tester) async {
  await tester.tap(find.text('Thêm').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sao lưu'));
  await settle(tester);
}

void main() {
  testWidgets(
    'đủ 10 công thức thì gợi ý bật sao lưu, bấm mở màn Sao lưu (AC-53)',
    (tester) async {
      final app = await pumpApp(tester);
      await _addRecipes(tester, app, 9);
      expect(find.textContaining('Bạn đã có'), findsNothing);

      await _addRecipes(tester, app, 1);
      expect(find.textContaining('Bạn đã có 10 công thức'), findsOneWidget);

      await tester.tap(find.text('Mở Sao lưu'));
      await settle(tester);
      expect(find.text('Chưa có lần sao lưu thành công nào'), findsOneWidget);
      expect(find.text('Chọn thư mục sao lưu tự động'), findsOneWidget);
      // Cuối màn: nói rõ file không mã hóa và lớp sao lưu của Android (AC-56).
      await tester.scrollUntilVisible(
        find.textContaining('KHÔNG được mã hóa'),
        300,
      );
      expect(find.textContaining('KHÔNG được mã hóa'), findsOneWidget);
      expect(find.textContaining('sao lưu của Android'), findsOneWidget);
      await disposeApp(tester, app);
    },
  );

  testWidgets(
    'lỗi nơi lưu hiện cảnh báo trên màn Công thức và màn Sao lưu (AC-51)',
    (tester) async {
      final db = await _prepared(tester, (db) async {
        final s = BackupSettingsRepository(db);
        await s.setTarget('content://tree/x', 'Drive');
        await s.recordError('target|mất quyền');
      });
      final app = await pumpApp(tester, db: db);
      expect(
        find.text('Sao lưu tự động đang lỗi. Mở để xem và chọn lại thư mục.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Mở Sao lưu'));
      await settle(tester);
      expect(
        find.textContaining('Không ghi được vào thư mục sao lưu'),
        findsWidgets,
      );
      await disposeApp(tester, app);
    },
  );

  testWidgets('sao lưu vào thư mục rồi khôi phục từ danh sách (AC-50, AC-54)', (
    tester,
  ) async {
    final dest = Directory.systemTemp.createTempSync('cooknote_ui_dest_');
    addTearDown(() {
      try {
        dest.deleteSync(recursive: true);
      } on FileSystemException {
        // Không ảnh hưởng kết quả.
      }
    });
    final db = await _prepared(tester, (db) async {
      await BackupSettingsRepository(db)
          .setTarget('content://tree/1', 'Thư mục thử');
      final repo = RecipeRepository(
        db,
        ImageStore(Directory('${dest.path}/unused')),
        clock: () => testNow,
      );
      // Vừa kiểm xong: lần mở app không tự sao lưu chen vào trước nút bấm.
      await BackupSettingsRepository(db).recordUnchanged(testNow);
      await repo.save(const RecipeDraft(name: 'Phở bò'));
      await repo.save(const RecipeDraft(name: 'Bánh flan'));
    });
    final app = await pumpApp(
      tester,
      db: db,
      overrides: [
        backupTargetFactoryProvider.overrideWithValue(
          (c) => c.treeUri == null ? null : LocalDirTarget(dest),
        ),
      ],
    );

    await _openBackup(tester);
    expect(find.text('Thư mục: Thư mục thử'), findsOneWidget);

    await tester.ensureVisible(find.text('Sao lưu vào thư mục ngay'));
    await tester.tap(find.text('Sao lưu vào thư mục ngay'));
    await tester.pump();
    await waitUntil(
      tester,
      () => find.textContaining('Đã sao lưu (').evaluate().isNotEmpty,
    );
    expect(find.textContaining('Đã sao lưu ('), findsOneWidget);
    expect(
      dest.listSync().where((e) => isOwnBackupName(e.uri.pathSegments.last)),
      hasLength(1),
    );

    // Xóa dữ liệu rồi khôi phục từ bản vừa ghi (thay thế toàn bộ).
    await tester.runAsync(() => app.db.delete(app.db.recipes).go());
    await settle(tester);
    // Chờ bản ghi trong danh sách thư mục xuất hiện.
    await waitUntil(
      tester,
      () => find.textContaining('CookNote-').evaluate().isNotEmpty,
    );
    final entry = find.textContaining('CookNote-');
    await tester.scrollUntilVisible(entry, 200);
    await tester.tap(entry);
    await waitUntil(
      tester,
      () => find.text('Khôi phục theo cách nào?').evaluate().isNotEmpty,
    );
    expect(find.text('Khôi phục theo cách nào?'), findsOneWidget);
    expect(find.textContaining('2 công thức'), findsOneWidget);
    await tester.tap(find.text('Thay thế toàn bộ'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Khôi phục'));
    await waitUntil(
      tester,
      () => find.textContaining('Đã khôi phục').evaluate().isNotEmpty,
    );
    expect(find.textContaining('Đã khôi phục: thêm 2'), findsOneWidget);

    final restored = await tester.runAsync(
      () => app.db.select(app.db.recipes).get(),
    );
    expect(restored!.length, 2);
    await disposeApp(tester, app);
  });
}
