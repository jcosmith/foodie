import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/receipt_scanning_providers.dart';
import '../domain/receipt.dart';
import '../l10n/generated/receipt_scanning_localizations.dart';
import 'receipt_scanning_routes.dart';
import 'receipt_texts.dart';

/// The "Receipts" segment of the Lists tab (UI examples, phone 15): the
/// archive, newest first, and a full-text search over every line.
class ReceiptsSegment extends ConsumerStatefulWidget {
  const ReceiptsSegment({super.key});

  @override
  ConsumerState<ReceiptsSegment> createState() => _ReceiptsSegmentState();
}

class _ReceiptsSegmentState extends ConsumerState<ReceiptsSegment> {
  final TextEditingController _query = TextEditingController();
  Future<List<ReceiptSearchHit>>? _hits;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search(String query) => setState(() {
    _hits = query.trim().isEmpty ? null : ref.read(receiptQueryServiceProvider).search(query);
  });

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final hits = _hits;
    // Searching again when the archive changes, such as after a deletion.
    ref.listen(receiptSummariesProvider, (_, _) {
      if (_hits != null) _search(_query.text);
    });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FoodieSpacing.screenGutter,
            FoodieSpacing.small,
            FoodieSpacing.screenGutter,
            FoodieSpacing.small,
          ),
          child: TextField(
            controller: _query,
            onChanged: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: localizations.searchHint,
              suffixIcon: _query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: context.commonLocalizations.actionClose,
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _query.clear();
                        _search('');
                      },
                    ),
            ),
          ),
        ),
        Expanded(
          child: hits == null
              ? switch (ref.watch(receiptSummariesProvider)) {
                  AsyncData(value: final receipts) when receipts.isEmpty => EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: localizations.noReceipts,
                  ),
                  AsyncData(value: final receipts) => _ReceiptList(
                    entries: [for (final receipt in receipts) (receipt, null)],
                  ),
                  AsyncError(:final error) => Center(child: Text('$error')),
                  _ => const Center(child: CircularProgressIndicator()),
                }
              : FutureBuilder(
                  future: hits,
                  builder: (context, snapshot) => switch (snapshot.data) {
                    null => const Center(child: CircularProgressIndicator()),
                    final hits when hits.isEmpty => EmptyStateView(
                      icon: Icons.search_off,
                      title: localizations.noSearchHits,
                    ),
                    final hits => _ReceiptList(
                      entries: [for (final hit in hits) (hit.receipt, hit.matchingLine)],
                    ),
                  },
                ),
        ),
      ],
    );
  }
}

class _ReceiptList extends StatelessWidget {
  const _ReceiptList({required this.entries});

  /// Each receipt with the line a search found in it.
  final List<(ReceiptSummary, ReceiptLine?)> entries;

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final colors = context.foodieColors;
    final dates = context.dateDisplayFormatter;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.screenGutter),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final (receipt, line) = entries[index];
        final title = [
          receipt.storeName ?? localizations.unknownStore,
          dates.formatShortDate(
            receipt.purchasedOn ?? CalendarDate.fromDateTime(receipt.createdAt.toLocal()),
          ),
        ].join(' · ');
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Text('🧾', style: TextStyle(fontSize: 24)),
          title: Text(title),
          subtitle: line == null
              ? null
              : Text(
                  localizations.lineWithPrice(
                    line.text,
                    formatCents(context, line.lineTotalInCents),
                  ),
                  style: receiptTextStyle(context).copyWith(fontSize: 12),
                ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (receipt.totalInCents case final total?) Text(formatCents(context, total)),
              if (receipt.openLineCount > 0)
                Text(
                  localizations.openBadge(receipt.openLineCount),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: colors.statusAging),
                ),
            ],
          ),
          onTap: () => context.push(
            ReceiptScanningRoutes.receipt(receipt.identifier, highlightedLine: line?.identifier),
          ),
        );
      },
    );
  }
}
