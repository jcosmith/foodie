import 'package:core_foundation/core_foundation.dart';
import 'package:intl/intl.dart';

import 'l10n/generated/common_localizations.dart';

/// Formats quantities for display: "200 g", "1.5 kg" ("1,5 kg" in German),
/// "½" pieces as "0.5 pcs", "2 portions".
final class QuantityFormatter {
  QuantityFormatter(this._localizations)
    : _wholeNumberFormat = NumberFormat.decimalPattern(_localizations.localeName)
        ..maximumFractionDigits = 0,
      _oneDecimalFormat = NumberFormat.decimalPattern(_localizations.localeName)
        ..maximumFractionDigits = 1,
      _twoDecimalsFormat = NumberFormat.decimalPattern(_localizations.localeName)
        ..maximumFractionDigits = 2,
      _inputAmountFormat = NumberFormat.decimalPattern(_localizations.localeName)
        ..maximumFractionDigits = 3
        ..turnOffGrouping();

  static const int _baseUnitsPerLargerUnit = 1000;

  final CommonLocalizations _localizations;
  final NumberFormat _wholeNumberFormat;
  final NumberFormat _oneDecimalFormat;
  final NumberFormat _twoDecimalsFormat;
  final NumberFormat _inputAmountFormat;

  String format(Quantity quantity) {
    final displayAmount = quantity.displayAmount;
    return switch (quantity.unit) {
      QuantityUnit.gram =>
        displayAmount.abs() >= _baseUnitsPerLargerUnit
            ? _localizations.quantityKilograms(
                _twoDecimalsFormat.format(displayAmount / _baseUnitsPerLargerUnit),
              )
            : _localizations.quantityGrams(_wholeNumberFormat.format(displayAmount)),
      QuantityUnit.milliliter =>
        displayAmount.abs() >= _baseUnitsPerLargerUnit
            ? _localizations.quantityLiters(
                _twoDecimalsFormat.format(displayAmount / _baseUnitsPerLargerUnit),
              )
            : _localizations.quantityMilliliters(_wholeNumberFormat.format(displayAmount)),
      QuantityUnit.piece => _localizations.quantityPieces(_oneDecimalFormat.format(displayAmount)),
      QuantityUnit.portion => _localizations.quantityPortions(
        _oneDecimalFormat.format(displayAmount),
        displayAmount,
      ),
    };
  }

  /// The plain number in display units, without unit or grouping, for input
  /// fields: "1500" grams, "0,5" pieces in German.
  String formatAmountForInput(Quantity quantity) =>
      _inputAmountFormat.format(quantity.displayAmount);

  /// Reads what the user typed into an amount field, in display units of
  /// [unit]. Accepts a decimal point or comma; returns `null` for anything
  /// that is not a non-negative number.
  static Quantity? parseDisplayAmount(String text, QuantityUnit unit) {
    final normalizedText = text.trim().replaceAll(' ', '').replaceAll(',', '.');
    final displayAmount = double.tryParse(normalizedText);
    if (displayAmount == null || !displayAmount.isFinite || displayAmount < 0) return null;
    return Quantity.fromDisplayAmount(displayAmount, unit);
  }

  /// The short unit shown next to an amount field, such as "g" or "pcs".
  String unitSymbol(QuantityUnit unit) => switch (unit) {
    QuantityUnit.gram => _localizations.unitSymbolGram,
    QuantityUnit.milliliter => _localizations.unitSymbolMilliliter,
    QuantityUnit.piece => _localizations.unitSymbolPiece,
    QuantityUnit.portion => _localizations.unitSymbolPortion,
  };

  /// The localized name of a unit, such as "Grams".
  String unitName(QuantityUnit unit) => switch (unit) {
    QuantityUnit.gram => _localizations.unitGram,
    QuantityUnit.milliliter => _localizations.unitMilliliter,
    QuantityUnit.piece => _localizations.unitPiece,
    QuantityUnit.portion => _localizations.unitPortion,
  };
}
