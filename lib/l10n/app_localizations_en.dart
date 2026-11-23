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

  @override
  String get moreActions => 'More options';

  @override
  String get select => 'Select';

  @override
  String get selectRecipes => 'Select recipes';

  @override
  String get privacyNote => 'Your recipes live only on this phone.';

  @override
  String get addSheetManualSub => 'Type or paste a recipe';

  @override
  String get addSheetWebSub => 'Open a page or paste a link';

  @override
  String get addSheetScanSub => 'Cookbook page or handwritten recipe';

  @override
  String get addSheetImportSub => 'From another app or a backup';

  @override
  String get needsInternet => 'Needs internet';

  @override
  String get addSheetTip => 'Tip: in your browser, tap Share → Bepbook';

  @override
  String get filterIncludesSubs => 'Includes sub-categories';

  @override
  String get filterTagsAll => 'Tags · must have all';

  @override
  String get filterStars => 'Minimum stars';

  @override
  String get filterAny => 'Any';

  @override
  String get servingsUnitsTitle => 'Servings & units';

  @override
  String get unitsLabel => 'Units';

  @override
  String get unitsCaption =>
      'Volume stays volume, weight stays weight. Cups and bowls never convert.';

  @override
  String get previewLabel => 'Preview';

  @override
  String get peopleUnit => 'people';

  @override
  String get decreaseServings => 'Fewer servings';

  @override
  String get increaseServings => 'More servings';

  @override
  String get noServings => 'No servings set';

  @override
  String get factServings => 'Servings';

  @override
  String get factPrep => 'Prep';

  @override
  String get factCook => 'Cook';

  @override
  String get factTotal => 'Total';

  @override
  String get factDifficulty => 'Difficulty';

  @override
  String get addToMenu => 'Add to menu';

  @override
  String get addToShopping => 'Add to shopping';

  @override
  String get openSourceLink => 'Open source link';

  @override
  String get textMode => 'Text';

  @override
  String get linesMode => 'Lines';

  @override
  String get addLine => 'Add line';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get makeHeading => 'Make heading';

  @override
  String get removeHeading => 'Remove heading';

  @override
  String get details => 'Details';

  @override
  String trashRemovedInDays(int count) {
    return 'Removed for good in $count days';
  }

  @override
  String get trashRemovedTomorrow => 'Removed for good tomorrow';

  @override
  String get emptyTrashTitle => 'Empty the trash?';

  @override
  String get emptyTrashBody =>
      'Every recipe in the trash will be removed for good. This cannot be undone.';

  @override
  String get emptyTrashDone => 'Trash emptied';

  @override
  String get trashEmptyBody => 'Deleted recipes stay here for 30 days.';

  @override
  String get deleteForeverTitle => 'Delete forever?';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String durationHM(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get categoryEmptyBody => 'Categories help you filter recipes faster.';

  @override
  String get close => 'Close';

  @override
  String get continueLabel => 'Continue';

  @override
  String get untitledRecipe => 'Untitled recipe';

  @override
  String previewSummary(int ing, int steps) {
    return '$ing ingredients · $steps steps';
  }

  @override
  String previewPhotos(int n) {
    return '$n photos will be saved to this device';
  }

  @override
  String get previewEdit => 'Edit in the editor';

  @override
  String get previewSave => 'Save recipe';

  @override
  String get webDownloadNote =>
      'Photos are saved on this device when you save, so they work offline.';

  @override
  String get previewMissingIngredients =>
      'This page had no ingredients — you can add them in the editor.';

  @override
  String get previewMissingSteps =>
      'This page had no steps — you can add them in the editor.';

  @override
  String get webInsecure => 'Not encrypted';

  @override
  String get webInsecureInfoTitle => 'Unencrypted page';

  @override
  String get webInsecureInfo =>
      'This page uses http. Other people on the same network may read the page, passwords you type, or card numbers. Only open pages you trust.';

  @override
  String get shareInTitle => 'Shared to Bepbook';

  @override
  String get shareInIntro => 'Content shared from another app:';

  @override
  String get shareInEmpty => 'Nothing was shared.';

  @override
  String get shareInUrl => 'Open the link in the browser';

  @override
  String get shareInText => 'Make a recipe from this text';

  @override
  String get pickTextHint =>
      'Paste the selected text, then choose where it belongs.';

  @override
  String get pickTextContent => 'Selected text';

  @override
  String get pickTextTarget => 'This text is';

  @override
  String get scanNotAvailable =>
      'Text recognition is not available on this device. You can type it in or import from the web.';

  @override
  String get scanPrivacy =>
      'Photos and text are processed on this device only and never sent anywhere.';

  @override
  String get scanFromGallery => 'Choose photos';

  @override
  String get scanMaxPages => 'Up to 10 pages at a time';

  @override
  String get scanTakePhoto => 'Take a photo';

  @override
  String get scanOnePage => 'One page';

  @override
  String get scanPickPdf => 'Choose a PDF';

  @override
  String get scanPdfHint => 'A cookbook or a recipe saved as PDF';

  @override
  String get scanHandwritingWarning =>
      'Printed text is recognised more accurately than handwriting; check the lines after scanning.';

  @override
  String scanProgress(int done, int total) {
    return 'Read $done/$total pages';
  }

  @override
  String get scanFailed => 'Could not read this photo';

  @override
  String get scanTooManyPages => 'Up to 10 pages can be scanned at once';

  @override
  String get scanNoLines => 'No text was recognised';

  @override
  String scanPdfPagesLimited(int total, int used) {
    return 'The file has $total pages; only the first $used were scanned';
  }

  @override
  String get scanAssignHint =>
      'Tap lines to select, then assign Name, Ingredients, Steps or Notes. Long-press to edit the text.';

  @override
  String get scanKeepPhotos => 'Keep the original photos as recipe photos';

  @override
  String get scanSelectFirst => 'Select at least one line';

  @override
  String scanSelected(int n) {
    return '$n lines selected';
  }

  @override
  String scanPage(int n) {
    return 'Page $n';
  }

  @override
  String get scanEditLine => 'Edit line';

  @override
  String get scanLineText => 'Text';

  @override
  String get scanLineRole => 'Part';

  @override
  String get scanLineName => 'Name';

  @override
  String get scanLineIngredients => 'Ingredients';

  @override
  String get scanLineSteps => 'Steps';

  @override
  String get scanLineNote => 'Note';

  @override
  String get scanLineSkip => 'Skip';

  @override
  String get scanDoubtful => 'This line may be misread';

  @override
  String get cookNoIngredients => 'This recipe has no ingredients yet.';

  @override
  String cookIngredientsDone(int done, int total) {
    return '$done/$total ingredients done';
  }

  @override
  String get cookStartOverHint =>
      'All ingredient and step ticks will be cleared.';

  @override
  String get cookAllStepsDone => 'All steps done. Enjoy your meal!';

  @override
  String get timerStarted => 'Timer started';

  @override
  String get recipeMissing =>
      'This recipe could not be found — it may have been deleted.';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get later => 'Later';

  @override
  String get apply => 'Apply';

  @override
  String get replace => 'Replace';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get back => 'Back';

  @override
  String get search => 'Search';

  @override
  String get today => 'Today';

  @override
  String get shoppingLists => 'Lists';

  @override
  String get shoppingNewList => 'New list';

  @override
  String get shoppingListName => 'List name';

  @override
  String get shoppingRenameList => 'Rename list';

  @override
  String get shoppingDeleteList => 'Delete list';

  @override
  String get shoppingAisles => 'Aisles';

  @override
  String get shoppingAislesHint => 'Order them like your shop\'s path';

  @override
  String shoppingBoughtOf(int bought, int total) {
    return '$bought of $total bought';
  }

  @override
  String shoppingAisleCount(int n) {
    return '$n aisles';
  }

  @override
  String get shoppingAddItem => 'Add item';

  @override
  String get shoppingItemHint => 'e.g. 500 g beef';

  @override
  String get shoppingItemEditTitle => 'Edit item';

  @override
  String get shoppingFrequent => 'Frequent items';

  @override
  String get shoppingEmptyHint =>
      'Add items by hand, from Frequent items, or from a recipe.';

  @override
  String get shoppingFromRecipe => 'Add from a recipe';

  @override
  String get shoppingBought => 'Bought';

  @override
  String get shoppingClearChecked => 'Clear checked items';

  @override
  String shoppingClearTitle(int n) {
    return 'Clear $n bought items?';
  }

  @override
  String get shoppingMoveToPantry => 'Move bought items to the Pantry';

  @override
  String shoppingCleared(int n) {
    return 'Cleared $n bought items';
  }

  @override
  String get shoppingShareTitle => 'Share list';

  @override
  String get shoppingShareEmpty => 'Nothing unchecked to share.';

  @override
  String get shoppingMoveAisleTitle => 'Move to which aisle?';

  @override
  String get shoppingNoAisle => 'Other';

  @override
  String shoppingDeleteItemConfirm(String name) {
    return 'Remove \"$name\" from the list?';
  }

  @override
  String get shoppingItemDeleted => 'Item removed';

  @override
  String get shoppingMergedTag => 'merged';

  @override
  String shoppingSourcesFor(String names) {
    return 'for $names';
  }

  @override
  String get shoppingInPantry => 'In pantry';

  @override
  String get shoppingAddToList => 'Add to:';

  @override
  String shoppingAddCount(int n) {
    return 'Add $n items';
  }

  @override
  String shoppingMergeWarning(int n) {
    return '$n items will be merged with items already on the list';
  }

  @override
  String get shoppingNoneSelected => 'Nothing selected';

  @override
  String get shoppingAsWritten => 'as written';

  @override
  String get shoppingNoListsHint => 'One list per shop works well.';

  @override
  String get shoppingItemName => 'Item name';

  @override
  String get shoppingAmountLabel => 'Quantity (optional)';

  @override
  String get shoppingNewListHint => 'e.g. Supermarket, Wet market';

  @override
  String shoppingAisleDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get shoppingAisleDeleteBody => 'Its items move to \"Other\".';

  @override
  String get shoppingAddAisle => 'Add aisle';

  @override
  String get shoppingAisleName => 'Aisle name';

  @override
  String get shoppingAisleRename => 'Rename aisle';

  @override
  String get shoppingAislesNote =>
      'Deleting an aisle moves its items to \"Other\". The Pantry uses the same aisles.';

  @override
  String shoppingAdded(int n) {
    return 'Added $n items';
  }

  @override
  String get shoppingNoIngredients => 'No ingredients to add.';

  @override
  String get shoppingAllDoneSub => 'You bought everything on the list.';

  @override
  String get menuDay => 'Day';

  @override
  String get menuWeek => 'Week';

  @override
  String get menuMonth => 'Month';

  @override
  String get menuRandom => 'Random suggestions';

  @override
  String get menuApplyTemplate => 'Apply a template';

  @override
  String get menuAddToShopping => 'Add to shopping';

  @override
  String get menuSaveWeekTemplate => 'Save week as template';

  @override
  String get menuAddToMenu => 'Add to menu';

  @override
  String get menuNothingPlannedWeek => 'Nothing planned this week';

  @override
  String get menuNothingPlannedDay => 'Nothing planned for this day';

  @override
  String get menuEmptyHint => 'Add meals to a slot, or use random suggestions.';

  @override
  String menuWeekRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String menuEntryServings(String n) {
    return '$n servings';
  }

  @override
  String get menuAddTitle => 'Add to menu';

  @override
  String get menuTabRecipe => 'Recipe';

  @override
  String get menuTabFreeText => 'Free text';

  @override
  String get menuDate => 'Date';

  @override
  String get menuSlot => 'Slot';

  @override
  String get menuServings => 'Servings';

  @override
  String get menuSearchRecipes => 'Search recipes';

  @override
  String get menuRecentFavourites => 'Recent & favourites';

  @override
  String get menuFreeTextHint => 'e.g. Eating out';

  @override
  String get menuNoRecipes => 'No matching recipes';

  @override
  String get menuEntryOpen => 'Open recipe';

  @override
  String get menuEntryCook => 'Cook';

  @override
  String get menuEntryMove => 'Move to…';

  @override
  String get menuEntryRemove => 'Remove from menu';

  @override
  String get menuMoveTitle => 'Move to…';

  @override
  String get menuMoveDay => 'Day';

  @override
  String get menuMoveMeal => 'Meal';

  @override
  String get menuMove => 'Move';

  @override
  String get menuEntryRemoved => 'Removed from menu';

  @override
  String get menuMealSlots => 'Meal slots';

  @override
  String get menuAddSlot => 'Add slot';

  @override
  String get menuSlotName => 'Slot name';

  @override
  String menuDeleteSlotTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get menuDeleteSlotBody =>
      'Every meal planned in this slot will be deleted.';

  @override
  String menuSlotUses(int n) {
    return '$n items';
  }

  @override
  String get menuTemplates => 'Menu templates';

  @override
  String get menuNewTemplate => 'New template';

  @override
  String get menuNoTemplates => 'No templates yet';

  @override
  String get menuNoTemplatesBody =>
      'Save a day or a week you like, then apply it again in one tap.';

  @override
  String get menuTemplateSaveWeek => 'Save this week as a template';

  @override
  String menuTemplateItems(int items, int days) {
    return '$items items · $days days';
  }

  @override
  String menuTemplateApplyTitle(String name) {
    return 'Apply \"$name\"';
  }

  @override
  String get menuTemplateStartDate => 'Start date';

  @override
  String get menuTemplateWeek => 'Whole week';

  @override
  String get menuTemplateDay => 'One day';

  @override
  String get menuTemplateOccupiedTitle => 'This day already has meals';

  @override
  String menuTemplateOccupiedBody(String date, int n) {
    return '$date already has $n items. Replace them with the template, or add the items next to them?';
  }

  @override
  String get menuTemplateReplaceHint =>
      'Replace only clears the meals the template fills.';

  @override
  String get menuTemplateApplied => 'Template applied';

  @override
  String get menuTemplateName => 'Template name';

  @override
  String get menuTemplateCreated => 'Template saved';

  @override
  String menuTemplateDeleteTitle(String name) {
    return 'Delete template \"$name\"?';
  }

  @override
  String get menuRandomTitle => 'Random suggestions';

  @override
  String menuRandomIntro(String from, String to) {
    return 'Fill the empty meals from $from to $to with recipes that match.';
  }

  @override
  String get menuRandomMaxTime => 'Maximum total time';

  @override
  String get menuRandomAny => 'Any';

  @override
  String get menuRandomPreview => 'Preview';

  @override
  String get menuRandomPreviewTitle => 'Preview suggestions';

  @override
  String get menuRandomNoRepeat => 'No recipe repeats this week';

  @override
  String get menuRandomSuggested => 'Suggested';

  @override
  String get menuRandomTooFew =>
      'There are fewer matching recipes than empty meals — some dishes will repeat.';

  @override
  String get menuRandomZero => 'No recipes match the filters.';

  @override
  String get menuRandomApplied => 'Empty meals filled';

  @override
  String get menuShoppingRangeTitle => 'Add to shopping';

  @override
  String get menuShoppingThisWeek => 'This week';

  @override
  String get menuShoppingNext3 => 'Next 3 days';

  @override
  String get menuShoppingCustom => 'Custom';

  @override
  String get menuShoppingFrom => 'From';

  @override
  String get menuShoppingTo => 'To';

  @override
  String menuShoppingSummary(int recipes, int lines) {
    return '$recipes recipes, $lines ingredient lines';
  }

  @override
  String get menuShoppingAtServings => 'At each meal\'s servings';

  @override
  String get menuShoppingChoose => 'Choose ingredients';

  @override
  String get menuEntryAdded => 'Added to menu';

  @override
  String get pantryAll => 'All';

  @override
  String get pantryFilterEmpty => 'Nothing in this filter';

  @override
  String pantrySoon(int n) {
    return 'Expiring soon ($n)';
  }

  @override
  String pantryExpired(int n) {
    return 'Expired ($n)';
  }

  @override
  String get pantryWhatCanICook => 'What can I cook?';

  @override
  String pantryAlmost(int n) {
    return '$n recipes you can almost cook';
  }

  @override
  String get pantryEmpty => 'Your pantry is empty';

  @override
  String get pantryEmptyBody =>
      'Add what you have, or move bought items here from Shopping.';

  @override
  String get pantryAdd => 'Add to pantry';

  @override
  String get pantryItemTitle => 'Pantry item';

  @override
  String get pantryName => 'Name';

  @override
  String get pantryQuantity => 'Quantity (optional)';

  @override
  String get pantryAisle => 'Aisle';

  @override
  String get pantryBought => 'Bought';

  @override
  String get pantryExpiry => 'Expiry (optional)';

  @override
  String get pantryNoExpiry => 'No expiry date';

  @override
  String get pantryNoExpiryShort => 'No expiry';

  @override
  String pantryExpiresIn(int n) {
    return 'Expires in $n days';
  }

  @override
  String pantryExpiredAgo(int n) {
    return 'Expired $n days ago';
  }

  @override
  String pantryExpiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String pantryBoughtOn(String date) {
    return 'Bought $date';
  }

  @override
  String get pantryExpiringSoon => 'Expiring soon';

  @override
  String get pantryExpiredTag => 'Expired';

  @override
  String get pantryItemDeleteTitle => 'Delete this item?';

  @override
  String get pantryToday => 'Today';

  @override
  String get pantryCanCookEmpty => 'No recipes to cook';

  @override
  String get pantryCanCookEmptyBody =>
      'Add what you have at home and Bepbook will rank your recipes by it.';

  @override
  String get pantryBasicsSwitch =>
      'Don\'t count basic seasonings as missing (salt, sugar, water, pepper, cooking oil, fish sauce)';

  @override
  String pantryMatch(int have, int total) {
    return '$have of $total';
  }

  @override
  String pantryMissingOne(int n, String names) {
    return 'Missing $n: $names';
  }

  @override
  String get pantryMissingNone => 'All ingredients available';

  @override
  String get pantryAddMissing => 'Add missing to shopping';

  @override
  String get pantryMissingAdded => 'Missing ingredients added to shopping';

  @override
  String pantryCanCookRecipes(int n) {
    return '$n recipes';
  }

  @override
  String get moreBackupOff => 'Automatic backup is off.';

  @override
  String get moreImportExport => 'Import & export';

  @override
  String get moreImportExportSub => 'Other apps, JSON, recipe book PDF';

  @override
  String get morePrivacy =>
      'Your recipes live only on this phone. Bepbook collects nothing.';

  @override
  String get onboardingTitle1 => 'Your recipes, one notebook';

  @override
  String get onboardingBody1 =>
      'Save recipes from websites, photos of cookbooks, or write your own.';

  @override
  String get onboardingTitle2 => 'Made for the kitchen';

  @override
  String get onboardingBody2 =>
      'Big text that stays on, timers for every step, and servings that scale themselves.';

  @override
  String get onboardingTitle3 => 'Keep them for life';

  @override
  String get onboardingBody3 =>
      'Your recipes live only on this phone. No account, nothing sent anywhere. Turn on automatic backup to a folder you choose so you never lose them.';

  @override
  String get onboardingBackup => 'Turn on automatic backup';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsCooking => 'Cooking';

  @override
  String get settingsDefaultUnits => 'Default units';

  @override
  String get settingsMenu => 'Menu';

  @override
  String get settingsWeekStart => 'First day of the week';

  @override
  String get settingsMonday => 'Monday';

  @override
  String get settingsSunday => 'Sunday';

  @override
  String get settingsMealSlots => 'Meal slots';

  @override
  String get settingsShoppingPantry => 'Shopping & pantry';

  @override
  String get settingsAisles => 'Aisles';

  @override
  String get settingsIgnoreBasics =>
      'Don\'t count basic seasonings as missing (salt, sugar, water, pepper, cooking oil, fish sauce)';

  @override
  String get settingsDeleteAll => 'Delete all data';

  @override
  String get deleteAllQuestion => 'Back up first?';

  @override
  String get deleteAllQuestionBody =>
      'Deleted data cannot be recovered. Save a backup first?';

  @override
  String get deleteAllSkip => 'Skip';

  @override
  String get deleteAllBackupNow => 'Back up now';

  @override
  String get deleteAllTitle => 'Delete all data?';

  @override
  String get deleteAllThisDeletes => 'This deletes:';

  @override
  String get deleteAllRecipes => 'all recipes and photos';

  @override
  String get deleteAllShopping => 'shopping lists, menu, pantry';

  @override
  String get deleteAllSettings => 'settings';

  @override
  String get deleteAllBrowser => 'browser cookies and site data';

  @override
  String get deleteAllBackupsSafe =>
      'Backup files in your folders are not deleted.';

  @override
  String get deleteAllContinue => 'Continue';

  @override
  String get deleteAllFinalTitle => 'This cannot be undone.';

  @override
  String get deleteAllFinalBody =>
      'Bepbook will restart as if freshly installed.';

  @override
  String get deleteAllConfirm => 'Delete everything';

  @override
  String get deleteAllWorking => 'Deleting…';

  @override
  String get deleteAllDone => 'All data deleted';

  @override
  String get deleteAllFailed => 'Could not delete all data';

  @override
  String get exchangeTitle => 'Import and export';

  @override
  String get exchangeImport => 'Import from file';

  @override
  String get exchangeImportSub => 'Paprika · Recipe Keeper · JSON · .cooknote';

  @override
  String get exchangeExportAll => 'Export all recipes (JSON)';

  @override
  String get exchangeCookbook => 'Recipe book from all recipes';

  @override
  String get exchangePdf => 'PDF';

  @override
  String get exchangeExportHint =>
      'To export some recipes, select them in the Recipes list.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutTagline =>
      'No account. No ads. No tracking. Nothing leaves your phone except the web pages you open.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutPrivacySoon => 'The privacy policy will be published later.';

  @override
  String get aboutContact => 'Contact & security reports';

  @override
  String get aboutLicenses => 'Open-source licences';

  @override
  String get aboutRights =>
      'Recipes imported from websites belong to their authors. Bepbook keeps the source link. Use them for your own cooking only.';

  @override
  String get licensesTitle => 'Open-source licences';

  @override
  String get licensesViewAll => 'View full licences';
}
