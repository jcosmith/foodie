import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/foodie_spacing.dart';

/// What a [ShelfLifeField] holds: the typed amount and the chosen unit.
final class ShelfLifeFieldController extends ChangeNotifier {
  /// Starts with [initialDays] in the unit they were most likely entered in,
  /// or empty in months.
  ShelfLifeFieldController({int? initialDays}) {
    if (initialDays != null) {
      final shelfLife = ShelfLife.fromDays(initialDays);
      amountController.text = '${shelfLife.amount}';
      _unit = shelfLife.unit;
    }
    amountController.addListener(notifyListeners);
  }

  final TextEditingController amountController = TextEditingController();
  ShelfLifeUnit _unit = ShelfLifeUnit.months;

  ShelfLifeUnit get unit => _unit;

  set unit(ShelfLifeUnit unit) {
    if (unit == _unit) return;
    _unit = unit;
    notifyListeners();
  }

  bool get isEmpty => amountController.text.trim().isEmpty;

  /// `null` while empty or not a whole number.
  ShelfLife? get shelfLife => switch (int.tryParse(amountController.text.trim())) {
    final amount? => ShelfLife(amount, _unit),
    null => null,
  };

  int? get inDays => shelfLife?.inDays;

  /// Empty, or a whole number between one day and 36 months.
  bool get isValid => isEmpty || (shelfLife?.isWithinLimits ?? false);

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}

/// A number with a days, weeks or months picker, so "2 days" can be entered
/// as easily as "9 months".
class ShelfLifeField extends StatelessWidget {
  const ShelfLifeField({
    required this.controller,
    required this.labelText,
    this.helperText,
    this.errorText,
    this.autofocus = false,
    this.onSubmitted,
    super.key,
  });

  final ShelfLifeFieldController controller;
  final String labelText;
  final String? helperText;
  final String? errorText;
  final bool autofocus;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final formatter = context.shelfLifeFormatter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller.amountController,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: labelText,
            helperText: helperText,
            helperMaxLines: 2,
            errorText: errorText,
            errorMaxLines: 2,
          ),
          onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
        ),
        const SizedBox(height: FoodieSpacing.small),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => SegmentedButton<ShelfLifeUnit>(
            showSelectedIcon: false,
            segments: [
              for (final unit in ShelfLifeUnit.values)
                ButtonSegment(value: unit, label: Text(formatter.unitName(unit))),
            ],
            selected: {controller.unit},
            onSelectionChanged: (selection) => controller.unit = selection.single,
          ),
        ),
      ],
    );
  }
}
