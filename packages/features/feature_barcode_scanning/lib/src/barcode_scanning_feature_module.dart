import 'package:core_database/core_database.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'application/barcode_decoder.dart';
import 'application/barcode_scanning_providers.dart';
import 'data/drift_product_barcode_repository.dart';
import 'data/mobile_scanner_barcode_decoder.dart';
import 'l10n/generated/barcode_scanning_localizations.dart';
import 'presentation/barcode_scanning_routes.dart';

/// Barcode scanning (build order phase 7, architecture document section
/// 10.3): on-device decoding, learning which code belongs to which product,
/// scan to add and scan to remove. Optional and off until the user turns it
/// on in Config; the inventory never imports this package.
final class BarcodeScanningFeatureModule extends FeatureModuleBase {
  const BarcodeScanningFeatureModule({this.barcodeDecoderOverride});

  static const String identifier = 'barcode_scanning';

  /// Replaces the camera, for tests.
  final BarcodeDecoder? barcodeDecoderOverride;

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    BarcodeScanningLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    productBarcodeRepositoryProvider.overrideWith(
      (ref) => DriftProductBarcodeRepository(
        productBarcodesDao: ref.watch(applicationDatabaseProvider).productBarcodesDao,
      ),
    ),
    barcodeDecoderProvider.overrideWith(
      (ref) => barcodeDecoderOverride ?? const MobileScannerBarcodeDecoder(),
    ),
  ];

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: false);

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => BarcodeScanningLocalizations.of(context).optionalFeatureTitle,
    detailBuilder: (context) => BarcodeScanningLocalizations.of(context).optionalFeatureDetail,
  );

  @override
  List<RouteBase> buildRoutes() => buildBarcodeScanningRoutes();

  /// "Scan to add" and "Scan to remove" in the floating add menu, after the
  /// inventory's own "Add to freezer" (10).
  @override
  List<QuickActionContribution> get quickActions => [
    QuickActionContribution(
      identifier: '$identifier.scan_to_add',
      sortOrder: 20,
      icon: Icons.qr_code_scanner,
      labelBuilder: (context) => BarcodeScanningLocalizations.of(context).quickActionScanToAdd,
      onSelected: (context) => context.push(BarcodeScanningRoutes.scanner(ScanMode.add)),
    ),
    QuickActionContribution(
      identifier: '$identifier.scan_to_remove',
      sortOrder: 30,
      icon: Icons.outbox_outlined,
      labelBuilder: (context) => BarcodeScanningLocalizations.of(context).quickActionScanToRemove,
      onSelected: (context) => context.push(BarcodeScanningRoutes.scanner(ScanMode.remove)),
    ),
  ];
}
