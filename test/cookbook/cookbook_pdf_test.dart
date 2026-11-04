import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cooknote/src/cookbook/cookbook_pdf.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'pdf_text.dart';

CookbookFonts loadFonts() => CookbookFonts(
  regular: File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync(),
  bold: File('assets/fonts/NotoSans-Bold.ttf').readAsBytesSync(),
);

Uint8List jpeg() {
  final image = img.Image(width: 80, height: 60);
  img.fill(image, color: img.ColorRgb8(200, 80, 40));
  return Uint8List.fromList(img.encodeJpg(image));
}

CookbookRecipe recipe(
  String name, {
  int steps = 2,
  Uint8List? cover,
  String? notes = 'Ghi chú nhỏ',
}) => CookbookRecipe(
  name: name,
  servings: 4,
  servingsUnit: 'người',
  prepMinutes: 10,
  cookMinutes: 20,
  totalMinutes: 30,
  source: 'Mẹ tôi',
  notes: notes,
  ingredients: const [
    RecipeLine('Phần nước dùng', isHeading: true),
    RecipeLine('500 g xương ống'),
    RecipeLine('Gia vị', isHeading: true),
    RecipeLine('1 muỗng muối'),
  ],
  steps: [
    for (var i = 1; i <= steps; i++)
      RecipeLine(
        'Bước làm số $i: hầm xương thật kỹ cho ngọt nước, nêm vừa ăn.',
      ),
  ],
  coverImage: cover,
);

CookbookInput input(List<CookbookRecipe> recipes, {Uint8List? cover}) =>
    CookbookInput(
      title: 'Sách của Chung',
      recipes: recipes,
      fonts: loadFonts(),
      coverImage: cover,
    );

/// Bỏ phần chân trang "Trang N " ở đầu văn bản trang (chân trang được ghi
/// trước nội dung trong luồng của package:pdf).
String body(String page) => page.replaceFirst(RegExp(r'^Trang \d+ '), '');

int? footerOf(String page) {
  final m = RegExp(r'^Trang (\d+) ').firstMatch(page);
  return m == null ? null : int.parse(m.group(1)!);
}

void main() {
  group('computeStartPages', () {
    test('cộng dồn từ trang sau bìa và mục lục', () {
      expect(
        computeStartPages(pagesBeforeRecipes: 2, recipePageCounts: [1, 3, 2]),
        [3, 4, 7],
      );
    });
    test('không có công thức', () {
      expect(
        computeStartPages(pagesBeforeRecipes: 2, recipePageCounts: []),
        isEmpty,
      );
    });
  });

  group('buildCookbookPdf', () {
    test('PDF hợp lệ: %PDF ở đầu, %%EOF ở cuối', () async {
      final bytes = await buildCookbookPdf(input([recipe('Phở bò')]));
      expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(
        latin1.decode(bytes.sublist(bytes.length - 8)).trim(),
        endsWith('%%EOF'),
      );
    });

    test('số trang: bìa + mục lục + mỗi công thức một trang', () async {
      final bytes = await buildCookbookPdf(
        input([recipe('A'), recipe('B'), recipe('C')]),
        compress: false,
      );
      expect(readPdf(bytes).pages.length, 1 + 1 + 3);
    });

    test('mục lục ghi đúng trang bắt đầu của từng công thức', () async {
      final names = ['Phở bò', 'Bún chả', 'Cơm tấm'];
      final bytes = await buildCookbookPdf(
        input([
          recipe(names[0], steps: 120), // dài, tràn nhiều trang
          recipe(names[1]),
          recipe(names[2], steps: 60),
        ]),
        compress: false,
      );
      final pdf = readPdf(bytes);
      final toc = pdf.pages[1];
      for (final name in names) {
        final idx = pdf.pages.indexWhere(
          (p) => body(p).startsWith('$name ') && p.contains('Nguyên liệu'),
        );
        final realPage = idx + 1;
        expect(realPage, greaterThan(2), reason: name);
        expect(footerOf(pdf.pages[idx]), realPage, reason: 'chân trang');
        expect(
          RegExp('${RegExp.escape(name)} $realPage\\b').hasMatch(toc),
          isTrue,
          reason: 'mục lục của "$name" phải ghi trang $realPage; toc=$toc',
        );
      }
      expect(pdf.pages.length, greaterThan(1 + 1 + 3)); // có tràn trang
    });

    test('mục lục dài hơn một trang vẫn đúng số trang', () async {
      final recipes = [for (var i = 1; i <= 120; i++) recipe('Món số $i')];
      final bytes = await buildCookbookPdf(input(recipes), compress: false);
      final pdf = readPdf(bytes);
      bool isRecipe(String p) => p.contains('Nguyên liệu');
      final first = pdf.pages.indexWhere(isRecipe);
      final tocPages = first - 1; // trừ trang bìa
      expect(tocPages, greaterThan(1)); // mục lục tràn nhiều trang
      final tocText = pdf.pages.sublist(1, first).map(body).join(' ');
      for (var i = 1; i <= 120; i++) {
        final real =
            pdf.pages.indexWhere(
              (p) => isRecipe(p) && body(p).startsWith('Món số $i '),
            ) +
            1;
        expect(real, first + i, reason: 'mỗi món một trang');
        expect(
          RegExp('Món số $i $real(?!\\d)').hasMatch(tocText),
          isTrue,
          reason: 'món $i phải ghi trang $real',
        );
      }
    });

    test('chữ Việt có dấu có mặt trong nội dung', () async {
      final bytes = await buildCookbookPdf(
        input([recipe('Bánh xèo Ơ Ư Đ ặ ể')]),
        compress: false,
      );
      final all = readPdf(bytes).pages.join('\n');
      for (final s in [
        'Sách của Chung',
        'Mục lục',
        'Bánh xèo Ơ Ư Đ ặ ể',
        'Nguyên liệu',
        'Cách làm',
        'Phần nước dùng',
        'Ghi chú',
        'Nguồn: Mẹ tôi',
        'Khẩu phần: 4 người',
      ]) {
        expect(all, contains(s));
      }
    });

    test('tiêu đề nhóm và bước đánh số', () async {
      final bytes = await buildCookbookPdf(
        input([recipe('X', steps: 3)]),
        compress: false,
      );
      final all = readPdf(bytes).pages.join('\n');
      expect(all, contains('Gia vị'));
      expect(all, contains('1.'));
      expect(all, contains('3.'));
    });

    test('không có công thức: vẫn ra PDF bìa + mục lục', () async {
      final bytes = await buildCookbookPdf(input([]), compress: false);
      expect(readPdf(bytes).pages.length, 2);
    });

    test('ảnh bìa và ảnh công thức nhúng JPEG', () async {
      final bytes = await buildCookbookPdf(
        input([recipe('A', cover: jpeg())], cover: jpeg()),
        compress: false,
      );
      expect(latin1.decode(bytes, allowInvalid: true), contains('/DCTDecode'));
    });

    test('ảnh hỏng không làm sập, vẫn đủ trang', () async {
      final bad = Uint8List.fromList([1, 2, 3, 4, 5]);
      final bytes = await buildCookbookPdf(
        input([recipe('A', cover: bad)], cover: bad),
        compress: false,
      );
      expect(readPdf(bytes).pages.length, 3);
    });

    test('tên có ký tự đặc biệt', () async {
      const name = r'Gà "chiên" (nước mắm) & <tỏi> \ / % # ★ 日本';
      final bytes = await buildCookbookPdf(
        input([recipe(name)]),
        compress: false,
      );
      final pdf = readPdf(bytes);
      expect(pdf.pages.length, 3);
      expect(pdf.pages[2], contains(r'Gà "chiên" (nước mắm) & <tỏi> \ / % # '));
    });

    test(
      'công thức rất ngắn (không nguyên liệu, không bước, không ghi chú)',
      () async {
        final bytes = await buildCookbookPdf(
          input([const CookbookRecipe(name: 'Trống')]),
          compress: false,
        );
        expect(readPdf(bytes).pages.length, 3);
      },
    );
  });

  group('buildRecipePdf', () {
    test('một công thức, không bìa không mục lục', () async {
      final bytes = await buildRecipePdf(
        recipe('Phở bò', cover: jpeg()),
        loadFonts(),
        compress: false,
      );
      final pdf = readPdf(bytes);
      expect(pdf.pages.length, 1);
      expect(pdf.pages.first, contains('Phở bò'));
      expect(pdf.pages.first, isNot(contains('Mục lục')));
      expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    });

    test('công thức dài tràn nhiều trang', () async {
      final bytes = await buildRecipePdf(
        recipe('Dài', steps: 200),
        loadFonts(),
        compress: false,
      );
      expect(readPdf(bytes).pages.length, greaterThan(2));
    });
  });
}
