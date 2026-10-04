import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodie_app/src/modules/module_registry.dart';
import 'package:foodie_app/src/startup/application_bootstrapper.dart';
import 'package:foodie_app/src/startup/application_startup_gate.dart';

import 'support/in_memory_platform_services.dart';

Future<void> _startApplication(
  WidgetTester tester, {
  InMemoryPlatformServices? platformServices,
  DateTime? now,
}) async {
  await tester.pumpWidget(
    ApplicationStartupGate(
      bootstrapper: ApplicationBootstrapper(
        platformServices: platformServices ?? InMemoryPlatformServices(),
        registeredModules: createRegisteredFeatureModules(),
        clock: FixedClock(now ?? DateTime(2026, 10, 2, 9)),
        logger: RecordingLogger(),
      ),
    ),
  );
  // The in-memory database opens, and the modules start, in real time
  // outside the fake clock; the startup gate shows a spinner until then.
  // Tabs that are not shown may keep a spinner of their own, because
  // Riverpod pauses them, so only a spinner that can be seen counts.
  for (var attempt = 0; attempt < 80; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(CircularProgressIndicator).hitTestable().evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

/// Unmounts the app so its database closes before the next test.
Future<void> _stopApplication(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
}

void main() {
  testWidgets('shows the five tabs in English', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await _startApplication(tester);

    for (final label in ['Home', 'Freezer', 'List', 'Insights', 'Config']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Eat soon'), findsOneWidget);
    expect(find.text('Nothing urgent. Well done!'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('follows a German phone', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await _startApplication(tester, now: DateTime(2026, 10, 2, 20));

    for (final label in ['Start', 'Gefrierfach', 'Liste', 'Auswertung', 'Konfig.']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Guten Abend'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('falls back to English for unsupported languages', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await _startApplication(tester);

    expect(find.text('Home'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('switches tabs through the bottom navigation', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await _startApplication(tester);

    await tester.tap(find.text('List'));
    await _settle(tester);
    expect(find.text('Your shopping list is empty'), findsOneWidget);

    await tester.tap(find.text('Insights'));
    await _settle(tester);
    expect(find.text('No activity yet'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('starts with an empty freezer that asks for its layout', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await _startApplication(tester);

    expect(find.text('Add to freezer'), findsOneWidget);
    await tester.tap(find.text('Freezer'));
    await _settle(tester);
    expect(find.text('Set up your freezer first'), findsOneWidget);

    await tester.tap(find.text('Config'));
    await _settle(tester);
    expect(find.text('Freezer layout'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('the first start walks through onboarding', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await _startApplication(
      tester,
      platformServices: InMemoryPlatformServices(isOnboardingCompleted: false),
    );

    expect(find.text('Welcome'), findsOneWidget);
    await tester.tap(find.text('Deutsch'));
    await _settle(tester);
    expect(find.text('Willkommen'), findsOneWidget);

    await tester.tap(find.text('Weiter'));
    await _settle(tester);
    expect(find.text('Dein Gefrierschrank'), findsOneWidget);
    await tester.tap(find.text('Weiter'));
    await _settle(tester);
    expect(find.text('Deine Daten bleiben hier'), findsOneWidget);
    await tester.tap(find.text('Jetzt nicht'));
    await _settle(tester);

    expect(find.text('Guten Morgen'), findsOneWidget);
    await tester.tap(find.text('Gefrierfach'));
    await _settle(tester);
    expect(find.text('Dein Gefrierschrank ist leer'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('item pictures can be switched off in Config', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await _startApplication(tester);

    await tester.tap(find.text('Config'));
    await _settle(tester);
    final configList = find
        .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(find.text('Item pictures'), 200, scrollable: configList);
    expect(find.text('Photos of products and leftovers'), findsOneWidget);
    final pictureSwitch = find.widgetWithText(SwitchListTile, 'Item pictures');
    expect(tester.widget<SwitchListTile>(pictureSwitch).value, isTrue);

    await tester.tap(pictureSwitch);
    await _settle(tester);

    expect(tester.widget<SwitchListTile>(pictureSwitch).value, isFalse);

    await _stopApplication(tester);
  });

  testWidgets('barcode scanning is off until switched on in Config', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await _startApplication(tester);
    expect(find.text('Add to freezer'), findsOneWidget);

    await tester.tap(find.text('Config'));
    await _settle(tester);
    final configList = find
        .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(find.text('Barcode scanning'), 200, scrollable: configList);
    expect(find.text('Uses the camera, on this phone only'), findsOneWidget);
    final scanningSwitch = find.widgetWithText(SwitchListTile, 'Barcode scanning');
    // To the top of the list, clear of the navigation bar.
    await tester.ensureVisible(scanningSwitch);
    await _settle(tester);
    expect(tester.widget<SwitchListTile>(scanningSwitch).value, isFalse);
    await tester.tap(scanningSwitch);
    await _settle(tester);
    expect(tester.widget<SwitchListTile>(scanningSwitch).value, isTrue);

    await tester.tap(find.text('Home'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add'));
    await _settle(tester);
    expect(find.text('Add to freezer'), findsOneWidget);
    expect(find.text('Scan to add'), findsOneWidget);
    expect(find.text('Scan to remove'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('switches language and theme in Config, in sync with the system', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final platformServices = InMemoryPlatformServices(perAppLanguageCode: '');
    await _startApplication(tester, platformServices: platformServices);

    await tester.tap(find.text('Config'));
    await _settle(tester);
    await tester.tap(find.text('Deutsch'));
    await _settle(tester);

    expect(find.text('Konfiguration'), findsOneWidget);
    expect(platformServices.perAppLanguageCode, 'de');

    await tester.scrollUntilVisible(
      find.text('Dunkel'),
      200,
      scrollable: find
          .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
          .first,
    );
    await tester.tap(find.text('Dunkel'));
    await _settle(tester);
    expect(Theme.of(tester.element(find.text('Konfiguration'))).brightness, Brightness.dark);

    await _stopApplication(tester);
  });

  testWidgets('adopts a language chosen in the system settings', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await _startApplication(
      tester,
      platformServices: InMemoryPlatformServices(perAppLanguageCode: 'de'),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Guten Morgen'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('a reminder notification opens the Eat soon list', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final platformServices = InMemoryPlatformServices();
    await _startApplication(tester, platformServices: platformServices);

    platformServices.notificationServices.simulateTap('/storage_reminders/eat-soon');
    await _settle(tester);

    expect(find.text('Nothing to eat soon'), findsOneWidget);

    await _stopApplication(tester);
  });

  testWidgets('explains a lost database key instead of starting over', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await _startApplication(
      tester,
      platformServices: InMemoryPlatformServices(
        databaseOpeningError: const DatabaseEncryptionKeyLostException(),
      ),
    );

    expect(find.text('Your data cannot be unlocked'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);

    await _stopApplication(tester);
  });

  testWidgets('offers a retry after other start-up failures', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await _startApplication(
      tester,
      platformServices: InMemoryPlatformServices(databaseOpeningError: StateError('disk full')),
    );

    expect(find.text('The app could not start'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await _stopApplication(tester);
  });
}
