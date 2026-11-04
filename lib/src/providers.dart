import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'data/image_store.dart';
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

final recipesProvider = StreamProvider<List<RecipeSummary>>(
  (ref) => ref.watch(recipeRepositoryProvider).watchRecipes(),
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
  await repo.purgeTrash();
  await ref.read(imageStoreProvider).sweep(await repo.referencedPhotos());
});
