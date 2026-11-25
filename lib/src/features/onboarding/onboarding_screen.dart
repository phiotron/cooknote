import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../ui/ui.dart';

/// SCR-01 (AC-59): ba trang giới thiệu ngắn, Bỏ qua luôn ở đầu thứ tự tiêu
/// điểm, không xin quyền nào. Trang cuối mời bật sao lưu tự động.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // Đã hiện một lần là đủ: thoát giữa chừng cũng không hiện lại (AC-59).
    ref.read(settingsRepositoryProvider).markOnboardingSeen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.go('/');

  void _next() {
    if (_page >= 2) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pages = <({String title, String body, BepIllo illo})>[
      (
        title: l.onboardingTitle1,
        body: l.onboardingBody1,
        illo: BepIllo.collect,
      ),
      (
        title: l.onboardingTitle2,
        body: l.onboardingBody2,
        illo: BepIllo.kitchen,
      ),
      (title: l.onboardingTitle3, body: l.onboardingBody3, illo: BepIllo.keep),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Semantics(
                  sortKey: const OrdinalSortKey(0),
                  child: TextButton(onPressed: _finish, child: Text(l.skip)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BepIllustration(page.illo, width: 240),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: BepMotion.of(context),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BepRadius.circular(BepRadius.full),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  if (_page == 2) ...[
                    BepButton(
                      block: true,
                      label: l.onboardingBackup,
                      icon: Icons.backup_outlined,
                      onPressed: () => context.push('/backup'),
                    ),
                    const SizedBox(height: 8),
                    BepButton(
                      block: true,
                      label: l.later,
                      kind: BepButtonKind.text,
                      onPressed: _finish,
                    ),
                  ] else
                    BepButton(block: true, label: l.next, onPressed: _next),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
