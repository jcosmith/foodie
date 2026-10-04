import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/widgets.dart';

String _shelfName(BuildContext context, int number) => 'Shelf $number';

/// A pantry-like domain with cupboards of shelves, so screens of the freezer
/// have something to leave out.
final class ShelvesModule extends FeatureModuleBase {
  const ShelvesModule();

  static const StorageTemplate cupboard = StorageTemplate(
    identifier: 'shelves.cupboard',
    storageKind: StorageKind('testCupboard'),
    domainIdentifier: StorageDomainIdentifier.pantry,
    compartmentCount: 2,
    sortOrder: 10,
  );

  @override
  String get moduleIdentifier => 'shelves';

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: true);

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: StorageDomainIdentifier.pantry,
    sortOrder: 30,
    iconEmoji: '🥫',
    labelBuilder: (context) => 'Shelves',
    descriptionBuilder: (context) => 'Cupboards and shelves',
    storedOnLabelBuilder: (context) => 'Bought on',
    addTitleBuilder: (context) => 'Add to the cupboard',
    bestBeforeLabelBuilder: (context) => 'Best before',
    countsDiscardsAsWaste: true,
  );

  @override
  List<StorageKindContribution> get storageKinds => [
    StorageKindContribution(
      storageName: cupboard.storageKind.storageName,
      domainIdentifier: StorageDomainIdentifier.pantry,
      sortOrder: 300,
      iconEmoji: '🗄️',
      placeNameBuilder: (context) => 'Cupboard',
      kindDescriptionBuilder: (context) => 'cupboard',
      compartmentNameBuilder: _shelfName,
      compartmentCountBuilder: (context, count) => '$count shelves',
      addCompartmentLabelBuilder: (context) => 'Add shelf',
      templates: [
        StorageTemplateContribution(
          identifier: cupboard.identifier,
          sortOrder: cupboard.sortOrder,
          compartmentCount: cupboard.compartmentCount,
          labelBuilder: (context) => 'Cupboard',
        ),
      ],
    ),
  ];
}
