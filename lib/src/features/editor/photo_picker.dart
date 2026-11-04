import 'package:image_picker/image_picker.dart';

/// Chọn ảnh từ thư viện hoặc chụp bằng camera. Dùng trình chọn ảnh và ứng dụng
/// camera của hệ điều hành nên không cần quyền bộ nhớ, thư viện ảnh hay camera
/// (AC-07, D-005).
abstract class PhotoPicker {
  /// Đường dẫn các ảnh được chọn, tối đa [limit]; rỗng nếu người dùng hủy.
  Future<List<String>> pickFromGallery({required int limit});

  /// Đường dẫn ảnh vừa chụp; null nếu người dùng hủy.
  Future<String?> takePhoto();
}

class SystemPhotoPicker implements PhotoPicker {
  final _picker = ImagePicker();

  @override
  Future<List<String>> pickFromGallery({required int limit}) async {
    if (limit < 1) return const [];
    if (limit == 1) {
      final one = await _picker.pickImage(source: ImageSource.gallery);
      return [if (one != null) one.path];
    }
    final many = await _picker.pickMultiImage(limit: limit);
    return [for (final f in many) f.path];
  }

  @override
  Future<String?> takePhoto() async =>
      (await _picker.pickImage(source: ImageSource.camera))?.path;
}
