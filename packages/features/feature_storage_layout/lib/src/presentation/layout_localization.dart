import 'package:flutter/widgets.dart';

import '../domain/compartment_display_name_resolver.dart';
import '../domain/freezer_template.dart';
import '../domain/layout_default_names.dart';
import '../domain/storage_kind.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_layout_failure.dart';
import '../l10n/generated/storage_layout_localizations.dart';

/// [LayoutDefaultNames] in the current app language.
final class LocalizedLayoutDefaultNames implements LayoutDefaultNames {
  const LocalizedLayoutDefaultNames(this._localizations);

  final StorageLayoutLocalizations _localizations;

  @override
  String freezerName(StorageKind storageKind) =>
      _localizations.defaultFreezerName(storageKind.storageName);

  @override
  String compartmentName(StorageKind storageKind, int number) =>
      _localizations.defaultCompartmentName(storageKind.storageName, number);

  @override
  String removedName(String name) => _localizations.removedName(name);
}

/// Display names for screens of any feature that shows freezers or drawers.
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

  String freezerSummaryOf(FreezerLayout freezerLayout) => freezerSummary(
    storageKindDescription(freezerLayout.freezer.storageKind.storageName),
    compartmentCount(freezerLayout.freezer.storageKind, freezerLayout.compartments.length),
  );

  String templateName(FreezerTemplate template) => switch (template) {
    FreezerTemplate.uprightWithThreeDrawers => templateUprightWithThreeDrawers,
    FreezerTemplate.uprightWithFiveDrawers => templateUprightWithFiveDrawers,
    FreezerTemplate.uprightWithSevenDrawers => templateUprightWithSevenDrawers,
    FreezerTemplate.chestWithBaskets => templateChestWithBaskets,
    FreezerTemplate.fridgeFreezerCompartment => templateFridgeFreezerCompartment,
    FreezerTemplate.empty => templateEmpty,
  };

  /// A sentence explaining [failure]; names refer to freezers or compartments
  /// depending on [isAboutFreezer].
  String describeFailure(StorageLayoutFailure failure, {bool isAboutFreezer = false}) =>
      switch (failure) {
        LayoutNameTooLong() => nameTooLong,
        LayoutNameAlreadyTaken() => isAboutFreezer ? freezerNameTaken : compartmentNameTaken,
        LastCompartmentCannotBeRemoved() => lastCompartmentHint,
        LastFreezerCannotBeRemoved() => lastFreezerCannotBeRemoved,
        FreezerNotEmpty(:final itemCount) => freezerNotEmpty(itemCount),
        FreezerNotFound() => freezerNotFound,
        CompartmentNotFound() ||
        CompartmentNotEmpty() ||
        InvalidMoveDestination() ||
        InvalidOrder() => genericFailure,
      };
}
