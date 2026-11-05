import 'package:drift/drift.dart';

import '../shopping/aisle_dictionary.dart';
import 'database.dart';

/// Khóa của 4 bữa mặc định, theo thứ tự (AC-38).
const defaultMealSlotKeys = ['breakfast', 'lunch', 'dinner', 'snack'];

const _slotVi = {
  'breakfast': 'Sáng',
  'lunch': 'Trưa',
  'dinner': 'Tối',
  'snack': 'Phụ',
};
const _slotEn = {
  'breakfast': 'Breakfast',
  'lunch': 'Lunch',
  'dinner': 'Dinner',
  'snack': 'Snack',
};

/// Tên bữa mặc định theo ngôn ngữ; khác `vi` dùng tiếng Anh.
String defaultMealSlotName(String key, String languageCode) =>
    (languageCode == 'vi' ? _slotVi : _slotEn)[key] ?? key;

/// Tên danh sách đi chợ đầu tiên.
String defaultShoppingListName(String languageCode) =>
    languageCode == 'vi' ? 'Đi chợ' : 'Shopping';

const _aislesSeeded = 'aislesSeeded';
const _slotsSeeded = 'mealSlotsSeeded';
const _listSeeded = 'shoppingListSeeded';

/// Tạo dữ liệu mặc định của phiên bản 3 theo ngôn ngữ ở lần đầu: 8 khu vực
/// (AC-36), 4 bữa (AC-38), một danh sách đi chợ (AC-34). Mỗi nhóm chỉ tạo
/// một lần; người dùng xóa hết rồi thì không tạo lại. Bảng đã có dữ liệu (ví
/// dụ vừa khôi phục) thì chỉ đánh dấu đã tạo. Trả về true nếu có tạo gì.
Future<bool> seedV3Defaults(
  AppDatabase db,
  String languageCode, {
  DateTime Function()? clock,
}) async {
  final done = {
    for (final s
        in await (db.select(db.settings)..where(
              (s) => s.key.isIn([_aislesSeeded, _slotsSeeded, _listSeeded]),
            ))
            .get())
      s.key,
  };
  if (done.length == 3) return false;
  var created = false;
  await db.transaction(() async {
    Future<void> mark(String key) => db
        .into(db.settings)
        .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: '1'));

    if (!done.contains(_aislesSeeded)) {
      if (await _isEmpty(db, db.aisles)) {
        for (var i = 0; i < defaultAisleKeys.length; i++) {
          final key = defaultAisleKeys[i];
          await db
              .into(db.aisles)
              .insert(
                AislesCompanion.insert(
                  key: Value(key),
                  name: defaultAisleName(key, languageCode),
                  position: Value(i),
                ),
              );
        }
        created = true;
      }
      await mark(_aislesSeeded);
    }
    if (!done.contains(_slotsSeeded)) {
      if (await _isEmpty(db, db.mealSlots)) {
        for (var i = 0; i < defaultMealSlotKeys.length; i++) {
          final key = defaultMealSlotKeys[i];
          await db
              .into(db.mealSlots)
              .insert(
                MealSlotsCompanion.insert(
                  key: Value(key),
                  name: defaultMealSlotName(key, languageCode),
                  position: Value(i),
                ),
              );
        }
        created = true;
      }
      await mark(_slotsSeeded);
    }
    if (!done.contains(_listSeeded)) {
      if (await _isEmpty(db, db.shoppingLists)) {
        await db
            .into(db.shoppingLists)
            .insert(
              ShoppingListsCompanion.insert(
                name: defaultShoppingListName(languageCode),
                createdAt: (clock ?? DateTime.now)(),
              ),
            );
        created = true;
      }
      await mark(_listSeeded);
    }
  });
  return created;
}

Future<bool> _isEmpty(AppDatabase db, TableInfo<Table, dynamic> table) async {
  final count = countAll();
  final row = await (db.selectOnly(table)..addColumns([count])).getSingle();
  return (row.read(count) ?? 0) == 0;
}
