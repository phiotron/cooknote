import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'aisle_repository.dart';
import 'meal_plan_repository.dart';
import 'pantry_repository.dart';
import 'shopping_repository.dart';
import 'v3_defaults.dart';

/// Provider cho dữ liệu phiên bản 3: Đi chợ (F-07), Lịch thực đơn (F-08),
/// Tủ bếp (F-09) và cài đặt đi kèm (AC-58). Tách riêng khỏi `providers.dart`
/// để không đụng file chung; dùng chung `databaseProvider`, `clockProvider`,
/// `settingsRepositoryProvider`, `deviceLanguageProvider` từ đó.

// ------------------------------------------------------------------- kho

final aisleRepositoryProvider = Provider<AisleRepository>(
  (ref) => AisleRepository(ref.watch(databaseProvider)),
);

final pantryRepositoryProvider = Provider<PantryRepository>(
  (ref) => PantryRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    aisles: ref.watch(aisleRepositoryProvider),
  ),
);

final shoppingRepositoryProvider = Provider<ShoppingRepository>(
  (ref) => ShoppingRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    aisles: ref.watch(aisleRepositoryProvider),
    pantry: ref.watch(pantryRepositoryProvider),
  ),
);

final mealPlanRepositoryProvider = Provider<MealPlanRepository>(
  (ref) => MealPlanRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    pantry: ref.watch(pantryRepositoryProvider),
  ),
);

/// Tạo khu vực, bữa, danh sách đi chợ mặc định theo ngôn ngữ ở lần đầu.
/// Màn Đi chợ, Thực đơn, Tủ bếp chờ provider này trước khi đọc dữ liệu (hoặc
/// thêm một dòng `await ref.read(v3StartupProvider.future)` vào
/// `startupProvider`).
final v3StartupProvider = FutureProvider<void>((ref) async {
  final saved = await ref.read(settingsRepositoryProvider).readLocaleCode();
  await seedV3Defaults(
    ref.read(databaseProvider),
    saved ?? ref.read(deviceLanguageProvider),
    clock: ref.read(clockProvider),
  );
});

// --------------------------------------------------------------- cài đặt

/// Ngày đầu tuần: `DateTime.monday` (mặc định), `saturday` hoặc `sunday`.
final weekStartProvider = StreamProvider<int>(
  (ref) => ref.watch(settingsRepositoryProvider).watchWeekStart(),
);

/// Hệ đơn vị mặc định: `metric` hoặc `us` (AC-58).
final unitSystemProvider = StreamProvider<String>(
  (ref) => ref.watch(settingsRepositoryProvider).watchUnitSystem(),
);

/// "Gia vị cơ bản không tính là thiếu" (AC-43).
final ignoreBasicsProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchIgnoreBasics(),
);

/// Lựa chọn lần trước của "chuyển món đã mua vào Tủ bếp" (AC-37).
final shoppingToPantryProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchShoppingToPantry(),
);

// ---------------------------------------------------------------- đi chợ

final aislesProvider = StreamProvider<List<Aisle>>(
  (ref) => ref.watch(aisleRepositoryProvider).watchAll(),
);

final shoppingListsProvider = StreamProvider<List<ShoppingListInfo>>(
  (ref) => ref.watch(shoppingRepositoryProvider).watchLists(),
);

/// Món của một danh sách, đã xếp (chưa gạch theo khu vực, đã gạch ở cuối).
final shoppingItemsProvider = StreamProvider.family<List<ShoppingItem>, int>(
  (ref, listId) => ref.watch(shoppingRepositoryProvider).watchItems(listId),
);

/// "Món hay mua": món đã ghim rồi món mua nhiều (AC-34).
final frequentItemsProvider = StreamProvider<List<KnownItem>>(
  (ref) => ref.watch(shoppingRepositoryProvider).watchFrequent(),
);

// ---------------------------------------------------------------- tủ bếp

final pantryItemsProvider =
    StreamProvider.family<List<PantryItem>, PantryFilter>(
      (ref, filter) =>
          ref.watch(pantryRepositoryProvider).watchItems(filter: filter),
    );

/// Số món sắp hết hạn và đã hết hạn (nhãn bộ lọc, AC-42).
final pantryExpiryCountsProvider = StreamProvider<({int soon, int expired})>(
  (ref) => ref.watch(pantryRepositoryProvider).watchExpiryCounts(),
);

/// "Nấu được gì?" theo cài đặt gia vị cơ bản (AC-43).
final cookableProvider = StreamProvider<List<CookableRecipe>>((ref) {
  final ignore = ref.watch(ignoreBasicsProvider).value ?? false;
  return ref
      .watch(pantryRepositoryProvider)
      .watchCookable(ignoreBasics: ignore);
});

// --------------------------------------------------------------- thực đơn

final mealSlotsProvider = StreamProvider<List<MealSlot>>(
  (ref) => ref.watch(mealPlanRepositoryProvider).watchSlots(),
);

/// Các món trong khoảng ngày (tính cả hai đầu); khóa là bản ghi
/// `(from: ..., to: ...)` lúc 00:00.
final mealPlanRangeProvider =
    StreamProvider.family<List<PlanEntry>, ({DateTime from, DateTime to})>(
      (ref, range) => ref
          .watch(mealPlanRepositoryProvider)
          .watchRange(range.from, range.to),
    );

final menuTemplatesProvider = StreamProvider<List<MenuTemplateInfo>>(
  (ref) => ref.watch(mealPlanRepositoryProvider).watchTemplates(),
);
