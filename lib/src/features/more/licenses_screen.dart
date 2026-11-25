import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../ui/ui.dart';

/// SCR-56 (AC-63): danh sách giấy phép của app và các gói nguồn mở; nút mở
/// trang giấy phép đầy đủ của Flutter (chỉ dùng token, không đổi màu).
class LicensesScreen extends ConsumerWidget {
  const LicensesScreen({super.key});

  static const _packages = <({String name, String license})>[
    (name: 'Lora', license: 'OFL-1.1 · font'),
    (name: 'Noto Sans', license: 'OFL-1.1 · font'),
    (name: 'Material Symbols Rounded', license: 'Apache-2.0 · icons'),
    (name: 'drift', license: 'MIT · 1 licence'),
    (name: 'flutter_tts', license: 'MIT · 1 licence'),
    (name: 'go_router', license: 'BSD-3-Clause · 1 licence'),
    (name: 'pdf', license: 'Apache-2.0 · 1 licence'),
    (name: 'printing', license: 'Apache-2.0 · 1 licence'),
    (name: 'tesseract (eng, vie data)', license: 'Apache-2.0 · 2 licences'),
    (name: 'webview_flutter', license: 'BSD-3-Clause · 1 licence'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.licensesTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.appTitle, style: theme.textTheme.titleLarge),
                Text(
                  version,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          for (final p in _packages)
            ListTile(
              dense: true,
              title: Text(p.name),
              subtitle: Text(p.license),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: BepButton(
              block: true,
              kind: BepButtonKind.outlined,
              label: l.licensesViewAll,
              icon: Icons.article_outlined,
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l.appTitle,
                applicationVersion: version,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
