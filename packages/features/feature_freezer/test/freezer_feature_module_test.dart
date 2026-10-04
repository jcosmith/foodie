import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _module = FreezerFeatureModule();

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
  test('the freezer is an optional domain, on after installing', () {
    expect(_module.moduleIdentifier, 'freezer');
    expect(_module.availability, const ModuleAvailability.optional(isEnabledByDefault: true));
    final domain = _module.storageDomain;
    expect(domain.identifier, StorageDomainIdentifier.freezer);
    expect(domain.sortOrder, 10);
    expect(domain.iconEmoji, '❄️');
    expect(domain.countsDiscardsAsWaste, isTrue);
  });

  test('the freezer is a tab of its own, with a colour icon', () {
    final destination = _module.navigationDestination;
    expect(destination.iconEmoji, '❄️');
    expect(destination.sortOrder, _module.storageDomain.sortOrder);
    expect(destination.initialLocation, ShellRoutePaths.domainTab(StorageDomainIdentifier.freezer));
    expect(destination.routes.whereType<GoRoute>().single.path, '/freezer');
  });

  test('brings the upright, chest and fridge freezer kinds with their templates', () {
    expect(_module.storageKinds.map((kind) => kind.storageName), [
      'upright',
      'chest',
      'fridgeFreezerCompartment',
    ]);
    expect(_module.storageKinds.map((kind) => kind.domainIdentifier).toSet(), {
      StorageDomainIdentifier.freezer,
    });
    final templates = [
      for (final kind in _module.storageKinds)
        for (final template in kind.templates) (template.identifier, template.compartmentCount),
    ];
    expect(templates, [
      ('freezer.upright_three', 3),
      ('freezer.upright_five', 5),
      ('freezer.upright_seven', 7),
      ('freezer.empty', 1),
      ('freezer.chest_baskets', 3),
      ('freezer.fridge_compartment', 1),
    ]);
  });

  test('seeds the frozen-food catalog that shipped with the freezer app', () {
    final catalog = _module.catalog;
    expect(catalog.categories.map((category) => category.catalogKey), [
      'vegetables',
      'fruit',
      'meatAndFish',
      'meals',
      'bakery',
      'desserts',
      'other',
    ]);
    expect(catalog.categories.map((category) => category.domainIdentifier).toSet(), {
      StorageDomainIdentifier.freezer,
    });
    expect(catalog.products, hasLength(24));
    final categoryKeys = {for (final category in catalog.categories) category.catalogKey};
    final productKeys = [for (final product in catalog.products) product.catalogKey];
    expect(productKeys.toSet(), hasLength(productKeys.length));
    for (final product in catalog.products) {
      expect(categoryKeys, contains(product.categoryCatalogKey), reason: product.catalogKey);
    }
    final spinach = catalog.products.singleWhere((product) => product.catalogKey == 'leafSpinach');
    expect(spinach.canonicalUnit, QuantityUnit.gram);
    expect(spinach.defaultPackageDisplayAmount, 1000);
    expect(
      catalog.categories
          .singleWhere((category) => category.catalogKey == 'vegetables')
          .shelfLifeDays,
      365,
    );
  });

  for (final locale in SupportedLocales.all) {
    testWidgets('every seeded entry and default name has a ${locale.languageCode} text', (
      tester,
    ) async {
      await _withContext(tester, locale, (context) {
        final catalog = _module.catalog;
        for (final category in catalog.categories) {
          expect(
            catalog.categoryNameBuilder(Localizations.localeOf(context), category.catalogKey),
            isNotEmpty,
          );
        }
        for (final product in catalog.products) {
          expect(
            catalog.productNameBuilder(Localizations.localeOf(context), product.catalogKey),
            isNotEmpty,
          );
        }
        expect(catalog.productNameBuilder(Localizations.localeOf(context), 'unknownKey'), isNull);
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
      });
    });
  }

  testWidgets('names read as they did in the freezer app', (tester) async {
    await _withContext(tester, const Locale('en'), (context) {
      final kinds = {for (final kind in _module.storageKinds) kind.storageName: kind};
      expect(kinds['upright']!.placeNameBuilder(context), 'Freezer');
      expect(kinds['chest']!.placeNameBuilder(context), 'Chest freezer');
      expect(kinds['fridgeFreezerCompartment']!.placeNameBuilder(context), 'Fridge freezer');
      expect(kinds['upright']!.compartmentNameBuilder(context, 3), 'Drawer 3');
      expect(kinds['chest']!.compartmentNameBuilder(context, 2), 'Basket 2');
      expect(
        kinds['fridgeFreezerCompartment']!.compartmentNameBuilder(context, 1),
        'Compartment 1',
      );
      expect(kinds['chest']!.compartmentCountBuilder(context, 3), '3 baskets');
      expect(kinds['upright']!.addCompartmentLabelBuilder(context), 'Add drawer');
      expect(
        _module.catalog.productNameBuilder(Localizations.localeOf(context), 'leafSpinach'),
        'Leaf spinach',
      );
      expect(_module.storageDomain.labelBuilder(context), 'Freezer');
      expect(_module.storageDomain.storedOnLabelBuilder(context), 'Frozen on');
      expect(_module.storageDomain.addTitleBuilder!(context), 'Add to the freezer');
      expect(_module.storageDomain.storedTodayLabelBuilder!(context), 'Frozen today');
      expect(
        _module.storageDomain.bestBeforeLabelBuilder,
        isNull,
        reason: 'frozen food keeps its own time',
      );
    });
    await _withContext(tester, const Locale('de'), (context) {
      final upright = _module.storageKinds.first;
      expect(upright.placeNameBuilder(context), 'Gefrierschrank');
      expect(upright.compartmentNameBuilder(context, 3), 'Schublade 3');
      expect(upright.kindDescriptionBuilder(context), 'stehend');
      expect(
        _module.catalog.productNameBuilder(Localizations.localeOf(context), 'leafSpinach'),
        'Blattspinat',
      );
      expect(_module.storageDomain.labelBuilder(context), 'Tiefkühler');
      expect(_module.storageDomain.storedOnLabelBuilder(context), 'Eingefroren am');
      expect(_module.storageDomain.addTitleBuilder!(context), 'In den Tiefkühler legen');
    });
  });
}
