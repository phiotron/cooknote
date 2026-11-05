import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Màn giữ chỗ của khung F0: hiện tên màn + mã SCR + nhóm phụ trách + tham số route.
/// Nhóm G1..G6 THAY RUỘT file stub của mình bằng màn thật (giữ tên lớp + hàm khởi tạo
/// như bảng trong notes/2026-11-05-f0-design-system.md); không dùng lại [StubScreen] sau đó.
/// Chuỗi trong stub không dịch vì tạm thời.
class StubScreen extends StatelessWidget {
  const StubScreen({
    super.key,
    required this.scr,
    required this.title,
    required this.group,
    this.params = const {},
    this.showAppBar = true,
  });

  /// Ví dụ "SCR-27".
  final String scr;
  final String title;

  /// Ví dụ "G4 Đi chợ".
  final String group;
  final Map<String, Object?> params;

  /// false khi stub là gốc của một tab (khung F0 đã có thanh tiêu đề riêng).
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final body = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_rounded, size: 40, color: cs.outline),
            const SizedBox(height: 12),
            Text(scr, style: text.labelLarge!.copyWith(color: cs.primary)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: text.titleLarge),
            const SizedBox(height: 8),
            Text(
              group,
              textAlign: TextAlign.center,
              style: text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
            if (params.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                params.entries.map((e) => '${e.key}=${e.value}').join(' · '),
                textAlign: TextAlign.center,
                style: text.bodySmall!
                    .copyWith(color: cs.onSurfaceVariant)
                    .tabular,
              ),
            ],
          ],
        ),
      ),
    );
    if (!showAppBar) return body;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }
}
