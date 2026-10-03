import 'package:core_database/core_database.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product_catalog.dart';
import '../domain/product_catalog_repository.dart';
import 'product_catalog_query_service.dart';
import 'product_icon_image_file_picker.dart';
import 'use_cases/archive_product_use_case.dart';
import 'use_cases/change_category_storage_limit_use_case.dart';
import 'use_cases/choose_product_icon_image_use_case.dart';
import 'use_cases/create_product_use_case.dart';
import 'use_cases/seed_catalog_use_case.dart';
import 'use_cases/update_product_use_case.dart';

/// Bound to the Drift implementation by the module's provider overrides.
final productCatalogRepositoryProvider = Provider<ProductCatalogRepository>(
  (ref) => throw UnimplementedError('productCatalogRepositoryProvider must be overridden'),
);

/// Bound to the system's open dialog by the module's provider overrides.
final productIconImageFilePickerProvider = Provider<ProductIconImageFilePicker>(
  (ref) => throw UnimplementedError('productIconImageFilePickerProvider must be overridden'),
);

final chooseProductIconImageUseCaseProvider = Provider<ChooseProductIconImageUseCase>(
  (ref) => ChooseProductIconImageUseCase(
    filePicker: ref.watch(productIconImageFilePickerProvider),
    imageProcessing: ref.watch(imageProcessingServiceProvider),
  ),
);

final productCatalogQueryServiceProvider = Provider<ProductCatalogQueryService>(
  (ref) => ProductCatalogQueryService(ref.watch(productCatalogRepositoryProvider)),
);

/// The live product catalog.
final productCatalogProvider = StreamProvider<ProductCatalog>(
  (ref) => ref.watch(productCatalogQueryServiceProvider).watchCatalog(),
);

final seedCatalogUseCaseProvider = Provider<SeedCatalogUseCase>(
  (ref) => SeedCatalogUseCase(
    repository: ref.watch(productCatalogRepositoryProvider),
    transactionRunner: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
  ),
);

final createProductUseCaseProvider = Provider<CreateProductUseCase>(
  (ref) => CreateProductUseCase(
    repository: ref.watch(productCatalogRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
  ),
);

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>(
  (ref) => UpdateProductUseCase(
    repository: ref.watch(productCatalogRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);

final changeCategoryStorageLimitUseCaseProvider = Provider<ChangeCategoryStorageLimitUseCase>(
  (ref) => ChangeCategoryStorageLimitUseCase(
    repository: ref.watch(productCatalogRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);

final archiveProductUseCaseProvider = Provider<ArchiveProductUseCase>(
  (ref) => ArchiveProductUseCase(
    repository: ref.watch(productCatalogRepositoryProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);
