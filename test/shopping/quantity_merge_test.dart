import 'package:cooknote/src/cooking/ingredient_parser.dart';
import 'package:cooknote/src/shopping/quantity_merge.dart';
import 'package:flutter_test/flutter_test.dart';

Quantity q(double? v, IngredientUnit? u, [String? text]) =>
    Quantity(v, u, text);

void main() {
  test('cùng loại đơn vị thì cộng: 200 g + 300 g = 500 g', () {
    final m = mergeQuantities(
      q(200, IngredientUnit.g),
      q(300, IngredientUnit.g),
    );
    expect(m!.value, 500);
    expect(m.unit, IngredientUnit.g);
    expect(formatQuantityText(m), '500 g');
  });

  test('khối lượng khác đơn vị vẫn cùng loại, lên kg khi từ 1000 g', () {
    final a = mergeQuantities(
      q(800, IngredientUnit.g),
      q(400, IngredientUnit.g),
    )!;
    expect(a.unit, IngredientUnit.kg);
    expect(a.value, closeTo(1.2, 1e-9));
    final b = mergeQuantities(
      q(1, IngredientUnit.kg),
      q(500, IngredientUnit.g),
    )!;
    expect(b.unit, IngredientUnit.kg);
    expect(b.value, closeTo(1.5, 1e-9));
    final c = mergeQuantities(
      q(1.5, IngredientUnit.kg),
      q(250, IngredientUnit.g),
    )!;
    expect(c.value, closeTo(1.75, 1e-9));
  });

  test('thể tích: ml và l cộng được', () {
    final m = mergeQuantities(
      q(500, IngredientUnit.ml),
      q(1, IngredientUnit.l),
    )!;
    expect(m.unit, IngredientUnit.l);
    expect(m.value, closeTo(1.5, 1e-9));
  });

  test('hệ Mỹ giữ hệ Mỹ', () {
    final m = mergeQuantities(
      q(1, IngredientUnit.lb),
      q(8, IngredientUnit.oz),
    )!;
    expect(m.unit, IngredientUnit.lb);
    expect(m.value, closeTo(1.5, 1e-3));
    final same = mergeQuantities(
      q(1, IngredientUnit.cup),
      q(2, IngredientUnit.cup),
    )!;
    expect(same.value, 3);
    expect(same.unit, IngredientUnit.cup);
  });

  test('đơn vị đếm giống nhau cộng, khác nhau thì không gộp', () {
    final m = mergeQuantities(
      q(2, IngredientUnit.cu),
      q(3, IngredientUnit.cu),
    )!;
    expect(m.value, 5);
    expect(formatQuantityText(m), '5 củ');
    expect(
      mergeQuantities(q(2, IngredientUnit.cu), q(1, IngredientUnit.qua)),
      isNull,
    );
    expect(
      mergeQuantities(q(200, IngredientUnit.g), q(2, IngredientUnit.cu)),
      isNull,
    );
    expect(
      mergeQuantities(q(200, IngredientUnit.g), q(200, IngredientUnit.ml)),
      isNull,
    );
  });

  test('không đơn vị với không đơn vị cộng được', () {
    final m = mergeQuantities(q(3, null), q(2, null))!;
    expect(m.value, 5);
    expect(formatQuantityText(m), '5');
  });

  test('không số lượng gộp với cái nào cùng tên, giữ số lượng có sẵn', () {
    final a = mergeQuantities(q(null, null), q(2, IngredientUnit.cu))!;
    expect(a.value, 2);
    expect(a.unit, IngredientUnit.cu);
    final b = mergeQuantities(q(2, IngredientUnit.cu), q(null, null))!;
    expect(b.value, 2);
    final c = mergeQuantities(q(null, null), q(null, null))!;
    expect(c.value, isNull);
    expect(formatQuantityText(c), '');
  });

  test('giữ chữ đơn vị người dùng viết khi cùng đơn vị', () {
    final m = mergeQuantities(
      q(1, IngredientUnit.tbsp, 'muỗng canh'),
      q(2, IngredientUnit.tbsp, 'tbsp'),
    )!;
    expect(m.value, 3);
    expect(formatQuantityText(m), '3 muỗng canh');
  });

  test('định dạng: phân số cho hệ Mỹ, dấu phẩy thập phân tiếng Việt', () {
    expect(formatQuantityText(q(1.5, IngredientUnit.cup)), '1 1/2 cup');
    expect(formatQuantityText(q(1.2, IngredientUnit.kg)), '1.2 kg');
    expect(
      formatQuantityText(q(1.2, IngredientUnit.kg), decimalComma: true),
      '1,2 kg',
    );
  });

  test('unitClassOf', () {
    expect(unitClassOf(IngredientUnit.g), unitClassOf(IngredientUnit.oz));
    expect(unitClassOf(IngredientUnit.ml), unitClassOf(IngredientUnit.tsp));
    expect(
      unitClassOf(IngredientUnit.g),
      isNot(unitClassOf(IngredientUnit.ml)),
    );
    expect(unitClassOf(null), isNot(unitClassOf(IngredientUnit.cu)));
  });
}
