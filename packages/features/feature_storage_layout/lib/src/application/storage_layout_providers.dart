import 'package:core_database/core_database.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/compartment.dart';
import '../domain/compartment_contents_port.dart';
import '../domain/storage_kind.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_layout_repository.dart';
import '../domain/storage_template.dart';
import 'storage_layout_query_service.dart';
import 'use_cases/add_compartment_use_case.dart';
import 'use_cases/archive_storage_place_use_case.dart';
import 'use_cases/change_compartment_color_use_case.dart';
import 'use_cases/create_storage_place_from_template_use_case.dart';
import 'use_cases/move_contents_and_archive_compartment_use_case.dart';
import 'use_cases/rename_compartment_use_case.dart';
import 'use_cases/rename_storage_place_use_case.dart';
import 'use_cases/reorder_compartments_use_case.dart';
import 'use_cases/reorder_storage_places_use_case.dart';

/// Bound to the Drift implementation by the module's provider overrides.
final storageLayoutRepositoryProvider = Provider<StorageLayoutRepository>(
  (ref) => throw UnimplementedError('storageLayoutRepositoryProvider must be overridden'),
);

/// What the layout knows about stored items. The inventory module overrides
/// this; without it every compartment counts as empty.
final compartmentContentsPortProvider = Provider<CompartmentContentsPort>(
  (ref) => const EmptyCompartmentContents(),
);

/// The domain of every storage kind a registered module brings, switched on
/// or not.
final storageKindDomainsProvider = Provider<Map<StorageKind, StorageDomainIdentifier>>(
  (ref) => {
    for (final kind in ref.watch(registeredStorageKindsProvider).values)
      StorageKind(kind.storageName): kind.domainIdentifier,
  },
);

/// Every template of every registered module by its identifier, with its
/// label.
final storageTemplateContributionsProvider = Provider<Map<String, StorageTemplateContribution>>(
  (ref) => {
    for (final kind in ref.watch(registeredStorageKindsProvider).values)
      for (final template in kind.templates) template.identifier: template,
  },
);

/// Every template of every registered module, in the order they are offered.
final registeredStorageTemplatesProvider = Provider<List<StorageTemplate>>(
  (ref) => [
    for (final kind in ref.watch(registeredStorageKindsProvider).values)
      for (final template in kind.templates)
        StorageTemplate(
          identifier: template.identifier,
          storageKind: StorageKind(kind.storageName),
          domainIdentifier: kind.domainIdentifier,
          compartmentCount: template.compartmentCount,
          sortOrder: template.sortOrder,
        ),
  ]..sort((first, second) => first.sortOrder.compareTo(second.sortOrder)),
);

/// The templates offered when adding a storage place to one domain.
final storageTemplatesOfDomainProvider =
    Provider.family<List<StorageTemplate>, StorageDomainIdentifier>(
      (ref, domainIdentifier) => [
        for (final template in ref.watch(registeredStorageTemplatesProvider))
          if (template.domainIdentifier == domainIdentifier) template,
      ],
    );

final storageLayoutQueryServiceProvider = Provider<StorageLayoutQueryService>(
  (ref) => StorageLayoutQueryService(
    repository: ref.watch(storageLayoutRepositoryProvider),
    compartmentContents: ref.watch(compartmentContentsPortProvider),
    domainOfStorageKind: ref.watch(storageKindDomainsProvider),
  ),
);

/// The live storage place layout.
final storageLayoutProvider = StreamProvider<StorageLayout>(
  (ref) => ref.watch(storageLayoutQueryServiceProvider).watchStorageLayout(),
);

/// The live layout without the places of switched-off domains, for pickers
/// and overviews.
final storageLayoutOfEnabledDomainsProvider = Provider<AsyncValue<StorageLayout>>(
  (ref) => ref
      .watch(storageLayoutProvider)
      .whenData(
        (layout) => layout.withoutDomains(ref.watch(pausedStorageDomainIdentifiersProvider)),
      ),
);

/// Live number of items per compartment.
final compartmentItemCountsProvider = StreamProvider<Map<CompartmentIdentifier, int>>(
  (ref) => ref.watch(storageLayoutQueryServiceProvider).watchItemCountsByCompartment(),
);

final createStoragePlaceFromTemplateUseCaseProvider =
    Provider<CreateStoragePlaceFromTemplateUseCase>(
      (ref) => CreateStoragePlaceFromTemplateUseCase(
        repository: ref.watch(storageLayoutRepositoryProvider),
        transactionRunner: ref.watch(transactionRunnerProvider),
        domainEventBus: ref.watch(domainEventBusProvider),
        clock: ref.watch(clockProvider),
        identifierGenerator: ref.watch(identifierGeneratorProvider),
      ),
    );

final renameStoragePlaceUseCaseProvider = Provider<RenameStoragePlaceUseCase>(
  (ref) => RenameStoragePlaceUseCase(repository: ref.watch(storageLayoutRepositoryProvider)),
);

final reorderStoragePlacesUseCaseProvider = Provider<ReorderStoragePlacesUseCase>(
  (ref) => ReorderStoragePlacesUseCase(
    repository: ref.watch(storageLayoutRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);

final archiveStoragePlaceUseCaseProvider = Provider<ArchiveStoragePlaceUseCase>(
  (ref) => ArchiveStoragePlaceUseCase(
    repository: ref.watch(storageLayoutRepositoryProvider),
    compartmentContents: ref.watch(compartmentContentsPortProvider),
    transactionRunner: ref.watch(transactionRunnerProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);

final addCompartmentUseCaseProvider = Provider<AddCompartmentUseCase>(
  (ref) => AddCompartmentUseCase(
    repository: ref.watch(storageLayoutRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
  ),
);

final renameCompartmentUseCaseProvider = Provider<RenameCompartmentUseCase>(
  (ref) => RenameCompartmentUseCase(
    repository: ref.watch(storageLayoutRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);

final reorderCompartmentsUseCaseProvider = Provider<ReorderCompartmentsUseCase>(
  (ref) => ReorderCompartmentsUseCase(
    repository: ref.watch(storageLayoutRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);

final changeCompartmentColorUseCaseProvider = Provider<ChangeCompartmentColorUseCase>(
  (ref) => ChangeCompartmentColorUseCase(repository: ref.watch(storageLayoutRepositoryProvider)),
);

final moveContentsAndArchiveCompartmentUseCaseProvider =
    Provider<MoveContentsAndArchiveCompartmentUseCase>(
      (ref) => MoveContentsAndArchiveCompartmentUseCase(
        repository: ref.watch(storageLayoutRepositoryProvider),
        compartmentContents: ref.watch(compartmentContentsPortProvider),
        transactionRunner: ref.watch(transactionRunnerProvider),
        domainEventBus: ref.watch(domainEventBusProvider),
        clock: ref.watch(clockProvider),
      ),
    );
