import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
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

/// The amount filter of the archive.
enum _AmountFilter {
  any(null, null),
  upTo20(null, 2000),
  over20(2000, null),
  over50(5000, null);

  const _AmountFilter(this.overCents, this.upToCents);

  final int? overCents;
  final int? upToCents;

  bool accepts(int? totalInCents) {
    if (this == any) return true;
    if (totalInCents == null) return false;
    return (overCents == null || totalInCents > overCents!) &&
        (upToCents == null || totalInCents <= upToCents!);
  }
}

class _ReceiptsSegmentState extends ConsumerState<ReceiptsSegment> {
  static const List<int> _periodMonths = [1, 3, 12];

  final TextEditingController _query = TextEditingController();
  Future<List<ReceiptSearchHit>>? _hits;
  String? _store;
  int? _months;
  _AmountFilter _amount = _AmountFilter.any;

  /// Store, period and amount filters (UI examples, phone 15).
  List<(ReceiptSummary, ReceiptLine?)> _filtered(List<(ReceiptSummary, ReceiptLine?)> entries) {
    final now = ref.read(clockProvider).nowUtc();
    final months = _months;
    final since = months == null ? null : DateTime.utc(now.year, now.month - months, now.day);
    return [
      for (final entry in entries)
        if ((_store == null || entry.$1.storeName == _store) &&
            (since == null || !_dateOf(entry.$1).isBefore(since)) &&
            _amount.accepts(entry.$1.totalInCents))
          entry,
    ];
  }

  static DateTime _dateOf(ReceiptSummary receipt) => switch (receipt.purchasedOn) {
    final purchasedOn? => DateTime.utc(purchasedOn.year, purchasedOn.month, purchasedOn.day),
    null => receipt.createdAt,
  };

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search(String query) => setState(() {
    _hits = query.trim().isEmpty ? null : ref.read(receiptQueryServiceProvider).search(query);
  });

  Widget _listOrEmpty(
    ReceiptScanningLocalizations localizations,
    List<(ReceiptSummary, ReceiptLine?)> entries,
  ) => entries.isEmpty
      ? EmptyStateView(icon: Icons.filter_alt_off_outlined, title: localizations.noFilteredReceipts)
      : _ReceiptList(entries: entries);

  Widget _filterRow(BuildContext context, List<ReceiptSummary> summaries) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final stores = {for (final receipt in summaries) ?receipt.storeName}.toList()..sort();
    String amountLabel(_AmountFilter filter) => switch (filter) {
      _AmountFilter.any => localizations.filterAnyAmount,
      _AmountFilter(upToCents: final upTo?) => localizations.filterUpTo(formatCents(context, upTo)),
      _AmountFilter(overCents: final over?) => localizations.filterOver(formatCents(context, over)),
      _ => localizations.filterAnyAmount,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.screenGutter),
      child: Row(
        children: [
          _FilterMenu<String?>(
            label: _store ?? localizations.filterAllStores,
            isActive: _store != null,
            options: [
              (null, localizations.filterAllStores),
              for (final store in stores) (store, store),
            ],
            onSelected: (store) => setState(() => _store = store),
          ),
          const SizedBox(width: FoodieSpacing.small),
          _FilterMenu<int?>(
            label: switch (_months) {
              null => localizations.filterAnyTime,
              final months => localizations.filterLastMonths(months),
            },
            isActive: _months != null,
            options: [
              (null, localizations.filterAnyTime),
              for (final months in _periodMonths) (months, localizations.filterLastMonths(months)),
            ],
            onSelected: (months) => setState(() => _months = months),
          ),
          const SizedBox(width: FoodieSpacing.small),
          _FilterMenu<_AmountFilter>(
            label: amountLabel(_amount),
            isActive: _amount != _AmountFilter.any,
            options: [for (final filter in _AmountFilter.values) (filter, amountLabel(filter))],
            onSelected: (filter) => setState(() => _amount = filter),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final hits = _hits;
    final summaries = ref.watch(receiptSummariesProvider).value ?? const <ReceiptSummary>[];
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
        if (summaries.isNotEmpty) _filterRow(context, summaries),
        Expanded(
          child: hits == null
              ? switch (ref.watch(receiptSummariesProvider)) {
                  AsyncData(value: final receipts) when receipts.isEmpty => EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: localizations.noReceipts,
                  ),
                  AsyncData(value: final receipts) => _listOrEmpty(
                    localizations,
                    _filtered([for (final receipt in receipts) (receipt, null)]),
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
                    final hits => _listOrEmpty(
                      localizations,
                      _filtered([for (final hit in hits) (hit.receipt, hit.matchingLine)]),
                    ),
                  },
                ),
        ),
      ],
    );
  }
}

/// A chip that opens a menu of choices.
class _FilterMenu<TValue> extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.isActive,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final bool isActive;
  final List<(TValue, String)> options;
  final ValueChanged<TValue> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Options by index: a null value would read as a cancelled menu.
    return PopupMenuButton<int>(
      tooltip: '',
      onSelected: (index) => onSelected(options[index].$1),
      itemBuilder: (context) => [
        for (final (index, (_, text)) in options.indexed)
          PopupMenuItem(value: index, child: Text(text)),
      ],
      child: Chip(
        backgroundColor: isActive ? colorScheme.secondaryContainer : null,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text(label), const Icon(Icons.arrow_drop_down, size: 18)],
        ),
      ),
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
