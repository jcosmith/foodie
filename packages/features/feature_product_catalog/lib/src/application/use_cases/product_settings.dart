import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:meta/meta.dart';

import '../../domain/category.dart';
import '../../domain/product_catalog_failure.dart';
import '../../domain/product_icon_image.dart';

/// What the product editor submits, for new and existing products alike.
@immutable
final class ProductSettings {
  const ProductSettings({
    required this.enteredName,
    required this.categoryIdentifier,
    this.defaultPackageQuantity,
    this.recommendedMaximumStorageDays,
    this.shelfLifeAfterOpeningDays,
    this.iconEmoji,
    this.iconImage,
    this.defaultCompartmentIdentifier,
    this.pieceLabel,
  });

  final String enteredName;
  final CategoryIdentifier categoryIdentifier;
  final Quantity? defaultPackageQuantity;

  /// `null` follows the category's recommendation.
  final int? recommendedMaximumStorageDays;

  /// `null` follows the category.
  final int? shelfLifeAfterOpeningDays;

  /// `null` uses the category icon.
  final String? iconEmoji;

  /// `null` shows the emoji.
  final ProductIconImage? iconImage;

  /// `null` suggests the compartment used last time.
  final CompartmentIdentifier? defaultCompartmentIdentifier;

  /// What one piece is called, such as "slices"; kept only for products
  /// counted in pieces.
  final String? pieceLabel;

  /// Checks the numbers; names are checked by the use cases.
  ProductCatalogFailure? validateNumbers() {
    final packageQuantity = defaultPackageQuantity;
    final storageDays = recommendedMaximumStorageDays;
    final daysAfterOpening = shelfLifeAfterOpeningDays;
    if ((packageQuantity != null && !packageQuantity.isPositive) ||
        (storageDays != null && storageDays <= 0) ||
        (daysAfterOpening != null && daysAfterOpening <= 0)) {
      return const InvalidProductSetting();
    }
    return null;
  }

  /// [pieceLabel] trimmed, for a product counted in [unit]; `null` when
  /// empty or the product is not counted in pieces.
  String? pieceLabelFor(QuantityUnit unit) {
    final trimmed = pieceLabel?.trim();
    return unit != QuantityUnit.piece || trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? get trimmedIconEmoji {
    final trimmed = iconEmoji?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
