import '../domain/restock_failure.dart';
import '../l10n/generated/restock_localizations.dart';

extension RestockFailureTexts on RestockLocalizations {
  String describeFailure(RestockFailure failure) => switch (failure) {
    MinimumQuantityNotPositive() => minimumNotPositive,
    TargetBelowMinimum() => targetBelowMinimum,
    NoCompartmentForBoughtItems() => noStoragePlaceForBoughtItems,
    AutomaticEntryCannotBeRemoved() => automaticEntryCannotBeRemoved,
    RestockUnitMismatch() ||
    RestockProductNotFound() ||
    ShoppingListEntryNotFound() => genericFailure,
  };
}
