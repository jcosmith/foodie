import 'dart:async';

import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _AlwaysOnModule extends FeatureModuleBase {
  const _AlwaysOnModule();

  @override
  String get moduleIdentifier => 'inventory';
}

final class _OptionalModule extends FeatureModuleBase {
  const _OptionalModule();

  @override
  String get moduleIdentifier => 'barcode_scanning';

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: false);
}

final class _InMemoryModuleEnablementStore implements ModuleEnablementStore {
  final StreamController<Set<String>> _changes = StreamController.broadcast();
  Set<String> _enabledIdentifiers = {};

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

void main() {
  test('optional modules join and leave the enabled list without a restart', () async {
    const optionalModule = _OptionalModule();
    final enablementStore = _InMemoryModuleEnablementStore();
    final container = ProviderContainer(
      overrides: [
        registeredFeatureModulesProvider.overrideWithValue([
          const _AlwaysOnModule(),
          optionalModule,
        ]),
        moduleEnablementStoreProvider.overrideWithValue(enablementStore),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(enabledFeatureModulesProvider, (_, _) {});
    addTearDown(subscription.close);

    Future<List<String>> enabledIdentifiers() async => (await container.read(
      enabledFeatureModulesProvider.future,
    )).map((module) => module.moduleIdentifier).toList();

    expect(await enabledIdentifiers(), ['inventory']);
    await enablementStore.setModuleEnabled(optionalModule, isEnabled: true);
    await pumpEventQueue();
    expect(await enabledIdentifiers(), ['inventory', 'barcode_scanning']);
  });
}
