import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/receipt_capture.dart';
import '../application/receipt_review.dart';
import '../application/receipt_scanning_providers.dart';
import '../application/receipt_use_cases.dart';
import '../domain/receipt_line_matcher.dart';
import '../l10n/generated/receipt_scanning_localizations.dart';
import 'receipt_review_list.dart';
import 'receipt_scanning_routes.dart';
import 'receipt_texts.dart';

/// "Scan receipt" (architecture 10.10, steps 1 to 6): photograph the pages,
/// read them on the phone, review the lines, add the ticked ones.
class ReceiptScanScreen extends ConsumerStatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  ConsumerState<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends ConsumerState<ReceiptScanScreen> {
  late final DiscardReceiptScanUseCase _discardScan;
  final List<RecognizedReceiptPage> _pages = [];
  ReceiptReviewDraft? _draft;
  bool _isBusy = false;
  bool _isArchived = false;
  String? _problem;

  @override
  void initState() {
    super.initState();
    _discardScan = ref.read(discardReceiptScanUseCaseProvider);
  }

  @override
  void dispose() {
    // Leaving without confirming keeps nothing: the page images go.
    if (!_isArchived) unawaited(_discardScan.execute(List.of(_pages)));
    super.dispose();
  }

  Future<void> _addPage(Future<ReceiptPhoto?> Function() takePhoto) async {
    setState(() {
      _isBusy = true;
      _problem = null;
    });
    final localizations = ReceiptScanningLocalizations.of(context);
    final photo = await takePhoto();
    if (photo == null) {
      if (mounted) setState(() => _isBusy = false);
      return;
    }
    final result = await ref.read(readReceiptPageUseCaseProvider).execute(photo);
    if (!mounted) {
      if (result case SuccessfulResult(value: final page)) unawaited(_discardScan.execute([page]));
      return;
    }
    setState(() {
      _isBusy = false;
      switch (result) {
        case SuccessfulResult(value: final page):
          _pages.add(page);
        case FailedResult(:final failure):
          _problem = localizations.describeFailure(failure);
      }
    });
  }

  Future<void> _readReceipt() async {
    setState(() => _isBusy = true);
    final review = await ref
        .read(prepareReceiptReviewUseCaseProvider)
        .execute(pages: List.of(_pages), names: context.productDisplayNameResolver);
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      _draft = ReceiptReviewDraft(review);
    });
  }

  Future<void> _confirm(ReceiptReviewDraft draft) async {
    final localizations = ReceiptScanningLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _isBusy = true);
    final result = await ref
        .read(confirmReceiptUseCaseProvider)
        .execute(draft.review, decisions: draft.decisions);
    if (!mounted) return;
    switch (result) {
      case SuccessfulResult(value: final receiptIdentifier):
        _isArchived = true;
        messenger.showSnackBar(
          SnackBar(content: Text(localizations.addedItems(draft.tickedCount))),
        );
        unawaited(router.pushReplacement(ReceiptScanningRoutes.receipt(receiptIdentifier)));
      case FailedResult(:final failure):
        setState(() => _isBusy = false);
        messenger.showSnackBar(
          SnackBar(content: Text(InventoryLocalizations.of(context).describeFailure(failure))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final draft = _draft;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          draft == null
              ? localizations.scanTitle
              : draft.review.storeName ?? localizations.unknownStore,
        ),
      ),
      body: _isBusy
          ? const Center(child: CircularProgressIndicator())
          : draft == null
          ? _CapturePanel(
              pageCount: _pages.length,
              problem: _problem,
              onTakePhoto: () => _addPage(ref.read(receiptPhotoSourceProvider).takePhoto),
              onPickFromGallery: () =>
                  _addPage(ref.read(receiptPhotoSourceProvider).pickFromGallery),
              onReadReceipt: _readReceipt,
            )
          : ReceiptReviewList(
              draft: draft,
              onChanged: () => setState(() {}),
              onConfirm: () => _confirm(draft),
            ),
    );
  }
}

class _CapturePanel extends StatelessWidget {
  const _CapturePanel({
    required this.pageCount,
    required this.problem,
    required this.onTakePhoto,
    required this.onPickFromGallery,
    required this.onReadReceipt,
  });

  final int pageCount;
  final String? problem;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onReadReceipt;

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.foodieColors;
    final hasPages = pageCount > 0;
    return ListView(
      padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
      children: [
        Icon(Icons.receipt_long_outlined, size: 72, color: theme.colorScheme.primary),
        const SizedBox(height: FoodieSpacing.large),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 16, color: colors.textMuted),
            const SizedBox(width: FoodieSpacing.extraSmall),
            Flexible(
              child: Text(
                localizations.scanPrivacy,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: FoodieSpacing.medium),
        Text(localizations.scanHint, textAlign: TextAlign.center),
        if (hasPages) ...[
          const SizedBox(height: FoodieSpacing.large),
          Text(
            localizations.pageCount(pageCount),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ],
        if (problem case final problem?) ...[
          const SizedBox(height: FoodieSpacing.large),
          Text(
            problem,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: FoodieSpacing.extraLarge),
        if (hasPages)
          FilledButton.tonalIcon(
            onPressed: onTakePhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(localizations.takePhoto),
          )
        else
          FilledButton.icon(
            onPressed: onTakePhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(localizations.takePhoto),
          ),
        const SizedBox(height: FoodieSpacing.small),
        OutlinedButton.icon(
          onPressed: onPickFromGallery,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(localizations.pickFromGallery),
        ),
        if (hasPages) ...[
          const SizedBox(height: FoodieSpacing.large),
          FilledButton.icon(
            onPressed: onReadReceipt,
            icon: const Icon(Icons.document_scanner_outlined),
            label: Text(localizations.readReceipt),
          ),
        ],
      ],
    );
  }
}

/// The user's choices on the review list, line by line.
final class ReceiptReviewDraft {
  ReceiptReviewDraft(this.review)
    : _lines = {for (final line in review.lines) line.position: line},
      _ticked = {
        for (final line in review.lines)
          if (line.status == ReceiptLineStatus.matched && line.canAddAsSuggested) line.position,
      };

  final ReceiptReview review;
  final Map<int, ReceiptReviewLine> _lines;
  final Set<int> _ticked;

  /// Lines the user ignored, and whether to remember that for the store.
  final Map<int, bool> _ignored = {};

  ReceiptReviewLine lineAt(int position) => _lines[position]!;

  Iterable<ReceiptReviewLine> get _all => review.lines.map((line) => _lines[line.position]!);

  /// Unrecognised and suggested lines the user has not answered yet.
  List<ReceiptReviewLine> get flaggedLines => [
    for (final line in _all)
      if ((line.status == ReceiptLineStatus.unrecognised ||
              line.status == ReceiptLineStatus.suggested) &&
          !_ignored.containsKey(line.position))
        line,
  ];

  List<ReceiptReviewLine> get recognisedLines => [
    for (final line in _all)
      if (line.status == ReceiptLineStatus.matched && !_ignored.containsKey(line.position)) line,
  ];

  List<ReceiptReviewLine> get notAddedLines => [
    for (final line in _all)
      if (line.status == ReceiptLineStatus.ignored || _ignored.containsKey(line.position)) line,
  ];

  bool isTicked(ReceiptReviewLine line) => _ticked.contains(line.position);

  /// Ignored by the user on this screen, so it can be undone.
  bool isIgnoredByUser(ReceiptReviewLine line) => _ignored.containsKey(line.position);

  int get tickedCount => _ticked.length;

  void setTicked(ReceiptReviewLine line, {required bool ticked}) {
    if (ticked && _lines[line.position]!.canAddAsSuggested) {
      _ticked.add(line.position);
    } else {
      _ticked.remove(line.position);
    }
  }

  /// A confirmed suggestion, a picked product or changed details.
  void replace(ReceiptReviewLine line) {
    _lines[line.position] = line;
    _ignored.remove(line.position);
    setTicked(line, ticked: line.status == ReceiptLineStatus.matched);
  }

  void ignore(ReceiptReviewLine line, {required bool remember}) {
    _ignored[line.position] = remember;
    _ticked.remove(line.position);
  }

  void undoIgnore(ReceiptReviewLine line) {
    _ignored.remove(line.position);
    setTicked(line, ticked: _lines[line.position]!.status == ReceiptLineStatus.matched);
  }

  /// Ticked lines are added, ignored ones ignored; the rest stay open.
  Map<int, ReceiptLineDecision> get decisions => {
    for (final position in _ticked) position: AddReceiptLine.suggested(_lines[position]!),
    for (final MapEntry(key: position, value: remember) in _ignored.entries)
      position: IgnoreReceiptLine(remember: remember),
  };
}

/// A small helper so lists can name a product and its amount.
String describeSuggestion(BuildContext context, ReceiptReviewLine line) {
  final product = line.product;
  if (product == null) return line.text;
  final name = context.productDisplayNameResolver.productName(product);
  final quantity = line.quantity;
  return quantity == null ? name : '$name · ${context.quantityFormatter.format(quantity)}';
}
