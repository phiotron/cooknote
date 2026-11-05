import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cooknote/src/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final x = _lum(a), y = _lum(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

void main() {
  group('token → ColorScheme / CookNoteColors (S-50 tương phản)', () {
    test('khớp tokens JSON (mẫu: primary, surface, ribbon, cookInk)', () {
      final j =
          jsonDecode(
                File('design/hifi/tokens/bepbook-tokens.json')
                    .readAsStringSync(),
              )['flutter']
              as Map<String, dynamic>;
      String hex(Color c) =>
          '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
              .toUpperCase();
      final l = j['ColorScheme']['light'] as Map<String, dynamic>;
      final d = j['ColorScheme']['dark'] as Map<String, dynamic>;
      expect(hex(bepbookLightScheme.primary), l['primary']);
      expect(hex(bepbookLightScheme.surface), l['surface']);
      expect(hex(bepbookDarkScheme.primary), d['primary']);
      expect(hex(bepbookDarkScheme.surface), d['surface']);
      final n = j['CookNoteColors'] as Map<String, dynamic>;
      expect(hex(cookNoteColorsLight.ribbon), n['light']['ribbon']);
      expect(hex(cookNoteColorsDark.cookInk), n['dark']['cookInk']);
    });

    for (final (name, cs, b) in [
      ('sáng', bepbookLightScheme, cookNoteColorsLight),
      ('tối', bepbookDarkScheme, cookNoteColorsDark),
    ]) {
      test('chữ ≥ 4.5:1 trên nền tương ứng ($name)', () {
        final pairs = <String, (Color, Color)>{
          'onSurface/surface': (cs.onSurface, cs.surface),
          'onSurfaceVariant/surface': (cs.onSurfaceVariant, cs.surface),
          'onPrimary/primary': (cs.onPrimary, cs.primary),
          'onPrimaryContainer/primaryContainer': (
            cs.onPrimaryContainer,
            cs.primaryContainer,
          ),
          'onSecondaryContainer/secondaryContainer': (
            cs.onSecondaryContainer,
            cs.secondaryContainer,
          ),
          'onError/error': (cs.onError, cs.error),
          'onErrorContainer/errorContainer': (
            cs.onErrorContainer,
            cs.errorContainer,
          ),
          'onInverseSurface/inverseSurface': (
            cs.onInverseSurface,
            cs.inverseSurface,
          ),
          'inversePrimary/inverseSurface (nút snackbar)': (
            cs.inversePrimary,
            cs.inverseSurface,
          ),
          'onSuccessContainer/successContainer': (
            b.onSuccessContainer,
            b.successContainer,
          ),
          'onWarningContainer/warningContainer': (
            b.onWarningContainer,
            b.warningContainer,
          ),
          'onInfoContainer/infoContainer': (b.onInfoContainer, b.infoContainer),
          'onCurrentStep/currentStep': (b.onCurrentStep, b.currentStep),
          'onTimerActive/timerActive': (b.onTimerActive, b.timerActive),
          'cookInk/cookSurface': (b.cookInk, b.cookSurface),
          'crossedOff/surface': (b.crossedOff, cs.surface),
          for (var i = 0; i < 8; i++)
            'onPhotoPlaceholder/placeholder${i + 1}': (
              b.onPhotoPlaceholder,
              b.photoPlaceholders[i],
            ),
        };
        for (final e in pairs.entries) {
          expect(
            contrast(e.value.$1, e.value.$2),
            greaterThanOrEqualTo(4.5),
            reason: e.key,
          );
        }
      });

      test('biên điều khiển/biểu tượng ≥ 3:1 ($name)', () {
        expect(contrast(cs.outline, cs.surface), greaterThanOrEqualTo(3));
        expect(
          contrast(b.currentStepEdge, b.currentStep),
          greaterThanOrEqualTo(3),
        );
        expect(contrast(b.ribbon, cs.surface), greaterThanOrEqualTo(3));
      });
    }

    test('CookNoteColors.lerp / copyWith không mất trường', () {
      final mid = cookNoteColorsLight.lerp(cookNoteColorsDark, .5);
      expect(mid.success, isNot(cookNoteColorsLight.success));
      expect(
        cookNoteColorsLight.copyWith(ribbon: Colors.red).ribbon,
        Colors.red,
      );
      expect(cookNoteColorsLight.photoPlaceholders, hasLength(8));
    });
  });

  group('ThemeData', () {
    test(
      'Lora cho tiêu đề, Noto Sans cho giao diện, số tabular cho hẹn giờ',
      () {
        final t = bepbookLightTheme();
        expect(t.textTheme.titleLarge!.fontFamily, kSerifFamily);
        expect(t.textTheme.headlineSmall!.fontFamily, kSerifFamily);
        expect(t.textTheme.bodyMedium!.fontFamily, kSansFamily);
        expect(t.textTheme.titleMedium!.fontFamily, kSansFamily);
        final cook = t.extension<CookTextStyles>()!;
        expect(cook.timer.fontFeatures, isNotNull);
        expect(cook.cookStepCurrent.fontSize, 28);
        expect(cook.cookStep.fontSize, 24);
      },
    );

    test('hai chủ đề dùng tone, không bóng đổ ở chế độ tối', () {
      final light = bepbookLightTheme();
      final dark = bepbookDarkTheme();
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(dark.floatingActionButtonTheme.elevation, 0);
      expect(dark.cardTheme.elevation, 0);
      expect(light.extension<CookNoteColors>(), isNotNull);
      expect(dark.extension<CookNoteColors>(), isNotNull);
    });

    test('AppBar: Android căn trái, iOS căn giữa tiêu đề nhỏ', () {
      final a = bepbookLightTheme(platform: TargetPlatform.android);
      final i = bepbookLightTheme(platform: TargetPlatform.iOS);
      expect(a.appBarTheme.centerTitle, isFalse);
      expect(i.appBarTheme.centerTitle, isTrue);
      expect(i.appBarTheme.titleTextStyle!.fontSize, 16);
      expect(a.appBarTheme.titleTextStyle!.fontSize, 21);
    });

    test('vùng chạm ≥ 48 dp cho nút, nút icon, dòng danh sách (AC-60)', () {
      final t = bepbookLightTheme();
      for (final s in [
        t.filledButtonTheme.style,
        t.outlinedButtonTheme.style,
        t.textButtonTheme.style,
        t.iconButtonTheme.style,
      ]) {
        final size = s!.minimumSize!.resolve({});
        expect(size!.height, greaterThanOrEqualTo(BepTap.min));
      }
      expect(t.listTileTheme.minTileHeight, greaterThanOrEqualTo(BepTap.min));
      expect(BepTap.cook, 64);
    });

    test('font khai trong pubspec và có file (Việt: Phở, ướp, đ)', () {
      final pub = File('pubspec.yaml').readAsStringSync();
      expect(pub, contains('family: Lora'));
      expect(pub, contains('family: NotoSans'));
      for (final f in [
        'Lora-Medium',
        'Lora-SemiBold',
        'Lora-Bold',
        'NotoSans-Regular-400',
        'NotoSans-Medium',
        'NotoSans-SemiBold',
        'NotoSans-Bold-700',
      ]) {
        expect(File('assets/fonts/$f.ttf').existsSync(), isTrue, reason: f);
        expect(pub, contains('assets/fonts/$f.ttf'));
      }
    });
  });

  testWidgets('chữ 200% không vỡ: tiêu đề Lora nhiều dòng trong AppBar', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: bepbookLightTheme(),
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: w!,
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('Bánh xèo miền Tây giòn rụm')),
          body: const Text('Phở ướp đậm đà'),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
