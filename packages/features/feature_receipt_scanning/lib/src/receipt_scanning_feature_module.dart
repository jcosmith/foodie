import 'package:core_database/core_database.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'application/receipt_capture.dart';
import 'application/receipt_scanning_providers.dart';
import 'data/drift_receipt_repository.dart';
import 'data/image_picker_receipt_photo_source.dart';
import 'data/ml_kit_receipt_text_recognizer.dart';
import 'l10n/generated/receipt_scanning_localizations.dart';
import 'presentation/receipt_scanning_routes.dart';
import 'presentation/receipts_segment.dart';

/// Receipt scanning (architecture document, section 10.10): on-device text
/// recognition, matching receipt lines to products with what was learned
/// per store, and a searchable receipt archive. Optional and off until the
/// user turns it on, because it uses the camera; the inventory never
/// imports this package.
final class ReceiptScanningFeatureModule extends FeatureModuleBase {
  const ReceiptScanningFeatureModule({this.photoSourceOverride, this.textRecognizerOverride});

  static const String identifier = 'receipts';

  /// Replace the camera and text recognition, for tests.
  final ReceiptPhotoSource? photoSourceOverride;
  final ReceiptTextRecognizer? textRecognizerOverride;

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    ReceiptScanningLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    receiptRepositoryProvider.overrideWith(
      (ref) => DriftReceiptRepository(
        receiptScanningDao: ref.watch(applicationDatabaseProvider).receiptScanningDao,
        transactionRunner: ref.watch(transactionRunnerProvider),
      ),
    ),
    receiptPhotoSourceProvider.overrideWith(
      (ref) => photoSourceOverride ?? ImagePickerReceiptPhotoSource(),
    ),
    receiptTextRecognizerProvider.overrideWith(
      (ref) => textRecognizerOverride ?? const MlKitReceiptTextRecognizer(),
    ),
  ];

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: false);

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => ReceiptScanningLocalizations.of(context).optionalFeatureTitle,
    detailBuilder: (context) => ReceiptScanningLocalizations.of(context).optionalFeatureDetail,
  );

  @override
  List<RouteBase> buildRoutes() => buildReceiptScanningRoutes();

  /// After the inventory's "Add item" (10) and barcode scanning (20, 30).
  @override
  List<QuickActionContribution> get quickActions => [
    QuickActionContribution(
      identifier: '$identifier.scan',
      sortOrder: 40,
      icon: Icons.receipt_long_outlined,
      labelBuilder: (context) => ReceiptScanningLocalizations.of(context).quickActionScanReceipt,
      onSelected: (context) => context.push(ReceiptScanningRoutes.scan),
    ),
  ];

  /// Next to the shopping list (10).
  @override
  List<ListsSegmentContribution> get listsSegments => [
    ListsSegmentContribution(
      identifier: '$identifier.archive',
      sortOrder: 20,
      labelBuilder: (context) => ReceiptScanningLocalizations.of(context).segmentTitle,
      subtitleBuilder: (context) => ReceiptScanningLocalizations.of(context).segmentSubtitle,
      builder: (context) => const ReceiptsSegment(),
    ),
  ];

  /// Removes page images no receipt refers to: those of a scan the app was
  /// closed in the middle of, or left by a deletion that was cut short.
  @override
  Future<void> initializeModule(ModuleInitializationContext context) async {
    final references = await context.read(receiptRepositoryProvider).readPictureReferences();
    await context.read(receiptPageImagesProvider).sweep(references);
  }
}
