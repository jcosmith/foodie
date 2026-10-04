import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../application/storage_layout_providers.dart';
import '../domain/compartment_display_name_resolver.dart';
import '../domain/layout_default_names.dart';
import '../domain/storage_kind.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_layout_failure.dart';
import '../domain/storage_template.dart';
import '../l10n/generated/storage_layout_localizations.dart';

/// [LayoutDefaultNames] in the current app language: the names the kind's
/// module gives, or neutral ones for a kind no registered module knows.
final class LocalizedLayoutDefaultNames implements LayoutDefaultNames {
  const LocalizedLayoutDefaultNames(this._context, this._localizations, this._storageKinds);

  final BuildContext _context;
  final StorageLayoutLocalizations _localizations;
  final Map<String, StorageKindContribution> _storageKinds;

  @override
  String storagePlaceName(StorageKind storageKind) =>
      _storageKinds[storageKind.storageName]?.placeNameBuilder(_context) ??
      _localizations.defaultStoragePlaceName;

  @override
  String compartmentName(StorageKind storageKind, int number) =>
      _storageKinds[storageKind.storageName]?.compartmentNameBuilder(_context, number) ??
      _localizations.defaultCompartmentName(number);

  @override
  String removedName(String name) => _localizations.removedName(name);
}

/// Display names for screens of any feature that shows storage places or compartments.
extension StorageLayoutLocalizationContext on BuildContext {
  T _read<T>(ProviderListenable<T> provider) =>
      ProviderScope.containerOf(this, listen: false).read(provider);

  StorageKindContribution? _storageKindOf(StorageKind storageKind) =>
      _read(registeredStorageKindsProvider)[storageKind.storageName];

  LayoutDefaultNames get layoutDefaultNames => LocalizedLayoutDefaultNames(
    this,
    StorageLayoutLocalizations.of(this),
    _read(registeredStorageKindsProvider),
  );

  CompartmentDisplayNameResolver compartmentDisplayNameResolver(StorageLayout layout) =>
      CompartmentDisplayNameResolver(layout: layout, defaultNames: layoutDefaultNames);

  /// "3 baskets" or "2 shelves".
  String compartmentCountOf(StorageKind storageKind, int count) =>
      _storageKindOf(storageKind)?.compartmentCountBuilder(this, count) ??
      StorageLayoutLocalizations.of(this).compartmentCount(count);

  /// "Add basket" or "Add shelf".
  String addCompartmentLabelOf(StorageKind storageKind) =>
      _storageKindOf(storageKind)?.addCompartmentLabelBuilder(this) ??
      StorageLayoutLocalizations.of(this).addCompartmentButton;

  /// "upright · 5 drawers".
  String storagePlaceSummaryOf(StoragePlaceLayout storagePlaceLayout) {
    final storageKind = storagePlaceLayout.storagePlace.storageKind;
    final localizations = StorageLayoutLocalizations.of(this);
    return localizations.storagePlaceSummary(
      _storageKindOf(storageKind)?.kindDescriptionBuilder(this) ??
          localizations.storageKindDescription,
      compartmentCountOf(storageKind, storagePlaceLayout.compartments.length),
    );
  }

  /// "Upright freezer with 5 drawers".
  String storageTemplateLabelOf(StorageTemplate template) =>
      _read(storageTemplateContributionsProvider)[template.identifier]?.labelBuilder(this) ??
      template.identifier;
}

extension StorageLayoutLocalizationsTexts on StorageLayoutLocalizations {
  /// A sentence explaining [failure]; names refer to storage places or compartments
  /// depending on [isAboutStoragePlace].
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
