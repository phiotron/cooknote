// Mẫu TỔNG HỢP dựng bằng mã, theo cấu trúc tra cứu được từ tài liệu công khai.
// Đây KHÔNG phải file xuất thật của Paprika / Recipe Keeper.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// JPEG tối thiểu (chỉ cần đúng chữ ký FF D8 FF để nhận dạng).
final Uint8List fakeJpeg = Uint8List.fromList([
  0xFF, 0xD8, 0xFF, 0xE0, 0, 0x10, 0x4A, 0x46, 0x49, 0x46, 0, 1, 2, 3, 4, //
  0xFF, 0xD9,
]);

/// PNG tối thiểu (chỉ chữ ký 8 byte + vài byte).
final Uint8List fakePng = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  9,
  9,
  9,
  9,
]);

Map<String, Object?> paprikaRecipe({
  String name = 'Phở bò',
  String uid = 'UID-0001',
  Object? photoData,
  List<Map<String, Object?>> photos = const [],
}) => {
  'uid': uid,
  'name': name,
  'ingredients': 'Nước dùng:\n1 kg xương bò\n200 g bánh phở\n',
  'directions': 'Hầm xương 3 giờ.\n\nChan nước dùng vào tô.',
  'notes': 'Ăn nóng.',
  'description': '',
  'servings': '4 phần',
  'prep_time': '20 min',
  'cook_time': '3 hr 10 min',
  'total_time': '',
  'source': 'Bà ngoại',
  'source_url': 'https://example.com/pho',
  'rating': 4,
  'categories': ['Món nước', 'Món chính'],
  'difficulty': 'Medium',
  'nutritional_info': '450 kcal',
  'created': '2020-05-17 08:30:00',
  'photo_data': photoData,
  'photos': photos,
};

List<int> gz(Map<String, Object?> json) =>
    GZipEncoder().encodeBytes(utf8.encode(jsonEncode(json)));

Uint8List zipOf(Map<String, List<int>> files) {
  final archive = Archive();
  files.forEach((n, b) => archive.addFile(ArchiveFile(n, b.length, b)));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

/// File `.paprikarecipes` tổng hợp: zip các `*.paprikarecipe` (JSON gzip).
Uint8List paprikaFile(Map<String, List<int>> entries) => zipOf(entries);
