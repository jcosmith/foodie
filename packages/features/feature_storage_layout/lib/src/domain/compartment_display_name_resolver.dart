import 'compartment.dart';
import 'freezer.dart';
import 'layout_default_names.dart';
import 'storage_kind.dart';
import 'storage_layout.dart';

/// Turns freezers and compartments into the names users see: their own name
/// if they typed one, otherwise the translated default, with "(removed)" for
/// archived compartments.
final class CompartmentDisplayNameResolver {
  const CompartmentDisplayNameResolver({required this.layout, required this.defaultNames});

  final StorageLayout layout;
  final LayoutDefaultNames defaultNames;

  String freezerName(Freezer freezer) =>
      freezer.customName ?? defaultNames.freezerName(freezer.storageKind);

  /// The name without the "(removed)" suffix, as the layout editor shows it.
  String plainCompartmentName(Compartment compartment) =>
      compartment.customName ??
      defaultNames.compartmentName(_storageKindOf(compartment), compartment.defaultNumber);

  /// The name for lists and statistics, with "(removed)" for archived compartments.
  String compartmentName(Compartment compartment) {
    final plainName = plainCompartmentName(compartment);
    return compartment.isArchived ? defaultNames.removedName(plainName) : plainName;
  }

  /// Like [compartmentName], prefixed with the freezer name when there is more
  /// than one freezer: "Cellar freezer · Basket 2".
  String compartmentNameWithFreezer(Compartment compartment) {
    final name = compartmentName(compartment);
    if (layout.freezers.length < 2) return name;
    final freezer = layout.freezerOf(compartment.freezerIdentifier);
    return freezer == null ? name : '${freezerName(freezer)} · $name';
  }

  /// Looks the compartment up by identifier; unknown ones get an empty name.
  String compartmentNameOf(CompartmentIdentifier compartmentIdentifier) {
    final compartment = layout.compartmentOf(compartmentIdentifier);
    return compartment == null ? '' : compartmentNameWithFreezer(compartment);
  }

  StorageKind _storageKindOf(Compartment compartment) =>
      layout.freezerOf(compartment.freezerIdentifier)?.storageKind ?? StorageKind.upright;
}
