import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Họ chữ khai trong pubspec.yaml: Lora (tiêu đề, tên công thức), Noto Sans (giao diện).
const String kSerifFamily = 'Lora';
const String kSansFamily = 'NotoSans';

/// Lora không có ₫ → rơi về Noto Sans.
const List<String> _serifFallback = [kSansFamily];

TextStyle _serif(double size, double line, FontWeight w, {double track = 0}) =>
    TextStyle(
      fontFamily: kSerifFamily,
      fontFamilyFallback: _serifFallback,
      fontSize: size,
      height: line / size,
      fontWeight: w,
      letterSpacing: track,
    );

TextStyle _sans(
  double size,
  double line,
  FontWeight w, {
  double track = 0,
  bool tabular = false,
}) => TextStyle(
  fontFamily: kSansFamily,
  fontSize: size,
  height: line / size,
  fontWeight: w,
  letterSpacing: track,
  fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
);

/// Thang chữ từ tokens JSON (`type`): serif cho display/headline/titleLarge,
/// sans cho phần còn lại. Màu do ThemeData gán theo ColorScheme.
TextTheme bepbookTextTheme() => TextTheme(
  displaySmall: _serif(34, 42, FontWeight.w600),
  headlineMedium: _serif(28, 36, FontWeight.w600),
  headlineSmall: _serif(24, 32, FontWeight.w600),
  titleLarge: _serif(21, 28, FontWeight.w600),
  titleMedium: _sans(16, 24, FontWeight.w600, track: 0.1),
  titleSmall: _sans(14, 20, FontWeight.w600, track: 0.1),
  bodyLarge: _sans(16, 24, FontWeight.w400, track: 0.1),
  bodyMedium: _sans(14, 21, FontWeight.w400, track: 0.15),
  bodySmall: _sans(12.5, 18, FontWeight.w400, track: 0.2),
  labelLarge: _sans(14, 20, FontWeight.w600, track: 0.1),
  labelMedium: _sans(12.5, 16, FontWeight.w600, track: 0.3),
  labelSmall: _sans(11.5, 16, FontWeight.w600, track: 0.4),
);

/// Kiểu chữ riêng Chế độ nấu và đồng hồ (tokens `cookIngredient`, `cookStep`,
/// `cookStepCurrent`, `timer`, `timerLarge`). Truy cập: `CookTextStyles.of(context)`.
/// Cỡ chữ trong app (5 bước 0.85–1.75) do màn Chế độ nấu nhân thêm bằng `scaled`.
@immutable
class CookTextStyles extends ThemeExtension<CookTextStyles> {
  const CookTextStyles({
    required this.cookIngredient,
    required this.cookStep,
    required this.cookStepCurrent,
    required this.timer,
    required this.timerLarge,
  });

  factory CookTextStyles.standard() => CookTextStyles(
    cookIngredient: _sans(22, 32, FontWeight.w400),
    cookStep: _sans(24, 34, FontWeight.w400),
    cookStepCurrent: _sans(28, 40, FontWeight.w500),
    timer: _sans(22, 28, FontWeight.w700, tabular: true),
    timerLarge: _sans(44, 52, FontWeight.w700, tabular: true),
  );

  final TextStyle cookIngredient;
  final TextStyle cookStep;
  final TextStyle cookStepCurrent;
  final TextStyle timer;
  final TextStyle timerLarge;

  /// Các bước cỡ chữ trong app (tokens `cookSizeSteps`).
  static const List<double> sizeSteps = [0.85, 1, 1.2, 1.45, 1.75];

  static CookTextStyles of(BuildContext context) =>
      Theme.of(context).extension<CookTextStyles>() ??
      CookTextStyles.standard();

  /// Nhân cỡ chữ (giữ tỉ lệ dòng) cho bước cỡ [factor] của Chế độ nấu.
  static TextStyle scaled(TextStyle s, double factor) =>
      s.copyWith(fontSize: s.fontSize! * factor);

  @override
  CookTextStyles copyWith({
    TextStyle? cookIngredient,
    TextStyle? cookStep,
    TextStyle? cookStepCurrent,
    TextStyle? timer,
    TextStyle? timerLarge,
  }) => CookTextStyles(
    cookIngredient: cookIngredient ?? this.cookIngredient,
    cookStep: cookStep ?? this.cookStep,
    cookStepCurrent: cookStepCurrent ?? this.cookStepCurrent,
    timer: timer ?? this.timer,
    timerLarge: timerLarge ?? this.timerLarge,
  );

  @override
  CookTextStyles lerp(ThemeExtension<CookTextStyles>? other, double t) {
    if (other is! CookTextStyles) return this;
    return CookTextStyles(
      cookIngredient: TextStyle.lerp(cookIngredient, other.cookIngredient, t)!,
      cookStep: TextStyle.lerp(cookStep, other.cookStep, t)!,
      cookStepCurrent: TextStyle.lerp(
        cookStepCurrent,
        other.cookStepCurrent,
        t,
      )!,
      timer: TextStyle.lerp(timer, other.timer, t)!,
      timerLarge: TextStyle.lerp(timerLarge, other.timerLarge, t)!,
    );
  }
}

/// Chữ số cùng bề rộng cho lượng nguyên liệu, giờ, số đếm.
extension TabularFigures on TextStyle {
  TextStyle get tabular => copyWith(
    fontFeatures: [...?fontFeatures, const FontFeature.tabularFigures()],
  );
}

/// Truy cập nhanh màu ngữ nghĩa và kiểu chữ nấu: `context.bep`.
extension BepThemeContext on BuildContext {
  CookNoteColors get bep => Theme.of(this).extension<CookNoteColors>()!;
}
