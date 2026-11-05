import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import 'recipe_list.dart';

/// Gốc tab "Công thức" (SCR-02, AC-01). Thanh dưới 5 mục nay do khung ứng dụng
/// (lib/src/ui/app_shell.dart) dựng; màn này chỉ còn danh sách + nút "+".
/// G1 làm lại theo mockup (giữ tên lớp [HomeScreen] và route `/`).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.tabRecipes)),
      body: const RecipeListTab(),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addRecipe,
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Bảng chọn cách thêm công thức (SCR-03, AC-01).
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
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: Text(l.scanPhoto),
              onTap: () {
                Navigator.pop(sheet);
                context.push('/scan');
              },
            ),
          ],
        ),
      ),
    );
  }
}
