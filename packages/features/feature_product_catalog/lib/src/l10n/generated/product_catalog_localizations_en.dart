// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'product_catalog_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ProductCatalogLocalizationsEn extends ProductCatalogLocalizations {
  ProductCatalogLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get configSectionTitle => 'Products';

  @override
  String get productListTitle => 'Products';

  @override
  String get productListHint =>
      'Products you hide disappear from this list and from the picker. Their history stays.';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get pickerTitle => 'Choose a product';

  @override
  String get searchHint => 'Search products';

  @override
  String get createProductAction => 'Create new product';

  @override
  String createProductWithName(String name) {
    return 'Create “$name”';
  }

  @override
  String noProductsFound(String query) {
    return 'No product matches “$query”.';
  }

  @override
  String get newProductTitle => 'New product';

  @override
  String get editProductTitle => 'Edit product';

  @override
  String get nameLabel => 'Name';

  @override
  String nameHintSeeded(String name) {
    return 'Leave empty for “$name”';
  }

  @override
  String get categoryLabel => 'Category';

  @override
  String get unitLabel => 'Counted in';

  @override
  String get unitLockedHint =>
      'The unit stays fixed, because stock of this product is stored in it.';

  @override
  String get packageSizeLabel => 'Usual package size (optional)';

  @override
  String get packageSizeHelper => 'Pre-fills the amount when you add it.';

  @override
  String get storageMonthsLabel => 'Keep for at most, in months (optional)';

  @override
  String storageMonthsHelper(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Leave empty to follow the category: about $months months.',
      one: 'Leave empty to follow the category: about 1 month.',
    );
    return '$_temp0';
  }

  @override
  String get storageRecommendationNote => 'Storage times are guidance, not a safety guarantee.';

  @override
  String get iconLabel => 'Icon (an emoji, optional)';

  @override
  String get iconImageChoose => 'Choose a picture';

  @override
  String get iconImageRemove => 'Remove picture';

  @override
  String get iconImageHint =>
      'A picture is shown instead of the emoji. Any picture file works; it is scaled to fit.';

  @override
  String get iconImageUnreadable => 'This file is no picture the app can read.';

  @override
  String get defaultCompartmentLabel => 'Default drawer';

  @override
  String get defaultCompartmentNone => 'The drawer used last time';

  @override
  String get defaultCompartmentHelper => 'Chosen for you when you add this product to the freezer.';

  @override
  String get archiveProductAction => 'Hide product';

  @override
  String archiveProductDialogTitle(String name) {
    return 'Hide $name?';
  }

  @override
  String get archiveProductDialogText =>
      'It disappears from the product list. Items already in the freezer and your statistics keep it.';

  @override
  String get nameMissing => 'Please enter a name.';

  @override
  String get nameTooLong => 'At most 40 characters.';

  @override
  String get invalidSetting => 'Amounts must be more than zero.';

  @override
  String get invalidNumber => 'Please enter a number.';

  @override
  String get genericFailure => 'That did not work. Please try again.';
}
