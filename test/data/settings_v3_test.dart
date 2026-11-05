import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository s;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    s = SettingsRepository(db);
  });
  tearDown(() => db.close());

  test('AC-58 ngày đầu tuần: mặc định thứ Hai, chọn được Bảy/CN', () async {
    expect(await s.watchWeekStart().first, DateTime.monday);
    await s.setWeekStart(DateTime.sunday);
    expect(await s.watchWeekStart().first, DateTime.sunday);
    await s.setWeekStart(DateTime.saturday);
    expect(await s.watchWeekStart().first, DateTime.saturday);
    expect(() => s.setWeekStart(DateTime.tuesday), throwsArgumentError);
  });

  test('AC-58 hệ đơn vị mặc định: mét, đổi được sang Mỹ', () async {
    expect(await s.watchUnitSystem().first, 'metric');
    await s.setUnitSystem('us');
    expect(await s.watchUnitSystem().first, 'us');
    await s.setUnitSystem('lạ');
    expect(await s.watchUnitSystem().first, 'metric');
  });

  test('AC-43, AC-37 tùy chọn gia vị cơ bản và chuyển vào tủ bếp', () async {
    expect(await s.watchIgnoreBasics().first, isFalse);
    await s.setIgnoreBasics(true);
    expect(await s.watchIgnoreBasics().first, isTrue);
    expect(await s.watchShoppingToPantry().first, isFalse);
    await s.setShoppingToPantry(true);
    expect(await s.watchShoppingToPantry().first, isTrue);
  });
}
