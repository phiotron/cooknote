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
  /// **'Bepbook'**
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

  /// No description provided for @webTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from a website'**
  String get webTitle;

  /// No description provided for @webAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Address or search words'**
  String get webAddressHint;

  /// No description provided for @webBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get webBack;

  /// No description provided for @webForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get webForward;

  /// No description provided for @webReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get webReload;

  /// No description provided for @webSave.
  ///
  /// In en, this message translates to:
  /// **'Save recipe'**
  String get webSave;

  /// No description provided for @webStartHint.
  ///
  /// In en, this message translates to:
  /// **'Type an address or search words (for example \"pho bo\"), open a page with a recipe, then tap Save recipe.'**
  String get webStartHint;

  /// No description provided for @webErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network, or the page could not be reached.'**
  String get webErrorNetwork;

  /// No description provided for @webErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The page took more than 20 seconds to load. The connection may be weak.'**
  String get webErrorTimeout;

  /// No description provided for @webErrorHttp.
  ///
  /// In en, this message translates to:
  /// **'The page reported error {code}.'**
  String webErrorHttp(int code);

  /// No description provided for @webErrorOther.
  ///
  /// In en, this message translates to:
  /// **'The page could not be opened.'**
  String get webErrorOther;

  /// No description provided for @webReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the page content.'**
  String get webReadFailed;

  /// No description provided for @webRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get webRetry;

  /// No description provided for @webNoRecipe.
  ///
  /// In en, this message translates to:
  /// **'This page has no recipe data. Select text on the page, then choose below.'**
  String get webNoRecipe;

  /// No description provided for @webSelectName.
  ///
  /// In en, this message translates to:
  /// **'Is the name'**
  String get webSelectName;

  /// No description provided for @webSelectIngredients.
  ///
  /// In en, this message translates to:
  /// **'Is ingredients'**
  String get webSelectIngredients;

  /// No description provided for @webSelectSteps.
  ///
  /// In en, this message translates to:
  /// **'Is the steps'**
  String get webSelectSteps;

  /// No description provided for @webSelectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No text is selected on the page.'**
  String get webSelectionEmpty;

  /// No description provided for @webPartsSummary.
  ///
  /// In en, this message translates to:
  /// **'Picked: {ingredients} ingredient lines, {steps} step lines'**
  String webPartsSummary(int ingredients, int steps);

  /// No description provided for @webClearParts.
  ///
  /// In en, this message translates to:
  /// **'Clear picks'**
  String get webClearParts;

  /// No description provided for @webDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'You already have this recipe'**
  String get webDuplicateTitle;

  /// No description provided for @webDuplicateBody.
  ///
  /// In en, this message translates to:
  /// **'This address is already in your book. Open the old one or save a new copy?'**
  String get webDuplicateBody;

  /// No description provided for @webOpenExisting.
  ///
  /// In en, this message translates to:
  /// **'Open the old one'**
  String get webOpenExisting;

  /// No description provided for @webSaveNew.
  ///
  /// In en, this message translates to:
  /// **'Save a new copy'**
  String get webSaveNew;

  /// No description provided for @webDownloadingImages.
  ///
  /// In en, this message translates to:
  /// **'Downloading photos {done}/{total}'**
  String webDownloadingImages(int done, int total);

  /// No description provided for @webSkipImages.
  ///
  /// In en, this message translates to:
  /// **'Skip photos'**
  String get webSkipImages;

  /// No description provided for @webImagesFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo could not be downloaded} other{{count} photos could not be downloaded}}'**
  String webImagesFailed(int count);

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

  /// No description provided for @cookButton.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cookButton;

  /// No description provided for @cookModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooking mode'**
  String get cookModeTitle;

  /// No description provided for @scaleFactorLabel.
  ///
  /// In en, this message translates to:
  /// **'Multiplier'**
  String get scaleFactorLabel;

  /// No description provided for @scaleServingsButton.
  ///
  /// In en, this message translates to:
  /// **'Servings…'**
  String get scaleServingsButton;

  /// No description provided for @scaleCustomButton.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get scaleCustomButton;

  /// No description provided for @scaleServingsTitle.
  ///
  /// In en, this message translates to:
  /// **'New servings'**
  String get scaleServingsTitle;

  /// No description provided for @scaleCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a multiplier (for example 1.5 or 1/2)'**
  String get scaleCustomTitle;

  /// No description provided for @scaleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Not a valid number'**
  String get scaleInvalid;

  /// No description provided for @unitOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get unitOriginal;

  /// No description provided for @unitMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitMetric;

  /// No description provided for @unitUs.
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get unitUs;

  /// No description provided for @viewingScaled.
  ///
  /// In en, this message translates to:
  /// **'Viewing ×{factor}. The original recipe is unchanged.'**
  String viewingScaled(String factor);

  /// No description provided for @viewingUnitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Viewing converted units. The original recipe is unchanged.'**
  String get viewingUnitsOnly;

  /// No description provided for @resetView.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetView;

  /// No description provided for @saveScaled.
  ///
  /// In en, this message translates to:
  /// **'Save at this scale'**
  String get saveScaled;

  /// No description provided for @saveScaledTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite the recipe?'**
  String get saveScaledTitle;

  /// No description provided for @saveScaledBody.
  ///
  /// In en, this message translates to:
  /// **'The ingredients and servings you are viewing will replace the original.'**
  String get saveScaledBody;

  /// No description provided for @scaledSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved at the new scale'**
  String get scaledSaved;

  /// No description provided for @cannotScale.
  ///
  /// In en, this message translates to:
  /// **'cannot be scaled automatically'**
  String get cannotScale;

  /// No description provided for @cookFontSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get cookFontSize;

  /// No description provided for @cookPin.
  ///
  /// In en, this message translates to:
  /// **'Pin for quick access'**
  String get cookPin;

  /// No description provided for @cookUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get cookUnpin;

  /// No description provided for @cookPinLimit.
  ///
  /// In en, this message translates to:
  /// **'You can pin at most {max} recipes. Unpin one first.'**
  String cookPinLimit(int max);

  /// No description provided for @cookNoSteps.
  ///
  /// In en, this message translates to:
  /// **'This recipe has no steps yet.'**
  String get cookNoSteps;

  /// No description provided for @cookTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a line to cross it off.'**
  String get cookTapHint;

  /// No description provided for @cookStepN.
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String cookStepN(int n);

  /// No description provided for @timerButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Set timer for {label}'**
  String timerButtonTooltip(String label);

  /// No description provided for @timerName.
  ///
  /// In en, this message translates to:
  /// **'{step} · {label}'**
  String timerName(String step, String label);

  /// No description provided for @timersRunning.
  ///
  /// In en, this message translates to:
  /// **'Running timers'**
  String get timersRunning;

  /// No description provided for @timerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel timer'**
  String get timerCancel;

  /// No description provided for @timerDone.
  ///
  /// In en, this message translates to:
  /// **'Time is up: {name}'**
  String timerDone(String name);

  /// No description provided for @timerDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get timerDismiss;

  /// No description provided for @timerNotifBody.
  ///
  /// In en, this message translates to:
  /// **'{recipe}: time is up'**
  String timerNotifBody(String recipe);

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Cooking timers'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Alerts when a cooking timer ends'**
  String get notifChannelDescription;

  /// No description provided for @notifRationaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert when time is up'**
  String get notifRationaleTitle;

  /// No description provided for @notifRationaleBody.
  ///
  /// In en, this message translates to:
  /// **'Bepbook needs notification permission to alert you when a timer ends, even when the screen is locked or the app is in the background. It is used only for cooking timers.'**
  String get notifRationaleBody;

  /// No description provided for @notifContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get notifContinue;

  /// No description provided for @notifLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notifLater;

  /// No description provided for @notifDeniedWarning.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off: timers still run but will not alert while the app is in the background.'**
  String get notifDeniedWarning;

  /// No description provided for @speakStep.
  ///
  /// In en, this message translates to:
  /// **'Read step'**
  String get speakStep;

  /// No description provided for @stopSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get stopSpeaking;

  /// No description provided for @noVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'No {language} voice on this device'**
  String noVoiceTitle(String language);

  /// No description provided for @noVoiceBody.
  ///
  /// In en, this message translates to:
  /// **'Open the device Settings, find \"Text-to-speech\" (the name may differ by manufacturer), pick the language and download a voice.'**
  String get noVoiceBody;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @speakError.
  ///
  /// In en, this message translates to:
  /// **'Could not read this step aloud'**
  String get speakError;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupAutoTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get backupAutoTitle;

  /// No description provided for @backupLast.
  ///
  /// In en, this message translates to:
  /// **'Last successful backup'**
  String get backupLast;

  /// No description provided for @backupNever.
  ///
  /// In en, this message translates to:
  /// **'No successful backup yet'**
  String get backupNever;

  /// No description provided for @backupLastDetail.
  ///
  /// In en, this message translates to:
  /// **'{when} · {size}'**
  String backupLastDetail(String when, String size);

  /// No description provided for @backupFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder: {name}'**
  String backupFolder(String name);

  /// No description provided for @backupChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose automatic backup folder'**
  String get backupChooseFolder;

  /// No description provided for @backupChangeFolder.
  ///
  /// In en, this message translates to:
  /// **'Change folder'**
  String get backupChangeFolder;

  /// No description provided for @backupDisable.
  ///
  /// In en, this message translates to:
  /// **'Turn off automatic backup'**
  String get backupDisable;

  /// No description provided for @backupFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a folder once, on this phone or in Google Drive or OneDrive. Bepbook writes backups there when you open or leave the app and keeps the latest few. If the cloud app does not allow automatic writes, use \"Back up now and save elsewhere\" below.'**
  String get backupFolderHint;

  /// No description provided for @backupInterval.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get backupInterval;

  /// No description provided for @intervalDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get intervalDaily;

  /// No description provided for @intervalWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get intervalWeekly;

  /// No description provided for @backupKeepLabel.
  ///
  /// In en, this message translates to:
  /// **'Copies to keep'**
  String get backupKeepLabel;

  /// No description provided for @backupKeepValue.
  ///
  /// In en, this message translates to:
  /// **'{count} copies'**
  String backupKeepValue(int count);

  /// No description provided for @backupRunNow.
  ///
  /// In en, this message translates to:
  /// **'Back up to the folder now'**
  String get backupRunNow;

  /// No description provided for @backupSaveElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Back up now and save elsewhere'**
  String get backupSaveElsewhere;

  /// No description provided for @backupSaveElsewhereHint.
  ///
  /// In en, this message translates to:
  /// **'Creates a backup file and opens the share sheet: save to Files, Google Drive, send by email...'**
  String get backupSaveElsewhereHint;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from a file...'**
  String get backupRestoreFile;

  /// No description provided for @backupRestoreFromFolder.
  ///
  /// In en, this message translates to:
  /// **'Backups in the automatic folder'**
  String get backupRestoreFromFolder;

  /// No description provided for @backupNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No backups in the folder yet'**
  String get backupNoFiles;

  /// No description provided for @backupListError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the backup folder'**
  String get backupListError;

  /// No description provided for @restoreReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace everything'**
  String get restoreReplace;

  /// No description provided for @restoreMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge (only add missing recipes)'**
  String get restoreMerge;

  /// No description provided for @restoreReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'All current data will be replaced. Bepbook saves a copy of the current data first.'**
  String get restoreReplaceWarning;

  /// No description provided for @restoreMergeInfo.
  ///
  /// In en, this message translates to:
  /// **'Recipes you already have (same name, same creation time) are kept as they are.'**
  String get restoreMergeInfo;

  /// No description provided for @restoreChooseMode.
  ///
  /// In en, this message translates to:
  /// **'How do you want to restore?'**
  String get restoreChooseMode;

  /// No description provided for @restoreInfo.
  ///
  /// In en, this message translates to:
  /// **'{recipes} recipes, {photos} photos, created {when}'**
  String restoreInfo(int recipes, int photos, String when);

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restored: {added} added, {skipped} already there'**
  String restoreDone(int added, int skipped);

  /// No description provided for @errBackupNotABackup.
  ///
  /// In en, this message translates to:
  /// **'This is not a Bepbook backup file'**
  String get errBackupNotABackup;

  /// No description provided for @errBackupNewer.
  ///
  /// In en, this message translates to:
  /// **'This file was made by a newer Bepbook. Update the app and try again'**
  String get errBackupNewer;

  /// No description provided for @errBackupChecksum.
  ///
  /// In en, this message translates to:
  /// **'The file is damaged (checksum mismatch). Your data was not changed'**
  String get errBackupChecksum;

  /// No description provided for @errBackupMissing.
  ///
  /// In en, this message translates to:
  /// **'The file is missing part of its data. Your data was not changed'**
  String get errBackupMissing;

  /// No description provided for @errBackupBad.
  ///
  /// In en, this message translates to:
  /// **'The file content is malformed. Your data was not changed'**
  String get errBackupBad;

  /// No description provided for @backupDone.
  ///
  /// In en, this message translates to:
  /// **'Backed up ({size})'**
  String backupDone(String size);

  /// No description provided for @backupUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Nothing changed since the last backup'**
  String get backupUnchanged;

  /// No description provided for @backupFailedTarget.
  ///
  /// In en, this message translates to:
  /// **'Could not write to the backup folder. Check permissions or choose the folder again.'**
  String get backupFailedTarget;

  /// No description provided for @backupFailedVerify.
  ///
  /// In en, this message translates to:
  /// **'The written file failed the read-back check, so it does not count as a successful backup. Try again or pick another folder.'**
  String get backupFailedVerify;

  /// No description provided for @backupFailedOther.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailedOther;

  /// No description provided for @backupCancelled.
  ///
  /// In en, this message translates to:
  /// **'Backup cancelled'**
  String get backupCancelled;

  /// No description provided for @backupWorking.
  ///
  /// In en, this message translates to:
  /// **'Backing up...'**
  String get backupWorking;

  /// No description provided for @restoreWorking.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get restoreWorking;

  /// No description provided for @backupUnencrypted.
  ///
  /// In en, this message translates to:
  /// **'Backup files are NOT encrypted: anyone with the file can read your recipes. Keep it somewhere safe.'**
  String get backupUnencrypted;

  /// No description provided for @backupSystemLayer.
  ///
  /// In en, this message translates to:
  /// **'If Android backup is on, the system also backs up the database (without photos) to your Google account. That layer has size limits and does not replace the backups above.'**
  String get backupSystemLayer;

  /// No description provided for @noticeSuggest.
  ///
  /// In en, this message translates to:
  /// **'You have {count} recipes. Turn on automatic backup so you do not lose them.'**
  String noticeSuggest(int count);

  /// No description provided for @noticeOverdue.
  ///
  /// In en, this message translates to:
  /// **'More than 7 days without a successful backup.'**
  String get noticeOverdue;

  /// No description provided for @noticeError.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup is failing. Open to review and choose the folder again.'**
  String get noticeError;

  /// No description provided for @noticeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Backup'**
  String get noticeOpen;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get importTitle;

  /// No description provided for @importIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a file exported from Paprika (.paprikarecipes), Recipe Keeper (.zip), schema.org JSON, or a .cooknote backup.'**
  String get importIntro;

  /// No description provided for @importUnverified.
  ///
  /// In en, this message translates to:
  /// **'The Paprika and Recipe Keeper formats are read from third-party documentation and are not yet verified against every real file. If a file cannot be read, your data stays unchanged.'**
  String get importUnverified;

  /// No description provided for @importChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get importChoose;

  /// No description provided for @importWorking.
  ///
  /// In en, this message translates to:
  /// **'Importing recipes…'**
  String get importWorking;

  /// No description provided for @importUnknown.
  ///
  /// In en, this message translates to:
  /// **'This file format is not recognised. Bepbook reads .paprikarecipes, Recipe Keeper zip, schema.org JSON and .cooknote.'**
  String get importUnknown;

  /// No description provided for @importBadFile.
  ///
  /// In en, this message translates to:
  /// **'This file could not be read. Your data was not changed.'**
  String get importBadFile;

  /// No description provided for @importCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled. Recipes imported so far are kept.'**
  String get importCancelled;

  /// No description provided for @importResult.
  ///
  /// In en, this message translates to:
  /// **'Imported {imported} recipes. Already present: {duplicates}. Skipped: {skipped}.'**
  String importResult(int imported, int duplicates, int skipped);

  /// No description provided for @importDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get importDetails;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @exitSelection.
  ///
  /// In en, this message translates to:
  /// **'Exit selection'**
  String get exitSelection;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @cookbookMake.
  ///
  /// In en, this message translates to:
  /// **'Recipe book (PDF)'**
  String get cookbookMake;

  /// No description provided for @trashSelected.
  ///
  /// In en, this message translates to:
  /// **'Move to trash'**
  String get trashSelected;

  /// No description provided for @trashedCount.
  ///
  /// In en, this message translates to:
  /// **'Moved {count} recipes to trash'**
  String trashedCount(int count);

  /// No description provided for @exportWorking.
  ///
  /// In en, this message translates to:
  /// **'Creating file…'**
  String get exportWorking;

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get exportCancelled;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the file.'**
  String get exportFailed;

  /// No description provided for @shareRecipe.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareRecipe;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get shareAsText;

  /// No description provided for @shareAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Share as PDF file'**
  String get shareAsPdf;

  /// No description provided for @shareAsCooknote.
  ///
  /// In en, this message translates to:
  /// **'Send a .cooknote file (importable in Bepbook)'**
  String get shareAsCooknote;

  /// No description provided for @printRecipe.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printRecipe;

  /// No description provided for @cookbookTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Book title'**
  String get cookbookTitleLabel;

  /// No description provided for @cookbookDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'My recipe book'**
  String get cookbookDefaultTitle;

  /// No description provided for @cookbookCreate.
  ///
  /// In en, this message translates to:
  /// **'Create book'**
  String get cookbookCreate;

  /// No description provided for @cookbookReady.
  ///
  /// In en, this message translates to:
  /// **'The book is ready'**
  String get cookbookReady;

  /// No description provided for @cookbookShare.
  ///
  /// In en, this message translates to:
  /// **'Share or save'**
  String get cookbookShare;

  /// No description provided for @cookbookNone.
  ///
  /// In en, this message translates to:
  /// **'No recipes to export'**
  String get cookbookNone;

  /// No description provided for @exchangeSection.
  ///
  /// In en, this message translates to:
  /// **'Import and export'**
  String get exchangeSection;

  /// No description provided for @exportAllJson.
  ///
  /// In en, this message translates to:
  /// **'Export all recipes (JSON)'**
  String get exportAllJson;

  /// No description provided for @cookbookAll.
  ///
  /// In en, this message translates to:
  /// **'Recipe book from all recipes'**
  String get cookbookAll;

  /// No description provided for @pdfContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get pdfContents;

  /// No description provided for @pdfServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get pdfServings;

  /// No description provided for @pdfPrep.
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get pdfPrep;

  /// No description provided for @pdfCook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get pdfCook;

  /// No description provided for @pdfTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get pdfTotal;

  /// No description provided for @pdfMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get pdfMinutes;

  /// No description provided for @pdfPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pdfPage;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get backupStatusSafe;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get backupStatusOverdue;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Failing'**
  String get backupStatusFailing;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get backupStatusNotSetUp;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Your data is unchanged.'**
  String get dataUnchanged;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'{name} · {time}'**
  String timerPillOne(String name, String time);

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'{count} timers · {time}'**
  String timerPillMany(int count, String time);

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Timer {name}, {time} left. Opens Cook mode.'**
  String timerPillSemantics(String name, String time);

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'{count} timers running, next ends in {time}. Opens Cook mode.'**
  String timerPillManySemantics(int count, String time);

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get errorRetry;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Recipes without this info go last'**
  String get sortMissingLast;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Show {n} recipes'**
  String showNRecipes(int n);

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get emptyTrash;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Check before saving'**
  String get previewTitle;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Sort the lines'**
  String get scanAssignTitle;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Reading the recipe…'**
  String get scanReading;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Pick text'**
  String get pickText;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get chooseAnotherFile;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Pages you open are the only thing Bepbook loads from the internet.'**
  String get webStartNote;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Saved to Bepbook — open?'**
  String get extShareSaved;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 step done · Show} other{{n} steps done · Show}}'**
  String cookStepsDoneShow(int n);

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get cookStartOver;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Your timer has already started'**
  String get timerAlreadyStarted;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get cookReadStopShort;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Make your first list'**
  String get shoppingMakeFirstList;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Nothing to buy'**
  String get shoppingNothingToBuy;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get shoppingAllDone;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Delete the list \"{name}\" and its {n, plural, =1{1 item} other{{n} items}}?'**
  String shoppingDeleteListConfirm(String name, int n);

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Drop here'**
  String get menuDropHere;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'This day already has meals'**
  String get menuDayHasMeals;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get deleting;

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'{n} of 5 stars'**
  String ratingSemantics(int n);

  /// F0/Hi-Fi v1
  ///
  /// In en, this message translates to:
  /// **'No rating'**
  String get ratingUnset;
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
