import 'package:core_database/core_database.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/compartment.dart';
import '../domain/compartment_contents_port.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_layout_repository.dart';
import 'storage_layout_query_service.dart';
import 'use_cases/add_compartment_use_case.dart';
import 'use_cases/archive_freezer_use_case.dart';
import 'use_cases/change_compartment_color_use_case.dart';
import 'use_cases/create_freezer_from_template_use_case.dart';
import 'use_cases/move_contents_and_archive_compartment_use_case.dart';
import 'use_cases/rename_compartment_use_case.dart';
import 'use_cases/rename_freezer_use_case.dart';
import 'use_cases/reorder_compartments_use_case.dart';
import 'use_cases/reorder_freezers_use_case.dart';

/// Bound to the Drift implementation by the module's provider overrides.
final storageLayoutRepositoryProvider = Provider<StorageLayoutRepository>(
  (ref) => throw UnimplementedError('storageLayoutRepositoryProvider must be overridden'),
);

/// What the layout knows about stored items. The inventory module overrides
/// this; without it every compartment counts as empty.
final compartmentContentsPortProvider = Provider<CompartmentContentsPort>(
  (ref) => const EmptyCompartmentContents(),
);

final storageLayoutQueryServiceProvider = Provider<StorageLayoutQueryService>(
  (ref) => StorageLayoutQueryService(
    repository: ref.watch(storageLayoutRepositoryProvider),
    compartmentContents: ref.watch(compartmentContentsPortProvider),
  ),
);

/// The live freezer layout.
final storageLayoutProvider = StreamProvider<StorageLayout>(
  (ref) => ref.watch(storageLayoutQueryServiceProvider).watchStorageLayout(),
);

/// Live number of items per compartment.
final compartmentItemCountsProvider = StreamProvider<Map<CompartmentIdentifier, int>>(
  (ref) => ref.watch(storageLayoutQueryServiceProvider).watchItemCountsByCompartment(),
);

final createFreezerFromTemplateUseCaseProvider = Provider<CreateFreezerFromTemplateUseCase>(
  (ref) => CreateFreezerFromTemplateUseCase(
    repository: ref.watch(storageLayoutRepositoryProvider),
    transactionRunner: ref.watch(transactionRunnerProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
  ),
);

final renameFreezerUseCaseProvider = Provider<RenameFreezerUseCase>(
  (ref) => RenameFreezerUseCase(repository: ref.watch(storageLayoutRepositoryProvider)),
);

final reorderFreezersUseCaseProvider = Provider<ReorderFreezersUseCase>(
  (ref) => ReorderFreezersUseCase(
    repository: ref.watch(storageLayoutRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);

final archiveFreezerUseCaseProvider = Provider<ArchiveFreezerUseCase>(
  (ref) => ArchiveFreezerUseCase(
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
