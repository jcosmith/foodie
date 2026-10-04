import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_fridge/feature_fridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _module = FridgeFeatureModule();

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
  test('the fridge is an optional domain, on after installing, after the freezer', () {
    expect(_module.moduleIdentifier, 'fridge');
    expect(_module.availability, const ModuleAvailability.optional(isEnabledByDefault: true));
    final domain = _module.storageDomain;
    expect(domain.identifier, StorageDomainIdentifier.fridge);
    expect(domain.sortOrder, 20);
    expect(domain.iconEmoji, '🧊');
    expect(domain.countsDiscardsAsWaste, isTrue);
  });

  test('the fridge is a tab of its own', () {
    final destination = _module.navigationDestination;
    expect(destination.iconEmoji, '🧊');
    expect(destination.sortOrder, 20);
    expect(destination.initialLocation, '/fridge');
    expect(destination.routes.whereType<GoRoute>().single.path, '/fridge');
  });

  test('brings the fridge, drinks fridge and wine fridge with their templates', () {
    expect(_module.storageKinds.map((kind) => kind.storageName), [
      'fridge',
      'drinksFridge',
      'wineFridge',
    ]);
    expect(_module.storageKinds.map((kind) => kind.domainIdentifier).toSet(), {
      StorageDomainIdentifier.fridge,
    });
    final templates = [
      for (final kind in _module.storageKinds)
        for (final template in kind.templates) (template.identifier, template.compartmentCount),
    ];
    expect(templates, [
      ('fridge.three_shelves', 3),
      ('fridge.five_shelves', 5),
      ('fridge.drinks', 3),
      ('fridge.wine', 4),
    ]);
    expect(FridgeStorageTemplates.threeShelves.domainIdentifier, StorageDomainIdentifier.fridge);
  });

  test('seeds fresh food that keeps days, with shorter times once opened', () {
    final catalog = _module.catalog;
    expect(catalog.categories.map((category) => category.catalogKey), [
      'dairy',
      'freshProduce',
      'freshMeatAndFish',
      'leftovers',
      'chilledOther',
    ]);
    expect(catalog.categories.map((category) => category.domainIdentifier).toSet(), {
      StorageDomainIdentifier.fridge,
    });
    final categoryKeys = {for (final category in catalog.categories) category.catalogKey};
    final productKeys = [for (final product in catalog.products) product.catalogKey];
    expect(productKeys.toSet(), hasLength(productKeys.length));
    expect(productKeys.length, greaterThanOrEqualTo(15));
    for (final product in catalog.products) {
      expect(categoryKeys, contains(product.categoryCatalogKey), reason: product.catalogKey);
    }
    for (final category in catalog.categories) {
      expect(category.shelfLifeDays, lessThanOrEqualTo(14), reason: category.catalogKey);
    }
    final milk = catalog.products.singleWhere((product) => product.catalogKey == 'milk');
    expect(milk.canonicalUnit, QuantityUnit.milliliter);
    expect(milk.shelfLifeAfterOpeningDays, 3);
    final herbs = catalog.products.singleWhere((product) => product.catalogKey == 'freshHerbs');
    expect(herbs.shelfLifeDays, 1, reason: 'one day is the shortest shelf life');
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
      final fridge = _module.storageKinds.first;
      expect(fridge.placeNameBuilder(context), 'Fridge');
      expect(fridge.compartmentNameBuilder(context, 2), 'Shelf 2');
      expect(fridge.compartmentCountBuilder(context, 3), '3 shelves');
      expect(_module.storageKinds.last.compartmentNameBuilder(context, 1), 'Rack 1');
      expect(_module.storageDomain.labelBuilder(context), 'Fridge');
      expect(_module.storageDomain.storedOnLabelBuilder(context), 'Bought on');
      expect(_module.storageDomain.bestBeforeLabelBuilder!(context), 'Best before');
      expect(_module.storageDomain.addTitleBuilder!(context), 'Add to the fridge');
      expect(_module.catalog.productNameBuilder(const Locale('en'), 'milk'), 'Milk');
    });
    await _withContext(tester, const Locale('de'), (context) {
      final fridge = _module.storageKinds.first;
      expect(fridge.placeNameBuilder(context), 'Kühlschrank');
      expect(fridge.compartmentNameBuilder(context, 2), 'Fach 2');
      expect(_module.storageDomain.storedOnLabelBuilder(context), 'Gekauft am');
      expect(_module.storageDomain.addTitleBuilder!(context), 'In den Kühlschrank legen');
      expect(_module.catalog.productNameBuilder(const Locale('de'), 'milk'), 'Milch');
    });
  });
}
