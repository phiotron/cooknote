import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme/theme.dart';

part 'illustrations.g.dart';

enum _Role { ink, accent, herb, turmeric }

/// Bảng màu minh hoạ theo chủ đề: nét = onSurfaceVariant, nhấn = primary,
/// rau = secondary, nghệ = tertiary (sáng và tối đều đủ tương phản 3:1 với nền).
class _Palette {
  _Palette(this.scheme);

  final ColorScheme scheme;

  Color color(_Role r) => switch (r) {
    _Role.ink => scheme.onSurfaceVariant,
    _Role.accent => scheme.primary,
    _Role.herb => scheme.secondary,
    _Role.turmeric => scheme.tertiary,
  };

  Paint stroke(_Role r, double width, {double opacity = 1}) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color(r).withValues(alpha: opacity);

  Paint fill(_Role r, {double opacity = 1}) => Paint()
    ..style = PaintingStyle.fill
    ..color = color(r).withValues(alpha: opacity);
}

void _dashed(Canvas c, Path path, Paint paint, double on, double off) {
  for (final m in path.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      c.drawPath(m.extractPath(d, math.min(d + on, m.length)), paint);
      d += on + off;
    }
  }
}

void _text(
  Canvas c,
  String s,
  double x,
  double y,
  _Role role,
  _Palette pal,
  double size,
) {
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
        fontFamily: kSansFamily,
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: pal.color(role),
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();
  // SVG đặt y ở đường cơ sở.
  tp.paint(
    c,
    Offset(x, y - tp.computeDistanceToActualBaseline(TextBaseline.alphabetic)),
  );
}

/// Minh hoạ nét đường của mockup (trạng thái rỗng, màn chào). Vẽ bằng Canvas, màu theo
/// chủ đề; không cần flutter_svg. Trang trí thuần: ẩn khỏi trình đọc màn hình
/// (nội dung nghĩa nằm ở tiêu đề kế bên) trừ khi truyền [semanticLabel].
class BepIllustration extends StatelessWidget {
  const BepIllustration(
    this.which, {
    super.key,
    this.width = 220,
    this.semanticLabel,
  });

  final BepIllo which;
  final double width;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final size = bepIlloSize(which);
    final pal = _Palette(Theme.of(context).colorScheme);
    final w = CustomPaint(
      size: Size(width, width * size.height / size.width),
      painter: _IlloPainter(which, pal),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: w);
    return Semantics(label: semanticLabel, image: true, child: w);
  }
}

class _IlloPainter extends CustomPainter {
  _IlloPainter(this.which, this.pal);

  final BepIllo which;
  final _Palette pal;

  @override
  void paint(Canvas canvas, Size size) {
    final src = bepIlloSize(which);
    canvas.save();
    canvas.scale(size.width / src.width, size.height / src.height);
    _paintIllo(which, canvas, pal);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IlloPainter old) =>
      old.which != which || old.pal.scheme != pal.scheme;
}
