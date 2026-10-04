import 'package:flutter/widgets.dart';

import '../domain/compartment_display_name_resolver.dart';
import '../domain/layout_default_names.dart';
import '../domain/storage_kind.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_layout_failure.dart';
import '../domain/storage_template.dart';
import '../l10n/generated/storage_layout_localizations.dart';

/// [LayoutDefaultNames] in the current app language.
final class LocalizedLayoutDefaultNames implements LayoutDefaultNames {
  const LocalizedLayoutDefaultNames(this._localizations);

  final StorageLayoutLocalizations _localizations;

  @override
  String storagePlaceName(StorageKind storageKind) =>
      _localizations.defaultStoragePlaceName(storageKind.storageName);

  @override
  String compartmentName(StorageKind storageKind, int number) =>
      _localizations.defaultCompartmentName(storageKind.storageName, number);

  @override
  String removedName(String name) => _localizations.removedName(name);
}

/// Display names for screens of any feature that shows storage places or compartments.
extension StorageLayoutLocalizationContext on BuildContext {
  LayoutDefaultNames get layoutDefaultNames =>
      LocalizedLayoutDefaultNames(StorageLayoutLocalizations.of(this));

  CompartmentDisplayNameResolver compartmentDisplayNameResolver(StorageLayout layout) =>
      CompartmentDisplayNameResolver(layout: layout, defaultNames: layoutDefaultNames);
}

extension StorageLayoutLocalizationsTexts on StorageLayoutLocalizations {
  String compartmentCount(StorageKind storageKind, int count) => switch (storageKind) {
    StorageKind.upright => drawerCount(count),
    StorageKind.chest => basketCount(count),
    StorageKind.fridgeFreezerCompartment => shelfCount(count),
  };

  String storagePlaceSummaryOf(StoragePlaceLayout storagePlaceLayout) => storagePlaceSummary(
    storageKindDescription(storagePlaceLayout.storagePlace.storageKind.storageName),
    compartmentCount(
      storagePlaceLayout.storagePlace.storageKind,
      storagePlaceLayout.compartments.length,
    ),
  );

  String templateName(StorageTemplate template) => switch (template) {
    StorageTemplate.uprightWithThreeDrawers => templateUprightWithThreeDrawers,
    StorageTemplate.uprightWithFiveDrawers => templateUprightWithFiveDrawers,
    StorageTemplate.uprightWithSevenDrawers => templateUprightWithSevenDrawers,
    StorageTemplate.chestWithBaskets => templateChestWithBaskets,
    StorageTemplate.fridgeFreezerCompartment => templateFridgeFreezerCompartment,
    StorageTemplate.empty => templateEmpty,
  };

  /// A sentence explaining [failure]; names refer to storage places or compartments
  /// depending on [isAboutFreezer].
  String describeFailure(StorageLayoutFailure failure, {bool isAboutStoragePlace = false}) =>
      switch (failure) {
        LayoutNameTooLong() => nameTooLong,
        LayoutNameAlreadyTaken() =>
          isAboutStoragePlace ? storagePlaceNameTaken : compartmentNameTaken,
        LastCompartmentCannotBeRemoved() => lastCompartmentHint,
        LastStoragePlaceCannotBeRemoved() => lastStoragePlaceCannotBeRemoved,
        StoragePlaceNotEmpty(:final itemCount) => storagePlaceNotEmpty(itemCount),
        StoragePlaceNotFound() => storagePlaceNotFound,
        CompartmentNotFound() ||
        CompartmentNotEmpty() ||
        InvalidMoveDestination() ||
        InvalidOrder() => genericFailure,
      };
}
