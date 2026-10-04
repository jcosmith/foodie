import 'package:core_database/core_database.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter_riverpod/misc.dart';

import 'application/receipt_scanning_providers.dart';
import 'data/drift_receipt_repository.dart';

/// Receipt scanning (architecture document, section 10.10): on-device text
/// recognition, matching receipt lines to products with what was learned
/// per store, and a searchable receipt archive. Optional and off until the
/// user turns it on; the inventory never imports this package.
final class ReceiptScanningFeatureModule extends FeatureModuleBase {
  const ReceiptScanningFeatureModule();

  static const String identifier = 'receipts';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    receiptRepositoryProvider.overrideWith(
      (ref) => DriftReceiptRepository(
        receiptScanningDao: ref.watch(applicationDatabaseProvider).receiptScanningDao,
        transactionRunner: ref.watch(transactionRunnerProvider),
      ),
    ),
  ];

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: false);
}
