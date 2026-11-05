import 'package:cooknote/src/shopping/aisle_dictionary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tám khu vực mặc định, có tên vi và en cùng thứ tự', () {
    expect(defaultAisleKeys, [
      'produce',
      'meat',
      'dairy',
      'dry',
      'spice',
      'frozen',
      'drink',
      'other',
    ]);
    expect(defaultAisleNames('vi'), [
      'Rau củ',
      'Thịt cá',
      'Sữa trứng',
      'Đồ khô',
      'Gia vị',
      'Đông lạnh',
      'Đồ uống',
      'Khác',
    ]);
    expect(defaultAisleNames('en'), [
      'Produce',
      'Meat & fish',
      'Dairy & eggs',
      'Dry goods',
      'Spices',
      'Frozen',
      'Drinks',
      'Other',
    ]);
    expect(defaultAisleNames('fr'), defaultAisleNames('en'));
  });

  const cases = <String, String>{
    // Thịt cá
    'thịt bò': 'meat',
    'Thịt ba chỉ': 'meat',
    'sườn heo': 'meat',
    'cánh gà': 'meat',
    'cá hồi': 'meat',
    'tôm sú': 'meat',
    'mực': 'meat',
    'chicken breast': 'meat',
    'ground beef': 'meat',
    'salmon fillets': 'meat',
    'shrimp': 'meat',
    'bacon': 'meat',
    // Rau củ
    'hành tây': 'produce',
    'cà chua': 'produce',
    'rau muống': 'produce',
    'hành lá': 'produce',
    'tỏi': 'produce',
    'gừng': 'produce',
    'ớt': 'produce',
    'chanh': 'produce',
    'sả': 'produce',
    'cà rốt': 'produce',
    'nấm rơm': 'produce',
    'xà lách': 'produce',
    'rau mùi': 'produce',
    'tomatoes': 'produce',
    'garlic cloves': 'produce',
    'yellow onions': 'produce',
    'lime': 'produce',
    'potatoes': 'produce',
    'basil': 'produce',
    'bơ': 'produce',
    // Sữa trứng
    'sữa tươi': 'dairy',
    'trứng gà': 'dairy',
    'eggs': 'dairy',
    'butter': 'dairy',
    'bơ lạt': 'dairy',
    'phô mai': 'dairy',
    'cheddar cheese': 'dairy',
    'sữa chua': 'dairy',
    'yogurt': 'dairy',
    'whipping cream': 'dairy',
    'đậu hũ': 'dairy',
    // Đồ khô
    'gạo': 'dry',
    'rice': 'dry',
    'bún': 'dry',
    'mì ý': 'dry',
    'spaghetti': 'dry',
    'bột mì': 'dry',
    'all-purpose flour': 'dry',
    'đậu xanh': 'dry',
    'lentils': 'dry',
    'miến': 'dry',
    'bánh phở': 'dry',
    'nước cốt dừa': 'dry',
    'sữa đặc': 'dry',
    'canned tomatoes': 'dry',
    'đậu phộng': 'dry',
    'baking powder': 'dry',
    // Gia vị
    'muối': 'spice',
    'đường': 'spice',
    'tiêu': 'spice',
    'nước mắm': 'spice',
    'fish sauce': 'spice',
    'soy sauce': 'spice',
    'nước tương': 'spice',
    'dầu ăn': 'spice',
    'olive oil': 'spice',
    'hạt nêm': 'spice',
    'bột ngọt': 'spice',
    'cumin': 'spice',
    'quế': 'spice',
    'giấm': 'spice',
    'black pepper': 'spice',
    'sugar': 'spice',
    'salt': 'spice',
    // Đông lạnh
    'tôm đông lạnh': 'frozen',
    'frozen peas': 'frozen',
    'kem': 'frozen',
    'ice cream': 'frozen',
    // Đồ uống
    'nước ngọt': 'drink',
    'bia': 'drink',
    'beer': 'drink',
    'rượu vang': 'drink',
    'trà': 'drink',
    'orange juice': 'drink',
    'cà phê': 'drink',
    'nước dừa': 'drink',
    'sparkling water': 'drink',
    // Không rõ
    'đồ gì đó lạ': 'other',
    'widget': 'other',
  };

  test('từ điển xếp đúng nguyên liệu thông dụng', () {
    final wrong = <String>[];
    cases.forEach((name, expected) {
      final got = aisleKeyFor(name);
      if (got != expected) wrong.add('$name: $got (cần $expected)');
    });
    expect(wrong, isEmpty);
  });

  test('cụm dài hơn thắng cụm ngắn', () {
    expect(aisleKeyFor('nước mắm ngon'), 'spice');
    expect(aisleKeyFor('tôm đông lạnh'), 'frozen');
  });

  test('chuỗi rỗng là Khác', () {
    expect(aisleKeyFor(''), 'other');
    expect(aisleKeyFor('   '), 'other');
  });
}
