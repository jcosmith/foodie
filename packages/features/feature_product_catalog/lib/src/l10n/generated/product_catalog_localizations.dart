import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'product_catalog_localizations_de.dart';
import 'product_catalog_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ProductCatalogLocalizations
/// returned by `ProductCatalogLocalizations.of(context)`.
///
/// Applications need to include `ProductCatalogLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/product_catalog_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ProductCatalogLocalizations.localizationsDelegates,
///   supportedLocales: ProductCatalogLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ProductCatalogLocalizations.supportedLocales
/// property.
abstract class ProductCatalogLocalizations {
  ProductCatalogLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ProductCatalogLocalizations of(BuildContext context) {
    return Localizations.of<ProductCatalogLocalizations>(context, ProductCatalogLocalizations)!;
  }

  static const LocalizationsDelegate<ProductCatalogLocalizations> delegate =
      _ProductCatalogLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en')];

  /// No description provided for @configSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get configSectionTitle;

  /// No description provided for @productListTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productListTitle;

  /// No description provided for @productListHint.
  ///
  /// In en, this message translates to:
  /// **'Products you hide disappear from this list and from the picker. Their history stays.'**
  String get productListHint;

  /// No description provided for @productCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product} other{{count} products}}'**
  String productCount(int count);

  /// No description provided for @pickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a product'**
  String get pickerTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchHint;

  /// No description provided for @createProductAction.
  ///
  /// In en, this message translates to:
  /// **'Create new product'**
  String get createProductAction;

  /// No description provided for @createProductWithName.
  ///
  /// In en, this message translates to:
  /// **'Create “{name}”'**
  String createProductWithName(String name);

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No product matches “{query}”.'**
  String noProductsFound(String query);

  /// No description provided for @newProductTitle.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get newProductTitle;

  /// No description provided for @editProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProductTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHintSeeded.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for “{name}”'**
  String nameHintSeeded(String name);

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Counted in'**
  String get unitLabel;

  /// No description provided for @unitLockedHint.
  ///
  /// In en, this message translates to:
  /// **'The unit stays fixed, because stock of this product is stored in it.'**
  String get unitLockedHint;

  /// No description provided for @packageSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Usual package size (optional)'**
  String get packageSizeLabel;

  /// No description provided for @packageSizeHelper.
  ///
  /// In en, this message translates to:
  /// **'Pre-fills the amount when you add it.'**
  String get packageSizeHelper;

  /// No description provided for @shelfLifeLabel.
  ///
  /// In en, this message translates to:
  /// **'Keeps for (optional)'**
  String get shelfLifeLabel;

  /// No description provided for @shelfLifeHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to follow the category: {shelfLife}.'**
  String shelfLifeHelper(String shelfLife);

  /// No description provided for @shelfLifeHelperNone.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep no shelf life, as the category does.'**
  String get shelfLifeHelperNone;

  /// No description provided for @storageRecommendationNote.
  ///
  /// In en, this message translates to:
  /// **'Storage times are guidance, not a safety guarantee.'**
  String get storageRecommendationNote;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon (an emoji, optional)'**
  String get iconLabel;

  /// No description provided for @iconImageChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a picture'**
  String get iconImageChoose;

  /// No description provided for @iconImageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove picture'**
  String get iconImageRemove;

  /// No description provided for @iconImageHint.
  ///
  /// In en, this message translates to:
  /// **'A picture is shown instead of the emoji. Any picture file works; it is scaled to fit.'**
  String get iconImageHint;

  /// No description provided for @iconImageUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This file is no picture the app can read.'**
  String get iconImageUnreadable;

  /// No description provided for @defaultCompartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Default compartment'**
  String get defaultCompartmentLabel;

  /// No description provided for @defaultCompartmentNone.
  ///
  /// In en, this message translates to:
  /// **'The compartment used last time'**
  String get defaultCompartmentNone;

  /// No description provided for @defaultCompartmentHelper.
  ///
  /// In en, this message translates to:
  /// **'Chosen for you when you add this product.'**
  String get defaultCompartmentHelper;

  /// No description provided for @archiveProductAction.
  ///
  /// In en, this message translates to:
  /// **'Hide product'**
  String get archiveProductAction;

  /// No description provided for @archiveProductDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide {name}?'**
  String archiveProductDialogTitle(String name);

  /// No description provided for @archiveProductDialogText.
  ///
  /// In en, this message translates to:
  /// **'It disappears from the product list. Items already at home and your statistics keep it.'**
  String get archiveProductDialogText;

  /// No description provided for @nameMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get nameMissing;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 40 characters.'**
  String get nameTooLong;

  /// No description provided for @invalidSetting.
  ///
  /// In en, this message translates to:
  /// **'Amounts must be more than zero.'**
  String get invalidSetting;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number.'**
  String get invalidNumber;

  /// No description provided for @genericFailure.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get genericFailure;
}

class _ProductCatalogLocalizationsDelegate
    extends LocalizationsDelegate<ProductCatalogLocalizations> {
  const _ProductCatalogLocalizationsDelegate();

  @override
  Future<ProductCatalogLocalizations> load(Locale locale) {
    return SynchronousFuture<ProductCatalogLocalizations>(
      lookupProductCatalogLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ProductCatalogLocalizationsDelegate old) => false;
}

ProductCatalogLocalizations lookupProductCatalogLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return ProductCatalogLocalizationsDe();
    case 'en':
      return ProductCatalogLocalizationsEn();
  }

  throw FlutterError(
    'ProductCatalogLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
