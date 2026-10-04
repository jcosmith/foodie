import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_pantry/feature_pantry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _module = PantryFeatureModule();

/// Runs [body] with a context in [locale], as the contributions' builders need one.
Future<void> _withContext(
  WidgetTester tester,
  Locale locale,
  void Function(BuildContext context) body,
) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: SupportedLocales.all,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
        builder: (context) {
          capturedContext = context;
          return const SizedBox();
        },
      ),
    ),
  );
  body(capturedContext);
}

void main() {
  test('the pantry is an optional domain, on after installing, after the fridge', () {
    expect(_module.moduleIdentifier, 'pantry');
    expect(_module.availability, const ModuleAvailability.optional(isEnabledByDefault: true));
    final domain = _module.storageDomain;
    expect(domain.identifier, StorageDomainIdentifier.pantry);
    expect(domain.sortOrder, 30);
    expect(domain.iconEmoji, '🥫');
    expect(domain.countsDiscardsAsWaste, isTrue);
  });

  test('the pantry is a tab of its own', () {
    final destination = _module.navigationDestination;
    expect(destination.iconEmoji, '🥫');
    expect(destination.sortOrder, 30);
    expect(destination.initialLocation, '/pantry');
    expect(destination.routes.whereType<GoRoute>().single.path, '/pantry');
  });

  test('brings the pantry, kitchen cupboard, cellar and drinks crate with templates', () {
    expect(_module.storageKinds.map((kind) => kind.storageName), [
      'pantry',
      'kitchenCupboard',
      'cellar',
      'drinksCrate',
    ]);
    expect(_module.storageKinds.map((kind) => kind.domainIdentifier).toSet(), {
      StorageDomainIdentifier.pantry,
    });
    final templates = [
      for (final kind in _module.storageKinds)
        for (final template in kind.templates) (template.identifier, template.compartmentCount),
    ];
    expect(templates, [
      ('pantry.shelves', 4),
      ('pantry.cupboard', 2),
      ('pantry.cellar', 3),
      ('pantry.drinks_crate', 1),
    ]);
    expect(PantryStorageTemplates.pantryShelves.domainIdentifier, StorageDomainIdentifier.pantry);
  });

  test('seeds dry goods, tins, bread and drinks, some with shorter times once opened', () {
    final catalog = _module.catalog;
    expect(catalog.categories.map((category) => category.catalogKey), [
      'breadAndBakery',
      'dryGoods',
      'tinsAndJars',
      'spicesAndCondiments',
      'oilsAndVinegar',
      'baking',
      'breakfastAndSpreads',
      'snacks',
      'drinks',
    ]);
    expect(catalog.categories.map((category) => category.domainIdentifier).toSet(), {
      StorageDomainIdentifier.pantry,
    });
    final categoryKeys = {for (final category in catalog.categories) category.catalogKey};
    final productKeys = [for (final product in catalog.products) product.catalogKey];
    expect(productKeys.toSet(), hasLength(productKeys.length));
    expect(productKeys.length, greaterThanOrEqualTo(20));
    for (final product in catalog.products) {
      expect(categoryKeys, contains(product.categoryCatalogKey), reason: product.catalogKey);
    }
    final jam = catalog.products.singleWhere((product) => product.catalogKey == 'jam');
    expect(jam.shelfLifeAfterOpeningDays, 28, reason: 'jam keeps four weeks once opened');
    final bread = catalog.categories.singleWhere((c) => c.catalogKey == 'breadAndBakery');
    expect(bread.shelfLifeDays, lessThanOrEqualTo(3));
  });

  for (final locale in SupportedLocales.all) {
    testWidgets('every seeded entry and default name has a ${locale.languageCode} text', (
      tester,
    ) async {
      await _withContext(tester, locale, (context) {
        final catalog = _module.catalog;
        final languageLocale = Localizations.localeOf(context);
        for (final category in catalog.categories) {
          expect(catalog.categoryNameBuilder(languageLocale, category.catalogKey), isNotEmpty);
        }
        for (final product in catalog.products) {
          expect(catalog.productNameBuilder(languageLocale, product.catalogKey), isNotEmpty);
        }
        expect(catalog.productNameBuilder(languageLocale, 'unknownKey'), isNull);
        for (final kind in _module.storageKinds) {
          expect(kind.placeNameBuilder(context), isNotEmpty);
          expect(kind.kindDescriptionBuilder(context), isNotEmpty);
          expect(kind.addCompartmentLabelBuilder(context), isNotEmpty);
          for (final template in kind.templates) {
            expect(template.labelBuilder(context), isNotEmpty);
          }
        }
        expect(_module.storageDomain.labelBuilder(context), isNotEmpty);
        expect(_module.storageDomain.descriptionBuilder(context), isNotEmpty);
        expect(_module.storageDomain.storedOnLabelBuilder(context), isNotEmpty);
        expect(_module.optionalFeatureDescription.titleBuilder(context), isNotEmpty);
      });
    });
  }

  testWidgets('speaks of shelves and buying, in both languages', (tester) async {
    await _withContext(tester, const Locale('en'), (context) {
      final pantry = _module.storageKinds.first;
      expect(pantry.placeNameBuilder(context), 'Pantry');
      expect(pantry.compartmentNameBuilder(context, 2), 'Shelf 2');
      expect(pantry.compartmentCountBuilder(context, 4), '4 shelves');
      expect(_module.storageKinds.last.compartmentNameBuilder(context, 1), 'Crate 1');
      expect(_module.storageDomain.labelBuilder(context), 'Pantry');
      expect(_module.storageDomain.storedOnLabelBuilder(context), 'Bought on');
      expect(_module.storageDomain.addTitleBuilder!(context), 'Add to the pantry');
      expect(_module.catalog.productNameBuilder(const Locale('en'), 'pasta'), 'Pasta');
    });
    await _withContext(tester, const Locale('de'), (context) {
      final pantry = _module.storageKinds.first;
      expect(pantry.placeNameBuilder(context), 'Vorratskammer');
      expect(pantry.compartmentNameBuilder(context, 2), 'Regal 2');
      expect(_module.storageDomain.labelBuilder(context), 'Vorrat');
      expect(_module.storageDomain.addTitleBuilder!(context), 'In den Vorrat legen');
      expect(_module.catalog.productNameBuilder(const Locale('de'), 'pasta'), 'Nudeln');
    });
  });
}
