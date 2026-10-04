import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_household_supplies/feature_household_supplies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _module = HouseholdSuppliesFeatureModule();

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
  test('household supplies are an optional domain, off until switched on, last of the tabs', () {
    expect(_module.moduleIdentifier, 'household');
    expect(_module.availability, const ModuleAvailability.optional(isEnabledByDefault: false));
    final domain = _module.storageDomain;
    expect(domain.identifier, StorageDomainIdentifier.household);
    expect(domain.sortOrder, 40);
    expect(domain.iconEmoji, '🧴');
    expect(domain.countsDiscardsAsWaste, isFalse, reason: 'used-up dish soap is never waste');
    expect(domain.storedTodayLabelBuilder, isNull);
  });

  test('household supplies are a tab of their own', () {
    final destination = _module.navigationDestination;
    expect(destination.iconEmoji, '🧴');
    expect(destination.sortOrder, 40);
    expect(destination.initialLocation, '/household');
    expect(destination.routes.whereType<GoRoute>().single.path, '/household');
  });

  test('brings cupboards, cabinets, rooms, the shed, the garage and a first-aid box', () {
    expect(_module.storageKinds.map((kind) => kind.storageName), [
      'cleaningCupboard',
      'bathroomCabinet',
      'laundryRoom',
      'gardenShed',
      'garage',
      'storageRoom',
      'firstAidBox',
    ]);
    expect(_module.storageKinds.map((kind) => kind.domainIdentifier).toSet(), {
      StorageDomainIdentifier.household,
    });
    for (final kind in _module.storageKinds) {
      expect(kind.templates, isNotEmpty, reason: kind.storageName);
    }
    expect(
      HouseholdSuppliesStorageTemplates.cleaningCupboard.domainIdentifier,
      StorageDomainIdentifier.household,
    );
  });

  test('seeds cleaning, laundry, bathroom and kitchen paper, none of it with a shelf life', () {
    final catalog = _module.catalog;
    expect(catalog.categories.map((category) => category.catalogKey), [
      'cleaning',
      'laundry',
      'bathroomAndCare',
      'kitchenPaperAndWrap',
    ]);
    expect(catalog.categories.map((category) => category.domainIdentifier).toSet(), {
      StorageDomainIdentifier.household,
    });
    for (final category in catalog.categories) {
      expect(category.shelfLifeDays, isNull, reason: 'supplies have no storage age');
    }
    final categoryKeys = {for (final category in catalog.categories) category.catalogKey};
    final productKeys = [for (final product in catalog.products) product.catalogKey];
    expect(productKeys.toSet(), hasLength(productKeys.length));
    expect(productKeys, containsAll(['dishSoap', 'detergent', 'toiletPaper', 'kitchenRoll']));
    for (final product in catalog.products) {
      expect(categoryKeys, contains(product.categoryCatalogKey), reason: product.catalogKey);
      expect(product.shelfLifeDays, isNull, reason: product.catalogKey);
    }
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

  testWidgets('speaks of shelves and expiry dates, in both languages', (tester) async {
    await _withContext(tester, const Locale('en'), (context) {
      final cupboard = _module.storageKinds.first;
      expect(cupboard.placeNameBuilder(context), 'Cleaning cupboard');
      expect(cupboard.compartmentNameBuilder(context, 2), 'Shelf 2');
      expect(_module.storageDomain.labelBuilder(context), 'Household');
      expect(_module.storageDomain.storedOnLabelBuilder(context), 'Bought on');
      expect(_module.storageDomain.bestBeforeLabelBuilder!(context), 'Expires');
      expect(_module.storageDomain.addTitleBuilder!(context), 'Add supplies');
      expect(_module.catalog.productNameBuilder(const Locale('en'), 'dishSoap'), 'Dish soap');
    });
    await _withContext(tester, const Locale('de'), (context) {
      final cupboard = _module.storageKinds.first;
      expect(cupboard.placeNameBuilder(context), 'Putzschrank');
      expect(cupboard.compartmentNameBuilder(context, 2), 'Regal 2');
      expect(_module.storageDomain.labelBuilder(context), 'Haushalt');
      expect(_module.storageDomain.bestBeforeLabelBuilder!(context), 'Haltbar bis');
      expect(_module.catalog.productNameBuilder(const Locale('de'), 'dishSoap'), 'Spülmittel');
    });
  });
}
