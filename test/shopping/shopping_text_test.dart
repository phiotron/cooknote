import 'package:cooknote/src/shopping/shopping_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chia sẻ dạng chữ: tiêu đề, nhóm theo khu vực, mỗi món một dòng', () {
    final text = shoppingListToText(
      title: 'Siêu thị',
      groups: [
        (aisle: 'Thịt cá', lines: ['500 g thịt bò', 'cá hồi']),
        (aisle: 'Rau củ', lines: ['2 củ hành']),
      ],
    );
    expect(
      text,
      'Siêu thị\n\nThịt cá\n- 500 g thịt bò\n- cá hồi\n\nRau củ\n- 2 củ hành\n',
    );
  });

  test('bỏ nhóm rỗng', () {
    final text = shoppingListToText(
      title: 'A',
      groups: [
        (aisle: 'X', lines: <String>[]),
        (aisle: 'Y', lines: ['z']),
      ],
    );
    expect(text, 'A\n\nY\n- z\n');
  });
}
