import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_product_catalog/src/application/product_catalog_providers.dart';
import 'package:feature_product_catalog/src/application/use_cases/product_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/product_catalog_test_harness.dart';

final class _DairyCatalogModule extends FeatureModuleBase {
  const _DairyCatalogModule();

  @override
  String get moduleIdentifier => 'test_dairy';

  @override
  CatalogContribution get catalog => CatalogContribution(
    categories: const [
      SeededCategoryContribution(
        catalogKey: 'testDairy',
        domainIdentifier: StorageDomainIdentifier.fridge,
        shelfLifeDays: 7,
        shelfLifeAfterOpeningDays: 4,
        iconEmoji: '🥛',
      ),
      SeededCategoryContribution(
        catalogKey: 'testCleaning',
        domainIdentifier: StorageDomainIdentifier.household,
        iconEmoji: '🧽',
      ),
    ],
    products: const [
      SeededProductContribution(
        catalogKey: 'testMilk',
        categoryCatalogKey: 'testDairy',
        canonicalUnit: QuantityUnit.milliliter,
        defaultPackageDisplayAmount: 1000,
        iconEmoji: '🥛',
        shelfLifeDays: 10,
        shelfLifeAfterOpeningDays: 3,
      ),
      SeededProductContribution(
        catalogKey: 'testIceCubes',
        categoryCatalogKey: 'other',
        canonicalUnit: QuantityUnit.piece,
        defaultPackageDisplayAmount: 20,
        iconEmoji: '🧊',
      ),
      SeededProductContribution(
        catalogKey: 'testDishSoap',
        categoryCatalogKey: 'testCleaning',
        canonicalUnit: QuantityUnit.piece,
        defaultPackageDisplayAmount: 1,
        iconEmoji: '🧴',
      ),
    ],
    categoryNameBuilder: (context, catalogKey) => null,
    productNameBuilder: (context, catalogKey) => null,
  );
}

void main() {
  late ProductCatalogTestHarness harness;

  setUp(() => harness = ProductCatalogTestHarness());
  tearDown(() => harness.dispose());

  Product seededProduct(ProductCatalog catalog, String catalogKey) =>
      catalog.activeProducts.singleWhere((product) => product.catalogKey == catalogKey);

  group('seeding the catalog', () {
    test('adds every seeded category and product once', () async {
      final seedCatalog = harness.read(seedCatalogUseCaseProvider);

      final firstRun = await seedCatalog.execute();
      final secondRun = await seedCatalog.execute();

      final seeded = harness.read(seededCatalogProvider);
      expect(seeded.products, hasLength(24));
      expect(firstRun, seeded.categories.length + seeded.products.length);
      expect(secondRun, 0);
      final catalog = await harness.readCatalog();
      expect(catalog.categories.map((category) => category.catalogKey), [
        'vegetables',
        'fruit',
        'meatAndFish',
        'meals',
        'bakery',
        'desserts',
        'other',
      ]);
      final spinach = seededProduct(catalog, 'leafSpinach');
      expect(
        spinach.defaultPackageQuantity,
        const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.gram),
      );
      expect(catalog.recommendedMaximumStorageDaysOf(spinach), 365);
      expect(
        seededProduct(catalog, 'bologneseHomemade').defaultPackageQuantity,
        const Quantity(amountInBaseUnits: 4000, unit: QuantityUnit.portion),
      );
    });

    test('adds entries of a later version but keeps archived ones archived', () async {
      final seedCatalog = harness.read(seedCatalogUseCaseProvider);
      final seeded = harness.read(seededCatalogProvider);
      await seedCatalog.execute(
        catalog: SeededCatalog(
          categories: seeded.categories,
          products: seeded.products.take(2).toList(),
        ),
      );
      final peas = seededProduct(await harness.readCatalog(), 'gardenPeas');
      await harness.read(archiveProductUseCaseProvider).execute(peas.identifier);

      final addedLater = await seedCatalog.execute();

      expect(addedLater, seeded.products.length - 2);
      final catalog = await harness.readCatalog();
      expect(catalog.productOf(peas.identifier)!.isArchived, isTrue);
      expect(catalog.activeProducts, hasLength(seeded.products.length - 1));
    });

    test('every module\'s catalog is seeded, after the categories that exist', () async {
      final twoModules = ProductCatalogTestHarness(
        registeredModules: const [FreezerFeatureModule(), _DairyCatalogModule()],
      );
      addTearDown(twoModules.dispose);
      await twoModules.read(seedCatalogUseCaseProvider).execute();

      final catalog = await twoModules.readCatalog();
      final dairy = catalog.categories.singleWhere((c) => c.catalogKey == 'testDairy');
      expect(dairy.catalogKey, 'testDairy');
      expect(
        dairy.sortOrder,
        greaterThan(catalog.categories.singleWhere((c) => c.catalogKey == 'other').sortOrder),
      );
      expect(dairy.storageDomain, StorageDomainIdentifier.fridge);
      expect(dairy.recommendedMaximumStorageDays, 7);
      expect(dairy.shelfLifeAfterOpeningDays, 4);
      final milk = seededProduct(catalog, 'testMilk');
      expect(milk.categoryIdentifier, dairy.identifier);
      expect(milk.recommendedMaximumStorageDays, 10);
      expect(milk.shelfLifeAfterOpeningDays, 3);
      expect(
        milk.defaultPackageQuantity,
        const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.milliliter),
      );
      // A product may live in another module's category.
      expect(seededProduct(catalog, 'testIceCubes').categoryIdentifier, isNot(dairy.identifier));
    });

    test('supplies keep no time: a category and its products may have no shelf life', () async {
      final twoModules = ProductCatalogTestHarness(
        registeredModules: const [FreezerFeatureModule(), _DairyCatalogModule()],
      );
      addTearDown(twoModules.dispose);
      await twoModules.read(seedCatalogUseCaseProvider).execute();

      final catalog = await twoModules.readCatalog();
      final cleaning = catalog.categories.singleWhere((c) => c.catalogKey == 'testCleaning');
      expect(cleaning.recommendedMaximumStorageDays, isNull);
      expect(cleaning.storageDomain, StorageDomainIdentifier.household);
      expect(
        catalog.recommendedMaximumStorageDaysOf(seededProduct(catalog, 'testDishSoap')),
        isNull,
      );

      // A shelf life can still be given to the category later.
      await twoModules
          .read(changeCategoryStorageLimitUseCaseProvider)
          .execute(categoryIdentifier: cleaning.identifier, recommendedMaximumStorageDays: 30);
      final changed = await twoModules.readCatalog();
      expect(changed.categoryOf(cleaning.identifier)!.recommendedMaximumStorageDays, 30);
    });

    test('a category added by a later version goes after the user\'s own sort order', () async {
      final seedCatalog = harness.read(seedCatalogUseCaseProvider);
      final seeded = harness.read(seededCatalogProvider);
      await seedCatalog.execute(
        catalog: SeededCatalog(categories: seeded.categories.take(3).toList(), products: const []),
      );
      await seedCatalog.execute();
      final sortOrders = (await harness.readCatalog()).categories.map((c) => c.sortOrder).toList();
      expect(sortOrders.toSet(), hasLength(sortOrders.length));
      expect(sortOrders, orderedEquals([...sortOrders]..sort()));
    });
  });

  group('creating a product', () {
    late CategoryIdentifier mealsCategory;

    setUp(() async {
      await harness.read(seedCatalogUseCaseProvider).execute();
      mealsCategory = (await harness.readCatalog()).categories
          .singleWhere((category) => category.catalogKey == 'meals')
          .identifier;
    });

    test('stores the product and announces it', () async {
      final result = await harness
          .read(createProductUseCaseProvider)
          .execute(
            settings: ProductSettings(
              enteredName: '  Grandma\'s goulash ',
              categoryIdentifier: mealsCategory,
              defaultPackageQuantity: const Quantity(
                amountInBaseUnits: 3000,
                unit: QuantityUnit.portion,
              ),
              iconEmoji: ' ',
            ),
            canonicalUnit: QuantityUnit.portion,
          );

      final product = (await harness.readCatalog()).productOf(result.valueOrNull!)!;
      expect(product.customName, "Grandma's goulash");
      expect(product.iconEmoji, isNull);
      expect(harness.publishedEvents.whereType<ProductCreated>(), hasLength(1));
    });

    test('refuses a missing name and a package size in another unit', () async {
      final createProduct = harness.read(createProductUseCaseProvider);

      final withoutName = await createProduct.execute(
        settings: ProductSettings(enteredName: ' ', categoryIdentifier: mealsCategory),
        canonicalUnit: QuantityUnit.gram,
      );
      final wrongUnit = await createProduct.execute(
        settings: ProductSettings(
          enteredName: 'Soup',
          categoryIdentifier: mealsCategory,
          defaultPackageQuantity: const Quantity(
            amountInBaseUnits: 500,
            unit: QuantityUnit.milliliter,
          ),
        ),
        canonicalUnit: QuantityUnit.gram,
      );

      expect(withoutName.failureOrNull, isA<ProductNameMissing>());
      expect(wrongUnit.failureOrNull, isA<InvalidProductSetting>());
    });
  });

  test('a renamed seeded product goes back to its translated name when cleared', () async {
    await harness.read(seedCatalogUseCaseProvider).execute();
    final spinach = seededProduct(await harness.readCatalog(), 'leafSpinach');
    final updateProduct = harness.read(updateProductUseCaseProvider);

    await updateProduct.execute(
      productIdentifier: spinach.identifier,
      settings: ProductSettings(
        enteredName: 'Spinach from the garden',
        categoryIdentifier: spinach.categoryIdentifier,
        recommendedMaximumStorageDays: 200,
      ),
    );
    final renamed = (await harness.readCatalog()).productOf(spinach.identifier)!;
    await updateProduct.execute(
      productIdentifier: spinach.identifier,
      settings: ProductSettings(enteredName: '', categoryIdentifier: spinach.categoryIdentifier),
    );
    final reset = (await harness.readCatalog()).productOf(spinach.identifier)!;

    expect(renamed.customName, 'Spinach from the garden');
    expect(renamed.recommendedMaximumStorageDays, 200);
    expect(renamed.canonicalUnit, QuantityUnit.gram);
    expect(reset.customName, isNull);
    expect(reset.recommendedMaximumStorageDays, isNull);
    expect(harness.publishedEvents.whereType<ProductUpdated>(), hasLength(2));
  });

  test('a name for one piece is kept for products in pieces only', () async {
    await harness.read(seedCatalogUseCaseProvider).execute();
    final catalog = await harness.readCatalog();
    final bread = seededProduct(catalog, 'wholegrainBread');
    final spinach = seededProduct(catalog, 'leafSpinach');
    final updateProduct = harness.read(updateProductUseCaseProvider);

    for (final product in [bread, spinach]) {
      await updateProduct.execute(
        productIdentifier: product.identifier,
        settings: ProductSettings(
          enteredName: '',
          categoryIdentifier: product.categoryIdentifier,
          pieceLabel: ' slices ',
        ),
      );
    }
    final updated = await harness.readCatalog();
    expect(updated.productOf(bread.identifier)!.pieceLabel, 'slices');
    expect(updated.productOf(bread.identifier)!.displayPieceLabel, 'slices');
    expect(updated.productOf(bread.identifier)!.canonicalUnit, QuantityUnit.piece);
    expect(updated.productOf(spinach.identifier)!.pieceLabel, isNull);

    await updateProduct.execute(
      productIdentifier: bread.identifier,
      settings: ProductSettings(enteredName: '', categoryIdentifier: bread.categoryIdentifier),
    );
    expect((await harness.readCatalog()).productOf(bread.identifier)!.pieceLabel, isNull);
  });

  test('remembers a default drawer until it is cleared', () async {
    await harness.read(seedCatalogUseCaseProvider).execute();
    final drawers = await harness.setUpStoragePlace();
    final spinach = seededProduct(await harness.readCatalog(), 'leafSpinach');
    final updateProduct = harness.read(updateProductUseCaseProvider);

    await updateProduct.execute(
      productIdentifier: spinach.identifier,
      settings: ProductSettings(
        enteredName: '',
        categoryIdentifier: spinach.categoryIdentifier,
        defaultCompartmentIdentifier: drawers[1].identifier,
      ),
    );
    final withDrawer = (await harness.readCatalog()).productOf(spinach.identifier)!;
    await updateProduct.execute(
      productIdentifier: spinach.identifier,
      settings: ProductSettings(enteredName: '', categoryIdentifier: spinach.categoryIdentifier),
    );
    final withoutDrawer = (await harness.readCatalog()).productOf(spinach.identifier)!;

    expect(spinach.defaultCompartmentIdentifier, isNull);
    expect(withDrawer.defaultCompartmentIdentifier, drawers[1].identifier);
    expect(withoutDrawer.defaultCompartmentIdentifier, isNull);
  });

  test('changes a category storage limit, keeping products with their own', () async {
    await harness.read(seedCatalogUseCaseProvider).execute();
    final catalog = await harness.readCatalog();
    final spinach = seededProduct(catalog, 'leafSpinach');
    final changeStorageLimit = harness.read(changeCategoryStorageLimitUseCaseProvider);

    final refused = await changeStorageLimit.execute(
      categoryIdentifier: spinach.categoryIdentifier,
      recommendedMaximumStorageDays: 0,
    );
    await changeStorageLimit.execute(
      categoryIdentifier: spinach.categoryIdentifier,
      recommendedMaximumStorageDays: 123,
    );
    final changedCatalog = await harness.readCatalog();

    expect(refused.failureOrNull, isA<InvalidProductSetting>());
    expect(changedCatalog.recommendedMaximumStorageDaysOf(spinach), 123);
    expect(harness.publishedEvents.whereType<CategoryUpdated>(), hasLength(1));

    await changeStorageLimit.execute(
      categoryIdentifier: spinach.categoryIdentifier,
      recommendedMaximumStorageDays: null,
    );
    expect(
      (await harness.readCatalog()).recommendedMaximumStorageDaysOf(spinach),
      isNull,
      reason: 'a category may keep no time, like supplies',
    );
  });

  group('storage domain and shelf life after opening', () {
    const dairy = CategoryIdentifier('category-dairy');
    final createdAt = DateTime.utc(2026, 10, 1);
    final catalog = ProductCatalog(
      categories: const [
        Category(
          identifier: dairy,
          catalogKey: 'dairyAndEggs',
          recommendedMaximumStorageDays: 7,
          shelfLifeAfterOpeningDays: 4,
          iconEmoji: '🥛',
          sortOrder: 0,
          storageDomain: StorageDomainIdentifier.fridge,
        ),
      ],
      productsIncludingArchived: [
        Product(
          identifier: const ProductIdentifier('product-milk'),
          categoryIdentifier: dairy,
          canonicalUnit: QuantityUnit.milliliter,
          customName: 'Milk',
          shelfLifeAfterOpeningDays: 3,
          createdAt: createdAt,
        ),
        Product(
          identifier: const ProductIdentifier('product-yoghurt'),
          categoryIdentifier: dairy,
          canonicalUnit: QuantityUnit.gram,
          customName: 'Yoghurt',
          createdAt: createdAt,
        ),
      ],
    );

    test('a product belongs to the domain of its category', () {
      final milk = catalog.productOf(const ProductIdentifier('product-milk'))!;
      expect(catalog.storageDomainOf(milk), StorageDomainIdentifier.fridge);
    });

    test("the product's shelf life after opening wins over its category's", () {
      final milk = catalog.productOf(const ProductIdentifier('product-milk'))!;
      final yoghurt = catalog.productOf(const ProductIdentifier('product-yoghurt'))!;
      expect(catalog.shelfLifeAfterOpeningDaysOf(milk), 3);
      expect(catalog.shelfLifeAfterOpeningDaysOf(yoghurt), 4);
    });

    test('seeded freezer categories belong to the freezer domain', () async {
      await harness.read(seedCatalogUseCaseProvider).execute();
      final seeded = await harness.readCatalog();
      expect(seeded.categories.map((category) => category.storageDomain).toSet(), {
        StorageDomainIdentifier.freezer,
      });
    });

    test('a product\'s shelf life after opening can be set and cleared', () async {
      await harness.read(seedCatalogUseCaseProvider).execute();
      final butter = seededProduct(await harness.readCatalog(), 'butter');
      final updateProduct = harness.read(updateProductUseCaseProvider);
      await updateProduct.execute(
        productIdentifier: butter.identifier,
        settings: ProductSettings(
          enteredName: '',
          categoryIdentifier: butter.categoryIdentifier,
          shelfLifeAfterOpeningDays: 30,
        ),
      );
      expect(seededProduct(await harness.readCatalog(), 'butter').shelfLifeAfterOpeningDays, 30);
      await updateProduct.execute(
        productIdentifier: butter.identifier,
        settings: ProductSettings(enteredName: '', categoryIdentifier: butter.categoryIdentifier),
      );
      expect(
        seededProduct(await harness.readCatalog(), 'butter').shelfLifeAfterOpeningDays,
        isNull,
      );
    });

    test('a shelf life after opening must be positive', () async {
      await harness.read(seedCatalogUseCaseProvider).execute();
      final butter = seededProduct(await harness.readCatalog(), 'butter');
      final result = await harness
          .read(updateProductUseCaseProvider)
          .execute(
            productIdentifier: butter.identifier,
            settings: ProductSettings(
              enteredName: '',
              categoryIdentifier: butter.categoryIdentifier,
              shelfLifeAfterOpeningDays: 0,
            ),
          );
      expect(result.failureOrNull, isA<InvalidProductSetting>());
    });
  });
}
