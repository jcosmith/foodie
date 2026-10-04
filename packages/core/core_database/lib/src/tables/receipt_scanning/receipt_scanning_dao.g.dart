// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_scanning_dao.dart';

// ignore_for_file: type=lint
mixin _$ReceiptScanningDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  ReceiptSearchIndex get receiptSearchIndex =>
      attachedDatabase.receiptSearchIndex;
  $ReceiptsTable get receipts => attachedDatabase.receipts;
  $ReceiptPagesTable get receiptPages => attachedDatabase.receiptPages;
  $CategoriesTable get categories => attachedDatabase.categories;
  $StoragePlacesTable get storagePlaces => attachedDatabase.storagePlaces;
  $CompartmentsTable get compartments => attachedDatabase.compartments;
  $ProductsTable get products => attachedDatabase.products;
  $StockBatchesTable get stockBatches => attachedDatabase.stockBatches;
  $ReceiptLinesTable get receiptLines => attachedDatabase.receiptLines;
  $ReceiptTextMappingsTable get receiptTextMappings =>
      attachedDatabase.receiptTextMappings;
  ReceiptScanningDaoManager get managers => ReceiptScanningDaoManager(this);
}

class ReceiptScanningDaoManager {
  final _$ReceiptScanningDaoMixin _db;
  ReceiptScanningDaoManager(this._db);
  $ReceiptSearchIndexTableManager get receiptSearchIndex =>
      $ReceiptSearchIndexTableManager(
        _db.attachedDatabase,
        _db.receiptSearchIndex,
      );
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db.attachedDatabase, _db.receipts);
  $$ReceiptPagesTableTableManager get receiptPages =>
      $$ReceiptPagesTableTableManager(_db.attachedDatabase, _db.receiptPages);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$StoragePlacesTableTableManager get storagePlaces =>
      $$StoragePlacesTableTableManager(_db.attachedDatabase, _db.storagePlaces);
  $$CompartmentsTableTableManager get compartments =>
      $$CompartmentsTableTableManager(_db.attachedDatabase, _db.compartments);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$StockBatchesTableTableManager get stockBatches =>
      $$StockBatchesTableTableManager(_db.attachedDatabase, _db.stockBatches);
  $$ReceiptLinesTableTableManager get receiptLines =>
      $$ReceiptLinesTableTableManager(_db.attachedDatabase, _db.receiptLines);
  $$ReceiptTextMappingsTableTableManager get receiptTextMappings =>
      $$ReceiptTextMappingsTableTableManager(
        _db.attachedDatabase,
        _db.receiptTextMappings,
      );
}
