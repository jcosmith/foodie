import 'dart:async';

import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

String _label(BuildContext context) => '';

String _numbered(BuildContext context, int number) => '$number';

StorageKindContribution _kind(String storageName, StorageDomainIdentifier domain) =>
    StorageKindContribution(
      storageName: storageName,
      domainIdentifier: domain,
      sortOrder: 0,
      iconEmoji: '📦',
      placeNameBuilder: _label,
      kindDescriptionBuilder: _label,
      compartmentNameBuilder: _numbered,
      compartmentCountBuilder: _numbered,
      addCompartmentLabelBuilder: _label,
      templates: [
        StorageTemplateContribution(
          identifier: '$storageName.default',
          sortOrder: 10,
          compartmentCount: 2,
          labelBuilder: _label,
        ),
      ],
    );

final class _DomainModule extends FeatureModuleBase {
  const _DomainModule(
    this.moduleIdentifier,
    this.domain, {
    required this.sortOrder,
    this.isEnabledByDefault = true,
    this.countsDiscardsAsWaste = true,
  });

  @override
  final String moduleIdentifier;
  final StorageDomainIdentifier domain;
  final int sortOrder;
  final bool isEnabledByDefault;
  final bool countsDiscardsAsWaste;

  @override
  ModuleAvailability get availability =>
      ModuleAvailability.optional(isEnabledByDefault: isEnabledByDefault);

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: domain,
    sortOrder: sortOrder,
    iconEmoji: '❄️',
    labelBuilder: _label,
    descriptionBuilder: _label,
    storedOnLabelBuilder: _label,
    countsDiscardsAsWaste: countsDiscardsAsWaste,
  );

  @override
  List<StorageKindContribution> get storageKinds => [_kind('${domain.value}_kind', domain)];

  @override
  CatalogContribution get catalog => CatalogContribution(
    categories: [
      SeededCategoryContribution(
        catalogKey: '${domain.value}Category',
        domainIdentifier: domain,
        shelfLifeDays: 30,
        iconEmoji: '📦',
      ),
    ],
    products: const [],
    categoryNameBuilder: (context, catalogKey) => null,
    productNameBuilder: (context, catalogKey) => null,
  );
}

final class _PlainModule extends FeatureModuleBase {
  const _PlainModule();

  @override
  String get moduleIdentifier => 'inventory';
}

final class _InMemoryModuleEnablementStore implements ModuleEnablementStore {
  _InMemoryModuleEnablementStore(this._enabledIdentifiers);

  final StreamController<Set<String>> _changes = StreamController.broadcast();
  Set<String> _enabledIdentifiers;

  @override
  Stream<Set<String>> watchEnabledOptionalModuleIdentifiers(List<FeatureModule> optionalModules) =>
      Stream.multi((controller) {
        controller.add(_enabledIdentifiers);
        final changeSubscription = _changes.stream.listen(controller.add);
        controller.onCancel = changeSubscription.cancel;
      });

  @override
  Future<void> setModuleEnabled(FeatureModule module, {required bool isEnabled}) async {
    _enabledIdentifiers = isEnabled
        ? {..._enabledIdentifiers, module.moduleIdentifier}
        : ({..._enabledIdentifiers}..remove(module.moduleIdentifier));
    _changes.add(_enabledIdentifiers);
  }
}

const _freezer = _DomainModule('freezer', StorageDomainIdentifier.freezer, sortOrder: 10);
const _fridge = _DomainModule('fridge', StorageDomainIdentifier.fridge, sortOrder: 20);
const _household = _DomainModule(
  'household_supplies',
  StorageDomainIdentifier.household,
  sortOrder: 40,
  isEnabledByDefault: false,
  countsDiscardsAsWaste: false,
);

ProviderContainer _containerWith(Set<String> enabledOptionalIdentifiers) {
  final container = ProviderContainer(
    overrides: [
      registeredFeatureModulesProvider.overrideWithValue([
        _household,
        const _PlainModule(),
        _fridge,
        _freezer,
      ]),
      moduleEnablementStoreProvider.overrideWithValue(
        _InMemoryModuleEnablementStore(enabledOptionalIdentifiers),
      ),
    ],
  );
  addTearDown(container.dispose);
  final subscription = container.listen(enabledFeatureModulesProvider, (_, _) {});
  addTearDown(subscription.close);
  return container;
}

void main() {
  test('modules contribute nothing to storage domains by default', () {
    const module = _PlainModule();
    expect(module.storageDomain, isNull);
    expect(module.storageKinds, isEmpty);
    expect(module.catalog, isNull);
  });

  test('registered domains are every domain module in sort order, switched on or not', () {
    final container = _containerWith({'freezer'});
    expect(container.read(registeredStorageDomainsProvider).map((domain) => domain.identifier), [
      StorageDomainIdentifier.freezer,
      StorageDomainIdentifier.fridge,
      StorageDomainIdentifier.household,
    ]);
  });

  test('enabled domains follow the switches, in sort order', () async {
    final container = _containerWith({'household_supplies', 'freezer'});
    await container.read(enabledFeatureModulesProvider.future);
    expect(container.read(enabledStorageDomainsProvider).map((domain) => domain.identifier), [
      StorageDomainIdentifier.freezer,
      StorageDomainIdentifier.household,
    ]);
    expect(container.read(enabledStorageDomainIdentifiersProvider), {
      StorageDomainIdentifier.freezer,
      StorageDomainIdentifier.household,
    });
  });

  test('at least one domain stays on even if every switch is off', () async {
    final container = _containerWith(const {});
    final enabledModules = await container.read(enabledFeatureModulesProvider.future);
    expect(enabledModules.map((module) => module.moduleIdentifier), contains('freezer'));
    expect(container.read(enabledStorageDomainsProvider).map((domain) => domain.identifier), [
      StorageDomainIdentifier.freezer,
    ]);
  });

  test('switched-off domains are paused; nothing is paused while none is known', () async {
    final container = _containerWith({'freezer'});
    expect(
      container.read(pausedStorageDomainIdentifiersProvider),
      isEmpty,
      reason: 'the switches are still loading',
    );
    await container.read(enabledFeatureModulesProvider.future);
    expect(container.read(pausedStorageDomainIdentifiersProvider), {
      StorageDomainIdentifier.fridge,
      StorageDomainIdentifier.household,
    });
  });

  test('the last enabled domain cannot be switched off; other modules can', () {
    expect(canSwitchModuleOff(_freezer, enabledModules: const [_freezer, _PlainModule()]), isFalse);
    expect(canSwitchModuleOff(_freezer, enabledModules: const [_freezer, _fridge]), isTrue);
    expect(canSwitchModuleOff(_fridge, enabledModules: const [_freezer]), isTrue);
  });

  test('storage kinds of every registered module are known by name', () {
    final container = _containerWith({'freezer'});
    final kinds = container.read(registeredStorageKindsProvider);
    expect(kinds.keys, containsAll(['freezer_kind', 'fridge_kind', 'household_kind']));
    expect(kinds['household_kind']!.domainIdentifier, StorageDomainIdentifier.household);
    expect(kinds['fridge_kind']!.templates.single.compartmentCount, 2);
  });

  test('a domain says whether throwing something away counts as waste', () {
    expect(_freezer.storageDomain.countsDiscardsAsWaste, isTrue);
    expect(_household.storageDomain.countsDiscardsAsWaste, isFalse);
  });

  test('catalog contributions of every registered module are collected', () {
    final container = _containerWith({'freezer'});
    final keys = [
      for (final catalog in container.read(registeredCatalogContributionsProvider))
        for (final category in catalog.categories) category.catalogKey,
    ];
    expect(keys, containsAll(['freezerCategory', 'fridgeCategory', 'householdCategory']));
  });
}
