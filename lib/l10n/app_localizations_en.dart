// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CookNote';

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
}
