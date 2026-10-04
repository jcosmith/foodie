import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/restock_providers.dart';
import '../domain/restock_failure.dart';
import '../domain/restock_rule.dart';
import '../l10n/generated/restock_localizations.dart';
import 'restock_routes.dart';
import 'restock_texts.dart';

/// The "Restock" section of the Config tab.
class RestockConfigSection extends ConsumerWidget {
  const RestockConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = RestockLocalizations.of(context);
    final ruleCount = ref.watch(restockRulesProvider).value?.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(localizations.configSectionExplanation, style: Theme.of(context).textTheme.bodySmall),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(localizations.minimumQuantitiesRow),
          subtitle: ruleCount == null ? null : Text(localizations.ruleCount(ruleCount)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(RestockRoutes.rules),
        ),
      ],
    );
  }
}

/// Minimum and target quantities per product.
class RestockRulesScreen extends ConsumerWidget {
  const RestockRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = RestockLocalizations.of(context);
    final rules = ref.watch(restockRulesProvider).value;
    final catalog = ref.watch(productCatalogProvider).value;
    final stockByProduct = ref.watch(stockByProductProvider).value ?? const {};
    final quantityFormatter = context.quantityFormatter;
    final nameResolver = context.productDisplayNameResolver;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.minimumQuantitiesRow)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRule(context, ref),
        icon: const Icon(Icons.add),
        label: Text(localizations.addRuleButton),
      ),
      body: switch ((rules, catalog)) {
        (null, _) || (_, null) => const Center(child: CircularProgressIndicator()),
        (final rules?, _) when rules.isEmpty => EmptyStateView(
          icon: Icons.inventory_2_outlined,
          title: localizations.rulesEmptyTitle,
          message: localizations.rulesEmptyMessage,
        ),
        (final rules?, final catalog?) => ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            for (final rule in rules)
              if (catalog.productOf(rule.productIdentifier) case final product?)
                ListTile(
                  leading: ProductIcon.ofProduct(product, catalog, size: 28),
                  title: Text(nameResolver.productName(product)),
                  subtitle: Text(switch (rule.targetQuantity) {
                    final targetQuantity? => localizations.ruleSummaryWithTarget(
                      quantityFormatter.format(rule.minimumQuantity),
                      quantityFormatter.format(targetQuantity),
                      quantityFormatter.format(
                        stockByProduct[product.identifier] ?? Quantity.zero(product.canonicalUnit),
                      ),
                    ),
                    null => localizations.ruleSummary(
                      quantityFormatter.format(rule.minimumQuantity),
                      quantityFormatter.format(
                        stockByProduct[product.identifier] ?? Quantity.zero(product.canonicalUnit),
                      ),
                    ),
                  }),
                  onTap: () => showRestockRuleDialog(context, product, existingRule: rule),
                ),
          ],
        ),
      },
    );
  }

  Future<void> _addRule(BuildContext context, WidgetRef ref) async {
    final productIdentifier = await showProductPickerSheet(context);
    if (productIdentifier == null || !context.mounted) return;
    final product = ref.read(productCatalogProvider).value?.productOf(productIdentifier);
    if (product == null) return;
    final existingRule = ref
        .read(restockRulesProvider)
        .value
        ?.where((rule) => rule.productIdentifier == productIdentifier)
        .firstOrNull;
    await showRestockRuleDialog(context, product, existingRule: existingRule);
  }
}

/// Edits the minimum and target of one product, or removes its rule.
Future<void> showRestockRuleDialog(
  BuildContext context,
  Product product, {
  RestockRule? existingRule,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => _RestockRuleDialog(product: product, existingRule: existingRule),
);

class _RestockRuleDialog extends ConsumerStatefulWidget {
  const _RestockRuleDialog({required this.product, required this.existingRule});

  final Product product;
  final RestockRule? existingRule;

  @override
  ConsumerState<_RestockRuleDialog> createState() => _RestockRuleDialogState();
}

class _RestockRuleDialogState extends ConsumerState<_RestockRuleDialog> {
  final TextEditingController _minimumController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String? _minimumError;
  String? _targetError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_minimumController.text.isNotEmpty || _targetController.text.isNotEmpty) return;
    final quantityFormatter = context.quantityFormatter;
    final initialMinimum =
        widget.existingRule?.minimumQuantity ?? widget.product.defaultPackageQuantity;
    if (initialMinimum != null) {
      _minimumController.text = quantityFormatter.formatAmountForInput(initialMinimum);
    }
    if (widget.existingRule?.targetQuantity case final targetQuantity?) {
      _targetController.text = quantityFormatter.formatAmountForInput(targetQuantity);
    }
  }

  @override
  void dispose() {
    _minimumController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final localizations = RestockLocalizations.of(context);
    final unit = widget.product.canonicalUnit;
    final minimum = QuantityFormatter.parseDisplayAmount(_minimumController.text, unit);
    final targetText = _targetController.text.trim();
    final target = targetText.isEmpty
        ? null
        : QuantityFormatter.parseDisplayAmount(targetText, unit);
    if (minimum == null || (targetText.isNotEmpty && target == null)) {
      setState(() {
        _minimumError = minimum == null ? localizations.minimumNotPositive : null;
        _targetError = minimum != null ? localizations.minimumNotPositive : null;
      });
      return;
    }
    final result = await ref
        .read(saveRestockRuleUseCaseProvider)
        .execute(
          productIdentifier: widget.product.identifier,
          minimumQuantity: minimum,
          targetQuantity: target,
        );
    if (!mounted) return;
    switch (result) {
      case SuccessfulResult():
        Navigator.of(context).pop();
      case FailedResult(:final failure):
        setState(() {
          _minimumError = failure is TargetBelowMinimum
              ? null
              : localizations.describeFailure(failure);
          _targetError = failure is TargetBelowMinimum
              ? localizations.describeFailure(failure)
              : null;
        });
    }
  }

  Future<void> _remove() async {
    final navigator = Navigator.of(context);
    await ref.read(removeRestockRuleUseCaseProvider).execute(widget.product.identifier);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = RestockLocalizations.of(context);
    final unitSymbol = context.quantityFormatter.unitSymbol(widget.product.canonicalUnit);
    return AlertDialog(
      title: Text(context.productDisplayNameResolver.productName(widget.product)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _minimumController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: localizations.minimumLabel,
              suffixText: unitSymbol,
              errorText: _minimumError,
            ),
          ),
          const SizedBox(height: FoodieSpacing.medium),
          TextField(
            controller: _targetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: localizations.targetLabel,
              suffixText: unitSymbol,
              errorText: _targetError,
            ),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        if (widget.existingRule != null)
          TextButton(onPressed: _remove, child: Text(context.commonLocalizations.actionRemove)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.commonLocalizations.actionCancel),
        ),
        FilledButton(onPressed: _save, child: Text(context.commonLocalizations.actionSave)),
      ],
    );
  }
}
