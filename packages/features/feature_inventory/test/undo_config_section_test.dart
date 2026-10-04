import 'package:core_design_system/testing.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_inventory/src/application/undo_time_limit.dart';
import 'package:feature_inventory/src/presentation/undo_config_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/inventory_test_harness.dart';

void main() {
  late InventoryTestHarness harness;

  setUp(() => harness = InventoryTestHarness());
  tearDown(() => harness.dispose());

  Future<void> settle(WidgetTester tester) async {
    for (var round = 0; round < 3; round++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
    }
  }

  Future<int> storedSeconds(WidgetTester tester) async => (await tester.runAsync(
    () => harness.read(preferencesStoreProvider).watch(UndoTimeLimit.seconds).first,
  ))!;

  Future<void> showSection(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: const InventoryFeatureModule().localizationDelegates,
          home: const Scaffold(
            body: Padding(padding: EdgeInsets.all(16), child: UndoConfigSection()),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('starts at 4 seconds and goes from none to "until dismissed"', (tester) async {
    await showSection(tester);
    expect(find.text('Undo stays available for 4 s'), findsOneWidget);
    expect(await storedSeconds(tester), 4);

    final slider = find.byType(Slider);
    final sliderBox = tester.getRect(slider);
    await tester.tapAt(Offset(sliderBox.left + 1, sliderBox.center.dy));
    await settle(tester);
    expect(find.text('No undo'), findsOneWidget);
    expect(await storedSeconds(tester), 0);

    await tester.tapAt(Offset(sliderBox.right - 1, sliderBox.center.dy));
    await settle(tester);
    expect(find.text('Undo stays until you close the message'), findsOneWidget);
    expect(await storedSeconds(tester), UndoTimeLimit.untilDismissed);
  });
}
