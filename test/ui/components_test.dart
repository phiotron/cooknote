import 'package:cooknote/l10n/app_localizations.dart';
import 'package:cooknote/src/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dựng [child] trong MaterialApp có theme Bepbook, tiếng Việt, màn 360×800 dp,
/// cỡ chữ [scale] và chủ đề [dark].
Future<void> pumpUi(
  WidgetTester tester,
  Widget child, {
  double scale = 1,
  bool dark = false,
  Locale locale = const Locale('vi'),
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: bepbookLightTheme(),
      darkTheme: bepbookDarkTheme(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      scaffoldMessengerKey: rootMessengerKey,
      builder: (c, w) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
        child: w!,
      ),
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('BepButton', () {
    for (final (size, min) in [
      (BepButtonSize.standard, 48.0),
      (BepButtonSize.big, 56.0),
      (BepButtonSize.cook, 64.0),
    ]) {
      testWidgets('cao ≥ $min dp ($size)', (tester) async {
        await pumpUi(
          tester,
          BepButton(label: 'Lưu', onPressed: () {}, size: size),
        );
        expect(
          tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(min),
        );
      });
    }

    testWidgets('biến thể: nhấn được, khóa khi onPressed null, icon, block', (
      tester,
    ) async {
      var taps = 0;
      await pumpUi(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final k in BepButtonKind.values)
              BepButton(
                key: ValueKey(k),
                label: k.name,
                kind: k,
                icon: Icons.add,
                block: true,
                onPressed: () => taps++,
              ),
            const BepButton(label: 'khóa', onPressed: null),
          ],
        ),
      );
      await tester.tap(find.text('filled'));
      await tester.tap(find.text('dangerText'));
      expect(taps, 2);
      await tester.tap(find.text('khóa'));
      expect(taps, 2);
      expect(
        tester.getSize(find.byKey(const ValueKey(BepButtonKind.tonal))).width,
        360,
      );
    });

    testWidgets('chữ 200%, nhãn dài vẫn không tràn', (tester) async {
      await pumpUi(
        tester,
        SizedBox(
          width: 300,
          child: BepButton(
            label: 'Sao lưu ngay và lưu ở nơi khác',
            onPressed: () {},
            icon: Icons.backup_outlined,
          ),
        ),
        scale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('BepTag', () {
    testWidgets('mọi trạng thái có chữ + biểu tượng (không chỉ màu)', (
      tester,
    ) async {
      await pumpUi(
        tester,
        Wrap(
          children: [
            for (final t in BepTone.values) BepTag('Nhãn ${t.name}', tone: t),
          ],
        ),
        dark: true,
      );
      for (final t in BepTone.values) {
        expect(find.text('Nhãn ${t.name}'), findsOneWidget);
      }
      expect(find.byType(Icon), findsNWidgets(BepTone.values.length));
    });
  });

  group('Ảnh thay thế / khung ảnh', () {
    test('màu ổn định theo tên, chữ cái đầu bỏ ký tự lạ', () {
      expect(placeholderIndex('Phở bò'), placeholderIndex('Phở bò'));
      expect(placeholderIndex('Phở bò'), inInclusiveRange(0, 7));
      expect(placeholderInitial('  ướp cá'), 'Ư');
      expect(placeholderInitial('🍜 Mì'), 'M');
      expect(placeholderInitial(''), '•');
    });

    testWidgets('PhotoPlaceholder hiện chữ cái đầu + danh mục (khung đủ cao)', (
      tester,
    ) async {
      await pumpUi(
        tester,
        const SizedBox(
          width: 160,
          height: 120,
          child: PhotoPlaceholder(
            title: 'Bánh xèo',
            categoryLabel: 'Món chính',
          ),
        ),
      );
      expect(find.text('B'), findsOneWidget);
      expect(find.text('MÓN CHÍNH'), findsOneWidget);
    });

    testWidgets('PhotoFrame có scrim khi có chữ phủ lên ảnh', (tester) async {
      await pumpUi(
        tester,
        const SizedBox(
          width: 200,
          child: PhotoFrame(
            photo: ColoredBox(color: Colors.orange),
            overlay: Text('Tên', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
      expect(find.byType(PhotoScrim), findsOneWidget);
      expect(find.text('Tên'), findsOneWidget);
    });
  });

  group('RecipeCard / RecipeRow', () {
    testWidgets('chạm được, tên 2 dòng ellipsis ở chữ 200%, không tràn', (
      tester,
    ) async {
      var tapped = false;
      await pumpUi(
        tester,
        SizedBox(
          width: 170,
          child: RecipeCard(
            cover: const PhotoPlaceholder(title: 'Bún chả'),
            title:
                'Bún chả Hà Nội nướng than hoa kèm nem rán và rau sống đầy đủ',
            meta: const Text('45 phút'),
            bookmarked: true,
            onTap: () => tapped = true,
          ),
        ),
        scale: 2,
      );
      await tester.tap(find.byType(RecipeCard));
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
      expect(find.byType(RibbonBookmark), findsOneWidget);
    });

    testWidgets('chế độ chọn: dấu tích hiện, dòng cao ≥ 72 dp', (tester) async {
      await pumpUi(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            RecipeRow(
              cover: PhotoPlaceholder(title: 'Cháo'),
              title: 'Cháo gà',
              selected: true,
            ),
            RecipeRow(
              cover: PhotoPlaceholder(title: 'Gỏi'),
              title: 'Gỏi cuốn',
              selected: false,
            ),
          ],
        ),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      expect(
        tester.getSize(find.byType(RecipeRow).first).height,
        greaterThanOrEqualTo(72),
      );
    });

    testWidgets('StarRating đọc "4 trên 5 sao" / nhập được (mỗi sao ≥ 48 dp)', (
      tester,
    ) async {
      int? picked;
      await pumpUi(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StarRating(value: 4),
            StarRating(value: 2, size: 24, onChanged: (v) => picked = v),
          ],
        ),
      );
      expect(find.bySemanticsLabel('4 trên 5 sao'), findsOneWidget);
      await tester.tap(find.byTooltip('5 trên 5 sao'));
      expect(picked, 5);
      expect(
        tester.getSize(find.byTooltip('5 trên 5 sao')).shortestSide,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('Tiêu đề nhóm + trạng thái rỗng', () {
    testWidgets('NotebookTabHeader là heading, hiện số đếm', (tester) async {
      await pumpUi(tester, const NotebookTabHeader('Món chính', count: '12'));
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byType(NotebookTabHeader)),
        isSemantics(isHeader: true),
      );
      handle.dispose();
      expect(find.text('12'), findsOneWidget);
    });

    for (final illo in BepIllo.values) {
      testWidgets(
        'EmptyState + minh hoạ ${illo.name} vẽ được ở 200%, sáng/tối',
        (tester) async {
          await pumpUi(
            tester,
            SizedBox(
              width: 360,
              height: 500,
              child: EmptyState(
                illustration: illo,
                title: 'Chưa có công thức nào',
                body: 'Thêm công thức đầu tiên để bắt đầu sổ tay của bạn.',
                actions: [BepButton(label: 'Thêm công thức', onPressed: () {})],
              ),
            ),
            scale: 2,
            dark: illo.index.isEven,
          );
          expect(find.text('Chưa có công thức nào'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('Thanh dưới 5 mục', () {
    final items = [
      for (final (i, l) in [
        (Icons.menu_book_outlined, 'Công thức'),
        (Icons.calendar_month_outlined, 'Thực đơn'),
        (Icons.shopping_basket_outlined, 'Đi chợ'),
        (Icons.kitchen_outlined, 'Tủ bếp'),
        (Icons.more_horiz_rounded, 'Thêm'),
      ])
        BepNavItem(icon: i, selectedIcon: i, label: l),
    ];

    for (final scale in [1.0, 2.0]) {
      testWidgets('5 nhãn vừa 360 dp, không tràn, chữ ${scale * 100}%', (
        tester,
      ) async {
        var sel = 0;
        await pumpUi(
          tester,
          StatefulBuilder(
            builder: (c, set) => BepNavigationBar(
              items: items,
              selectedIndex: sel,
              onSelected: (i) => set(() => sel = i),
            ),
          ),
          scale: scale,
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(NavigationDestination), findsNWidgets(5));
        // Nhãn bị chặn ở 1.3× (không phình theo 200%).
        final h = tester.getSize(find.byType(NavigationBar)).height;
        expect(h, lessThanOrEqualTo(72 + 1));
        // Vùng chạm mỗi mục ≥ 48 dp.
        for (final d in tester.widgetList(find.byType(NavigationDestination))) {
          expect(d, isNotNull);
        }
        expect(
          tester.getSize(find.byType(NavigationDestination).first).height,
          greaterThanOrEqualTo(48),
        );
        await tester.tap(find.text('Đi chợ'));
        await tester.pump();
        expect(sel, 2);
      });
    }

    testWidgets('tooltip + nhãn đọc màn hình là tên đầy đủ', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        BepNavigationBar(items: items, selectedIndex: 0, onSelected: (_) {}),
        scale: 2,
      );
      expect(find.byTooltip('Công thức'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Công thức')), findsWidgets);
      handle.dispose();
    });
  });

  group('Hộp trạng thái sao lưu', () {
    testWidgets('bốn trạng thái: từ + biểu tượng, tiếng Việt và Anh', (
      tester,
    ) async {
      const vi = {
        BackupStatus.safe: 'An toàn',
        BackupStatus.overdue: 'Quá hạn',
        BackupStatus.failing: 'Đang lỗi',
        BackupStatus.notSetUp: 'Chưa bật',
      };
      await pumpUi(
        tester,
        SingleChildScrollView(
          child: Column(
            children: [
              for (final s in BackupStatus.values)
                BackupStatusCard(
                  status: s,
                  body: 'Bản gần nhất: hôm qua',
                  actions: [
                    BepButton(
                      label: 'Sao lưu ngay',
                      kind: BepButtonKind.text,
                      onPressed: () {},
                    ),
                  ],
                ),
            ],
          ),
        ),
        dark: true,
      );
      for (final w in vi.values) {
        expect(find.text(w), findsOneWidget);
      }
      for (final s in BackupStatus.values) {
        expect(find.byIcon(BackupStatusCard.iconOf(s)), findsOneWidget);
      }
      await pumpUi(
        tester,
        const BackupStatusCard(status: BackupStatus.overdue),
        locale: const Locale('en'),
      );
      expect(find.text('Overdue'), findsOneWidget);
    });
  });

  group('Hộp thoại / thanh thông báo / bảng đáy', () {
    testWidgets('showConfirmDialog trả true/false; nguy hiểm dùng màu lỗi', (
      tester,
    ) async {
      late BuildContext ctx;
      await pumpUi(
        tester,
        Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      );
      var f = showConfirmDialog(
        ctx,
        title: 'Xóa công thức?',
        body: 'Sẽ vào thùng rác 30 ngày.',
        confirmLabel: 'Xóa',
        cancelLabel: 'Hủy',
        destructive: true,
      );
      await tester.pumpAndSettle();
      expect(find.text('Xóa công thức?'), findsOneWidget);
      final del = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Xóa'),
      );
      expect(del.style!.foregroundColor!.resolve({}), bepbookLightScheme.error);
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();
      expect(await f, isTrue);

      f = showConfirmDialog(
        ctx,
        title: 'Thoát?',
        confirmLabel: 'Thoát',
        cancelLabel: 'Ở lại',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ở lại'));
      await tester.pumpAndSettle();
      expect(await f, isFalse);
    });

    testWidgets('snackbar có hành động; nâng lên khi có viên thuốc hẹn giờ', (
      tester,
    ) async {
      await pumpUi(tester, const SizedBox());
      var undone = false;
      snackBarLift.value = 56;
      addTearDown(() => snackBarLift.value = 0);
      showBepSnackBar(
        'Đã xóa · Hoàn tác',
        actionLabel: 'Hoàn tác',
        onAction: () => undone = true,
      );
      await tester.pumpAndSettle();
      final bar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect((bar.margin! as EdgeInsets).bottom, 68);
      await tester.tap(find.text('Hoàn tác'));
      expect(undone, isTrue);
    });

    testWidgets('showBepSheet cuộn được, có tay nắm', (tester) async {
      late BuildContext ctx;
      await pumpUi(
        tester,
        Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
        scale: 2,
      );
      showBepSheet<void>(
        ctx,
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 30; i++) ListTile(title: Text('Dòng $i')),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Dòng 0'), findsOneWidget);
    });
  });
}
