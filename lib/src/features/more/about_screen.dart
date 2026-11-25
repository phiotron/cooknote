import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../ui/ui.dart';

/// SCR-55 (AC-63, AC-65): tên app, phiên bản, lời hứa riêng tư, liên hệ và
/// giấy phép nguồn mở.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const contactEmail = 'phamphuongphuongnd@gmail.com';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(l.appTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  l.aboutVersion(_prettyVersion(version)),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.aboutTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.aboutPrivacy),
            onTap: () => showMessage(l.aboutPrivacySoon),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l.aboutContact),
            subtitle: const Text(contactEmail),
            onTap: () async {
              await Clipboard.setData(const ClipboardData(text: contactEmail));
              if (!context.mounted) return;
              showMessage(l.aboutEmailCopied);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l.aboutLicenses),
            onTap: () => context.push('/licenses'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              l.aboutRights,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `1.0.0+1` → `1.0.0 (1)`; giữ nguyên nếu không có dấu `+`.
  String _prettyVersion(String raw) {
    final parts = raw.split('+');
    if (parts.length == 2 && parts[1].isNotEmpty) {
      return '${parts[0]} (${parts[1]})';
    }
    return raw;
  }
}
