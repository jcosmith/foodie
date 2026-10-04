import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_product_catalog/src/application/product_catalog_providers.dart';
import 'package:feature_product_catalog/src/application/product_icon_image_file_picker.dart';
import 'package:feature_product_catalog/src/data/drift_product_catalog_repository.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// A provider container on an in-memory database with the module wired in.
final class ProductCatalogTestHarness {
  /// [iconImageFilePicker] stands in for the system's open dialog.
  ProductCatalogTestHarness({ProductIconImageFilePicker? iconImageFilePicker})
    : database = createInMemoryApplicationDatabase(clock: clock) {
    final eventBus = InProcessDomainEventBus(logger: RecordingLogger());
    eventBus.subscribe<DomainEvent>(publishedEvents.add);
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: SequentialIdentifierGenerator(),
      domainEventBus: eventBus,
      logger: RecordingLogger(),
    );
    container = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(clock),
        identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
        domainEventBusProvider.overrideWithValue(eventBus),
        if (iconImageFilePicker == null)
          ...const ProductCatalogFeatureModule().buildProviderOverrides(dependencies)
        else ...[
          productCatalogRepositoryProvider.overrideWith(
            (ref) => DriftProductCatalogRepository(ref.watch(productCatalogDaoProvider)),
          ),
          productIconImageFilePickerProvider.overrideWithValue(iconImageFilePicker),
        ],
        ...const StorageLayoutFeatureModule().buildProviderOverrides(dependencies),
        enabledFeatureModulesProvider.overrideWith((ref) => Stream.value(const [])),
      ],
    );
  }

  static final FixedClock clock = FixedClock(DateTime.utc(2026, 10, 2, 12));

  final ApplicationDatabase database;
  final List<DomainEvent> publishedEvents = [];
  late final ProviderContainer container;

  TValue read<TValue>(ProviderListenable<TValue> provider) => container.read(provider);

  Future<ProductCatalog> readCatalog() =>
      container.read(productCatalogQueryServiceProvider).readCatalog();

  /// Creates a freezer with three drawers, for products' default drawers.
  Future<List<Compartment>> setUpStoragePlace() async {
    await read(createStoragePlaceFromTemplateUseCaseProvider).execute(
      template: StorageTemplate.uprightWithThreeDrawers,
      enteredName: 'Freezer',
      defaultNames: const _EnglishLayoutDefaultNames(),
    );
    return (await read(storageLayoutQueryServiceProvider).readStorageLayout()).activeCompartments;
  }

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

/// English default names without Flutter localizations.
final class _EnglishLayoutDefaultNames implements LayoutDefaultNames {
  const _EnglishLayoutDefaultNames();

  @override
  String storagePlaceName(StorageKind storageKind) => 'Freezer';

  @override
  String compartmentName(StorageKind storageKind, int number) => 'Drawer $number';

  @override
  String removedName(String name) => '$name (removed)';
}
