import 'package:core_design_system/testing.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_reminders/feature_storage_reminders.dart';
import 'package:feature_storage_reminders/src/application/storage_reminders_providers.dart';
import 'package:feature_storage_reminders/src/presentation/eat_soon_widgets.dart';
import 'package:feature_storage_reminders/src/presentation/reminders_config_section.dart';
import 'package:feature_storage_reminders/src/presentation/storage_limits_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feature_household_supplies/feature_household_supplies.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/storage_reminders_test_harness.dart';

void main() {
  late StorageRemindersTestHarness harness;

  setUp(() async {
    harness = StorageRemindersTestHarness();
    await harness.seedCatalogAndStoragePlace();
  });
  tearDown(() => harness.dispose());

  Future<void> show(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: [
            ...const StorageRemindersFeatureModule().localizationDelegates,
            ...const InventoryFeatureModule().localizationDelegates,
            ...const ProductCatalogFeatureModule().localizationDelegates,
          ],
          home: home,
        ),
      ),
    );
    await _settle(tester);
  }

  Future<void> addOldBatch(WidgetTester tester, String catalogKey, int daysAgo) async {
    await tester.runAsync(() async {
      final product = await harness.productWithKey(catalogKey);
      await harness.addBatch(product, storedOn: harness.today.addDays(-daysAgo));
    });
  }

  testWidgets('the Eat soon card praises an empty list and shows the three most urgent', (
    tester,
  ) async {
    await show(tester, const Scaffold(body: SingleChildScrollView(child: EatSoonCard())));
    expect(find.text('Nothing urgent. Well done!'), findsOneWidget);

    await addOldBatch(tester, 'mincedMeat', 900);
    await addOldBatch(tester, 'leafSpinach', 900);
    await addOldBatch(tester, 'gardenPeas', 900);
    await addOldBatch(tester, 'broccoli', 900);
    await addOldBatch(tester, 'butter', 1);
    await _settle(tester);

    expect(find.byType(StockItemTile), findsNWidgets(3));
    expect(find.text('See all'), findsOneWidget);
    expect(find.text('Butter'), findsNothing);
  });

  testWidgets('the Eat soon screen lists everything that is due', (tester) async {
    await addOldBatch(tester, 'mincedMeat', 900);
    await addOldBatch(tester, 'butter', 1);

    await show(tester, const EatSoonScreen());

    expect(find.byType(StockItemTile), findsOneWidget);
    expect(find.text('Minced meat'), findsOneWidget);
  });

  testWidgets('the Reminders section changes settings and asks for permission', (tester) async {
    await show(
      tester,
      const Scaffold(body: SingleChildScrollView(child: RemindersConfigSection())),
    );

    expect(find.textContaining('Notifications are switched off'), findsOneWidget);
    expect(find.text('6:00 PM'), findsOneWidget);
    await tester.tap(find.text('Allow'));
    await _settle(tester);
    await tester.tap(find.text('Show food names in notifications'));
    await _settle(tester);

    expect(find.textContaining('Notifications are switched off'), findsNothing);
    expect(
      (await tester.runAsync(
        () => harness.read(storageReminderSettingsStoreProvider).read(),
      ))!.showsItemNamesInNotifications,
      isTrue,
    );
    expect(
      await tester.runAsync(() => harness.notificationServices.currentStatus()),
      NotificationPermissionStatus.granted,
    );
  });

  testWidgets('storage limits are grouped by storage area, without switched-off ones', (
    tester,
  ) async {
    await tester.runAsync(harness.dispose);
    harness = StorageRemindersTestHarness(
      registeredModules: const [FreezerFeatureModule(), HouseholdSuppliesFeatureModule()],
      enabledModules: const [FreezerFeatureModule()],
    );
    await tester.runAsync(harness.seedCatalogAndStoragePlace);
    await show(tester, const StorageLimitsScreen());

    expect(find.text('🧊 Freezer'), findsOneWidget);
    expect(find.text('Vegetables'), findsOneWidget);
    expect(find.text('Cleaning'), findsNothing, reason: 'Household is switched off');

    await tester.tap(find.text('Vegetables'));
    await _settle(tester);
    await tester.tap(find.text('No shelf life'));
    await _settle(tester);

    final catalog = await tester.runAsync(
      () => harness.read(productCatalogQueryServiceProvider).readCatalog(),
    );
    expect(
      catalog!.categories
          .firstWhere((category) => category.catalogKey == 'vegetables')
          .recommendedMaximumStorageDays,
      isNull,
    );
    expect(find.text('No shelf life'), findsOneWidget, reason: 'shown on the row');
  });

  testWidgets('storage limits are shown and changed in days, weeks or months', (tester) async {
    await show(tester, const StorageLimitsScreen());
    final catalog = await tester.runAsync(
      () => harness.read(productCatalogQueryServiceProvider).readCatalog(),
    );
    final vegetables = catalog!.categories.firstWhere(
      (category) => category.catalogKey == 'vegetables',
    );
    Future<int?> vegetableDays() async {
      final changedCatalog = await tester.runAsync(
        () => harness.read(productCatalogQueryServiceProvider).readCatalog(),
      );
      return changedCatalog!.categories
          .firstWhere((category) => category.identifier == vegetables.identifier)
          .recommendedMaximumStorageDays;
    }

    await tester.tap(find.text('Vegetables'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField), '40');
    await tester.tap(find.text('Save'));
    await _settle(tester);
    expect(find.text('Enter between 1 day and 36 months.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '2');
    await tester.tap(find.text('Save'));
    await _settle(tester);
    expect(await vegetableDays(), 61);
    expect(find.text('2 months'), findsOneWidget);

    await tester.tap(find.text('Vegetables'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField), '3');
    await tester.tap(find.text('days'));
    await _settle(tester);
    await tester.tap(find.text('Save'));
    await _settle(tester);
    expect(await vegetableDays(), 3);
    expect(find.text('3 days'), findsOneWidget);
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var round = 0; round < 3; round++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}
