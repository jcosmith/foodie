import 'package:core_design_system/testing.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:feature_storage_layout/src/presentation/storage_place_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/storage_layout_test_harness.dart';

void main() {
  late StorageLayoutTestHarness harness;
  late FakeCompartmentContents compartmentContents;

  setUp(() {
    compartmentContents = FakeCompartmentContents();
    harness = StorageLayoutTestHarness(compartmentContents: compartmentContents);
  });
  tearDown(() => harness.dispose());

  Future<StoragePlaceIdentifier> showEditor(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    final storagePlaceIdentifier = (await tester.runAsync(
      () => harness
          .read(createStoragePlaceFromTemplateUseCaseProvider)
          .execute(
            template: harness.template('freezer.upright_three'),
            defaultNames: const EnglishLayoutDefaultNames(),
          ),
    ))!.valueOrNull!;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestApplication(
          locale: locale,
          featureLocalizationDelegates: const StorageLayoutFeatureModule().localizationDelegates,
          home: StoragePlaceEditorScreen(storagePlaceIdentifier: storagePlaceIdentifier),
        ),
      ),
    );
    await _settle(tester);
    return storagePlaceIdentifier;
  }

  testWidgets('shows the drawers with their translated default names', (tester) async {
    await showEditor(tester, locale: const Locale('de'));

    expect(find.text('Gefrierschrank'), findsOneWidget);
    expect(find.text('stehend · 3 Schubladen'), findsOneWidget);
    for (final name in ['Schublade 1', 'Schublade 2', 'Schublade 3']) {
      expect(find.widgetWithText(TextField, name), findsOneWidget);
    }
    expect(find.text('Leer'), findsNWidgets(3));
  });

  testWidgets('explains why a name cannot be used', (tester) async {
    await showEditor(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Drawer 1'), 'drawer 3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _settle(tester);

    expect(find.text('Another drawer already has this name.'), findsOneWidget);
  });

  testWidgets('adds a drawer and asks where the items of a removed drawer go', (tester) async {
    final storagePlaceIdentifier = await showEditor(tester);
    final layout = (await tester.runAsync(harness.readLayout))!;
    final firstDrawer = layout.storagePlaceLayoutOf(storagePlaceIdentifier)!.compartments.first;
    compartmentContents.setItemCount(firstDrawer.identifier, 2);

    await tester.tap(find.text('Add drawer'));
    await _settle(tester);
    expect(find.widgetWithText(TextField, 'Drawer 4'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove: Drawer 1'));
    await _settle(tester);
    expect(find.text('Remove Drawer 1?'), findsOneWidget);
    expect(find.text('It holds 2 items. Where should they go?'), findsOneWidget);

    await tester.tap(find.text('Move and remove'));
    await _settle(tester);

    expect(find.widgetWithText(TextField, 'Drawer 1'), findsNothing);
    expect(find.text('Removed (kept for your statistics): Drawer 1'), findsOneWidget);
  });
}

/// Lets the database work outside the fake clock, then settles the frames.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}
