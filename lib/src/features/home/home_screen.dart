import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../exchange/exchange_actions.dart';
import 'recipe_list.dart';

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
      0 => const RecipeListTab(),
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
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.fromWeb),
              onTap: () {
                Navigator.pop(sheet);
                context.push('/web');
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: Text(l.importFile),
              onTap: () {
                Navigator.pop(sheet);
                context.push('/import');
              },
            ),
            for (final (icon, label) in [
              (Icons.document_scanner_outlined, l.scanPhoto),
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

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(AppLocalizations.of(context).comingSoon));
}

class _MoreTab extends ConsumerWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.file_open_outlined),
          title: Text(l.importFile),
          onTap: () => context.push('/import'),
        ),
        ListTile(
          leading: const Icon(Icons.ios_share),
          title: Text(l.exportAllJson),
          onTap: () async {
            final ids = await allRecipeIds(ref);
            if (!context.mounted) return;
            exportRecipesJson(context, ref, ids);
          },
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf_outlined),
          title: Text(l.cookbookAll),
          onTap: () async {
            final ids = await allRecipeIds(ref);
            if (!context.mounted) return;
            makeCookbook(context, ref, ids);
          },
        ),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: Text(l.backup),
          onTap: () => context.push('/backup'),
        ),
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(l.categories),
          onTap: () => context.push('/categories'),
        ),
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
