import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/barcode_decoder.dart';
import '../application/barcode_scanning_providers.dart';
import '../application/barcode_use_cases.dart';
import '../domain/scanned_barcode.dart';
import '../l10n/generated/barcode_scanning_localizations.dart';
import 'barcode_scanning_routes.dart';
import 'scan_result_panels.dart';
import 'unpacking_list_card.dart';

/// One screen with an Add / Remove switch (UI examples document, phone 4):
/// the camera picture, and below it what the last code turned out to be.
/// "Several in a row" collects scanned groceries in a review list instead
/// and puts them all into the freezer at once (section 10.3).
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({required this.initialMode, super.key});

  final ScanMode initialMode;

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  late ScanMode _mode = widget.initialMode;

  /// The code on screen; new codes are ignored until the user moves on.
  BarcodeResolution? _resolution;
  bool _isCodeJustLearned = false;
  bool _isResolving = false;

  /// The continuous mode for unpacking groceries, and what it collected.
  bool _isScanningSeveral = false;
  final List<ScanToAddSuggestion> _unpackingList = [];
  bool _isPuttingAway = false;

  /// When each code was last in front of the camera. A code held in view is
  /// added once; taking it away for a moment and showing it again adds the
  /// next package.
  final Map<String, DateTime> _lastSightingByCode = {};
  static const Duration _sameCodeQuietPeriod = Duration(seconds: 2);

  bool get _collectsIntoList => _isScanningSeveral && _mode == ScanMode.add;

  Future<void> _handleBarcodeDetected(ScannedBarcode scannedBarcode) async {
    if (_collectsIntoList && _isRepeatedSighting(scannedBarcode.value)) return;
    if (_resolution != null || _isResolving) return;
    _isResolving = true;
    final resolution = await ref.read(resolveBarcodeUseCaseProvider).execute(scannedBarcode);
    if (_collectsIntoList && resolution is RecognizedBarcode) {
      await _addToUnpackingList(resolution);
      _isResolving = false;
      return;
    }
    _isResolving = false;
    if (!mounted) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _resolution = resolution;
      _isCodeJustLearned = false;
    });
  }

  bool _isRepeatedSighting(String code) {
    final now = ref.read(clockProvider).nowUtc();
    final lastSighting = _lastSightingByCode[code];
    _lastSightingByCode[code] = now;
    return lastSighting != null && now.difference(lastSighting) < _sameCodeQuietPeriod;
  }

  Future<void> _addToUnpackingList(RecognizedBarcode recognizedBarcode) async {
    final suggestion = await ref.read(scanToAddUseCaseProvider).suggest(recognizedBarcode);
    if (!mounted) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() => _unpackingList.add(suggestion));
  }

  Future<void> _showLearnedProduct(RecognizedBarcode recognizedBarcode) async {
    if (_collectsIntoList) {
      await _addToUnpackingList(recognizedBarcode);
      _scanNext();
      return;
    }
    setState(() {
      _resolution = recognizedBarcode;
      _isCodeJustLearned = true;
    });
  }

  void _scanNext() {
    if (mounted) setState(() => _resolution = null);
  }

  Future<void> _putAway() async {
    final localizations = BarcodeScanningLocalizations.of(context);
    final inventoryLocalizations = InventoryLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final entries = List.of(_unpackingList);
    setState(() => _isPuttingAway = true);
    final result = await ref.read(scanToAddUseCaseProvider).addAll(entries);
    if (!mounted) return;
    setState(() {
      _isPuttingAway = false;
      if (result.isSuccess) _unpackingList.clear();
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          SuccessfulResult(value: final stockBatchIdentifiers) => localizations.putAwaySnackbar(
            stockBatchIdentifiers.length,
          ),
          FailedResult(:final failure) => inventoryLocalizations.describeFailure(failure),
        }),
      ),
    );
  }

  /// Leaving with scanned items that are not in the freezer yet asks first.
  Future<void> _confirmLeavingWithUnpackingList() async {
    final localizations = BarcodeScanningLocalizations.of(context);
    final navigator = Navigator.of(context);
    final isDiscarded = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.discardListTitle),
        content: Text(localizations.discardListMessage(_unpackingList.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.commonLocalizations.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.discardButton),
          ),
        ],
      ),
    );
    if (isDiscarded != true || !mounted) return;
    setState(_unpackingList.clear);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = BarcodeScanningLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolution = _resolution;
    return PopScope(
      canPop: _unpackingList.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_confirmLeavingWithUnpackingList());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.scannerTitle)),
        body: ListView(
          padding: const EdgeInsets.all(FreezerSpacing.screenGutter),
          children: [
            SegmentedButton<ScanMode>(
              segments: [
                ButtonSegment(
                  value: ScanMode.add,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.scanModeAdd),
                ),
                ButtonSegment(
                  value: ScanMode.remove,
                  icon: const Icon(Icons.remove),
                  label: Text(localizations.scanModeRemove),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (modes) => setState(() => _mode = modes.single),
            ),
            if (_mode == ScanMode.add) ...[
              const SizedBox(height: FreezerSpacing.small),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilterChip(
                  avatar: const Icon(Icons.playlist_add),
                  label: Text(localizations.scanSeveral),
                  selected: _isScanningSeveral,
                  onSelected: (isScanningSeveral) => setState(() {
                    _isScanningSeveral = isScanningSeveral;
                    if (isScanningSeveral && _resolution is RecognizedBarcode) _resolution = null;
                  }),
                ),
              ),
            ],
            const SizedBox(height: FreezerSpacing.medium),
            _CameraFrame(
              camera: ref
                  .read(barcodeDecoderProvider)
                  .buildCameraView(
                    context,
                    onBarcodeDetected: _handleBarcodeDetected,
                    problemBuilder: (context, problem) => _CameraProblemView(problem: problem),
                  ),
            ),
            const SizedBox(height: FreezerSpacing.small),
            Text(
              localizations.scannerHint,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (_collectsIntoList) ...[
              const SizedBox(height: FreezerSpacing.medium),
              UnpackingListCard(
                entries: _unpackingList,
                isPuttingAway: _isPuttingAway,
                onQuantityChanged: (index, quantity) => setState(
                  () => _unpackingList[index] = _unpackingList[index].withQuantity(quantity),
                ),
                onRemoved: (index) => setState(() => _unpackingList.removeAt(index)),
                onPutAway: _putAway,
              ),
            ],
            if (resolution != null) ...[
              const SizedBox(height: FreezerSpacing.medium),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(FreezerSpacing.medium),
                  child: switch (resolution) {
                    UnrecognizedBarcode() => UnknownCodePanel(
                      unrecognizedBarcode: resolution,
                      onLearned: _showLearnedProduct,
                      onScanNext: _scanNext,
                    ),
                    RecognizedBarcode() when _mode == ScanMode.add => ScanToAddPanel(
                      key: ValueKey(('add', resolution.barcode.scannedValue, resolution.product)),
                      recognizedBarcode: resolution,
                      isCodeJustLearned: _isCodeJustLearned,
                      onLearned: _showLearnedProduct,
                      onDone: _scanNext,
                    ),
                    RecognizedBarcode() => ScanToRemovePanel(
                      recognizedBarcode: resolution,
                      isCodeJustLearned: _isCodeJustLearned,
                      onLearned: _showLearnedProduct,
                      onDone: _scanNext,
                    ),
                  },
                ),
              ),
            ],
            const SizedBox(height: FreezerSpacing.medium),
            Text(
              localizations.scannerPrivacy,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// The camera picture with frame corners to aim with.
class _CameraFrame extends StatelessWidget {
  const _CameraFrame({required this.camera});

  final Widget camera;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF0B0F15)),
          camera,
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 3),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CameraProblemView extends StatelessWidget {
  const _CameraProblemView({required this.problem});

  final CameraProblem problem;

  @override
  Widget build(BuildContext context) {
    final localizations = BarcodeScanningLocalizations.of(context);
    return ColoredBox(
      color: const Color(0xFF0B0F15),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(FreezerSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 36),
              const SizedBox(height: FreezerSpacing.small),
              Text(
                switch (problem) {
                  CameraProblem.permissionDenied => localizations.cameraPermissionDenied,
                  CameraProblem.unavailable => localizations.cameraUnavailable,
                },
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
