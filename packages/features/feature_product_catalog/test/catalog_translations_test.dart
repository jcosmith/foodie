import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _GermanCatalogNames implements CatalogNames {
  const _GermanCatalogNames();

  @override
  String? categoryName(String catalogKey) => catalogKey == 'vegetables' ? 'Gemüse' : null;

  @override
  String? productName(String catalogKey) => catalogKey == 'leafSpinach' ? 'Blattspinat' : null;
}

final class _CatalogModule extends FeatureModuleBase {
  const _CatalogModule(this.moduleIdentifier, this.productKey, this.productName);

  @override
  final String moduleIdentifier;
  final String productKey;
  final String productName;

  @override
  CatalogContribution get catalog => CatalogContribution(
    categories: const [],
    products: const [],
    categoryNameBuilder: (context, catalogKey) => null,
    productNameBuilder: (context, catalogKey) => catalogKey == productKey ? productName : null,
  );
}

void main() {
  final spinach = Product(
    identifier: const ProductIdentifier('spinach'),
    categoryIdentifier: const CategoryIdentifier('vegetables'),
    catalogKey: 'leafSpinach',
    canonicalUnit: QuantityUnit.gram,
    createdAt: DateTime.utc(2026),
  );

  test('user names win over translations', () {
    const resolver = ProductDisplayNameResolver(_GermanCatalogNames());

    expect(resolver.productName(spinach), 'Blattspinat');
    expect(
      resolver.productName(spinach.copyWith(customName: () => 'Spinat vom Markt')),
      'Spinat vom Markt',
    );
  });

  test('a key nobody translates shows as itself rather than as nothing', () {
    const resolver = ProductDisplayNameResolver(_GermanCatalogNames());
    final unknown = spinach.copyWith();
    expect(
      resolver.productName(
        Product(
          identifier: unknown.identifier,
          categoryIdentifier: unknown.categoryIdentifier,
          catalogKey: 'mysteryKey',
          canonicalUnit: QuantityUnit.gram,
          createdAt: unknown.createdAt,
        ),
      ),
      'mysteryKey',
    );
  });

  testWidgets('seeded names are translated by the module that seeded them', (tester) async {
    late CatalogNames catalogNames;
    final container = ProviderContainer(
      overrides: [
        registeredFeatureModulesProvider.overrideWithValue(const [
          _CatalogModule('fridge', 'wholeMilk', 'Whole milk'),
          _CatalogModule('pantry', 'basmatiRice', 'Basmati rice'),
        ]),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: const ProductCatalogFeatureModule().localizationDelegates,
          home: Builder(
            builder: (context) {
              catalogNames = context.catalogNames;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(catalogNames.productName('wholeMilk'), 'Whole milk');
    expect(catalogNames.productName('basmatiRice'), 'Basmati rice');
    expect(catalogNames.productName('unknownKey'), isNull);
    expect(catalogNames.categoryName('unknownKey'), isNull);
  });
}
