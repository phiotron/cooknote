import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CookNote'**
  String get appTitle;

  /// No description provided for @tabRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get tabRecipes;

  /// No description provided for @tabMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get tabMenu;

  /// No description provided for @tabShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get tabShopping;

  /// No description provided for @tabPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get tabPantry;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later version'**
  String get comingSoon;

  /// No description provided for @noRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipes;

  /// No description provided for @noRecipesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first recipe'**
  String get noRecipesHint;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add recipe'**
  String get addRecipe;

  /// No description provided for @addManual.
  ///
  /// In en, this message translates to:
  /// **'Write it myself'**
  String get addManual;

  /// No description provided for @fromWeb.
  ///
  /// In en, this message translates to:
  /// **'From a website'**
  String get fromWeb;

  /// No description provided for @scanPhoto.
  ///
  /// In en, this message translates to:
  /// **'Scan a photo'**
  String get scanPhoto;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import a file'**
  String get importFile;

  /// No description provided for @newRecipe.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get newRecipe;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipe;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this recipe have not been saved.'**
  String get discardBody;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 200 characters'**
  String get nameTooLong;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @servingsUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g. people)'**
  String get servingsUnit;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep (min)'**
  String get prepTime;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook (min)'**
  String get cookTime;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total (min)'**
  String get totalTime;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @sourceUrl.
  ///
  /// In en, this message translates to:
  /// **'Source link'**
  String get sourceUrl;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @difficultyNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get difficultyNone;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @ratingStars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No rating} =1{1 of 5 stars} other{{count} of 5 stars}}'**
  String ratingStars(int count);

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @ingredientsHint.
  ///
  /// In en, this message translates to:
  /// **'One per line. End a line with : for a group title.'**
  String get ingredientsHint;

  /// No description provided for @stepsHint.
  ///
  /// In en, this message translates to:
  /// **'One step per line. End a line with : for a group title.'**
  String get stepsHint;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get fromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @coverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get coverPhoto;

  /// No description provided for @tooManyPhotos.
  ///
  /// In en, this message translates to:
  /// **'A recipe can have at most 20 photos'**
  String get tooManyPhotos;

  /// No description provided for @imageError.
  ///
  /// In en, this message translates to:
  /// **'This file could not be read as a photo'**
  String get imageError;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this recipe?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'It moves to the trash and is removed for good after 30 days.'**
  String get deleteBody;

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get deletedMessage;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @duplicated.
  ///
  /// In en, this message translates to:
  /// **'Duplicate created'**
  String get duplicated;

  /// No description provided for @copyLabel.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get copyLabel;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'The trash is empty'**
  String get trashEmpty;

  /// No description provided for @trashInfo.
  ///
  /// In en, this message translates to:
  /// **'Recipes are removed for good 30 days after deleting.'**
  String get trashInfo;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @deleteForeverBody.
  ///
  /// In en, this message translates to:
  /// **'This recipe and its photos will be removed for good.'**
  String get deleteForeverBody;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Recipe restored'**
  String get restored;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'This recipe no longer exists'**
  String get notFound;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @openLinkError.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link'**
  String get openLinkError;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterWithCount.
  ///
  /// In en, this message translates to:
  /// **'Filter ({count})'**
  String filterWithCount(int count);

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortCreated.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get sortCreated;

  /// No description provided for @sortUpdated.
  ///
  /// In en, this message translates to:
  /// **'Date edited'**
  String get sortUpdated;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sortRating;

  /// No description provided for @sortCookTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking time'**
  String get sortCookTime;

  /// No description provided for @sortLastCooked.
  ///
  /// In en, this message translates to:
  /// **'Last cooked'**
  String get sortLastCooked;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// No description provided for @viewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get viewGrid;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get viewList;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recipes} =1{1 recipe} other{{count} recipes}}'**
  String resultCount(int count);

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No recipes match'**
  String get noMatch;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @filterCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get filterCategories;

  /// No description provided for @filterTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get filterTags;

  /// No description provided for @filterMinRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum stars'**
  String get filterMinRating;

  /// No description provided for @filterFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get filterFavorite;

  /// No description provided for @filterMaxTime.
  ///
  /// In en, this message translates to:
  /// **'Maximum total time'**
  String get filterMaxTime;

  /// No description provided for @filterIngredient.
  ///
  /// In en, this message translates to:
  /// **'Has ingredient'**
  String get filterIngredient;

  /// No description provided for @anyTime.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyTime;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @addSubCategory.
  ///
  /// In en, this message translates to:
  /// **'Add subcategory'**
  String get addSubCategory;

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Its subcategories are deleted too. Recipes are not deleted.'**
  String get deleteCategoryBody;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categoryNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 1 to 50 characters'**
  String get categoryNameInvalid;

  /// No description provided for @categoryDepthLimit.
  ///
  /// In en, this message translates to:
  /// **'Categories nest at most 3 levels'**
  String get categoryDepthLimit;

  /// No description provided for @categoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmpty;

  /// No description provided for @chooseCategories.
  ///
  /// In en, this message translates to:
  /// **'Choose categories'**
  String get chooseCategories;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No category selected'**
  String get noCategories;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Type, then press comma or Done to add a tag'**
  String get tagsHint;

  /// No description provided for @removeTag.
  ///
  /// In en, this message translates to:
  /// **'Remove tag {tag}'**
  String removeTag(String tag);

  /// No description provided for @tagTooLong.
  ///
  /// In en, this message translates to:
  /// **'A tag has at most 40 characters'**
  String get tagTooLong;

  /// No description provided for @cooked.
  ///
  /// In en, this message translates to:
  /// **'Cooked'**
  String get cooked;

  /// No description provided for @markCooked.
  ///
  /// In en, this message translates to:
  /// **'Mark as cooked'**
  String get markCooked;

  /// No description provided for @cookedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Never cooked} =1{Cooked once} other{Cooked {count} times}}'**
  String cookedTimes(int count);

  /// No description provided for @lastCooked.
  ///
  /// In en, this message translates to:
  /// **'Last time: {date}'**
  String lastCooked(String date);

  /// No description provided for @cookedRecorded.
  ///
  /// In en, this message translates to:
  /// **'Cooking recorded'**
  String get cookedRecorded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
