import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:meta/meta.dart';

import '../domain/barcode_normalization.dart';
import '../domain/barcode_scanning_failure.dart';
import '../domain/product_barcode.dart';
import '../domain/product_barcode_repository.dart';
import '../domain/scanned_barcode.dart';

/// What a scanned code turned out to be.
sealed class BarcodeResolution {
  const BarcodeResolution(this.barcode);

  final NormalizedBarcode barcode;
}

final class RecognizedBarcode extends BarcodeResolution {
  const RecognizedBarcode(super.barcode, this.product);

  final Product product;
}

/// A code the app has not learned yet, or one whose product was archived.
final class UnrecognizedBarcode extends BarcodeResolution {
  const UnrecognizedBarcode(super.barcode);
}

/// Finds the product of a scanned code among the user's own products. No
/// online product database is ever asked (section 11).
final class ResolveBarcodeUseCase {
  const ResolveBarcodeUseCase({
    required ProductBarcodeRepository repository,
    required ProductCatalogQueryService productCatalog,
  }) : _repository = repository,
       _productCatalog = productCatalog;

  final ProductBarcodeRepository _repository;
  final ProductCatalogQueryService _productCatalog;

  Future<BarcodeResolution> execute(ScannedBarcode scannedBarcode) async {
    final barcode = BarcodeNormalization.normalize(scannedBarcode);
    final learnedBarcode = await _repository.readBarcode(barcode.lookupValue);
    if (learnedBarcode == null) return UnrecognizedBarcode(barcode);
    final product = await _productCatalog.readProduct(learnedBarcode.productIdentifier);
    if (product == null || product.isArchived) return UnrecognizedBarcode(barcode);
    return RecognizedBarcode(barcode, product);
  }
}

/// Maps a code to a product once, so the next scan recognises it. Learning
/// a known code again moves it to the new product, which fixes a wrong
/// choice.
final class LearnBarcodeUseCase {
  const LearnBarcodeUseCase({
    required ProductBarcodeRepository repository,
    required ProductCatalogQueryService productCatalog,
    required Clock clock,
  }) : _repository = repository,
       _productCatalog = productCatalog,
       _clock = clock;

  final ProductBarcodeRepository _repository;
  final ProductCatalogQueryService _productCatalog;
  final Clock _clock;

  Future<Result<RecognizedBarcode, BarcodeScanningFailure>> execute({
    required NormalizedBarcode barcode,
    required ProductIdentifier productIdentifier,
  }) async {
    final product = await _productCatalog.readProduct(productIdentifier);
    if (product == null || product.isArchived) {
      return const Result.failure(BarcodeProductUnavailable());
    }
    await _repository.saveBarcode(
      ProductBarcode(
        barcodeValue: barcode.lookupValue,
        productIdentifier: productIdentifier,
        symbology: barcode.symbology,
        isVariableMeasure: barcode.isVariableMeasure,
        learnedAt: _clock.nowUtc(),
      ),
    );
    return Result.success(RecognizedBarcode(barcode, product));
  }
}

/// What one tap on "Add" would put into storage.
@immutable
final class ScanToAddSuggestion {
  const ScanToAddSuggestion({required this.product, this.quantity, this.compartment});

  final Product product;

  /// The weight printed into a weighed-goods code, else the package size;
  /// `null` when neither is known and the user has to type it.
  final Quantity? quantity;

  /// The compartment this product went into last time, else the first compartment;
  /// `null` while there is no storage place.
  final Compartment? compartment;

  bool get canAddWithOneTap => quantity != null && compartment != null;

  ScanToAddSuggestion withQuantity(Quantity quantity) =>
      ScanToAddSuggestion(product: product, quantity: quantity, compartment: compartment);
}

/// Scan to add (section 10.3): the product with its package size (or the
/// weight in the code) into the compartment used last time. Adds through the
/// inventory's own use case, so restock and reminders react as usual.
final class ScanToAddUseCase {
  const ScanToAddUseCase({
    required InventoryQueryService inventory,
    required StorageLayoutQueryService storageLayout,
    required AddStockBatchUseCase addStockBatch,
    required Clock clock,
  }) : _inventory = inventory,
       _storageLayout = storageLayout,
       _addStockBatch = addStockBatch,
       _clock = clock;

  final InventoryQueryService _inventory;
  final StorageLayoutQueryService _storageLayout;
  final AddStockBatchUseCase _addStockBatch;
  final Clock _clock;

  Future<ScanToAddSuggestion> suggest(RecognizedBarcode recognizedBarcode) async {
    final product = recognizedBarcode.product;
    final layout = await _storageLayout.readStorageLayout();
    final lastCompartmentIdentifier = await _inventory.readLastCompartmentOfProduct(
      product.identifier,
    );
    final activeCompartments = layout.activeCompartments;
    final compartment =
        activeCompartments
            .where((compartment) => compartment.identifier == lastCompartmentIdentifier)
            .firstOrNull ??
        activeCompartments.firstOrNull;
    return ScanToAddSuggestion(
      product: product,
      quantity:
          recognizedBarcode.barcode.embeddedWeightFor(product.canonicalUnit) ??
          product.defaultPackageQuantity,
      compartment: compartment,
    );
  }

  Future<Result<StockBatchIdentifier, InventoryFailure>> add(ScanToAddSuggestion suggestion) =>
      _addStockBatch.execute(_commandFor(suggestion));

  /// Unpacking groceries (section 10.3): everything scanned in a row goes
  /// into storage in one transaction, or nothing does.
  Future<Result<List<StockBatchIdentifier>, InventoryFailure>> addAll(
    List<ScanToAddSuggestion> suggestions,
  ) => _addStockBatch.executeAll([for (final suggestion in suggestions) _commandFor(suggestion)]);

  AddStockBatchCommand _commandFor(ScanToAddSuggestion suggestion) {
    final quantity = suggestion.quantity;
    final compartment = suggestion.compartment;
    if (quantity == null || compartment == null) {
      throw StateError('Only a suggestion that can be added with one tap can be added');
    }
    return AddStockBatchCommand(
      productIdentifier: suggestion.product.identifier,
      compartmentIdentifier: compartment.identifier,
      quantity: quantity,
      storedOn: _clock.todayLocal(),
    );
  }
}
