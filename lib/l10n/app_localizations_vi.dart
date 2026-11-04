// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'CookNote';

  @override
  String get tabRecipes => 'Công thức';

  @override
  String get tabMenu => 'Thực đơn';

  @override
  String get tabShopping => 'Đi chợ';

  @override
  String get tabPantry => 'Tủ bếp';

  @override
  String get tabMore => 'Thêm';

  @override
  String get comingSoon => 'Sẽ có ở phiên bản sau';

  @override
  String get noRecipes => 'Chưa có công thức nào';

  @override
  String get noRecipesHint => 'Bấm + để thêm công thức đầu tiên';

  @override
  String get addRecipe => 'Thêm công thức';

  @override
  String get addManual => 'Tự viết';

  @override
  String get fromWeb => 'Từ trang web';

  @override
  String get scanPhoto => 'Quét từ ảnh';

  @override
  String get importFile => 'Nhập từ file';

  @override
  String get newRecipe => 'Công thức mới';

  @override
  String get editRecipe => 'Sửa công thức';

  @override
  String get save => 'Lưu';

  @override
  String get discardTitle => 'Bỏ thay đổi?';

  @override
  String get discardBody => 'Các thay đổi của công thức này chưa được lưu.';

  @override
  String get keepEditing => 'Tiếp tục sửa';

  @override
  String get discard => 'Bỏ';

  @override
  String get name => 'Tên';

  @override
  String get nameRequired => 'Hãy nhập tên';

  @override
  String get nameTooLong => 'Tối đa 200 ký tự';

  @override
  String get servings => 'Khẩu phần';

  @override
  String get servingsUnit => 'Đơn vị (ví dụ người)';

  @override
  String get prepTime => 'Sơ chế (phút)';

  @override
  String get cookTime => 'Nấu (phút)';

  @override
  String get totalTime => 'Tổng (phút)';

  @override
  String get source => 'Nguồn';

  @override
  String get sourceUrl => 'Liên kết nguồn';

  @override
  String get notes => 'Ghi chú';

  @override
  String get nutrition => 'Dinh dưỡng';

  @override
  String get difficulty => 'Độ khó';

  @override
  String get difficultyNone => 'Chưa đặt';

  @override
  String get difficultyEasy => 'Dễ';

  @override
  String get difficultyMedium => 'Vừa';

  @override
  String get difficultyHard => 'Khó';

  @override
  String get rating => 'Đánh giá';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trên 5 sao',
      zero: 'Chưa đánh giá',
    );
    return '$_temp0';
  }

  @override
  String get favorite => 'Yêu thích';

  @override
  String get ingredients => 'Nguyên liệu';

  @override
  String get steps => 'Các bước';

  @override
  String get ingredientsHint =>
      'Mỗi dòng một nguyên liệu. Dòng kết thúc bằng : là tiêu đề nhóm.';

  @override
  String get stepsHint =>
      'Mỗi dòng một bước. Dòng kết thúc bằng : là tiêu đề nhóm.';

  @override
  String get photos => 'Ảnh';

  @override
  String get addPhotos => 'Thêm ảnh';

  @override
  String get fromGallery => 'Từ thư viện';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get removePhoto => 'Gỡ ảnh';

  @override
  String get coverPhoto => 'Ảnh bìa';

  @override
  String get tooManyPhotos => 'Mỗi công thức tối đa 20 ảnh';

  @override
  String get imageError => 'Không đọc được file này thành ảnh';

  @override
  String get edit => 'Sửa';

  @override
  String get delete => 'Xóa';

  @override
  String get deleteTitle => 'Xóa công thức này?';

  @override
  String get deleteBody => 'Công thức vào thùng rác và bị xóa hẳn sau 30 ngày.';

  @override
  String get deletedMessage => 'Đã xóa công thức';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get cancel => 'Hủy';

  @override
  String get duplicate => 'Nhân bản';

  @override
  String get duplicated => 'Đã tạo bản sao';

  @override
  String get copyLabel => 'bản sao';

  @override
  String get trash => 'Thùng rác';

  @override
  String get trashEmpty => 'Thùng rác trống';

  @override
  String get trashInfo => 'Công thức bị xóa hẳn sau 30 ngày kể từ lúc xóa.';

  @override
  String get restore => 'Khôi phục';

  @override
  String get deleteForever => 'Xóa hẳn';

  @override
  String get deleteForeverBody => 'Công thức này và ảnh của nó sẽ bị xóa hẳn.';

  @override
  String get restored => 'Đã khôi phục công thức';

  @override
  String get notFound => 'Công thức này không còn nữa';

  @override
  String minutesShort(int count) {
    return '$count phút';
  }

  @override
  String get settings => 'Cài đặt';

  @override
  String get theme => 'Giao diện';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get openLinkError => 'Không mở được liên kết này';
}
