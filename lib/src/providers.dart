import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/category_repository.dart';
import 'data/database.dart';
import 'data/image_store.dart';
import 'data/recipe_query.dart';
import 'data/recipe_repository.dart';
import 'data/settings_repository.dart';
import 'features/editor/photo_picker.dart';

/// Cơ sở dữ liệu của app; test ghi đè bằng cơ sở dữ liệu trong bộ nhớ.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Hôm nay; test ghi đè để cố định ngày.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Thư mục ảnh trong bộ nhớ riêng của app. `main()` xác định đường dẫn rồi ghi
/// đè; test ghi đè bằng thư mục tạm.
final imageStoreProvider = Provider<ImageStore>(
  (ref) => throw UnimplementedError('imageStoreProvider chưa được ghi đè'),
);

final photoPickerProvider = Provider<PhotoPicker>((ref) => SystemPhotoPicker());

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepository(
    ref.watch(databaseProvider),
    ref.watch(imageStoreProvider),
    clock: ref.watch(clockProvider),
  ),
);

final themeModeProvider = StreamProvider<ThemeMode>(
  (ref) => ref.watch(settingsRepositoryProvider).watchThemeMode(),
);

final localeCodeProvider = StreamProvider<String?>(
  (ref) => ref.watch(settingsRepositoryProvider).watchLocaleCode(),
);

/// Ô tìm, bộ lọc và cách sắp xếp đang dùng ở danh sách công thức (AC-12, AC-13).
class RecipeQueryNotifier extends Notifier<RecipeQuery> {
  @override
  RecipeQuery build() => const RecipeQuery();

  void set(RecipeQuery query) => state = query;
}

final recipeQueryProvider = NotifierProvider<RecipeQueryNotifier, RecipeQuery>(
  RecipeQueryNotifier.new,
);

final recipesProvider = StreamProvider<List<RecipeSummary>>(
  (ref) => ref
      .watch(recipeRepositoryProvider)
      .watchRecipes(query: ref.watch(recipeQueryProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(databaseProvider)),
);

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// Cách xem danh sách: `list` hoặc `grid`, được giữ sau khi tắt app (AC-14).
final viewModeProvider = StreamProvider<String>(
  (ref) => ref.watch(settingsRepositoryProvider).watchViewMode(),
);

/// Thẻ đang dùng, tính lại mỗi lần mở màn cần tới nó (AC-11).
final tagsProvider = FutureProvider.autoDispose<List<TagCount>>(
  (ref) => ref.watch(recipeRepositoryProvider).allTags(),
);

/// Ngôn ngữ của máy, ví dụ `vi`; test ghi đè.
final deviceLanguageProvider = Provider<String>(
  (ref) => WidgetsBinding.instance.platformDispatcher.locale.languageCode,
);

final trashProvider = StreamProvider<List<RecipeSummary>>(
  (ref) => ref.watch(recipeRepositoryProvider).watchTrash(),
);

final recipeProvider = StreamProvider.family<RecipeDetail?, int>(
  (ref, id) => ref.watch(recipeRepositoryProvider).watchRecipe(id),
);

/// Việc chạy một lần khi mở app: xóa hẳn công thức quá 30 ngày trong thùng
/// rác (AC-05) và dọn ảnh không còn công thức nào dùng (AC-07).
final startupProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(recipeRepositoryProvider);
  final settings = ref.read(settingsRepositoryProvider);
  final saved = await settings.readLocaleCode();
  final String language = saved ?? ref.read(deviceLanguageProvider);
  await ref.read(categoryRepositoryProvider).seedDefaults(language);
  await repo.purgeTrash();
  await ref.read(imageStoreProvider).sweep(await repo.referencedPhotos());
});
