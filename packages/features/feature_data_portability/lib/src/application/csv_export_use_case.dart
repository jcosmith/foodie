import 'dart:convert';
import 'dart:typed_data';

import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:meta/meta.dart';

import '../domain/csv_writer.dart';
import 'backup_file_store.dart';

/// The two spreadsheets the app can export.
enum CsvExportKind { stockContents, history }

/// Column headers and names in the app's language; amounts and dates stay
/// machine-readable (decimal point, ISO 8601) so spreadsheets can compute
/// with them.
@immutable
final class CsvExportTexts {
  const CsvExportTexts({
    required this.contentsHeader,
    required this.historyHeader,
    required this.catalogNames,
    required this.layoutDefaultNames,
    required this.movementKindName,
    required this.discardReasonName,
    required this.unitSymbol,
  });

  /// Product, category, amount, unit, frozen on, drawer, note.
  final List<String> contentsHeader;

  /// Time, what happened, product, amount, unit, drawer, reason.
  final List<String> historyHeader;
  final CatalogNames catalogNames;
  final LayoutDefaultNames layoutDefaultNames;
  final String Function(MovementKind kind) movementKindName;
  final String Function(DiscardReason reason) discardReasonName;
  final String Function(QuantityUnit unit) unitSymbol;
}

/// Exports what is in the freezer, or the whole history, as CSV.
final class CsvExportUseCase {
  const CsvExportUseCase({
    required InventoryQueryService inventory,
    required ProductCatalogQueryService productCatalog,
    required StorageLayoutQueryService storageLayout,
    required BackupFileStore fileStore,
    required Clock clock,
  }) : _inventory = inventory,
       _productCatalog = productCatalog,
       _storageLayout = storageLayout,
       _fileStore = fileStore,
       _clock = clock;

  final InventoryQueryService _inventory;
  final ProductCatalogQueryService _productCatalog;
  final StorageLayoutQueryService _storageLayout;
  final BackupFileStore _fileStore;
  final Clock _clock;

  /// Returns whether the file was saved (`false` when cancelled).
  Future<bool> execute(CsvExportKind kind, CsvExportTexts texts) async {
    final csvText = await buildCsv(kind, texts);
    final dateText = CalendarDate.fromDateTime(_clock.nowLocal()).toIso8601String();
    final fileName = switch (kind) {
      CsvExportKind.stockContents => 'freezer-contents-$dateText.csv',
      CsvExportKind.history => 'freezer-history-$dateText.csv',
    };
    return _fileStore.saveFile(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(csvText)),
      mimeType: 'text/csv',
    );
  }

  @visibleForTesting
  Future<String> buildCsv(CsvExportKind kind, CsvExportTexts texts) async {
    final catalog = await _productCatalog.readCatalog();
    final layout = await _storageLayout.readStorageLayout();
    final productNames = ProductDisplayNameResolver(texts.catalogNames);
    final compartmentNames = CompartmentDisplayNameResolver(
      layout: layout,
      defaultNames: texts.layoutDefaultNames,
    );
    String productNameOf(ProductIdentifier productIdentifier) =>
        switch (catalog.productOf(productIdentifier)) {
          final product? => productNames.productName(product),
          null => '',
        };

    return switch (kind) {
      CsvExportKind.stockContents => CsvWriter.write(texts.contentsHeader, [
        for (final batch in await _inventory.readActiveBatches())
          [
            productNameOf(batch.productIdentifier),
            switch (catalog.productOf(batch.productIdentifier)) {
              final product? => switch (catalog.categoryOfProduct(product)) {
                final category? => productNames.categoryName(category),
                null => '',
              },
              null => '',
            },
            _amount(batch.quantityRemaining),
            texts.unitSymbol(batch.unit),
            batch.storedOn.toIso8601String(),
            compartmentNames.compartmentNameOf(batch.compartmentIdentifier),
            batch.note ?? '',
          ],
      ]),
      CsvExportKind.history => CsvWriter.write(texts.historyHeader, [
        for (final movement in await _inventory.readMovementHistory())
          [
            movement.occurredAt.toLocal().toIso8601String(),
            texts.movementKindName(movement.kind),
            productNameOf(movement.productIdentifier),
            _amount(movement.quantityDelta),
            texts.unitSymbol(movement.quantityDelta.unit),
            compartmentNames.compartmentNameOf(movement.compartmentIdentifier),
            switch (movement.discardReason) {
              final discardReason? => texts.discardReasonName(discardReason),
              null => '',
            },
          ],
      ]),
    };
  }

  /// "500", "0.5" or "-1.25": a plain decimal number in display units.
  static String _amount(Quantity quantity) {
    final displayAmount = quantity.displayAmount;
    return displayAmount == displayAmount.roundToDouble()
        ? displayAmount.round().toString()
        : displayAmount.toString();
  }
}
