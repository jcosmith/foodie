import 'compartment.dart';
import 'layout_default_names.dart';
import 'storage_kind.dart';
import 'storage_layout.dart';
import 'storage_place.dart';

/// Turns storage places and compartments into the names users see: their own name
/// if they typed one, otherwise the translated default, with "(removed)" for
/// archived compartments.
final class CompartmentDisplayNameResolver {
  const CompartmentDisplayNameResolver({required this.layout, required this.defaultNames});

  final StorageLayout layout;
  final LayoutDefaultNames defaultNames;

  String storagePlaceName(StoragePlace storagePlace) =>
      storagePlace.customName ?? defaultNames.storagePlaceName(storagePlace.storageKind);

  /// The name without the "(removed)" suffix, as the layout editor shows it.
  String plainCompartmentName(Compartment compartment) =>
      compartment.customName ??
      defaultNames.compartmentName(_storageKindOf(compartment), compartment.defaultNumber);

  /// The name for lists and statistics, with "(removed)" for archived compartments.
  String compartmentName(Compartment compartment) {
    final plainName = plainCompartmentName(compartment);
    return compartment.isArchived ? defaultNames.removedName(plainName) : plainName;
  }

  /// Like [compartmentName], prefixed with the storage place name when there is more
  /// than one storage place: "Cellar storage place · Basket 2".
  String compartmentNameWithStoragePlace(Compartment compartment) {
    final name = compartmentName(compartment);
    if (layout.storagePlaces.length < 2) return name;
    final storagePlace = layout.storagePlaceOf(compartment.storagePlaceIdentifier);
    return storagePlace == null ? name : '${storagePlaceName(storagePlace)} · $name';
  }

  /// Looks the compartment up by identifier; unknown ones get an empty name.
  String compartmentNameOf(CompartmentIdentifier compartmentIdentifier) {
    final compartment = layout.compartmentOf(compartmentIdentifier);
    return compartment == null ? '' : compartmentNameWithStoragePlace(compartment);
  }

  StorageKind _storageKindOf(Compartment compartment) =>
      layout.storagePlaceOf(compartment.storagePlaceIdentifier)?.storageKind ?? StorageKind.unknown;
}
