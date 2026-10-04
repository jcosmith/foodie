import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/inventory_overview.dart';
import '../application/inventory_providers.dart';
import '../l10n/generated/inventory_localizations.dart';
import 'inventory_routes.dart';
import 'stock_batch_sheets.dart';
import 'stock_item_tile.dart';

/// How the overview lists the batches.
enum InventoryListOrder { byCompartment, eatFirst }

/// The stock screen every domain tab mounts with its own domain (UI example
/// phones 2 and 12): everything in the domain's storage places, grouped by
/// compartment or with the least time left first, with a search over product
/// names. Compartment groups collapse with a tap on their header.
class InventoryOverviewScreen extends ConsumerStatefulWidget {
  const InventoryOverviewScreen({required this.domainIdentifier, super.key});

  final StorageDomainIdentifier domainIdentifier;

  @override
  ConsumerState<InventoryOverviewScreen> createState() => _InventoryOverviewScreenState();
}

class _InventoryOverviewScreenState extends ConsumerState<InventoryOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  InventoryListOrder _listOrder = InventoryListOrder.byCompartment;
  final Set<CompartmentIdentifier> _collapsedCompartments = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = InventoryLocalizations.of(context);
    final overview = ref.watch(inventoryOverviewProvider).value?.ofDomain(widget.domainIdentifier);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.overviewTitle),
            if (overview != null && overview.hasStoragePlace)
              Text(
                localizations.itemsInDrawers(
                  localizations.itemCount(overview.items.length),
                  localizations.drawerCount(overview.layout.activeCompartments.length),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      floatingActionButton: overview != null && overview.hasStoragePlace
          ? FloatingActionButton.extended(
              onPressed: () => context.push(InventoryRoutes.addStockBatch()),
              icon: const Icon(Icons.add),
              label: Text(localizations.addButton),
            )
          : null,
      body: switch (overview) {
        null => const Center(child: CircularProgressIndicator()),
        final overview when !overview.hasStoragePlace => EmptyStateView(
          icon: Icons.kitchen_outlined,
          title: localizations.noStoragePlaceTitle,
          message: localizations.noStoragePlaceMessage,
          actionLabel: localizations.setUpStoragePlaceButton,
          onActionPressed: () =>
              context.push(StorageLayoutRoutes.newStoragePlaceIn(widget.domainIdentifier)),
        ),
        final overview when overview.items.isEmpty => EmptyStateView(
          icon: Icons.ac_unit,
          title: localizations.emptyTitle,
          message: localizations.emptyMessage,
          actionLabel: localizations.addButton,
          onActionPressed: () => context.push(InventoryRoutes.addStockBatch()),
        ),
        final overview => _buildContents(context, overview),
      },
    );
  }

  Widget _buildContents(BuildContext context, InventoryOverview overview) {
    final localizations = InventoryLocalizations.of(context);
    final productNames = context.productDisplayNameResolver;
    final searchQuery = _searchController.text.trim().toLowerCase();
    final matchingItems = [
      for (final item in overview.items)
        if (searchQuery.isEmpty ||
            productNames.productName(item.product).toLowerCase().contains(searchQuery))
          item,
    ];
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            FoodieSpacing.screenGutter,
            FoodieSpacing.small,
            FoodieSpacing.screenGutter,
            0,
          ),
          sliver: SliverList.list(
            children: [
              SearchBar(
                controller: _searchController,
                hintText: localizations.searchHint,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (_) => setState(() {}),
                trailing: [
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                      onPressed: () => setState(_searchController.clear),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              const SizedBox(height: FoodieSpacing.small),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: FoodieSpacing.small,
                      children: [
                        for (final (listOrder, label) in [
                          (InventoryListOrder.byCompartment, localizations.sortByDrawer),
                          (InventoryListOrder.eatFirst, localizations.sortByEatBefore),
                        ])
                          ChoiceChip(
                            label: Text(label),
                            selected: _listOrder == listOrder,
                            onSelected: (_) => setState(() => _listOrder = listOrder),
                          ),
                      ],
                    ),
                  ),
                  if (_listOrder == InventoryListOrder.byCompartment && searchQuery.isEmpty)
                    _buildExpandAllButton(localizations, overview),
                ],
              ),
            ],
          ),
        ),
        if (matchingItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateView(
              icon: Icons.search_off,
              title: localizations.noSearchResults(_searchController.text.trim()),
            ),
          )
        else
          ..._buildItemSlivers(context, overview, matchingItems),
        const SliverToBoxAdapter(child: SizedBox(height: 88)),
      ],
    );
  }

  List<Widget> _buildItemSlivers(
    BuildContext context,
    InventoryOverview overview,
    List<InventoryItem> matchingItems,
  ) {
    Widget tileFor(InventoryItem item) => StockItemTile(
      item: item,
      today: overview.today,
      onTap: () => showTakeStockSheet(context, item),
    );

    if (_listOrder == InventoryListOrder.eatFirst) {
      return [
        SliverList.list(
          children: [for (final item in sortedByEatBefore(matchingItems)) tileFor(item)],
        ),
      ];
    }
    final nameResolver = context.compartmentDisplayNameResolver(overview.layout);
    // While searching, every drawer with a match is open, so no match hides.
    final isSearching = _searchController.text.trim().isNotEmpty;
    final itemCount = InventoryLocalizations.of(context).itemCount;
    final slivers = <Widget>[];
    for (final compartment in overview.layout.activeCompartments) {
      final itemsInCompartment = [
        for (final item in matchingItems)
          if (item.batch.compartmentIdentifier == compartment.identifier) item,
      ];
      if (itemsInCompartment.isEmpty) continue;
      final isExpanded = isSearching || !_collapsedCompartments.contains(compartment.identifier);
      slivers.add(
        SliverList.list(
          children: [
            _CompartmentHeader(
              name: nameResolver.compartmentNameWithStoragePlace(compartment),
              color: CompartmentColorPalette.colorAt(compartment.colorTagIndex),
              itemCountText: itemCount(itemsInCompartment.length),
              isExpanded: isExpanded,
              onTap: isSearching
                  ? null
                  : () => setState(() {
                      if (!_collapsedCompartments.remove(compartment.identifier)) {
                        _collapsedCompartments.add(compartment.identifier);
                      }
                    }),
            ),
            if (isExpanded)
              for (final item in sortedByEatBefore(itemsInCompartment)) tileFor(item),
          ],
        ),
      );
    }
    return slivers;
  }

  /// "Expand all" while any drawer is collapsed, otherwise "Collapse all".
  Widget _buildExpandAllButton(InventoryLocalizations localizations, InventoryOverview overview) {
    final compartmentsWithItems = {
      for (final item in overview.items) item.batch.compartmentIdentifier,
    };
    final isAnyCollapsed = _collapsedCompartments.any(compartmentsWithItems.contains);
    return TextButton.icon(
      onPressed: () => setState(() {
        if (isAnyCollapsed) {
          _collapsedCompartments.clear();
        } else {
          _collapsedCompartments.addAll(compartmentsWithItems);
        }
      }),
      icon: Icon(isAnyCollapsed ? Icons.unfold_more : Icons.unfold_less),
      label: Text(
        isAnyCollapsed ? localizations.expandAllDrawers : localizations.collapseAllDrawers,
      ),
    );
  }
}

/// A drawer's name and item count; tapping it collapses or expands the
/// drawer's items when [onTap] is set.
class _CompartmentHeader extends StatelessWidget {
  const _CompartmentHeader({
    required this.name,
    required this.color,
    required this.itemCountText,
    required this.isExpanded,
    required this.onTap,
  });

  final String name;
  final Color color;
  final String itemCountText;
  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      header: true,
      expanded: isExpanded,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            FoodieSpacing.screenGutter,
            FoodieSpacing.large,
            FoodieSpacing.screenGutter,
            FoodieSpacing.extraSmall,
          ),
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: color),
              const SizedBox(width: FoodieSpacing.small),
              Expanded(
                child: Text(
                  name,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(itemCountText, style: textTheme.bodySmall),
              if (onTap != null) ...[
                const SizedBox(width: FoodieSpacing.extraSmall),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
