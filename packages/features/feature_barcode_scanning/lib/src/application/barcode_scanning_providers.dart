import 'package:core_foundation/foundation_providers.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product_barcode_repository.dart';
import 'barcode_decoder.dart';
import 'barcode_use_cases.dart';

/// Bound to the Drift repository by the module's provider overrides.
final productBarcodeRepositoryProvider = Provider<ProductBarcodeRepository>(
  (ref) => throw UnimplementedError('productBarcodeRepositoryProvider must be overridden'),
);

/// Bound to the camera decoder by the module's provider overrides.
final barcodeDecoderProvider = Provider<BarcodeDecoder>(
  (ref) => throw UnimplementedError('barcodeDecoderProvider must be overridden'),
);

final resolveBarcodeUseCaseProvider = Provider<ResolveBarcodeUseCase>(
  (ref) => ResolveBarcodeUseCase(
    repository: ref.watch(productBarcodeRepositoryProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
  ),
);

final learnBarcodeUseCaseProvider = Provider<LearnBarcodeUseCase>(
  (ref) => LearnBarcodeUseCase(
    repository: ref.watch(productBarcodeRepositoryProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    clock: ref.watch(clockProvider),
  ),
);

final scanToAddUseCaseProvider = Provider<ScanToAddUseCase>(
  (ref) => ScanToAddUseCase(
    inventory: ref.watch(inventoryQueryServiceProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
    addStockBatch: ref.watch(addStockBatchUseCaseProvider),
    clock: ref.watch(clockProvider),
  ),
);
