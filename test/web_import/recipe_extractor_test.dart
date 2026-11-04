import 'dart:io';

import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:cooknote/src/web_import/recipe_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

String fixture(String name) =>
    File('test/fixtures/web/$name').readAsStringSync();

WebRecipe? extract(String name, {String? url}) => extractRecipeFromHtml(
  fixture(name),
  pageUrl: url == null ? null : Uri.parse(url),
);

/// Bọc một khối JSON-LD thành trang HTML tối thiểu.
String ld(String json) =>
    '<html><head><script type="application/ld+json">$json</script></head></html>';

List<String> texts(List<RecipeLine> l) => l.map((e) => e.text).toList();

void main() {
  group('JSON-LD: các kiểu trang', () {
    test(
      'blog kiểu WP Recipe Maker: một đối tượng, HowToSection, yield mảng',
      () {
        final r = extract(
          'wprm_blog.html',
          url: 'https://blog.example.test/noodles/',
        )!;
        final d = r.draft;
        expect(d.name, 'Garlic Butter Noodles');
        expect(d.servings, 4);
        expect(d.servingsUnit, 'servings');
        expect(d.prepMinutes, 15);
        expect(d.cookMinutes, 20);
        expect(d.totalMinutes, 35);
        expect(
          d.notes,
          'A quick weeknight dish & a great way to use leftover herbs.',
        );
        expect(d.source, 'Mẫu Blog Bếp Nhà');
        expect(d.sourceUrl, 'https://blog.example.test/noodles/');
        expect(texts(d.ingredients), [
          '250 g dried noodles',
          '3 tbsp butter',
          '4 cloves garlic, minced',
          '1 handful fresh parsley',
        ]);
        expect(d.steps, const [
          RecipeLine('Make the sauce', isHeading: true),
          RecipeLine('Melt the butter over low heat.'),
          RecipeLine('Add the garlic and cook until fragrant.'),
          RecipeLine('Finish', isHeading: true),
          RecipeLine('Toss the cooked noodles in the sauce.'),
          RecipeLine('Scatter parsley on top and serve.'),
        ]);
        expect(d.nutrition, contains('420 kcal'));
        expect(d.nutrition, contains('14 g'));
        expect(r.imageUrls, [
          'https://blog.example.test/uploads/noodles-1x1.jpg',
          'https://blog.example.test/uploads/noodles-4x3.jpg',
          'https://blog.example.test/uploads/noodles-og.jpg',
        ]);
      },
    );

    test('blog kiểu Tasty: JSON-LD là mảng, @type mảng, ImageObject, thẻ HTML trong bước', () {
      final r = extract('tasty_blog.html')!;
      final d = r.draft;
      expect(d.name, 'Lemon Rice');
      expect(d.servings, 3);
      expect(d.servingsUnit, 'servings');
      expect(d.totalMinutes, 90 - 60);
      expect(d.source, 'Blog Mẫu Hai');
      expect(d.sourceUrl, isNull);
      expect(texts(d.ingredients), [
        '2 cups cooked rice',
        '1 lemon, juiced',
        '1½ tbsp oil',
        'salt to taste',
      ]);
      expect(texts(d.steps), [
        'Heat the oil in a pan.',
        'Stir in the rice and lemon juice.',
        'Season with salt and serve warm.',
      ]);
      expect(r.imageUrls, ['https://blog2.example.test/img/lemon-rice.jpg']);
    });

    test(
      'trang báo dùng @graph, @type ["Recipe","Article"], tham chiếu @id',
      () {
        final r = extract('graph_news.html')!;
        final d = r.draft;
        expect(d.name, 'Tomato Soup');
        expect(d.servings, 6);
        expect(d.servingsUnit, isNull);
        expect(d.prepMinutes, 10);
        expect(d.cookMinutes, 40);
        expect(d.source, 'Tạp Chí Ẩm Thực Mẫu');
        expect(texts(d.steps), [
          'Roast the tomatoes.',
          'Simmer with the onion and stock.',
          'Blend until smooth.',
        ]);
        expect(r.imageUrls, [
          'https://news.example.test/media/tomato-soup.jpg',
        ]);
      },
    );

    test(
      'trang tiếng Việt kiểu Cooky: bước đánh số, tiêu đề nhóm, ảnh tương đối',
      () {
        final r = extract(
          'vi_cooky.html',
          url: 'https://vi1.example.test/cong-thuc/canh-chua',
        )!;
        final d = r.draft;
        expect(d.name, 'Canh chua cá lóc');
        expect(d.servings, 4);
        expect(d.servingsUnit, 'người');
        expect(d.totalMinutes, 90);
        expect(d.notes, 'Món canh chua thanh mát cho bữa cơm gia đình.');
        expect(d.steps, const [
          RecipeLine('Sơ chế', isHeading: true),
          RecipeLine('Cá rửa sạch, cắt khúc, ướp chút muối.'),
          RecipeLine('Cà chua và dứa cắt miếng vừa ăn.'),
          RecipeLine('Nấu canh', isHeading: true),
          RecipeLine('Phi hành, xào cà chua, đổ nước vào đun sôi.'),
          RecipeLine('Cho cá vào nấu chín, thêm rau thơm rồi tắt bếp.'),
        ]);
        expect(d.ingredients.length, 4);
        expect(r.imageUrls, [
          'https://vi1.example.test/anh/canh-chua.jpg',
          'https://vi1.example.test/anh/canh-chua-2.jpg',
        ]);
      },
    );

    test('trang tiếng Việt kiểu Món Ngon: script nháy đơn, yield số, P0DT', () {
      final d = extract('vi_monngon.html')!.draft;
      expect(d.name, 'Thịt kho trứng');
      expect(d.servings, 6);
      expect(d.servingsUnit, isNull);
      expect(d.prepMinutes, 20);
      expect(d.cookMinutes, 60);
      expect(d.source, 'Món Ngon Mẫu');
      expect(texts(d.steps), [
        'Thịt cắt miếng vuông, trần qua nước sôi.',
        'Cho thịt, nước dừa, nước mắm vào nồi, đun nhỏ lửa.',
        'Thêm trứng luộc, kho đến khi nước sánh lại.',
      ]);
    });

    test(
      'trang tiếng Anh đơn giản: thẻ, thực thể, mục rỗng, chuỗi nhiều dòng',
      () {
        final d = extract('en_simple.html')!.draft;
        expect(d.name, 'Simple Omelette & Toast');
        expect(texts(d.ingredients), [
          '3 eggs',
          '1 tbsp butter (softened)',
          'pinch of salt',
        ]);
        expect(texts(d.steps), [
          'Beat the eggs with salt.',
          'Melt the butter in a pan.',
          'Pour in the eggs and fold when set.',
          'Slide onto a plate — enjoy!',
        ]);
        expect(d.notes, isNull);
      },
    );

    test('HowToSection lồng nhau; section tên rỗng không tạo tiêu đề', () {
      final d = extract('nested_sections.html')!.draft;
      expect(d.ingredients, const [
        RecipeLine('For the sponge', isHeading: true),
        RecipeLine('200 g flour'),
        RecipeLine('4 eggs'),
        RecipeLine('For the cream', isHeading: true),
        RecipeLine('300 ml cream'),
      ]);
      expect(d.steps, const [
        RecipeLine('Sponge', isHeading: true),
        RecipeLine('Whisk the eggs.'),
        RecipeLine('Baking', isHeading: true),
        RecipeLine('Pour into a tin.'),
        RecipeLine('Bake until golden.'),
        RecipeLine('Whip the cream.'),
        RecipeLine('Assemble', isHeading: true),
        RecipeLine('Layer the sponge with cream.'),
      ]);
    });

    test('recipeYield dạng mảng ["24","24 cookies"]', () {
      final d = extract('yield_array.html')!.draft;
      expect(d.servings, 24);
      expect(d.servingsUnit, 'cookies');
    });

    test('thời gian có phần ngày: P0DT0H45M, P1DT2H, P1DT2H45M', () {
      final d = extract('duration_days.html')!.draft;
      expect(d.prepMinutes, 45);
      expect(d.cookMinutes, 26 * 60);
      expect(d.totalMinutes, 26 * 60 + 45);
    });
  });

  group('microdata', () {
    test('trang cũ: itemprop, time/meta, nutrition lồng, bỏ Person ngoài công thức', () {
      final r = extract(
        'microdata_old.html',
        url: 'https://old.example.test/a/pancakes',
      )!;
      final d = r.draft;
      expect(d.name, 'Fluffy Pancakes');
      expect(d.servings, 4);
      expect(d.servingsUnit, 'servings');
      expect(d.prepMinutes, 10);
      expect(d.cookMinutes, 15);
      expect(d.source, 'Tác Giả Cũ');
      expect(d.notes, 'Soft pancakes for Sunday & holidays.');
      expect(texts(d.ingredients), ['1 cup flour', '1 egg', '1 cup milk']);
      expect(texts(d.steps), [
        'Whisk everything together.',
        'Pour onto a hot pan.',
        'Flip when bubbles appear.',
      ]);
      expect(d.nutrition, contains('300 kcal'));
      expect(r.imageUrls, ['https://old.example.test/photos/pancakes.jpg']);
    });

    test('blog tiếng Việt: yield "3-4 phần ăn", thực thể, og:site_name', () {
      final d = extract('vi_blog_microdata.html')!.draft;
      expect(d.name, 'Bánh flan caramel – mềm mịn');
      expect(d.servings, 3);
      expect(d.servingsUnit, 'phần ăn');
      expect(d.totalMinutes, 120);
      expect(d.source, 'Bếp Nhà Mẫu');
      expect(d.ingredients.length, 3);
      expect(d.steps.length, 3);
    });
  });

  group('trang không có / hỏng', () {
    test('trang không có Recipe trả về null', () {
      expect(extract('no_recipe.html'), isNull);
    });

    test('HTML rỗng hoặc không phải HTML trả về null', () {
      expect(extractRecipeFromHtml(''), isNull);
      expect(extractRecipeFromHtml('chỉ là chữ thường'), isNull);
    });

    test(
      'khối JSON-LD hỏng (phẩy thừa, chú thích) bị bỏ qua, khối đúng vẫn dùng',
      () {
        final d = extract('broken_jsonld.html')!.draft;
        expect(d.name, 'Fried Rice');
        expect(d.ingredients.length, 3);
        expect(d.steps.length, 3);
      },
    );

    test('mọi khối đều hỏng thì null', () {
      expect(extract('only_broken_jsonld.html'), isNull);
    });
  });

  group('ảnh', () {
    test(
      'tuyệt đối hóa theo pageUrl, bỏ trùng, bỏ data: và rỗng, thêm og:image',
      () {
        final r = extract(
          'image_variants.html',
          url: 'https://site.example.test/food/dish/',
        )!;
        expect(r.imageUrls, [
          'https://site.example.test/media/hero.jpg',
          'https://cdn.example.test/a.jpg',
          'https://site.example.test/food/dish/media/relative.jpg',
          'https://cdn.example.test/extra.jpg',
        ]);
      },
    );

    test('không có pageUrl: chỉ giữ ảnh tuyệt đối http(s)', () {
      final r = extract('image_variants.html')!;
      expect(r.imageUrls, [
        'https://cdn.example.test/a.jpg',
        'https://cdn.example.test/extra.jpg',
      ]);
    });

    test('cắt còn tối đa 20 ảnh', () {
      final imgs = List.generate(
        30,
        (i) => '"https://x.test/$i.jpg"',
      ).join(',');
      final r = extractRecipeFromHtml(
        ld('{"@type":"Recipe","name":"A","image":[$imgs]}'),
      )!;
      expect(r.imageUrls.length, maxRecipePhotos);
      expect(r.imageUrls.first, 'https://x.test/0.jpg');
    });
  });

  group('giới hạn và làm sạch', () {
    test('tên dài hơn 200 ký tự bị cắt, không ném lỗi', () {
      final r = extractRecipeFromHtml(
        ld('{"@type":"Recipe","name":"${'a' * 250}"}'),
      )!;
      expect(r.draft.name.length, maxRecipeName);
    });

    test('@type chuỗi URL đầy đủ vẫn nhận ra', () {
      final r = extractRecipeFromHtml(
        ld('{"@type":"https://schema.org/Recipe","name":"X"}'),
      );
      expect(r?.draft.name, 'X');
    });

    test('Recipe lồng trong mảng ở @graph và trong mảng cấp trên', () {
      final r = extractRecipeFromHtml(
        ld('[{"@graph":[{"@type":"Thing"},{"@type":"Recipe","name":"Y"}]}]'),
      );
      expect(r?.draft.name, 'Y');
    });

    test('gộp khoảng trắng và giải mã thực thể số', () {
      final d = extractRecipeFromHtml(
        ld(
          '{"@type":"Recipe","name":"  Tom&#8217;s \\n  stew ","recipeIngredient":["a &amp;   b"]}',
        ),
      )!.draft;
      expect(d.name, 'Tom’s stew');
      expect(texts(d.ingredients), ['a & b']);
    });

    test('bước chỉ có name (không text) vẫn lấy name', () {
      final d = extractRecipeFromHtml(
        ld(
          '{"@type":"Recipe","name":"Z","recipeInstructions":[{"@type":"HowToStep","name":"Stir well"}]}',
        ),
      )!.draft;
      expect(texts(d.steps), ['Stir well']);
    });

    test('ingredients là một chuỗi nhiều dòng', () {
      final d = extractRecipeFromHtml(
        ld(
          '{"@type":"Recipe","name":"Z","recipeIngredient":"1 egg\\n2 cups milk"}',
        ),
      )!.draft;
      expect(texts(d.ingredients), ['1 egg', '2 cups milk']);
    });

    test('đơn vị khẩu phần: "Serves 4", "Makes 12 cookies", số 2.5', () {
      WebRecipe y(String v) => extractRecipeFromHtml(
        ld('{"@type":"Recipe","name":"Z","recipeYield":$v}'),
      )!;
      expect(y('"Serves 4"').draft.servings, 4);
      expect(y('"Serves 4"').draft.servingsUnit, isNull);
      expect(y('"Makes 12 cookies"').draft.servings, 12);
      expect(y('"Makes 12 cookies"').draft.servingsUnit, 'cookies');
      expect(y('2.5').draft.servings, 2.5);
      expect(y('"nhiều"').draft.servings, isNull);
      expect(y('0').draft.servings, isNull);
    });

    test('thời gian không hợp lệ hoặc bằng 0 thì null', () {
      final d = extractRecipeFromHtml(
        ld(
          '{"@type":"Recipe","name":"Z","prepTime":"soon","cookTime":"PT0M","totalTime":"PT1H30M"}',
        ),
      )!.draft;
      expect(d.prepMinutes, isNull);
      expect(d.cookMinutes, isNull);
      expect(d.totalMinutes, 90);
    });

    test('ISO 8601: tuần, giây, thập phân, chữ thường', () {
      int? t(String v) => extractRecipeFromHtml(
        ld('{"@type":"Recipe","name":"Z","totalTime":"$v"}'),
      )!.draft.totalMinutes;
      expect(t('PT45M'), 45);
      expect(t('PT1H30M'), 90);
      expect(t('P0DT1H'), 60);
      expect(t('P1DT2H'), 26 * 60);
      expect(t('P1W'), 7 * 24 * 60);
      expect(t('PT90S'), 2);
      expect(t('PT1.5H'), 90);
      expect(t('pt20m'), 20);
    });

    test('không có tên thì lấy <title>, không có cả hai thì null', () {
      final r = extractRecipeFromHtml(
        '<html><head><title>Tiêu đề trang</title>'
        '<script type="application/ld+json">{"@type":"Recipe","recipeIngredient":["a"]}</script></head></html>',
      );
      expect(r?.draft.name, 'Tiêu đề trang');
      expect(
        extractRecipeFromHtml(
          ld('{"@type":"Recipe","recipeIngredient":["a"]}'),
        ),
        isNull,
      );
    });
  });
}
