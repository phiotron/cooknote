// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bepbook';

  @override
  String get tabRecipes => 'Recipes';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabShopping => 'Shopping';

  @override
  String get tabPantry => 'Pantry';

  @override
  String get tabMore => 'More';

  @override
  String get comingSoon => 'Coming in a later version';

  @override
  String get noRecipes => 'No recipes yet';

  @override
  String get noRecipesHint => 'Tap + to add your first recipe';

  @override
  String get addRecipe => 'Add recipe';

  @override
  String get addManual => 'Write it myself';

  @override
  String get fromWeb => 'From a website';

  @override
  String get scanPhoto => 'Scan a photo';

  @override
  String get importFile => 'Import a file';

  @override
  String get newRecipe => 'New recipe';

  @override
  String get editRecipe => 'Edit recipe';

  @override
  String get save => 'Save';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardBody => 'Your changes to this recipe have not been saved.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get nameTooLong => 'At most 200 characters';

  @override
  String get servings => 'Servings';

  @override
  String get servingsUnit => 'Unit (e.g. people)';

  @override
  String get prepTime => 'Prep (min)';

  @override
  String get cookTime => 'Cook (min)';

  @override
  String get totalTime => 'Total (min)';

  @override
  String get source => 'Source';

  @override
  String get sourceUrl => 'Source link';

  @override
  String get notes => 'Notes';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficultyNone => 'Not set';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get rating => 'Rating';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of 5 stars',
      one: '1 of 5 stars',
      zero: 'No rating',
    );
    return '$_temp0';
  }

  @override
  String get favorite => 'Favorite';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get steps => 'Steps';

  @override
  String get ingredientsHint =>
      'One per line. End a line with : for a group title.';

  @override
  String get stepsHint =>
      'One step per line. End a line with : for a group title.';

  @override
  String get photos => 'Photos';

  @override
  String get addPhotos => 'Add photos';

  @override
  String get fromGallery => 'From gallery';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get coverPhoto => 'Cover';

  @override
  String get tooManyPhotos => 'A recipe can have at most 20 photos';

  @override
  String get imageError => 'This file could not be read as a photo';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTitle => 'Delete this recipe?';

  @override
  String get deleteBody =>
      'It moves to the trash and is removed for good after 30 days.';

  @override
  String get deletedMessage => 'Recipe deleted';

  @override
  String get undo => 'Undo';

  @override
  String get cancel => 'Cancel';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get duplicated => 'Duplicate created';

  @override
  String get copyLabel => 'copy';

  @override
  String get trash => 'Trash';

  @override
  String get trashEmpty => 'The trash is empty';

  @override
  String get trashInfo =>
      'Recipes are removed for good 30 days after deleting.';

  @override
  String get restore => 'Restore';

  @override
  String get deleteForever => 'Delete forever';

  @override
  String get deleteForeverBody =>
      'This recipe and its photos will be removed for good.';

  @override
  String get restored => 'Recipe restored';

  @override
  String get notFound => 'This recipe no longer exists';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get openLinkError => 'Could not open this link';

  @override
  String get searchHint => 'Search recipes';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filter => 'Filter';

  @override
  String filterWithCount(int count) {
    return 'Filter ($count)';
  }

  @override
  String get sort => 'Sort';

  @override
  String get sortName => 'Name';

  @override
  String get sortCreated => 'Date added';

  @override
  String get sortUpdated => 'Date edited';

  @override
  String get sortRating => 'Rating';

  @override
  String get sortCookTime => 'Cooking time';

  @override
  String get sortLastCooked => 'Last cooked';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get viewGrid => 'Grid view';

  @override
  String get viewList => 'List view';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
      zero: 'No recipes',
    );
    return '$_temp0';
  }

  @override
  String get noMatch => 'No recipes match';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get filterCategories => 'Categories';

  @override
  String get filterTags => 'Tags';

  @override
  String get filterMinRating => 'Minimum stars';

  @override
  String get filterFavorite => 'Favorites only';

  @override
  String get filterMaxTime => 'Maximum total time';

  @override
  String get filterIngredient => 'Has ingredient';

  @override
  String get anyTime => 'Any';

  @override
  String get done => 'Done';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get addSubCategory => 'Add subcategory';

  @override
  String get renameCategory => 'Rename';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get deleteCategoryBody =>
      'Its subcategories are deleted too. Recipes are not deleted.';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameInvalid => 'Enter 1 to 50 characters';

  @override
  String get categoryDepthLimit => 'Categories nest at most 3 levels';

  @override
  String get categoriesEmpty => 'No categories yet';

  @override
  String get chooseCategories => 'Choose categories';

  @override
  String get noCategories => 'No category selected';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint => 'Type, then press comma or Done to add a tag';

  @override
  String removeTag(String tag) {
    return 'Remove tag $tag';
  }

  @override
  String get tagTooLong => 'A tag has at most 40 characters';

  @override
  String get webTitle => 'Import from a website';

  @override
  String get webAddressHint => 'Address or search words';

  @override
  String get webBack => 'Back';

  @override
  String get webForward => 'Forward';

  @override
  String get webReload => 'Reload';

  @override
  String get webSave => 'Save recipe';

  @override
  String get webStartHint =>
      'Type an address or search words (for example \"pho bo\"), open a page with a recipe, then tap Save recipe.';

  @override
  String get webErrorNetwork => 'No network, or the page could not be reached.';

  @override
  String get webErrorTimeout =>
      'The page took more than 20 seconds to load. The connection may be weak.';

  @override
  String webErrorHttp(int code) {
    return 'The page reported error $code.';
  }

  @override
  String get webErrorOther => 'The page could not be opened.';

  @override
  String get webReadFailed => 'Could not read the page content.';

  @override
  String get webRetry => 'Try again';

  @override
  String get webNoRecipe =>
      'This page has no recipe data. Select text on the page, then choose below.';

  @override
  String get webSelectName => 'Is the name';

  @override
  String get webSelectIngredients => 'Is ingredients';

  @override
  String get webSelectSteps => 'Is the steps';

  @override
  String get webSelectionEmpty => 'No text is selected on the page.';

  @override
  String webPartsSummary(int ingredients, int steps) {
    return 'Picked: $ingredients ingredient lines, $steps step lines';
  }

  @override
  String get webClearParts => 'Clear picks';

  @override
  String get webDuplicateTitle => 'You already have this recipe';

  @override
  String get webDuplicateBody =>
      'This address is already in your book. Open the old one or save a new copy?';

  @override
  String get webOpenExisting => 'Open the old one';

  @override
  String get webSaveNew => 'Save a new copy';

  @override
  String webDownloadingImages(int done, int total) {
    return 'Downloading photos $done/$total';
  }

  @override
  String get webSkipImages => 'Skip photos';

  @override
  String webImagesFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos could not be downloaded',
      one: '1 photo could not be downloaded',
    );
    return '$_temp0';
  }

  @override
  String get cooked => 'Cooked';

  @override
  String get markCooked => 'Mark as cooked';

  @override
  String cookedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cooked $count times',
      one: 'Cooked once',
      zero: 'Never cooked',
    );
    return '$_temp0';
  }

  @override
  String lastCooked(String date) {
    return 'Last time: $date';
  }

  @override
  String get cookedRecorded => 'Cooking recorded';

  @override
  String get cookButton => 'Cook';

  @override
  String get cookModeTitle => 'Cooking mode';

  @override
  String get scaleFactorLabel => 'Multiplier';

  @override
  String get scaleServingsButton => 'Servings…';

  @override
  String get scaleCustomButton => 'Custom…';

  @override
  String get scaleServingsTitle => 'New servings';

  @override
  String get scaleCustomTitle => 'Enter a multiplier (for example 1.5 or 1/2)';

  @override
  String get scaleInvalid => 'Not a valid number';

  @override
  String get unitOriginal => 'Original';

  @override
  String get unitMetric => 'Metric';

  @override
  String get unitUs => 'US';

  @override
  String viewingScaled(String factor) {
    return 'Viewing ×$factor. The original recipe is unchanged.';
  }

  @override
  String get viewingUnitsOnly =>
      'Viewing converted units. The original recipe is unchanged.';

  @override
  String get resetView => 'Reset';

  @override
  String get saveScaled => 'Save at this scale';

  @override
  String get saveScaledTitle => 'Overwrite the recipe?';

  @override
  String get saveScaledBody =>
      'The ingredients and servings you are viewing will replace the original.';

  @override
  String get scaledSaved => 'Saved at the new scale';

  @override
  String get cannotScale => 'cannot be scaled automatically';

  @override
  String get cookFontSize => 'Text size';

  @override
  String get cookPin => 'Pin for quick access';

  @override
  String get cookUnpin => 'Unpin';

  @override
  String cookPinLimit(int max) {
    return 'You can pin at most $max recipes. Unpin one first.';
  }

  @override
  String get cookNoSteps => 'This recipe has no steps yet.';

  @override
  String get cookTapHint => 'Tap a line to cross it off.';

  @override
  String cookStepN(int n) {
    return 'Step $n';
  }

  @override
  String timerButtonTooltip(String label) {
    return 'Set timer for $label';
  }

  @override
  String timerName(String step, String label) {
    return '$step · $label';
  }

  @override
  String get timersRunning => 'Running timers';

  @override
  String get timerCancel => 'Cancel timer';

  @override
  String timerDone(String name) {
    return 'Time is up: $name';
  }

  @override
  String get timerDismiss => 'Dismiss';

  @override
  String timerNotifBody(String recipe) {
    return '$recipe: time is up';
  }

  @override
  String get notifChannelName => 'Cooking timers';

  @override
  String get notifChannelDescription => 'Alerts when a cooking timer ends';

  @override
  String get notifRationaleTitle => 'Alert when time is up';

  @override
  String get notifRationaleBody =>
      'Bepbook needs notification permission to alert you when a timer ends, even when the screen is locked or the app is in the background. It is used only for cooking timers.';

  @override
  String get notifContinue => 'Continue';

  @override
  String get notifLater => 'Not now';

  @override
  String get notifDeniedWarning =>
      'Notifications are off: timers still run but will not alert while the app is in the background.';

  @override
  String get speakStep => 'Read step';

  @override
  String get stopSpeaking => 'Stop reading';

  @override
  String noVoiceTitle(String language) {
    return 'No $language voice on this device';
  }

  @override
  String get noVoiceBody =>
      'Open the device Settings, find \"Text-to-speech\" (the name may differ by manufacturer), pick the language and download a voice.';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get languageEnglish => 'English';

  @override
  String get speakError => 'Could not read this step aloud';

  @override
  String get backup => 'Backup';

  @override
  String get backupAutoTitle => 'Automatic backup';

  @override
  String get backupLast => 'Last successful backup';

  @override
  String get backupNever => 'No successful backup yet';

  @override
  String backupLastDetail(String when, String size) {
    return '$when · $size';
  }

  @override
  String backupFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get backupChooseFolder => 'Choose automatic backup folder';

  @override
  String get backupChangeFolder => 'Change folder';

  @override
  String get backupDisable => 'Turn off automatic backup';

  @override
  String get backupFolderHint =>
      'Pick a folder once, on this phone or in Google Drive or OneDrive. Bepbook writes backups there when you open or leave the app and keeps the latest few. If the cloud app does not allow automatic writes, use \"Back up now and save elsewhere\" below.';

  @override
  String get backupInterval => 'Schedule';

  @override
  String get intervalDaily => 'Daily';

  @override
  String get intervalWeekly => 'Weekly';

  @override
  String get backupKeepLabel => 'Copies to keep';

  @override
  String backupKeepValue(int count) {
    return '$count copies';
  }

  @override
  String get backupRunNow => 'Back up to the folder now';

  @override
  String get backupSaveElsewhere => 'Back up now and save elsewhere';

  @override
  String get backupSaveElsewhereHint =>
      'Creates a backup file and opens the share sheet: save to Files, Google Drive, send by email...';

  @override
  String get backupRestoreTitle => 'Restore';

  @override
  String get backupRestoreFile => 'Restore from a file...';

  @override
  String get backupRestoreFromFolder => 'Backups in the automatic folder';

  @override
  String get backupNoFiles => 'No backups in the folder yet';

  @override
  String get backupListError => 'Could not read the backup folder';

  @override
  String get restoreReplace => 'Replace everything';

  @override
  String get restoreMerge => 'Merge (only add missing recipes)';

  @override
  String get restoreReplaceWarning =>
      'All current data will be replaced. Bepbook saves a copy of the current data first.';

  @override
  String get restoreMergeInfo =>
      'Recipes you already have (same name, same creation time) are kept as they are.';

  @override
  String get restoreChooseMode => 'How do you want to restore?';

  @override
  String restoreInfo(int recipes, int photos, String when) {
    return '$recipes recipes, $photos photos, created $when';
  }

  @override
  String restoreDone(int added, int skipped) {
    return 'Restored: $added added, $skipped already there';
  }

  @override
  String get errBackupNotABackup => 'This is not a Bepbook backup file';

  @override
  String get errBackupNewer =>
      'This file was made by a newer Bepbook. Update the app and try again';

  @override
  String get errBackupChecksum =>
      'The file is damaged (checksum mismatch). Your data was not changed';

  @override
  String get errBackupMissing =>
      'The file is missing part of its data. Your data was not changed';

  @override
  String get errBackupBad =>
      'The file content is malformed. Your data was not changed';

  @override
  String backupDone(String size) {
    return 'Backed up ($size)';
  }

  @override
  String get backupUnchanged => 'Nothing changed since the last backup';

  @override
  String get backupFailedTarget =>
      'Could not write to the backup folder. Check permissions or choose the folder again.';

  @override
  String get backupFailedVerify =>
      'The written file failed the read-back check, so it does not count as a successful backup. Try again or pick another folder.';

  @override
  String get backupFailedOther => 'Backup failed';

  @override
  String get backupCancelled => 'Backup cancelled';

  @override
  String get backupWorking => 'Backing up...';

  @override
  String get restoreWorking => 'Restoring...';

  @override
  String get backupUnencrypted =>
      'Backup files are NOT encrypted: anyone with the file can read your recipes. Keep it somewhere safe.';

  @override
  String get backupSystemLayer =>
      'If Android backup is on, the system also backs up the database (without photos) to your Google account. That layer has size limits and does not replace the backups above.';

  @override
  String noticeSuggest(int count) {
    return 'You have $count recipes. Turn on automatic backup so you do not lose them.';
  }

  @override
  String get noticeOverdue => 'More than 7 days without a successful backup.';

  @override
  String get noticeError =>
      'Automatic backup is failing. Open to review and choose the folder again.';

  @override
  String get noticeOpen => 'Open Backup';

  @override
  String get importTitle => 'Import from file';

  @override
  String get importIntro =>
      'Choose a file exported from Paprika (.paprikarecipes), Recipe Keeper (.zip), schema.org JSON, or a .cooknote backup.';

  @override
  String get importUnverified =>
      'The Paprika and Recipe Keeper formats are read from third-party documentation and are not yet verified against every real file. If a file cannot be read, your data stays unchanged.';

  @override
  String get importChoose => 'Choose file';

  @override
  String get importWorking => 'Importing recipes…';

  @override
  String get importUnknown =>
      'This file format is not recognised. Bepbook reads .paprikarecipes, Recipe Keeper zip, schema.org JSON and .cooknote.';

  @override
  String get importBadFile =>
      'This file could not be read. Your data was not changed.';

  @override
  String get importCancelled =>
      'Import cancelled. Recipes imported so far are kept.';

  @override
  String importResult(int imported, int duplicates, int skipped) {
    return 'Imported $imported recipes. Already present: $duplicates. Skipped: $skipped.';
  }

  @override
  String get importDetails => 'Details';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get exitSelection => 'Exit selection';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get cookbookMake => 'Recipe book (PDF)';

  @override
  String get trashSelected => 'Move to trash';

  @override
  String trashedCount(int count) {
    return 'Moved $count recipes to trash';
  }

  @override
  String get exportWorking => 'Creating file…';

  @override
  String get exportCancelled => 'Cancelled';

  @override
  String get exportFailed => 'Could not create the file.';

  @override
  String get shareRecipe => 'Share';

  @override
  String get shareAsText => 'Share as text';

  @override
  String get shareAsPdf => 'Share as PDF file';

  @override
  String get shareAsCooknote => 'Send a .cooknote file (importable in Bepbook)';

  @override
  String get printRecipe => 'Print';

  @override
  String get cookbookTitleLabel => 'Book title';

  @override
  String get cookbookDefaultTitle => 'My recipe book';

  @override
  String get cookbookCreate => 'Create book';

  @override
  String get cookbookReady => 'The book is ready';

  @override
  String get cookbookShare => 'Share or save';

  @override
  String get cookbookNone => 'No recipes to export';

  @override
  String get exchangeSection => 'Import and export';

  @override
  String get exportAllJson => 'Export all recipes (JSON)';

  @override
  String get cookbookAll => 'Recipe book from all recipes';

  @override
  String get pdfContents => 'Contents';

  @override
  String get pdfServings => 'Servings';

  @override
  String get pdfPrep => 'Prep';

  @override
  String get pdfCook => 'Cook';

  @override
  String get pdfTotal => 'Total';

  @override
  String get pdfMinutes => 'min';

  @override
  String get pdfPage => 'Page';

  @override
  String get backupStatusSafe => 'Safe';

  @override
  String get backupStatusOverdue => 'Overdue';

  @override
  String get backupStatusFailing => 'Failing';

  @override
  String get backupStatusNotSetUp => 'Not set up';

  @override
  String get dataUnchanged => 'Your data is unchanged.';

  @override
  String timerPillOne(String name, String time) {
    return '$name · $time';
  }

  @override
  String timerPillMany(int count, String time) {
    return '$count timers · $time';
  }

  @override
  String timerPillSemantics(String name, String time) {
    return 'Timer $name, $time left. Opens Cook mode.';
  }

  @override
  String timerPillManySemantics(int count, String time) {
    return '$count timers running, next ends in $time. Opens Cook mode.';
  }

  @override
  String get errorRetry => 'Try again';

  @override
  String get sortMissingLast => 'Recipes without this info go last';

  @override
  String showNRecipes(int n) {
    return 'Show $n recipes';
  }

  @override
  String get emptyTrash => 'Empty trash';

  @override
  String get previewTitle => 'Check before saving';

  @override
  String get scanAssignTitle => 'Sort the lines';

  @override
  String get scanReading => 'Reading the recipe…';

  @override
  String get pickText => 'Pick text';

  @override
  String get chooseAnotherFile => 'Choose another file';

  @override
  String get webStartNote =>
      'Pages you open are the only thing Bepbook loads from the internet.';

  @override
  String get extShareSaved => 'Saved to Bepbook — open?';

  @override
  String cookStepsDoneShow(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n steps done · Show',
      one: '1 step done · Show',
    );
    return '$_temp0';
  }

  @override
  String get cookStartOver => 'Start over';

  @override
  String get timerAlreadyStarted => 'Your timer has already started';

  @override
  String get cookReadStopShort => 'Stop';

  @override
  String get shoppingMakeFirstList => 'Make your first list';

  @override
  String get shoppingNothingToBuy => 'Nothing to buy';

  @override
  String get shoppingAllDone => 'All done!';

  @override
  String shoppingDeleteListConfirm(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n items',
      one: '1 item',
    );
    return 'Delete the list \"$name\" and its $_temp0?';
  }

  @override
  String get menuDropHere => 'Drop here';

  @override
  String get menuDayHasMeals => 'This day already has meals';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get deleting => 'Deleting…';

  @override
  String ratingSemantics(int n) {
    return '$n of 5 stars';
  }

  @override
  String get ratingUnset => 'No rating';
}
