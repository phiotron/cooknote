import 'dart:convert';

import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:cooknote/src/exchange/imported_recipe.dart';
import 'package:cooknote/src/exchange/schema_org_json.dart';
import 'package:flutter_test/flutter_test.dart';

import 'exchange_samples.dart';

ImportedRecipe sample({String name = 'Phở bò', String? uid}) => ImportedRecipe(
  draft: RecipeDraft(
    name: name,
    servings: 4,
    servingsUnit: 'phần',
    prepMinutes: 20,
    cookMinutes: 190,
    totalMinutes: 210,
    source: 'Bà ngoại',
    sourceUrl: 'https://example.com/pho',
    notes: 'Ăn nóng.\nThêm hành.',
    nutrition: '450 kcal',
    rating: 4,
    ingredients: const [
      RecipeLine('Nước dùng', isHeading: true),
      RecipeLine('1 kg xương bò'),
      RecipeLine('Bánh', isHeading: true),
      RecipeLine('200 g bánh phở'),
    ],
    steps: const [
      RecipeLine('Chuẩn bị xương.'),
      RecipeLine('Nấu nước', isHeading: true),
      RecipeLine('Hầm 3 giờ.'),
      RecipeLine('Nêm nếm.'),
      RecipeLine('Lắp tô', isHeading: true),
      RecipeLine('Chan nước.'),
    ],
    tags: const ['việt', 'súp'],
  ),
  photos: const [],
  categoryNames: const ['Món nước'],
  sourceUid: uid,
  createdAt: DateTime.utc(2020, 5, 17, 8, 30),
  dedupeKey: 'k',
);

void main() {
  test('khứ hồi một công thức giữ mọi trường (AC-45)', () {
    final json = exportRecipesAsSchemaOrg([sample()]);
    final map = jsonDecode(json) as Map<String, dynamic>;
    expect(map['@type'], 'Recipe');
    expect(map['prepTime'], 'PT20M');
    expect(map['cookTime'], 'PT3H10M');
    expect(map['totalTime'], 'PT3H30M');
    final back = importSchemaOrgJson(json).single;
    final a = sample().draft, b = back.draft;
    expect(b.name, a.name);
    expect(b.ingredients, a.ingredients);
    expect(b.steps, a.steps);
    expect(b.servings, 4);
    expect(b.servingsUnit, 'phần');
    expect(b.prepMinutes, 20);
    expect(b.cookMinutes, 190);
    expect(b.totalMinutes, 210);
    expect(b.notes, a.notes);
    expect(b.source, a.source);
    expect(b.sourceUrl, a.sourceUrl);
    expect(b.rating, 4);
    expect(b.nutrition, a.nutrition);
    expect(b.tags, a.tags);
    expect(back.categoryNames, ['Món nước']);
    expect(back.createdAt, DateTime.utc(2020, 5, 17, 8, 30));
  });

  test('khứ hồi nhiều công thức; dedupeKey ổn định', () {
    final json = exportRecipesAsSchemaOrg([
      sample(),
      sample(name: 'Bún bò', uid: 'U2'),
    ]);
    expect(jsonDecode(json), isA<List<dynamic>>());
    final back = importSchemaOrgJson(json);
    expect(back.map((r) => r.draft.name), ['Phở bò', 'Bún bò']);
    expect(back[1].sourceUid, 'U2');
    expect(
      importSchemaOrgJson(json).map((r) => r.dedupeKey),
      back.map((r) => r.dedupeKey),
    );
    expect(back[0].dedupeKey, isNot(back[1].dedupeKey));
  });

  test('ảnh xuất dạng data URI rồi nhập lại', () {
    final r = ImportedRecipe(
      draft: const RecipeDraft(name: 'X'),
      photos: [ImportedPhoto('p.jpg', fakeJpeg)],
      categoryNames: const [],
      dedupeKey: 'k',
    );
    final json = exportRecipesAsSchemaOrg([r], includePhotos: true);
    expect(importSchemaOrgJson(json).single.photos.single.bytes, fakeJpeg);
    expect(
      importSchemaOrgJson(exportRecipesAsSchemaOrg([r])).single.photos,
      isEmpty,
    );
  });

  test('nhập mảng, @graph và đối tượng lẻ từ web', () {
    const one = {
      '@type': 'Recipe',
      'name': 'Bánh',
      'recipeYield': ['6', '6 cái'],
      'recipeIngredient': ['2 trứng', '100 g bột'],
      'recipeInstructions': 'Trộn.\nNướng.',
      'prepTime': 'PT10M',
      'aggregateRating': {'ratingValue': '4.6', 'bestRating': '5'},
      'author': {'@type': 'Person', 'name': 'Lan'},
      'keywords': 'ngọt, nướng',
      'recipeCategory': 'Tráng miệng',
    };
    final single = importSchemaOrgJson(jsonEncode(one)).single;
    expect(single.draft.name, 'Bánh');
    expect(single.draft.servings, 6);
    expect(single.draft.servingsUnit, 'cái');
    expect(single.draft.steps.map((l) => l.text), ['Trộn.', 'Nướng.']);
    expect(single.draft.rating, 5);
    expect(single.draft.source, 'Lan');
    expect(single.draft.tags, ['ngọt', 'nướng']);
    expect(single.categoryNames, ['Tráng miệng']);

    final graph = jsonEncode({
      '@context': 'https://schema.org',
      '@graph': [
        {'@type': 'WebSite', 'name': 'Trang'},
        {
          '@type': ['Recipe'],
          'name': 'Chè',
          'recipeInstructions': [
            {
              '@type': 'HowToSection',
              'name': 'Nấu',
              'itemListElement': [
                {'@type': 'HowToStep', 'text': 'Đun sôi.'},
              ],
            },
          ],
        },
      ],
    });
    final g = importSchemaOrgJson(graph).single;
    expect(g.draft.name, 'Chè');
    expect(g.draft.steps, [
      const RecipeLine('Nấu', isHeading: true),
      const RecipeLine('Đun sôi.'),
    ]);

    final arr = jsonEncode([
      one,
      {...one, 'name': 'Bánh 2'},
    ]);
    expect(importSchemaOrgJson(arr), hasLength(2));
  });

  test('báo cáo: mục không phải Recipe hoặc thiếu tên bị bỏ', () {
    final res = importSchemaOrgJsonWithReport(
      jsonEncode([
        {'@type': 'Recipe', 'name': ''},
        {'@type': 'Recipe', 'name': 'Ok'},
        {'@type': 'Person', 'name': 'Không phải'},
      ]),
    );
    expect(res.recipes.single.draft.name, 'Ok');
    expect(res.report.skipped, 1);
  });

  test('JSON hỏng ném ImportFormatException; xuất rỗng là []', () {
    expect(
      () => importSchemaOrgJson('{không phải json'),
      throwsA(isA<ImportFormatException>()),
    );
    expect(exportRecipesAsSchemaOrg([]), '[]');
  });
}
