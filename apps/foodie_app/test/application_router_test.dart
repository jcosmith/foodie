import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodie_app/src/foodie_application.dart';
import 'package:foodie_app/src/routing/application_router.dart';
import 'package:go_router/go_router.dart';

/// A storage domain with its own tab, like the freezer.
final class _DomainModule extends FeatureModuleBase {
  const _DomainModule(
    this.moduleIdentifier,
    this.label,
    this.emoji,
    this.sortOrder, {
    this.isEnabledByDefault = true,
  });

  @override
  final String moduleIdentifier;
  final String label;
  final String emoji;
  final int sortOrder;
  final bool isEnabledByDefault;

  @override
  ModuleAvailability get availability =>
      ModuleAvailability.optional(isEnabledByDefault: isEnabledByDefault);

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: StorageDomainIdentifier(moduleIdentifier),
    sortOrder: sortOrder,
    iconEmoji: emoji,
    labelBuilder: (context) => label,
    descriptionBuilder: (context) => '$label things',
    storedOnLabelBuilder: (context) => 'Stored on',
    countsDiscardsAsWaste: true,
  );

  @override
  NavigationDestinationContribution get navigationDestination => NavigationDestinationContribution(
    sortOrder: sortOrder,
    iconEmoji: emoji,
    labelBuilder: (context) => label,
    initialLocation: '/$moduleIdentifier',
    routes: [
      GoRoute(
        path: '/$moduleIdentifier',
        builder: (context, state) => Scaffold(body: Text('$label contents')),
      ),
    ],
  );
}

/// Brings a segment of the Lists tab and an entry of the More tab.
final class _ListsAndMoreModule extends FeatureModuleBase {
  const _ListsAndMoreModule(this.moduleIdentifier, this.name, {required this.sortOrder});

  @override
  final String moduleIdentifier;
  final String name;
  final int sortOrder;

  @override
  List<ListsSegmentContribution> get listsSegments => [
    ListsSegmentContribution(
      identifier: '$moduleIdentifier.list',
      sortOrder: sortOrder,
      labelBuilder: (context) => '$name list',
      subtitleBuilder: (context) => 'All the $name',
      builder: (context) => Text('$name list contents'),
    ),
  ];

  @override
  List<MoreEntryContribution> get moreEntries => [
    MoreEntryContribution(
      identifier: '$moduleIdentifier.entry',
      sortOrder: sortOrder,
      iconEmoji: '📊',
      titleBuilder: (context) => '$name entry',
      subtitleBuilder: (context) => 'About $name',
      location: '/$moduleIdentifier',
      routes: [
        GoRoute(
          path: '/$moduleIdentifier',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: Text('$name screen')),
            body: const SizedBox(),
          ),
        ),
      ],
    ),
  ];
}

final class _InMemoryModuleEnablementStore implements ModuleEnablementStore {
  _InMemoryModuleEnablementStore(this._enabledIdentifiers);

  Set<String> _enabledIdentifiers;
  final StreamController<Set<String>> _changes = StreamController.broadcast();

  @override
  Stream<Set<String>> watchEnabledOptionalModuleIdentifiers(List<FeatureModule> optionalModules) =>
      Stream.multi((controller) {
        controller.add(_enabledIdentifiers);
        final subscription = _changes.stream.listen(controller.add);
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<void> setModuleEnabled(FeatureModule module, {required bool isEnabled}) async {
    _enabledIdentifiers = isEnabled
        ? {..._enabledIdentifiers, module.moduleIdentifier}
        : ({..._enabledIdentifiers}..remove(module.moduleIdentifier));
    _changes.add(_enabledIdentifiers);
  }
}

const _cold = _DomainModule('cold', 'Cold', '❄️', 10);
const _shelf = _DomainModule('shelf', 'Shelf', '🥫', 30);
const _extra = _DomainModule('extra', 'Extra', '🧴', 40, isEnabledByDefault: false);

Future<GoRouter> _pumpShell(
  WidgetTester tester, {
  required List<FeatureModule> modules,
  required _InMemoryModuleEnablementStore enablementStore,
}) async {
  final router = buildApplicationRouter(registeredModules: modules);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        registeredFeatureModulesProvider.overrideWithValue(modules),
        moduleEnablementStoreProvider.overrideWithValue(enablementStore),
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 4, 9))),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: shellLocalizationDelegates,
        theme: FoodieTheme.light(),
      ),
    ),
  );
  await _settle(tester);
  return router;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}

List<String> _tabLabels(WidgetTester tester) => [
  for (final destination in tester.widgetList<NavigationDestination>(
    find.byType(NavigationDestination),
  ))
    destination.label,
];

void main() {
  testWidgets('Home, the domain tabs that are on, then Lists and More, all with colour icons', (
    tester,
  ) async {
    await _pumpShell(
      tester,
      modules: const [_shelf, _extra, _cold],
      enablementStore: _InMemoryModuleEnablementStore({'cold', 'shelf'}),
    );

    expect(_tabLabels(tester), ['Home', 'Cold', 'Shelf', 'Lists', 'More']);
    for (final destination in tester.widgetList<NavigationDestination>(
      find.byType(NavigationDestination),
    )) {
      expect(destination.icon, isA<ColourTabIcon>(), reason: destination.label);
    }
  });

  testWidgets('switching a domain on or off adds or removes its tab at once', (tester) async {
    final enablementStore = _InMemoryModuleEnablementStore({'cold', 'shelf'});
    await _pumpShell(
      tester,
      modules: const [_cold, _shelf, _extra],
      enablementStore: enablementStore,
    );

    await tester.tap(find.text('Shelf'));
    await _settle(tester);
    expect(find.text('Shelf contents'), findsOneWidget);

    await tester.runAsync(() => enablementStore.setModuleEnabled(_extra, isEnabled: true));
    await _settle(tester);
    expect(_tabLabels(tester), ['Home', 'Cold', 'Shelf', 'Extra', 'Lists', 'More']);
    expect(find.text('Shelf contents'), findsOneWidget, reason: 'the open tab stays open');

    await tester.tap(find.text('Extra'));
    await _settle(tester);
    expect(find.text('Extra contents'), findsOneWidget);
    await tester.runAsync(() => enablementStore.setModuleEnabled(_shelf, isEnabled: false));
    await _settle(tester);
    expect(_tabLabels(tester), ['Home', 'Cold', 'Extra', 'Lists', 'More']);
    expect(find.text('Extra contents'), findsOneWidget);
  });

  testWidgets('a link to a switched-off domain opens Home instead', (tester) async {
    final router = await _pumpShell(
      tester,
      modules: const [_cold, _extra],
      enablementStore: _InMemoryModuleEnablementStore({'cold'}),
    );

    router.go('/extra');
    await _settle(tester);

    expect(find.text('Extra contents'), findsNothing);
    expect(find.text('Good morning'), findsOneWidget);
  });

  testWidgets('Lists shows the segments of every module, one at a time', (tester) async {
    await _pumpShell(
      tester,
      modules: const [
        _cold,
        _ListsAndMoreModule('receipts', 'Receipt', sortOrder: 20),
        _ListsAndMoreModule('shopping', 'Shopping', sortOrder: 10),
      ],
      enablementStore: _InMemoryModuleEnablementStore({'cold'}),
    );

    await tester.tap(find.text('Lists'));
    await _settle(tester);
    expect(find.text('Shopping list contents'), findsOneWidget);
    expect(find.text('All the Shopping'), findsOneWidget);
    expect(find.byType(SegmentedButton<String>), findsOneWidget);

    await tester.tap(find.text('Receipt list'));
    await _settle(tester);
    expect(find.text('Receipt list contents'), findsOneWidget);
    expect(find.text('Shopping list contents'), findsNothing);
  });

  testWidgets('a single list needs no segment buttons', (tester) async {
    await _pumpShell(
      tester,
      modules: const [_cold, _ListsAndMoreModule('shopping', 'Shopping', sortOrder: 10)],
      enablementStore: _InMemoryModuleEnablementStore({'cold'}),
    );

    await tester.tap(find.text('Lists'));
    await _settle(tester);
    expect(find.text('Shopping list contents'), findsOneWidget);
    expect(find.byType(SegmentedButton<String>), findsNothing);
  });

  testWidgets('More lists its entries in order and opens them inside the tab', (tester) async {
    await _pumpShell(
      tester,
      modules: const [
        _cold,
        _ListsAndMoreModule('options', 'Options', sortOrder: 20),
        _ListsAndMoreModule('statistics', 'Statistics', sortOrder: 10),
      ],
      enablementStore: _InMemoryModuleEnablementStore({'cold'}),
    );

    await tester.tap(find.text('More'));
    await _settle(tester);
    expect(
      tester.getTopLeft(find.text('Statistics entry')).dy,
      lessThan(tester.getTopLeft(find.text('Options entry')).dy),
    );
    expect(find.text('About Statistics'), findsOneWidget);
    expect(find.text('Your data never leaves this phone.'), findsOneWidget);

    await tester.tap(find.text('Options entry'));
    await _settle(tester);
    expect(find.text('Options screen'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget, reason: 'the bottom bar stays');

    await tester.pageBack();
    await _settle(tester);
    expect(find.text('Statistics entry'), findsOneWidget);
  });
}
