import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Số 0..7 ổn định từ [seed] (tên công thức/danh mục) để chọn màu ô ảnh thay thế.
int placeholderIndex(String seed) {
  var h = 0;
  for (final c in seed.runes) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h % 8;
}

/// Chữ cái đầu để hiện lớn trên ô thay thế (bỏ ký tự không phải chữ/số đầu chuỗi).
String placeholderInitial(String title) {
  for (final r in title.trim().runes) {
    final ch = String.fromCharCode(r);
    if (RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(ch)) {
      return ch.toUpperCase();
    }
  }
  return '•';
}

/// Ô thay thế cho công thức chưa có ảnh: thẻ index-card (dòng kẻ, lề đỏ, chữ cái đầu,
/// tên danh mục) với 1 trong 8 màu nền (§2.2). Trang trí: ẩn khỏi trình đọc màn hình.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.title,
    this.categoryLabel,
    this.seed,
  });

  final String title;

  /// Tên danh mục in nhỏ dưới chữ cái đầu (có thể null).
  final String? categoryLabel;

  /// Quyết định màu nền; mặc định dùng [title].
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final b = context.bep;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = b.photoPlaceholders[placeholderIndex(seed ?? title)];
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, box) {
          final h = box.hasBoundedHeight ? box.maxHeight : 120.0;
          final big = (h * 0.42).clamp(20.0, 64.0);
          return CustomPaint(
            painter: _IndexCardPainter(bg: bg, dark: dark),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    placeholderInitial(title),
                    style: TextStyle(
                      fontFamily: kSerifFamily,
                      fontFamilyFallback: const [kSansFamily],
                      fontWeight: FontWeight.w600,
                      fontSize: big,
                      height: 1,
                      color: b.onPhotoPlaceholder,
                    ),
                  ),
                  if (categoryLabel != null && h >= 96)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        categoryLabel!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                          color: b.onPhotoPlaceholder,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IndexCardPainter extends CustomPainter {
  _IndexCardPainter({required this.bg, required this.dark});

  final Color bg;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    final rule = Paint()
      ..strokeWidth = 1
      ..color = dark
          ? const Color(0xFFFFF0DC).withValues(alpha: .08)
          : const Color(0xFF3C2814).withValues(alpha: .13);
    for (var y = 17.0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }
    canvas.drawRect(
      Rect.fromLTWH(18, 0, 1.5, size.height),
      Paint()..color = const Color(0xFFB0261B).withValues(alpha: .35),
    );
  }

  @override
  bool shouldRepaint(_IndexCardPainter old) => old.bg != bg || old.dark != dark;
}

/// Lớp phủ tối dần ở đáy ảnh để chữ đặt trên ảnh luôn đọc được (tương phản ≥ 4.5:1).
/// Xếp trong một [Stack] ngay trên ảnh và dưới chữ.
class PhotoScrim extends StatelessWidget {
  const PhotoScrim({super.key, this.height = 96, this.strength = .62});

  final double height;
  final double strength;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    height: height,
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: strength),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Khung ảnh: [photo] (ảnh thật hoặc [PhotoPlaceholder]) + scrim đáy + [overlay]
/// (chữ trắng ở góc dưới). Tỷ lệ mặc định 4:3, bo góc [radius].
class PhotoFrame extends StatelessWidget {
  const PhotoFrame({
    super.key,
    required this.photo,
    this.overlay,
    this.aspectRatio = 4 / 3,
    this.radius = 0,
    this.showScrim = true,
  });

  final Widget photo;
  final Widget? overlay;
  final double aspectRatio;
  final double radius;
  final bool showScrim;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          photo,
          if (overlay != null && showScrim) const PhotoScrim(),
          if (overlay != null)
            Positioned(left: 12, right: 12, bottom: 10, child: overlay!),
        ],
      ),
    ),
  );
}

/// Dải đánh dấu (ribbon bookmark) cho công thức ghim/yêu thích — chỉ là hình;
/// ngữ nghĩa phải do chỗ dùng cung cấp bằng chữ ("Yêu thích").
class RibbonBookmark extends StatelessWidget {
  const RibbonBookmark({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(size * 2 / 3, size),
      painter: _RibbonPainter(context.bep.ribbon),
      child: SizedBox(
        width: size * 2 / 3,
        height: size,
        child: Align(
          alignment: const Alignment(0, -.6),
          child: Icon(Icons.favorite, size: size * .4, color: Colors.white),
        ),
      ),
    ),
  );
}

class _RibbonPainter extends CustomPainter {
  _RibbonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width, 0)
      ..lineTo(s.width, s.height)
      ..lineTo(s.width / 2, s.height * .76)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => old.color != color;
}
