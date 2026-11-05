import 'name_match.dart';

/// Khóa của 8 khu vực mặc định, theo thứ tự hiển thị ban đầu (AC-36).
const defaultAisleKeys = [
  'produce',
  'meat',
  'dairy',
  'dry',
  'spice',
  'frozen',
  'drink',
  'other',
];

const _namesVi = {
  'produce': 'Rau củ',
  'meat': 'Thịt cá',
  'dairy': 'Sữa trứng',
  'dry': 'Đồ khô',
  'spice': 'Gia vị',
  'frozen': 'Đông lạnh',
  'drink': 'Đồ uống',
  'other': 'Khác',
};
const _namesEn = {
  'produce': 'Produce',
  'meat': 'Meat & fish',
  'dairy': 'Dairy & eggs',
  'dry': 'Dry goods',
  'spice': 'Spices',
  'frozen': 'Frozen',
  'drink': 'Drinks',
  'other': 'Other',
};

/// Tên của một khu vực mặc định theo ngôn ngữ; ngôn ngữ khác `vi` dùng tiếng
/// Anh.
String defaultAisleName(String key, String languageCode) =>
    (languageCode == 'vi' ? _namesVi : _namesEn)[key] ?? key;

/// Tên 8 khu vực mặc định theo ngôn ngữ, cùng thứ tự với [defaultAisleKeys].
List<String> defaultAisleNames(String languageCode) => [
  for (final k in defaultAisleKeys) defaultAisleName(k, languageCode),
];

// Từ điển: cụm từ (viết có dấu như người dùng gõ) → khu vực. Tra theo cụm
// dài nhất; cụm nhiều chữ dùng để gỡ nhập nhằng ("nước dừa" khác "nước cốt
// dừa", "fish sauce" khác "fish").
const _dictionary = <String, List<String>>{
  'produce': [
    // vi
    'rau', 'rau muống', 'rau mùi', 'rau răm', 'rau thơm', 'ngò', 'ngò gai',
    'húng', 'húng quế', 'tía tô', 'kinh giới', 'thì là', 'cải', 'cải thảo',
    'bắp cải', 'súp lơ', 'bông cải', 'xà lách', 'cần', 'cần tây', 'hẹ',
    'hành', 'hành tây', 'hành lá', 'hành tím', 'tỏi', 'gừng', 'riềng', 'nghệ',
    'sả', 'ớt', 'chanh', 'tắc', 'quất', 'cà chua', 'cà rốt', 'cà tím',
    'khoai', 'khoai tây', 'khoai lang', 'khoai môn', 'bí', 'bí đỏ', 'bí đao',
    'mướp', 'khổ qua', 'mướp đắng', 'dưa leo', 'dưa chuột', 'dưa hấu',
    'đậu que', 'đậu bắp', 'giá', 'giá đỗ', 'nấm', 'bắp', 'ngô', 'củ cải',
    'củ dền', 'su su', 'su hào', 'măng', 'bơ', 'chuối', 'táo', 'cam', 'quýt',
    'bưởi', 'xoài', 'dứa', 'thơm', 'ổi', 'nho', 'dâu', 'lê', 'đu đủ',
    'thanh long',
    'chôm chôm',
    'sầu riêng',
    'mít',
    'dừa',
    'trái cây',
    'lá chanh',
    'lá dứa', 'lá lốt', 'hoa chuối',
    // en
    'vegetable', 'fruit', 'onion', 'green onion', 'scallion', 'shallot',
    'garlic',
    'garlic clove',
    'ginger',
    'chili',
    'chilli',
    'tomato',
    'potato',
    'sweet potato',
    'carrot', 'celery', 'cucumber', 'lettuce', 'spinach', 'kale', 'cabbage',
    'broccoli', 'cauliflower', 'zucchini', 'eggplant', 'bell pepper',
    'jalapeno', 'mushroom', 'corn', 'pea', 'green bean', 'bean sprout',
    'lemon', 'lime', 'orange', 'apple', 'banana', 'avocado', 'mango',
    'pineapple', 'strawberry', 'blueberry', 'berry', 'grape', 'pear', 'peach',
    'basil', 'cilantro', 'coriander', 'parsley', 'mint', 'dill', 'thyme',
    'rosemary', 'lemongrass', 'herb', 'leek', 'radish', 'beet', 'squash',
    'pumpkin', 'asparagus', 'arugula',
  ],
  'meat': [
    // vi
    'thịt', 'thịt bò', 'thịt heo', 'thịt lợn', 'thịt gà', 'thịt ba chỉ', 'bò',
    'heo', 'lợn', 'gà', 'vịt', 'ngan', 'dê', 'cừu', 'sườn', 'giò', 'chả',
    'xúc xích', 'lạp xưởng', 'gan', 'tim', 'cật', 'lòng', 'xương', 'cá',
    'cá hồi',
    'cá thu',
    'cá basa',
    'tôm',
    'tép',
    'cua',
    'ghẹ',
    'mực',
    'bạch tuộc',
    'nghêu', 'ngao', 'sò', 'hến', 'ốc', 'hàu', 'hải sản', 'chả cá',
    // en
    'meat', 'beef', 'pork', 'chicken', 'turkey', 'duck', 'lamb', 'mutton',
    'veal', 'bacon', 'ham', 'sausage', 'mince', 'steak', 'rib', 'wing',
    'thigh', 'fish', 'salmon', 'tuna', 'cod', 'tilapia', 'shrimp', 'prawn',
    'crab', 'lobster', 'squid', 'octopus', 'clam', 'mussel', 'oyster',
    'scallop', 'seafood', 'anchovy',
  ],
  'dairy': [
    // vi
    'sữa', 'sữa tươi', 'sữa chua', 'sữa không đường', 'trứng', 'trứng gà',
    'trứng vịt', 'trứng cút', 'phô mai', 'phô-mai', 'bơ lạt', 'bơ mặn',
    'bơ thực vật', 'kem tươi', 'kem sữa', 'váng sữa', 'đậu hũ', 'đậu phụ',
    'tàu hũ',
    // en
    'milk', 'egg', 'cheese', 'butter', 'cream', 'whipping cream',
    'heavy cream', 'sour cream', 'yogurt', 'yoghurt', 'buttermilk', 'tofu',
    'margarine', 'mozzarella', 'parmesan', 'ricotta', 'mascarpone',
    'cream cheese',
  ],
  'dry': [
    // vi
    'gạo', 'gạo nếp', 'nếp', 'bún', 'phở', 'bánh phở', 'miến', 'mì', 'mỳ',
    'mì ý', 'nui', 'hủ tiếu', 'bánh tráng', 'bánh đa', 'bột', 'bột mì',
    'bột năng', 'bột gạo', 'bột nở', 'bột nổi', 'men nở', 'đậu xanh', 'đậu đen',
    'đậu đỏ', 'đậu nành', 'đậu phộng', 'lạc', 'mè', 'vừng', 'hạt điều',
    'hạnh nhân', 'óc chó', 'yến mạch', 'ngũ cốc', 'nước cốt dừa', 'sữa đặc',
    'đồ hộp', 'cá hộp', 'nấm khô', 'mộc nhĩ', 'nấm mèo', 'táo đỏ', 'kỷ tử',
    'bánh mì', 'socola', 'sô cô la', 'mật ong',
    // en
    'rice', 'pasta', 'spaghetti', 'noodle', 'macaroni', 'penne', 'flour',
    'all-purpose flour', 'bread', 'breadcrumb', 'oat', 'cereal', 'bean',
    'black bean', 'chickpea', 'lentil', 'quinoa', 'couscous', 'nut', 'almond',
    'walnut', 'peanut', 'cashew', 'sesame', 'baking powder', 'baking soda',
    'yeast', 'cornstarch', 'cocoa', 'chocolate', 'honey', 'coconut milk',
    'condensed milk', 'canned', 'tortilla', 'cracker',
  ],
  'spice': [
    // vi
    'muối', 'đường', 'tiêu', 'hạt tiêu', 'nước mắm', 'nước tương', 'xì dầu',
    'dầu ăn', 'dầu', 'dầu hào', 'dầu mè', 'dầu ô liu', 'hạt nêm', 'bột ngọt',
    'mì chính', 'bột canh', 'giấm', 'mắm', 'mắm tôm', 'mắm ruốc', 'tương',
    'tương ớt', 'tương cà', 'sa tế', 'quế', 'hồi', 'đại hồi', 'thảo quả',
    'đinh hương', 'ngũ vị hương', 'bột cà ri', 'cà ri', 'nghệ bột', 'gia vị',
    'me', 'đường phèn', 'đường thốt nốt', 'tỏi phi', 'hành phi', 'bột ớt',
    // en
    'salt', 'sugar', 'brown sugar', 'pepper', 'black pepper', 'oil',
    'olive oil', 'vegetable oil', 'sesame oil', 'vinegar', 'soy sauce',
    'fish sauce', 'oyster sauce', 'hoisin', 'sriracha', 'ketchup', 'mustard',
    'mayonnaise', 'sauce', 'spice', 'cumin', 'paprika', 'cinnamon', 'nutmeg',
    'oregano', 'curry', 'turmeric', 'clove', 'star anise', 'bay leaf',
    'vanilla', 'stock', 'broth', 'bouillon', 'seasoning', 'chili flake',
    'chili powder',
  ],
  'frozen': [
    'kem',
    'kem que',
    'kem ly',
    'đá viên',
    'ice',
    'ice cream',
    'frozen',
  ],
  'drink': [
    // vi
    'nước ngọt', 'nước suối', 'nước khoáng', 'nước dừa', 'nước ép',
    'nước cam', 'bia', 'rượu', 'rượu vang', 'trà', 'chè xanh', 'cà phê',
    'sữa đậu nành',
    // en
    'water', 'sparkling water', 'soda', 'juice', 'orange juice', 'beer',
    'wine', 'tea', 'coffee', 'lemonade', 'cola', 'kombucha',
  ],
};

// Dấu hiệu đổi khu vực bất kể tên món: "tôm đông lạnh", "frozen peas",
// "canned tomatoes", "nấm khô".
const _markers = <String, List<String>>{
  'frozen': ['đông lạnh', 'đông đá', 'frozen'],
  'dry': ['canned', 'đóng hộp', 'khô', 'dried'],
};

final Map<String, String> _accented = {};
final Map<String, String> _folded = {};

void _ensureBuilt() {
  if (_accented.isNotEmpty) return;
  for (final e in _dictionary.entries) {
    for (final phrase in e.value) {
      _accented.putIfAbsent(accentKey(phrase), () => e.key);
      _folded.putIfAbsent(foldKey(phrase), () => e.key);
    }
  }
}

/// Khu vực của cụm dài nhất trong [words] có trong [table]. Cùng độ dài:
/// tên có dấu (tiếng Việt, danh từ chính đứng trước) lấy cụm đầu; tên không
/// dấu (tiếng Anh, danh từ chính đứng sau) lấy cụm cuối.
String? _longest(
  List<String> words,
  Map<String, String> table, {
  required bool headFirst,
}) {
  for (var len = words.length; len >= 1; len--) {
    String? found;
    for (var i = 0; i + len <= words.length; i++) {
      final hit = table[words.sublist(i, i + len).join(' ')];
      if (hit != null) {
        found = hit;
        if (headFirst) break;
      }
    }
    if (found != null) return found;
  }
  return null;
}

bool _hasMarker(String accented, String folded, List<String> markers) {
  final aw = ' $accented ';
  final fw = ' $folded ';
  for (final m in markers) {
    if (aw.contains(' ${accentKey(m)} ')) return true;
    if (accentKey(m) == foldKey(m) && fw.contains(' ${foldKey(m)} ')) {
      return true;
    }
  }
  return false;
}

/// Khu vực mặc định của một món theo từ điển tiếng Việt và tiếng Anh (AC-36);
/// không nhận ra thì `other`. Lựa chọn của người dùng được nhớ riêng (kho
/// đi chợ), tra trước từ điển này.
String aisleKeyFor(String name) {
  _ensureBuilt();
  final accented = accentKey(name);
  if (accented.isEmpty) return 'other';
  final folded = foldKey(name);
  for (final e in _markers.entries) {
    if (_hasMarker(accented, folded, e.value)) return e.key;
  }
  final hasAccents = accented != folded;
  final hit = hasAccents
      ? _longest(accented.split(' '), _accented, headFirst: true) ??
            _longest(folded.split(' '), _folded, headFirst: true)
      : _longest(folded.split(' '), _folded, headFirst: false);
  return hit ?? 'other';
}
