import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../ui/recipe_photo.dart';

/// Màn chính với 5 mục điều hướng dưới (AC-01).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tabs = [
      (Icons.menu_book_outlined, Icons.menu_book, l.tabRecipes),
      (Icons.calendar_month_outlined, Icons.calendar_month, l.tabMenu),
      (Icons.shopping_cart_outlined, Icons.shopping_cart, l.tabShopping),
      (Icons.kitchen_outlined, Icons.kitchen, l.tabPantry),
      (Icons.more_horiz, Icons.more_horiz, l.tabMore),
    ];
    final body = switch (_index) {
      0 => const _RecipeList(),
      4 => const _MoreTab(),
      _ => _ComingSoon(title: tabs[_index].$3),
    };
    return Scaffold(
      appBar: AppBar(title: Text(tabs[_index].$3)),
      body: body,
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              tooltip: l.addRecipe,
              onPressed: () => _showAddSheet(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: Icon(t.$1),
              selectedIcon: Icon(t.$2),
              label: t.$3,
            ),
        ],
      ),
    );
  }

  /// Bảng chọn cách thêm công thức; chỉ "Tự viết" có ở G1 (AC-01).
  void _showAddSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.addManual),
              onTap: () {
                Navigator.pop(sheet);
                context.push('/recipe/new');
              },
            ),
            for (final (icon, label) in [
              (Icons.language, l.fromWeb),
              (Icons.document_scanner_outlined, l.scanPhoto),
              (Icons.file_open_outlined, l.importFile),
            ])
              ListTile(
                enabled: false,
                leading: Icon(icon),
                title: Text(label),
                subtitle: Text(l.comingSoon),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecipeList extends ConsumerWidget {
  const _RecipeList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final recipes = ref.watch(recipesProvider);
    return recipes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    l.noRecipes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(l.noRecipesHint, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final r = list[i];
            return ListTile(
              minTileHeight: 72,
              leading: SizedBox(
                width: 56,
                height: 56,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: RecipePhoto(r.coverPhoto, cacheWidth: 200),
                ),
              ),
              title: Text(r.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: r.totalMinutes == null
                  ? null
                  : Text(l.minutesShort(r.totalMinutes!)),
              trailing: r.favorite
                  ? const Icon(Icons.favorite, color: Colors.redAccent)
                  : null,
              onTap: () => context.push('/recipe/${r.id}'),
            );
          },
        );
      },
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(AppLocalizations.of(context).comingSoon));
}

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text(l.trash),
          onTap: () => context.push('/trash'),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l.settings),
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }
}
