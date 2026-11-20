import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_repository.dart';
import '../../ui/theme/theme.dart';
import '../../web_import/browser_input.dart';

/// Màn nhận nội dung chia sẻ từ app khác (SCR-18, AC-17).
///
/// Có URL: mở thẳng trình duyệt trong app. Chỉ có chữ: mở trình soạn với chữ
/// đó trong Ghi chú để người dùng gán vào nguyên liệu/bước.
class ShareInScreen extends StatelessWidget {
  const ShareInScreen({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final raw = (text ?? '').trim();
    final url = raw.isEmpty ? null : firstUrlIn(raw);
    return Scaffold(
      appBar: AppBar(title: Text(l.shareInTitle)),
      body: raw.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.shareInEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l.shareInIntro, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BepRadius.circular(BepRadius.md),
                  ),
                  child: Text(raw, style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 20),
                if (url != null) ...[
                  FilledButton.icon(
                    onPressed: () => context.push(
                      '/web?url=${Uri.encodeQueryComponent(url)}',
                    ),
                    icon: const Icon(Icons.public),
                    label: Text(l.shareInUrl),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/recipe/new',
                    extra: RecipeDraft(name: '', notes: raw),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l.shareInText),
                ),
              ],
            ),
    );
  }
}
