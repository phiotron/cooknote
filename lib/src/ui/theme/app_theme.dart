import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'text_styles.dart';
import 'tokens.dart';

/// ThemeData sáng của Bepbook (mockup Hi-Fi v1). [platform] chỉ để test ép iOS/Android;
/// mặc định theo hệ điều hành (AppBar Android căn trái, iOS căn giữa, tiêu đề nhỏ — §7).
ThemeData bepbookLightTheme({TargetPlatform? platform}) =>
    _build(bepbookLightScheme, cookNoteColorsLight, platform);

/// ThemeData tối ("bếp ban đêm": than ấm, dùng tông thay bóng đổ).
ThemeData bepbookDarkTheme({TargetPlatform? platform}) =>
    _build(bepbookDarkScheme, cookNoteColorsDark, platform);

ThemeData _build(
  ColorScheme cs,
  CookNoteColors bep,
  TargetPlatform? platformOverride,
) {
  final platform = platformOverride ?? defaultTargetPlatform;
  final ios = platform == TargetPlatform.iOS;
  final dark = cs.brightness == Brightness.dark;
  final text = bepbookTextTheme().apply(
    bodyColor: cs.onSurface,
    displayColor: cs.onSurface,
  );
  final outline = BorderSide(color: cs.outline);
  const stadium = StadiumBorder();
  final labelLarge = text.labelLarge!;

  final fieldBorder = OutlineInputBorder(
    borderRadius: BepRadius.circular(BepRadius.md),
    borderSide: BorderSide(color: cs.outline),
  );

  return ThemeData(
    useMaterial3: true,
    platform: platform,
    brightness: cs.brightness,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    canvasColor: cs.surface,
    fontFamily: kSansFamily,
    textTheme: text,
    extensions: [bep, CookTextStyles.standard()],
    // Tối: tông thay bóng đổ.
    applyElevationOverlayColor: false,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: ios,
      toolbarHeight: ios ? 56 : 64,
      titleSpacing: ios ? null : 0,
      titleTextStyle: ios ? text.titleMedium : text.titleLarge,
      iconTheme: IconThemeData(color: cs.onSurfaceVariant),
      actionsIconTheme: IconThemeData(color: cs.onSurfaceVariant),
    ),
    iconTheme: IconThemeData(color: cs.onSurfaceVariant),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(BepTap.min, BepTap.min),
        foregroundColor: cs.onSurfaceVariant,
      ),
    ),
    cardTheme: CardThemeData(
      color: dark ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BepRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: cs.secondaryContainer,
      disabledColor: cs.surfaceContainerHigh,
      side: outline,
      labelStyle: labelLarge.copyWith(
        fontSize: 13.5,
        color: cs.onSurfaceVariant,
      ),
      secondaryLabelStyle: labelLarge.copyWith(
        fontSize: 13.5,
        color: cs.onSecondaryContainer,
      ),
      iconTheme: IconThemeData(size: 18, color: cs.onSurfaceVariant),
      checkmarkColor: cs.onSecondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BepRadius.circular(9)),
      showCheckmark: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, BepTap.min),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: stadium,
        textStyle: labelLarge,
        disabledBackgroundColor: cs.surfaceContainerHighest,
        disabledForegroundColor: cs.onSurfaceVariant,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, BepTap.min),
        shape: stadium,
        textStyle: labelLarge,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, BepTap.min),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: stadium,
        textStyle: labelLarge,
        foregroundColor: cs.primary,
        side: outline,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, BepTap.min),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: stadium,
        textStyle: labelLarge,
        foregroundColor: cs.primary,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: dark ? 0 : 3,
      focusElevation: dark ? 0 : 3,
      hoverElevation: dark ? 0 : 4,
      highlightElevation: dark ? 0 : 4,
      shape: RoundedRectangleBorder(borderRadius: BepRadius.circular(18)),
      sizeConstraints: const BoxConstraints.tightFor(width: 56, height: 56),
      extendedSizeConstraints: const BoxConstraints.tightFor(height: 56),
      extendedTextStyle: labelLarge.copyWith(fontSize: 15),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        minimumSize: const Size(0, BepTap.min),
        textStyle: labelLarge.copyWith(fontSize: 13.5),
        side: outline,
        selectedBackgroundColor: cs.secondaryContainer,
        selectedForegroundColor: cs.onSecondaryContainer,
        foregroundColor: cs.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      focusedErrorBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      disabledBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      labelStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
      floatingLabelStyle: text.labelMedium!.copyWith(
        color: cs.onSurfaceVariant,
      ),
      helperStyle: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
      errorStyle: text.bodySmall!.copyWith(
        color: cs.error,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
      constraints: const BoxConstraints(minHeight: 52),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      textStyle: WidgetStatePropertyAll(text.bodyLarge),
      hintStyle: WidgetStatePropertyAll(
        text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: cs.surfaceContainerLow,
      modalBarrierColor: Colors.black.withValues(alpha: dark ? .6 : .42),
      elevation: 0,
      modalElevation: 0,
      showDragHandle: true,
      dragHandleColor: cs.outline,
      dragHandleSize: const Size(36, 4),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BepRadius.circular(28)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cs.inverseSurface,
      contentTextStyle: text.bodyMedium!.copyWith(
        color: cs.onInverseSurface,
        height: 1.35,
      ),
      actionTextColor: cs.inversePrimary,
      closeIconColor: cs.onInverseSurface,
      elevation: dark ? 0 : 3,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BepRadius.circular(10)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      height: 72,
      indicatorColor: cs.primaryContainer,
      indicatorShape: stadium,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          size: 24,
          color: s.contains(WidgetState.selected)
              ? cs.onPrimaryContainer
              : cs.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => text.labelMedium!.copyWith(
          color: s.contains(WidgetState.selected)
              ? cs.onSurface
              : cs.onSurfaceVariant,
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      minTileHeight: 56,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      iconColor: cs.onSurfaceVariant,
      textColor: cs.onSurface,
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodyMedium!.copyWith(
        fontSize: 13.5,
        color: cs.onSurfaceVariant,
      ),
      minVerticalPadding: 8,
      horizontalTitleGap: 14,
    ),
    dividerTheme: DividerThemeData(
      color: cs.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? Colors.transparent : cs.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? cs.primary
            : cs.surfaceContainerHighest,
      ),
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? cs.onPrimary : cs.outline,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BepRadius.circular(6)),
      side: BorderSide(color: cs.onSurfaceVariant, width: 2),
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? cs.primary : null,
      ),
      checkColor: WidgetStatePropertyAll(cs.onPrimary),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? cs.primary : cs.onSurfaceVariant,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: cs.primary,
      linearTrackColor: cs.surfaceContainerHighest,
      circularTrackColor: Colors.transparent,
      linearMinHeight: 6,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: cs.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: dark ? 0 : 3,
      shape: RoundedRectangleBorder(borderRadius: BepRadius.circular(12)),
      textStyle: text.bodyLarge,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: cs.onSurface,
      unselectedLabelColor: cs.onSurfaceVariant,
      indicatorColor: cs.primary,
      dividerColor: cs.outlineVariant,
      labelStyle: text.titleSmall,
      unselectedLabelStyle: text.titleSmall,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: BepRadius.circular(8),
      ),
      textStyle: text.bodySmall!.copyWith(color: cs.onInverseSurface),
      waitDuration: const Duration(milliseconds: 400),
    ),
    focusColor: cs.primary.withValues(alpha: .16),
  );
}
