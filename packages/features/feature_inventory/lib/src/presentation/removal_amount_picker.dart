import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';

import '../domain/removal_amount_policy.dart';
import '../domain/stock_batch.dart';
import '../l10n/generated/inventory_localizations.dart';

/// Chooses how much of a batch to take, throw away or move (UI example
/// phone 3): quick fractions for estimates, a slider that snaps to a step
/// that suits the package (1, 10 or 50 g, or half a piece), and exact entry
/// for people who weigh.
class RemovalAmountPicker extends StatefulWidget {
  const RemovalAmountPicker({
    required this.batch,
    required this.amount,
    required this.onAmountChanged,
    this.pieceLabel,
    super.key,
  });

  final StockBatch batch;
  final Quantity amount;
  final ValueChanged<Quantity> onAmountChanged;

  /// The product's name for one piece, such as "slices".
  final String? pieceLabel;

  @override
  State<RemovalAmountPicker> createState() => _RemovalAmountPickerState();
}

class _RemovalAmountPickerState extends State<RemovalAmountPicker> {
  final TextEditingController _exactAmountController = TextEditingController();
  final FocusNode _exactAmountFocusNode = FocusNode();
  String? _exactAmountError;

  Quantity get _remaining => widget.batch.quantityRemaining;

  Quantity get _packageSize => widget.batch.initialQuantity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _showAmountInField();
  }

  @override
  void didUpdateWidget(RemovalAmountPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_exactAmountFocusNode.hasFocus) _showAmountInField();
  }

  @override
  void dispose() {
    _exactAmountController.dispose();
    _exactAmountFocusNode.dispose();
    super.dispose();
  }

  void _showAmountInField() {
    _exactAmountController.text = context.quantityFormatter.formatAmountForInput(widget.amount);
  }

  void _onExactAmountChanged(String text) {
    final localizations = InventoryLocalizations.of(context);
    final enteredAmount = QuantityFormatter.parseDisplayAmount(text, _remaining.unit);
    setState(() {
      _exactAmountError = switch (enteredAmount) {
        null => localizations.invalidAmount,
        final amount when !amount.isPositive => localizations.quantityNotPositive,
        final amount when amount.isGreaterThan(_remaining) =>
          localizations.quantityExceedsRemaining,
        _ => null,
      };
    });
    if (_exactAmountError == null) widget.onAmountChanged(enteredAmount!);
  }

  void _selectAmount(Quantity amount) {
    _exactAmountFocusNode.unfocus();
    setState(() => _exactAmountError = null);
    widget.onAmountChanged(amount);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = InventoryLocalizations.of(context);
    final quantityFormatter = context.quantityFormatter;
    final colors = context.foodieColors;
    final theme = Theme.of(context);
    final step = RemovalAmountPolicy.stepFor(_packageSize);
    final remainingAfter = _remaining - widget.amount;
    final minimumAmount = _remaining.isGreaterThan(step) ? step : _remaining;
    final sliderDivisions =
        (_remaining.amountInBaseUnits - minimumAmount.amountInBaseUnits) ~/ step.amountInBaseUnits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              quantityFormatter.format(widget.amount, pieceLabel: widget.pieceLabel),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                remainingAfter.isPositive
                    ? localizations.leftAfter(
                        quantityFormatter.format(remainingAfter, pieceLabel: widget.pieceLabel),
                      )
                    : localizations.allTaken,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: FoodieSpacing.small),
        _PackageBar(batch: widget.batch, amount: widget.amount),
        if (sliderDivisions > 0)
          Slider(
            value: widget.amount.amountInBaseUnits.toDouble().clamp(
              minimumAmount.amountInBaseUnits.toDouble(),
              _remaining.amountInBaseUnits.toDouble(),
            ),
            min: minimumAmount.amountInBaseUnits.toDouble(),
            max: _remaining.amountInBaseUnits.toDouble(),
            divisions: sliderDivisions,
            semanticFormatterCallback: (_) =>
                quantityFormatter.format(widget.amount, pieceLabel: widget.pieceLabel),
            label: quantityFormatter.format(widget.amount, pieceLabel: widget.pieceLabel),
            onChanged: (position) => _selectAmount(
              RemovalAmountPolicy.snap(_remaining, position.round(), packageSize: _packageSize),
            ),
          ),
        Row(
          children: [
            for (final (fraction, label) in [
              (0.25, '¼'),
              (0.5, '½'),
              (0.75, '¾'),
              (1.0, localizations.all),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.extraSmall),
                  child: OutlinedButton(
                    onPressed: () => _selectAmount(
                      RemovalAmountPolicy.fractionOf(
                        _remaining,
                        fraction,
                        packageSize: _packageSize,
                      ),
                    ),
                    child: Text(label),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: FoodieSpacing.medium),
        TextField(
          controller: _exactAmountController,
          focusNode: _exactAmountFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: localizations.exactAmount,
            suffixText: quantityFormatter.unitSymbol(
              _remaining.unit,
              pieceLabel: widget.pieceLabel,
            ),
            errorText: _exactAmountError,
          ),
          onChanged: _onExactAmountChanged,
        ),
      ],
    );
  }
}

/// What is taken, what stays and what was used earlier, as parts of the
/// original package.
class _PackageBar extends StatelessWidget {
  const _PackageBar({required this.batch, required this.amount});

  final StockBatch batch;
  final Quantity amount;

  @override
  Widget build(BuildContext context) {
    final colors = context.foodieColors;
    final initialAmount = batch.initialQuantity.amountInBaseUnits;
    if (initialAmount <= 0) return const SizedBox.shrink();
    final takenAmount = amount.amountInBaseUnits.clamp(0, initialAmount);
    final leftAmount = (batch.quantityRemaining.amountInBaseUnits - takenAmount).clamp(
      0,
      initialAmount,
    );
    final usedBeforeAmount = (initialAmount - takenAmount - leftAmount).clamp(0, initialAmount);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 12,
          child: Row(
            children: [
              if (takenAmount > 0)
                Expanded(
                  flex: takenAmount,
                  child: ColoredBox(color: Theme.of(context).colorScheme.primary),
                ),
              if (leftAmount > 0)
                Expanded(
                  flex: leftAmount,
                  child: ColoredBox(color: colors.primarySoft),
                ),
              if (usedBeforeAmount > 0)
                Expanded(
                  flex: usedBeforeAmount,
                  child: ColoredBox(color: colors.border),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
