import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:meta/meta.dart';

import 'category.dart';
import 'product_icon_image.dart';

typedef ProductIdentifier = TypedIdentifier<Product>;

/// Something the household keeps, such as leaf spinach or dish soap.
///
/// Every quantity of a product is stored in its [canonicalUnit] (decision
/// D10), so stock of one product can always be added up.
@immutable
final class Product {
  const Product({
    required this.identifier,
    required this.categoryIdentifier,
    required this.canonicalUnit,
    required this.createdAt,
    this.catalogKey,
    this.customName,
    this.defaultPackageQuantity,
    this.recommendedMaximumStorageDays,
    this.shelfLifeAfterOpeningDays,
    this.iconEmoji,
    this.iconImage,
    this.defaultCompartmentIdentifier,
    this.isArchived = false,
  });

  final ProductIdentifier identifier;
  final CategoryIdentifier categoryIdentifier;

  /// Set for seeded products, whose names are translated until renamed.
  final String? catalogKey;

  /// The name the user typed; always set for products the user created.
  final String? customName;

  final QuantityUnit canonicalUnit;

  /// Pre-fills the add form, for example 1 kg for a bag of spinach.
  final Quantity? defaultPackageQuantity;

  /// Overrides the category's shelf life when set.
  final int? recommendedMaximumStorageDays;

  /// Overrides the category's shelf life after opening when set.
  final int? shelfLifeAfterOpeningDays;

  /// Falls back to the category icon when not set.
  final String? iconEmoji;

  /// Shown instead of the emoji where there is room for a picture; the
  /// emoji stays for places that only show text.
  final ProductIconImage? iconImage;

  /// The drawer a new batch goes into unless the user picks another; without
  /// one, the add form suggests the drawer used last time.
  final CompartmentIdentifier? defaultCompartmentIdentifier;

  final bool isArchived;
  final DateTime createdAt;

  int effectiveRecommendedMaximumStorageDays(Category category) =>
      recommendedMaximumStorageDays ?? category.recommendedMaximumStorageDays;

  String effectiveIconEmoji(Category category) => iconEmoji ?? category.iconEmoji;

  Product copyWith({
    CategoryIdentifier? categoryIdentifier,
    String? Function()? customName,
    Quantity? Function()? defaultPackageQuantity,
    int? Function()? recommendedMaximumStorageDays,
    int? Function()? shelfLifeAfterOpeningDays,
    String? Function()? iconEmoji,
    ProductIconImage? Function()? iconImage,
    CompartmentIdentifier? Function()? defaultCompartmentIdentifier,
    bool? isArchived,
  }) => Product(
    identifier: identifier,
    categoryIdentifier: categoryIdentifier ?? this.categoryIdentifier,
    catalogKey: catalogKey,
    customName: customName == null ? this.customName : customName(),
    canonicalUnit: canonicalUnit,
    defaultPackageQuantity: defaultPackageQuantity == null
        ? this.defaultPackageQuantity
        : defaultPackageQuantity(),
    recommendedMaximumStorageDays: recommendedMaximumStorageDays == null
        ? this.recommendedMaximumStorageDays
        : recommendedMaximumStorageDays(),
    shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays == null
        ? this.shelfLifeAfterOpeningDays
        : shelfLifeAfterOpeningDays(),
    iconEmoji: iconEmoji == null ? this.iconEmoji : iconEmoji(),
    iconImage: iconImage == null ? this.iconImage : iconImage(),
    defaultCompartmentIdentifier: defaultCompartmentIdentifier == null
        ? this.defaultCompartmentIdentifier
        : defaultCompartmentIdentifier(),
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Product &&
      other.identifier == identifier &&
      other.categoryIdentifier == categoryIdentifier &&
      other.catalogKey == catalogKey &&
      other.customName == customName &&
      other.canonicalUnit == canonicalUnit &&
      other.defaultPackageQuantity == defaultPackageQuantity &&
      other.recommendedMaximumStorageDays == recommendedMaximumStorageDays &&
      other.shelfLifeAfterOpeningDays == shelfLifeAfterOpeningDays &&
      other.iconEmoji == iconEmoji &&
      other.iconImage == iconImage &&
      other.defaultCompartmentIdentifier == defaultCompartmentIdentifier &&
      other.isArchived == isArchived &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    identifier,
    categoryIdentifier,
    catalogKey,
    customName,
    canonicalUnit,
    defaultPackageQuantity,
    recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays,
    iconEmoji,
    iconImage,
    defaultCompartmentIdentifier,
    isArchived,
    createdAt,
  );
}
