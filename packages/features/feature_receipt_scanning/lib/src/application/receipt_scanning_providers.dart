import 'package:core_database/core_database.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/receipt.dart';
import '../domain/receipt_repository.dart';
import 'receipt_query_service.dart';
import 'receipt_use_cases.dart';

/// Bound to the Drift repository by the module's provider overrides.
final receiptRepositoryProvider = Provider<ReceiptRepository>(
  (ref) => throw UnimplementedError('receiptRepositoryProvider must be overridden'),
);

final receiptQueryServiceProvider = Provider<ReceiptQueryService>(
  (ref) => ReceiptQueryService(ref.watch(receiptRepositoryProvider)),
);

/// The archive, newest first.
final receiptSummariesProvider = StreamProvider<List<ReceiptSummary>>(
  (ref) => ref.watch(receiptQueryServiceProvider).watchReceipts(),
);

final prepareReceiptReviewUseCaseProvider = Provider<PrepareReceiptReviewUseCase>(
  (ref) => PrepareReceiptReviewUseCase(
    repository: ref.watch(receiptRepositoryProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    inventory: ref.watch(inventoryQueryServiceProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
    clock: ref.watch(clockProvider),
    readPausedDomains: () => ref.read(pausedStorageDomainIdentifiersProvider),
    readDomainsWithBestBefore: () => {
      for (final domain in ref.read(registeredStorageDomainsProvider))
        if (domain.bestBeforeLabelBuilder != null) domain.identifier,
    },
  ),
);

final confirmReceiptUseCaseProvider = Provider<ConfirmReceiptUseCase>(
  (ref) => ConfirmReceiptUseCase(
    repository: ref.watch(receiptRepositoryProvider),
    addStockBatch: ref.watch(addStockBatchUseCaseProvider),
    transactionRunner: ref.watch(transactionRunnerProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
    clock: ref.watch(clockProvider),
  ),
);

final resolveReceiptLineUseCaseProvider = Provider<ResolveReceiptLineUseCase>(
  (ref) => ResolveReceiptLineUseCase(
    repository: ref.watch(receiptRepositoryProvider),
    addStockBatch: ref.watch(addStockBatchUseCaseProvider),
    transactionRunner: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
  ),
);

final deleteReceiptUseCaseProvider = Provider<DeleteReceiptUseCase>(
  (ref) => DeleteReceiptUseCase(repository: ref.watch(receiptRepositoryProvider)),
);
