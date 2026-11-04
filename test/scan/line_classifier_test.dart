import 'package:cooknote/src/scan/line_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

// Các mẩu văn bản dưới đây do tự viết để mô phỏng đầu ra OCR (có lỗi OCR cố
// ý: l thay 1, O thay 0, gạch đầu dòng rác, số trang), không chép từ trang thật.

List<LineRole> roles(List<String> lines) =>
    classifyRecipeLines(lines).map((l) => l.role).toList();

List<String> texts(List<String> lines) =>
    classifyRecipeLines(lines).map((l) => l.text).toList();

void main() {
  const t = LineRole.title;
  const h = LineRole.heading;
  const i = LineRole.ingredient;
  const s = LineRole.step;
  const n = LineRole.note;
  const x = LineRole.noise;

  group('tiếng Việt', () {
    test('1. công thức cơ bản, l thành 1', () {
      final lines = [
        'PHỞ BÒ NHÀ LÀM',
        'Nguyên liệu:',
        '500 g thịt bò',
        'l củ hành tây',
        '2 thìa nước mắm',
        'Cách làm:',
        '1. Ninh xương 2 giờ.',
        '2. Cho bò vào tô, chan nước dùng.',
      ];
      expect(roles(lines), [t, h, i, i, i, h, s, s]);
      final out = texts(lines);
      expect(out[3], '1 củ hành tây');
      expect(out[6], 'Ninh xương 2 giờ.');
    });

    test('2. gạch đầu dòng rác, O thành 0, số trang cuối', () {
      final lines = [
        'Bánh bông lan',
        'Nguyên liệu',
        '• 200g bột mì',
        '- O,5 kg đường',
        '~ 3 quả trứng',
        '12',
      ];
      expect(roles(lines), [t, h, i, i, i, x]);
      final out = texts(lines);
      expect(out[2], '200g bột mì');
      expect(out[3], '0,5 kg đường');
      expect(out[4], '3 quả trứng');
    });

    test('3. "Bước N" và "Trang N"', () {
      final lines = [
        'Bánh flan',
        'Thành phần',
        '4 quả trứng',
        '500ml sữa tươi',
        'Các bước',
        'Bước 1: Đánh trứng với đường.',
        'Bước 2 Hấp 20 phút',
        'Trang 3',
      ];
      expect(roles(lines), [t, h, i, i, h, s, s, x]);
      expect(texts(lines)[5], 'Đánh trứng với đường.');
      expect(texts(lines)[6], 'Hấp 20 phút');
    });

    test('4. tiêu đề nhóm bị đọc sai l thành I', () {
      final lines = [
        'Gà kho gừng',
        'Nguyên Iiệu:',
        'Muối, tiêu vừa đủ',
        '1 củ gừng',
      ];
      expect(roles(lines), [t, h, i, i]);
    });

    test('5. ghi chú và thông tin phụ', () {
      final lines = [
        'Chè đậu xanh',
        'Thời gian: 30 phút',
        'Nguyên liệu',
        '200 g đậu xanh',
        'Cách làm',
        'Nấu đậu cho mềm rồi thêm đường.',
        'Ghi chú:',
        'Có thể thay đường bằng mật ong.',
      ];
      expect(roles(lines), [t, n, h, i, h, s, h, n]);
    });

    test('6. không có tiêu đề nhóm, chỉ số lượng và số thứ tự', () {
      final lines = [
        'Nước chanh',
        '2 quả chanh',
        '3 thìa đường',
        '1. Vắt chanh.',
        '2. Thêm đường và nước.',
      ];
      expect(roles(lines), [t, i, i, s, s]);
    });

    test('7. câu bị ngắt dòng vẫn là bước', () {
      final lines = [
        'Cách làm',
        '1. Cho bò vào tô, chan',
        'nước dùng nóng.',
        '2. Rắc hành ngò.',
      ];
      expect(roles(lines), [h, s, s, s]);
    });

    test('8. quên tiêu đề "Cách làm": số thứ tự chuyển sang bước', () {
      final lines = [
        'Bánh mì nướng',
        'Nguyên liệu:',
        '2 lát bánh mì',
        '1 thìa bơ',
        '1. Phết bơ lên bánh.',
        '2. Nướng 3 phút.',
      ];
      expect(roles(lines), [t, h, i, i, s, s]);
    });
  });

  group('tiếng Anh', () {
    test('9. cơ bản, l thành 1', () {
      final lines = [
        'Pancakes',
        'Ingredients',
        '1 cup all-purpose flour',
        '2 tbsp sugar',
        'l tsp baking powder',
        'Directions',
        '1. Whisk the dry ingredients together.',
        '2) Pour in milk and cook until golden.',
      ];
      expect(roles(lines), [t, h, i, i, i, h, s, s]);
      expect(texts(lines)[4], '1 tsp baking powder');
      expect(texts(lines)[7], 'Pour in milk and cook until golden.');
    });

    test('10. tiêu đề đọc sai, ký tự rác, "Page 2/4"', () {
      final lines = [
        'Garlic Butter Shrimp',
        'Ingredlents',
        '* 1/2 cup butter',
        '~ 3 cloves garlic, minced',
        'Method',
        '1.Preheat the oven to 180 C.',
        'Page 2/4',
      ];
      expect(roles(lines), [t, h, i, i, h, s, x]);
      expect(texts(lines)[5], 'Preheat the oven to 180 C.');
    });

    test('11. Serves, Notes', () {
      final lines = [
        'Tomato Soup',
        'Serves 4',
        'Ingredients',
        '4 ripe tomatoes',
        'Salt to taste',
        'Instructions',
        'Simmer the tomatoes for 20 minutes.',
        'Notes',
        'Best served hot.',
      ];
      expect(roles(lines), [t, n, h, i, i, h, s, h, n]);
    });

    test('12. danh sách nguyên liệu có đánh số, phân số', () {
      final lines = [
        'Ingredients:',
        '1. 200 g flour',
        '2. ½ cup sugar',
        '3. 1 1/2 tsp salt',
        'Directions:',
        '1. Mix everything.',
      ];
      expect(roles(lines), [h, i, i, i, h, s]);
      expect(texts(lines)[1], '200 g flour');
    });
  });

  group('trường hợp biên', () {
    test('13. toàn rác và số trang', () {
      expect(roles(['  ', '~~~', '12', '|', 'Trang 5']), [x, x, x, x]);
    });

    test('14. danh sách rỗng', () {
      expect(classifyRecipeLines([]), isEmpty);
    });

    test('15. độ tin cậy nằm trong [0, 1], tiêu đề nhóm tin cậy cao', () {
      final out = classifyRecipeLines([
        'Pancakes',
        'Ingredients',
        '1 cup flour',
        'Directions',
        '1. Mix.',
        '~~',
      ]);
      for (final l in out) {
        expect(l.confidence, inInclusiveRange(0.0, 1.0));
      }
      expect(out[1].confidence, greaterThanOrEqualTo(0.9));
    });

    test('16. dòng đầu dài như một câu không thành tên', () {
      final lines = [
        'Trộn đều bột với trứng rồi để yên trong nửa giờ cho nở hết cỡ.',
      ];
      expect(roles(lines).single, isNot(t));
    });
  });
}
