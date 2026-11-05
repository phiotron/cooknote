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

  @override
  String get searchHint => 'Tìm công thức';

  @override
  String get clearSearch => 'Xóa ô tìm';

  @override
  String get filter => 'Lọc';

  @override
  String filterWithCount(int count) {
    return 'Lọc ($count)';
  }

  @override
  String get sort => 'Sắp xếp';

  @override
  String get sortName => 'Tên';

  @override
  String get sortCreated => 'Ngày thêm';

  @override
  String get sortUpdated => 'Ngày sửa';

  @override
  String get sortRating => 'Đánh giá';

  @override
  String get sortCookTime => 'Thời gian nấu';

  @override
  String get sortLastCooked => 'Lần nấu gần nhất';

  @override
  String get sortAscending => 'Tăng dần';

  @override
  String get sortDescending => 'Giảm dần';

  @override
  String get viewGrid => 'Xem dạng lưới';

  @override
  String get viewList => 'Xem dạng dòng';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count công thức',
      zero: 'Không có công thức nào',
    );
    return '$_temp0';
  }

  @override
  String get noMatch => 'Không có công thức nào khớp';

  @override
  String get clearFilters => 'Xóa bộ lọc';

  @override
  String get filterCategories => 'Danh mục';

  @override
  String get filterTags => 'Thẻ';

  @override
  String get filterMinRating => 'Số sao tối thiểu';

  @override
  String get filterFavorite => 'Chỉ công thức yêu thích';

  @override
  String get filterMaxTime => 'Tổng thời gian tối đa';

  @override
  String get filterIngredient => 'Có nguyên liệu';

  @override
  String get anyTime => 'Bất kỳ';

  @override
  String get done => 'Xong';

  @override
  String get categories => 'Danh mục';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get addSubCategory => 'Thêm danh mục con';

  @override
  String get renameCategory => 'Đổi tên';

  @override
  String get deleteCategory => 'Xóa danh mục';

  @override
  String get deleteCategoryBody =>
      'Các danh mục con cũng bị xóa. Công thức không bị xóa.';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get categoryNameInvalid => 'Nhập tên từ 1 đến 50 ký tự';

  @override
  String get categoryDepthLimit => 'Danh mục chỉ lồng tối đa 3 cấp';

  @override
  String get categoriesEmpty => 'Chưa có danh mục nào';

  @override
  String get chooseCategories => 'Chọn danh mục';

  @override
  String get noCategories => 'Chưa chọn danh mục';

  @override
  String get tagsLabel => 'Thẻ';

  @override
  String get tagsHint => 'Gõ rồi bấm dấu phẩy hoặc Xong để thêm thẻ';

  @override
  String removeTag(String tag) {
    return 'Bỏ thẻ $tag';
  }

  @override
  String get tagTooLong => 'Thẻ tối đa 40 ký tự';

  @override
  String get webTitle => 'Nhập từ trang web';

  @override
  String get webAddressHint => 'Địa chỉ hoặc từ khóa tìm kiếm';

  @override
  String get webBack => 'Trang trước';

  @override
  String get webForward => 'Trang sau';

  @override
  String get webReload => 'Tải lại';

  @override
  String get webSave => 'Lưu công thức';

  @override
  String get webStartHint =>
      'Gõ địa chỉ hoặc từ khóa (ví dụ \"phở bò\"), mở trang có công thức rồi bấm Lưu công thức.';

  @override
  String get webErrorNetwork =>
      'Không có mạng hoặc không kết nối được tới trang.';

  @override
  String get webErrorTimeout => 'Trang tải quá 20 giây. Mạng có thể đang yếu.';

  @override
  String webErrorHttp(int code) {
    return 'Trang báo lỗi $code.';
  }

  @override
  String get webErrorOther => 'Không mở được trang.';

  @override
  String get webReadFailed => 'Không đọc được nội dung trang.';

  @override
  String get webRetry => 'Thử lại';

  @override
  String get webNoRecipe =>
      'Trang này không có dữ liệu công thức. Bôi đen chữ trên trang rồi chọn bên dưới.';

  @override
  String get webSelectName => 'Là tên';

  @override
  String get webSelectIngredients => 'Là nguyên liệu';

  @override
  String get webSelectSteps => 'Là các bước';

  @override
  String get webSelectionEmpty => 'Chưa bôi đen chữ nào trên trang.';

  @override
  String webPartsSummary(int ingredients, int steps) {
    return 'Đã chọn: $ingredients dòng nguyên liệu, $steps dòng bước';
  }

  @override
  String get webClearParts => 'Xóa đã chọn';

  @override
  String get webDuplicateTitle => 'Đã có công thức này';

  @override
  String get webDuplicateBody =>
      'Địa chỉ này đã có trong sổ. Mở bản cũ hay lưu thêm một bản mới?';

  @override
  String get webOpenExisting => 'Mở bản cũ';

  @override
  String get webSaveNew => 'Lưu bản mới';

  @override
  String webDownloadingImages(int done, int total) {
    return 'Đang tải ảnh $done/$total';
  }

  @override
  String get webSkipImages => 'Bỏ qua ảnh';

  @override
  String webImagesFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ảnh không tải được',
    );
    return '$_temp0';
  }

  @override
  String get cooked => 'Đã nấu';

  @override
  String get markCooked => 'Đánh dấu đã nấu';

  @override
  String cookedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã nấu $count lần',
      zero: 'Chưa nấu lần nào',
    );
    return '$_temp0';
  }

  @override
  String lastCooked(String date) {
    return 'Lần gần nhất: $date';
  }

  @override
  String get cookedRecorded => 'Đã ghi lần nấu';

  @override
  String get cookButton => 'Nấu';

  @override
  String get cookModeTitle => 'Chế độ nấu';

  @override
  String get scaleFactorLabel => 'Hệ số';

  @override
  String get scaleServingsButton => 'Khẩu phần…';

  @override
  String get scaleCustomButton => 'Tự nhập…';

  @override
  String get scaleServingsTitle => 'Khẩu phần mới';

  @override
  String get scaleCustomTitle => 'Nhập hệ số (ví dụ 1,5 hoặc 1/2)';

  @override
  String get scaleInvalid => 'Số không hợp lệ';

  @override
  String get unitOriginal => 'Gốc';

  @override
  String get unitMetric => 'Hệ mét';

  @override
  String get unitUs => 'Hệ Mỹ';

  @override
  String viewingScaled(String factor) {
    return 'Đang xem ×$factor. Công thức gốc không đổi.';
  }

  @override
  String get viewingUnitsOnly =>
      'Đang xem đổi đơn vị. Công thức gốc không đổi.';

  @override
  String get resetView => 'Về gốc';

  @override
  String get saveScaled => 'Lưu theo khẩu phần này';

  @override
  String get saveScaledTitle => 'Ghi đè công thức?';

  @override
  String get saveScaledBody =>
      'Nguyên liệu và khẩu phần đang xem sẽ thay cho bản gốc.';

  @override
  String get scaledSaved => 'Đã lưu theo khẩu phần mới';

  @override
  String get cannotScale => 'không tự nhân được';

  @override
  String get cookFontSize => 'Cỡ chữ';

  @override
  String get cookPin => 'Ghim để nấu nhanh';

  @override
  String get cookUnpin => 'Bỏ ghim';

  @override
  String cookPinLimit(int max) {
    return 'Chỉ ghim được tối đa $max công thức. Bỏ ghim một công thức trước.';
  }

  @override
  String get cookNoSteps => 'Công thức chưa có bước nào.';

  @override
  String get cookTapHint => 'Chạm một dòng để gạch đi.';

  @override
  String cookStepN(int n) {
    return 'Bước $n';
  }

  @override
  String timerButtonTooltip(String label) {
    return 'Hẹn giờ $label';
  }

  @override
  String timerName(String step, String label) {
    return '$step · $label';
  }

  @override
  String get timersRunning => 'Hẹn giờ đang chạy';

  @override
  String get timerCancel => 'Hủy hẹn giờ';

  @override
  String timerDone(String name) {
    return 'Hết giờ: $name';
  }

  @override
  String get timerDismiss => 'Tắt';

  @override
  String timerNotifBody(String recipe) {
    return '$recipe: hết giờ';
  }

  @override
  String get notifChannelName => 'Hẹn giờ nấu';

  @override
  String get notifChannelDescription => 'Báo khi hẹn giờ nấu kết thúc';

  @override
  String get notifRationaleTitle => 'Báo khi hết giờ';

  @override
  String get notifRationaleBody =>
      'CookNote cần quyền thông báo để báo bạn khi hẹn giờ kết thúc, kể cả khi màn hình khóa hoặc app ở nền. Quyền này chỉ dùng cho hẹn giờ nấu.';

  @override
  String get notifContinue => 'Tiếp tục';

  @override
  String get notifLater => 'Để sau';

  @override
  String get notifDeniedWarning =>
      'Chưa có quyền thông báo: hẹn giờ vẫn chạy nhưng sẽ không báo khi app ở nền.';

  @override
  String get speakStep => 'Đọc bước';

  @override
  String get stopSpeaking => 'Dừng đọc';

  @override
  String noVoiceTitle(String language) {
    return 'Máy chưa có giọng đọc $language';
  }

  @override
  String get noVoiceBody =>
      'Vào Cài đặt của máy, tìm \"Chuyển văn bản thành giọng nói\" (tên có thể khác tùy hãng), chọn ngôn ngữ rồi tải giọng đọc.';

  @override
  String get languageVietnamese => 'tiếng Việt';

  @override
  String get languageEnglish => 'tiếng Anh';

  @override
  String get speakError => 'Không đọc được bước này';

  @override
  String get backup => 'Sao lưu';

  @override
  String get backupAutoTitle => 'Sao lưu tự động';

  @override
  String get backupLast => 'Lần sao lưu thành công gần nhất';

  @override
  String get backupNever => 'Chưa có lần sao lưu thành công nào';

  @override
  String backupLastDetail(String when, String size) {
    return '$when · $size';
  }

  @override
  String backupFolder(String name) {
    return 'Thư mục: $name';
  }

  @override
  String get backupChooseFolder => 'Chọn thư mục sao lưu tự động';

  @override
  String get backupChangeFolder => 'Đổi thư mục';

  @override
  String get backupDisable => 'Tắt sao lưu tự động';

  @override
  String get backupFolderHint =>
      'Chọn một lần một thư mục trên máy hoặc của Google Drive, OneDrive. CookNote tự ghi bản sao lưu vào đó khi bạn mở hoặc rời app, và giữ vài bản gần nhất. Nếu ứng dụng đám mây không cho ghi tự động, hãy dùng \"Sao lưu ngay và lưu ở nơi khác\" bên dưới.';

  @override
  String get backupInterval => 'Chu kỳ';

  @override
  String get intervalDaily => 'Hằng ngày';

  @override
  String get intervalWeekly => 'Hằng tuần';

  @override
  String get backupKeepLabel => 'Số bản giữ lại';

  @override
  String backupKeepValue(int count) {
    return '$count bản';
  }

  @override
  String get backupRunNow => 'Sao lưu vào thư mục ngay';

  @override
  String get backupSaveElsewhere => 'Sao lưu ngay và lưu ở nơi khác';

  @override
  String get backupSaveElsewhereHint =>
      'Tạo file sao lưu rồi mở bảng chia sẻ: lưu vào Tệp, Google Drive, gửi email...';

  @override
  String get backupRestoreTitle => 'Khôi phục';

  @override
  String get backupRestoreFile => 'Khôi phục từ file...';

  @override
  String get backupRestoreFromFolder => 'Các bản trong thư mục tự động';

  @override
  String get backupNoFiles => 'Chưa có bản sao lưu nào trong thư mục';

  @override
  String get backupListError => 'Không đọc được thư mục sao lưu';

  @override
  String get restoreReplace => 'Thay thế toàn bộ';

  @override
  String get restoreMerge => 'Gộp (chỉ thêm công thức chưa có)';

  @override
  String get restoreReplaceWarning =>
      'Dữ liệu hiện tại sẽ bị thay thế toàn bộ. CookNote tự lưu một bản dữ liệu hiện tại trước khi thay.';

  @override
  String get restoreMergeInfo =>
      'Công thức đã có (cùng tên, cùng thời điểm tạo) được giữ nguyên.';

  @override
  String get restoreChooseMode => 'Khôi phục theo cách nào?';

  @override
  String restoreInfo(int recipes, int photos, String when) {
    return '$recipes công thức, $photos ảnh, tạo lúc $when';
  }

  @override
  String restoreDone(int added, int skipped) {
    return 'Đã khôi phục: thêm $added, bỏ qua $skipped công thức đã có';
  }

  @override
  String get errBackupNotABackup => 'Đây không phải file sao lưu của CookNote';

  @override
  String get errBackupNewer =>
      'File này do bản CookNote mới hơn tạo. Hãy cập nhật ứng dụng rồi thử lại';

  @override
  String get errBackupChecksum =>
      'File bị hỏng (mã kiểm tra không khớp). Dữ liệu hiện có không bị đổi';

  @override
  String get errBackupMissing =>
      'File thiếu một phần dữ liệu. Dữ liệu hiện có không bị đổi';

  @override
  String get errBackupBad =>
      'Nội dung file sai cấu trúc. Dữ liệu hiện có không bị đổi';

  @override
  String backupDone(String size) {
    return 'Đã sao lưu ($size)';
  }

  @override
  String get backupUnchanged => 'Dữ liệu không đổi từ lần sao lưu trước';

  @override
  String get backupFailedTarget =>
      'Không ghi được vào thư mục sao lưu. Kiểm tra quyền hoặc chọn lại thư mục.';

  @override
  String get backupFailedVerify =>
      'File ghi ra bị lỗi khi đọc lại nên chưa tính là sao lưu thành công. Thử lại hoặc chọn thư mục khác.';

  @override
  String get backupFailedOther => 'Sao lưu không thành công';

  @override
  String get backupCancelled => 'Đã hủy sao lưu';

  @override
  String get backupWorking => 'Đang sao lưu...';

  @override
  String get restoreWorking => 'Đang khôi phục...';

  @override
  String get backupUnencrypted =>
      'File sao lưu KHÔNG được mã hóa: ai có file đều đọc được công thức của bạn. Giữ ở nơi an toàn.';

  @override
  String get backupSystemLayer =>
      'Ngoài ra, nếu bật sao lưu của Android, hệ thống tự sao lưu cơ sở dữ liệu (không có ảnh) vào tài khoản Google. Lớp này có giới hạn dung lượng và không thay được sao lưu ở trên.';

  @override
  String noticeSuggest(int count) {
    return 'Bạn đã có $count công thức. Bật sao lưu tự động để không bị mất.';
  }

  @override
  String get noticeOverdue => 'Đã hơn 7 ngày chưa có lần sao lưu thành công.';

  @override
  String get noticeError =>
      'Sao lưu tự động đang lỗi. Mở để xem và chọn lại thư mục.';

  @override
  String get noticeOpen => 'Mở Sao lưu';
}
