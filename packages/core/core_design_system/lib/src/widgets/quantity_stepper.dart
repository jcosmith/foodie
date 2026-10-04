import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';

import '../theme/foodie_spacing.dart';

/// Minus and plus buttons around a formatted quantity.
///
/// [step] is in the quantity's unit (for example 50 g or ½ piece); the value
/// stays between [minimum] and [maximum].
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.value,
    required this.step,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
    super.key,
  });

  final Quantity value;
  final Quantity step;
  final Quantity minimum;
  final Quantity maximum;
  final ValueChanged<Quantity> onChanged;

  @override
  Widget build(BuildContext context) {
    final formatter = context.quantityFormatter;
    final decreased = value - step;
    final increased = value + step;
    final canDecrease = !decreased.isLessThan(minimum);
    final canIncrease = !increased.isGreaterThan(maximum);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          tooltip: '− ${formatter.format(step)}',
          onPressed: canDecrease ? () => onChanged(decreased) : null,
          icon: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.medium),
          child: Text(
            formatter.format(value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton.outlined(
          tooltip: '+ ${formatter.format(step)}',
          onPressed: canIncrease ? () => onChanged(increased) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
