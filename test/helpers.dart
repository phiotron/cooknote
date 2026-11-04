import 'dart:io';

import 'package:cooknote/src/app.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/settings_repository.dart';
import 'package:cooknote/src/features/editor/photo_picker.dart';
import 'package:cooknote/src/providers.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

export 'fixtures.dart';

/// Ngày cố định cho test.
final testNow = DateTime(2026, 11, 3, 9);

/// Cơ sở dữ liệu trong bộ nhớ cho widget test. Phải tạo bên trong thân
/// `testWidgets`; tạo ở `setUp` thì thao tác đầu tiên bị treo.
AppDatabase memoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Chờ thao tác cơ sở dữ liệu và file thật xong rồi vẽ lại.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }
}

/// Trình chọn ảnh giả: trả về các file đã chuẩn bị sẵn.
class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker(this.directory);

  final Directory directory;
  int galleryCalls = 0;
  int cameraCalls = 0;
  int? lastLimit;

  String _make(String name) {
    final f = File('${directory.path}/$name')
      ..writeAsBytesSync(jpegBytes(64, 48));
    return f.path;
  }

  @override
  Future<List<String>> pickFromGallery({required int limit}) async {
    galleryCalls++;
    lastLimit = limit;
    return [
      _make('g${galleryCalls}a.jpg'),
      _make('g${galleryCalls}b.jpg'),
    ].take(limit).toList();
  }

  @override
  Future<String?> takePhoto() async {
    cameraCalls++;
    return _make('c$cameraCalls.jpg');
  }
}

/// ImageStore ghi lại các ảnh được yêu cầu xóa. Trên Windows, ảnh đang hiện
/// trong cây widget bị khóa nên không kiểm bằng sự có mặt của file được.
class RecordingImageStore extends ImageStore {
  RecordingImageStore(super.directory);

  final deleted = <String>[];

  @override
  Future<void> delete(String name) {
    deleted.add(name);
    return super.delete(name);
  }
}

/// Môi trường app cho widget test.
class TestApp {
  TestApp(this.db, this.images, this.picker);

  final AppDatabase db;
  final RecordingImageStore images;
  final FakePhotoPicker picker;
}

/// Mở app với cơ sở dữ liệu mới, tiếng Việt, thư mục ảnh tạm.
Future<TestApp> pumpApp(
  WidgetTester tester, {
  String? localeCode = 'vi',
  AppDatabase? db,
  DateTime Function()? clock,
  List overrides = const [],
}) async {
  usePhoneScreen(tester);
  final database = db ?? memoryDatabase();
  final temp = (await tester.runAsync(
    () => Directory.systemTemp.createTemp('cooknote_w_'),
  ))!;
  addTearDown(() {
    // Windows có thể còn giữ file ảnh đang mở; bỏ qua lỗi dọn thư mục tạm.
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException {
      // Không ảnh hưởng kết quả test.
    }
  });
  final images = RecordingImageStore(Directory('${temp.path}/photos'));
  final picker = FakePhotoPicker(temp);
  await tester.runAsync(
    () => SettingsRepository(database).setLocaleCode(localeCode),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        imageStoreProvider.overrideWithValue(images),
        photoPickerProvider.overrideWithValue(picker),
        appDirsProvider.overrideWithValue(
          AppDirs(
            temp: Directory('${temp.path}/tmp'),
            safety: Directory('${temp.path}/safety'),
          ),
        ),
        clockProvider.overrideWithValue(clock ?? () => testNow),
        ...overrides.cast(),
      ],
      child: CookNoteApp(router: createRouter()),
    ),
  );
  await settle(tester);
  return TestApp(database, images, picker);
}

/// Màn hình dọc 360×800 dp, bề rộng nhỏ nhất SPEC hỗ trợ (mục 5).
void usePhoneScreen(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Gỡ cây widget và đóng cơ sở dữ liệu để không còn stream treo khi test kết thúc.
Future<void> disposeApp(WidgetTester tester, TestApp app) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(app.db.close);
}

/// Chờ tới khi [condition] đúng, tối đa [seconds] giây; việc thật chạy ở
/// isolate khác nên phải nhường cho vòng lặp sự kiện thật.
Future<void> waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  int seconds = 30,
}) async {
  for (var i = 0; i < seconds * 100 && !condition(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    // Phải tiến thời gian giả: Future.delayed trong mã chỉ chạy khi thời gian tiến.
    await tester.pump(const Duration(milliseconds: 10));
  }
  await tester.pumpAndSettle();
}

/// Nút Back của hệ điều hành (qua PopScope), khác nút Back trên thanh tiêu đề.
Future<void> systemBack(WidgetTester tester) async {
  await tester.pump();
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
