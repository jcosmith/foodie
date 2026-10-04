import 'dart:typed_data';

import 'package:core_database/core_database.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/receipt.dart';
import '../domain/receipt_photo_retention.dart';
import '../domain/receipt_repository.dart';
import 'receipt_capture.dart';
import 'receipt_page_images.dart';
import 'receipt_query_service.dart';
import 'receipt_use_cases.dart';

/// Bound to the Drift repository by the module's provider overrides.
final receiptRepositoryProvider = Provider<ReceiptRepository>(
  (ref) => throw UnimplementedError('receiptRepositoryProvider must be overridden'),
);

/// Bound to the system camera by the module's provider overrides.
final receiptPhotoSourceProvider = Provider<ReceiptPhotoSource>(
  (ref) => throw UnimplementedError('receiptPhotoSourceProvider must be overridden'),
);

/// Bound to on-device text recognition by the module's provider overrides.
final receiptTextRecognizerProvider = Provider<ReceiptTextRecognizer>(
  (ref) => throw UnimplementedError('receiptTextRecognizerProvider must be overridden'),
);

final receiptPageImagesProvider = Provider<ReceiptPageImages>(
  (ref) => ReceiptPageImages(
    store: ref.watch(receiptMediaFileStoreProvider),
    imageProcessing: ref.watch(imageProcessingServiceProvider),
  ),
);

/// A decrypted page image, only loaded when a receipt is opened.
final receiptPageImageProvider = FutureProvider.autoDispose.family<Uint8List, String>(
  (ref, reference) => ref.watch(receiptPageImagesProvider).read(reference),
);

/// One archived receipt; invalidated after its lines change.
final receiptProvider = FutureProvider.autoDispose.family<Receipt?, ReceiptIdentifier>(
  (ref, receiptIdentifier) => ref.watch(receiptQueryServiceProvider).readReceipt(receiptIdentifier),
);

final readReceiptPageUseCaseProvider = Provider<ReadReceiptPageUseCase>(
  (ref) => ReadReceiptPageUseCase(
    recognizer: ref.watch(receiptTextRecognizerProvider),
    photoSource: ref.watch(receiptPhotoSourceProvider),
    pageImages: ref.watch(receiptPageImagesProvider),
  ),
);

final discardReceiptScanUseCaseProvider = Provider<DiscardReceiptScanUseCase>(
  (ref) => DiscardReceiptScanUseCase(pageImages: ref.watch(receiptPageImagesProvider)),
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
  (ref) => DeleteReceiptUseCase(
    repository: ref.watch(receiptRepositoryProvider),
    pageImages: ref.watch(receiptPageImagesProvider),
  ),
);

abstract final class ReceiptPreferenceKeys {
  static final PreferenceKey<ReceiptPhotoRetention> photoRetention = PreferenceKey.enumeration(
    moduleNamespace: 'receipts',
    name: 'photo_retention',
    defaultValue: ReceiptPhotoRetention.forever,
    values: ReceiptPhotoRetention.values,
  );
}

final receiptPhotoRetentionProvider = StreamProvider<ReceiptPhotoRetention>(
  (ref) => ref.watch(preferencesStoreProvider).watch(ReceiptPreferenceKeys.photoRetention),
);

final applyReceiptPhotoRetentionUseCaseProvider = Provider<ApplyReceiptPhotoRetentionUseCase>(
  (ref) => ApplyReceiptPhotoRetentionUseCase(
    repository: ref.watch(receiptRepositoryProvider),
    pageImages: ref.watch(receiptPageImagesProvider),
    clock: ref.watch(clockProvider),
  ),
);

final correctReceiptLineTextUseCaseProvider = Provider<CorrectReceiptLineTextUseCase>(
  (ref) => CorrectReceiptLineTextUseCase(repository: ref.watch(receiptRepositoryProvider)),
);
