import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/catalog_names.dart';
import '../domain/product_catalog_failure.dart';
import '../l10n/generated/product_catalog_localizations.dart';

/// Seeded catalog names in [locale], translated by the module that seeded
/// each entry. Works without a widget, for example for reminders.
final class ContributedCatalogNames implements CatalogNames {
  const ContributedCatalogNames(this._contributions, this._locale);

  final List<CatalogContribution> _contributions;
  final Locale _locale;

  @override
  String? categoryName(String catalogKey) {
    for (final contribution in _contributions) {
      final name = contribution.categoryNameBuilder(_locale, catalogKey);
      if (name != null) return name;
    }
    return null;
  }

  @override
  String? productName(String catalogKey) {
    for (final contribution in _contributions) {
      final name = contribution.productNameBuilder(_locale, catalogKey);
      if (name != null) return name;
    }
    return null;
  }
}

/// Display names for screens of any feature that shows products.
extension ProductCatalogLocalizationContext on BuildContext {
  /// Seeded catalog names in the current app language.
  CatalogNames get catalogNames => ContributedCatalogNames(
    ProviderScope.containerOf(this, listen: false).read(registeredCatalogContributionsProvider),
    Localizations.localeOf(this),
  );

  ProductDisplayNameResolver get productDisplayNameResolver =>
      ProductDisplayNameResolver(catalogNames);
}

extension ProductCatalogFailureTexts on ProductCatalogLocalizations {
  String describeFailure(ProductCatalogFailure failure) => switch (failure) {
    ProductNameMissing() => nameMissing,
    ProductNameTooLong() => nameTooLong,
    InvalidProductSetting() => invalidSetting,
    UnreadableIconImage() => iconImageUnreadable,
    ProductNotFound() || CategoryNotFound() => genericFailure,
  };
}
