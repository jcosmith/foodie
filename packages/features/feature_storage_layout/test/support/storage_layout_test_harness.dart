import 'dart:async';

import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// English default names without Flutter localizations, for use case tests.
final class EnglishLayoutDefaultNames implements LayoutDefaultNames {
  const EnglishLayoutDefaultNames();

  @override
  String storagePlaceName(StorageKind storageKind) => switch (storageKind) {
    StorageKind.upright => 'Freezer',
    StorageKind.chest => 'Chest freezer',
    StorageKind.fridgeFreezerCompartment => 'Fridge freezer',
  };

  @override
  String compartmentName(StorageKind storageKind, int number) => switch (storageKind) {
    StorageKind.upright => 'Drawer $number',
    StorageKind.chest => 'Basket $number',
    StorageKind.fridgeFreezerCompartment => 'Compartment $number',
  };

  @override
  String removedName(String name) => '$name (removed)';
}

/// A contents port with settable item counts that records requested moves.
final class FakeCompartmentContents implements CompartmentContentsPort {
  final Map<CompartmentIdentifier, int> _itemCounts = {};
  final StreamController<Map<CompartmentIdentifier, int>> _changes = StreamController.broadcast();
  final List<(CompartmentIdentifier, CompartmentIdentifier)> requestedMoves = [];

  void setItemCount(CompartmentIdentifier compartmentIdentifier, int itemCount) {
    _itemCounts[compartmentIdentifier] = itemCount;
    _changes.add(Map.of(_itemCounts));
  }

  void removeAllItems() {
    _itemCounts.clear();
    _changes.add(const {});
  }

  @override
  Stream<Map<CompartmentIdentifier, int>> watchItemCountsByCompartment() =>
      Stream.multi((controller) {
        controller.add(Map.of(_itemCounts));
        final subscription = _changes.stream.listen(controller.add);
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<int> countItemsInCompartment(CompartmentIdentifier compartmentIdentifier) async =>
      _itemCounts[compartmentIdentifier] ?? 0;

  @override
  Future<List<DomainEvent>> moveAllContents({
    required CompartmentIdentifier sourceCompartmentIdentifier,
    required CompartmentIdentifier destinationCompartmentIdentifier,
  }) async {
    requestedMoves.add((sourceCompartmentIdentifier, destinationCompartmentIdentifier));
    final movedCount = _itemCounts.remove(sourceCompartmentIdentifier) ?? 0;
    setItemCount(
      destinationCompartmentIdentifier,
      (_itemCounts[destinationCompartmentIdentifier] ?? 0) + movedCount,
    );
    return const [];
  }
}

/// A provider container on an in-memory database with the module wired in.
final class StorageLayoutTestHarness {
  StorageLayoutTestHarness({CompartmentContentsPort? compartmentContents})
    : database = createInMemoryApplicationDatabase(clock: clock) {
    final eventBus = InProcessDomainEventBus(logger: RecordingLogger());
    eventBus.subscribe<DomainEvent>(publishedEvents.add);
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: identifierGenerator,
      domainEventBus: eventBus,
      logger: RecordingLogger(),
    );
    container = ProviderContainer(overrides: overridesFor(dependencies, compartmentContents));
  }

  static final FixedClock clock = FixedClock(DateTime.utc(2026, 10, 2, 12));

  final ApplicationDatabase database;
  final SequentialIdentifierGenerator identifierGenerator = SequentialIdentifierGenerator();
  final List<DomainEvent> publishedEvents = [];
  late final ProviderContainer container;

  List<Override> overridesFor(
    ModuleDependencies dependencies,
    CompartmentContentsPort? compartmentContents,
  ) => [
    applicationDatabaseProvider.overrideWithValue(database),
    clockProvider.overrideWithValue(dependencies.clock),
    identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
    domainEventBusProvider.overrideWithValue(dependencies.domainEventBus),
    ...const StorageLayoutFeatureModule().buildProviderOverrides(dependencies),
    if (compartmentContents != null)
      compartmentContentsPortProvider.overrideWithValue(compartmentContents),
  ];

  TValue read<TValue>(ProviderListenable<TValue> provider) => container.read(provider);

  Future<StorageLayout> readLayout() =>
      container.read(storageLayoutQueryServiceProvider).readStorageLayout();

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}
