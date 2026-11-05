import 'package:flutter/material.dart';

/// Khoảng cách (lưới 4/8) — tokens `space1..space12` → `s1..s12`.
abstract final class BepSpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;

  /// Lề ngang chuẩn của màn (mockup dùng 16).
  static const double gutter = 16;
}

/// Bo góc — tokens `radiusXs..radiusFull` → `xs..full`.
abstract final class BepRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static BorderRadius circular(double r) => BorderRadius.circular(r);
}

/// Vùng chạm tối thiểu (AC-60, S-50): `tapMin` 48 dp, `tapIos` 44 pt, `tapCook` 64 dp.
abstract final class BepTap {
  static const double min = 48;
  static const double ios = 44;
  static const double cook = 64;
}

/// Chuyển động 150–250 ms; reduce-motion thì tức thì (không trượt, không nhấp nháy).
abstract final class BepMotion {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration long = Duration(milliseconds: 250);
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  /// [d] hoặc 0 khi người dùng bật "giảm chuyển động".
  static Duration of(BuildContext context, [Duration d = medium]) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}
