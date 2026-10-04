import 'package:core_foundation/core_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'module_registry_providers.dart';
import 'storage_contributions.dart';

/// Every storage domain the app was built with, switched on or not, in tab
/// order. Names of switched-off domains are still needed, for example for
/// backups and history.
final registeredStorageDomainsProvider = Provider<List<StorageDomainContribution>>(
  (ref) =>
      ref
          .watch(registeredFeatureModulesProvider)
          .map((module) => module.storageDomain)
          .nonNulls
          .toList()
        ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder)),
);

/// The domains that are switched on right now, in tab order.
final enabledStorageDomainsProvider = Provider<List<StorageDomainContribution>>(
  (ref) =>
      (ref.watch(enabledFeatureModulesProvider).value ?? const [])
          .map((module) => module.storageDomain)
          .nonNulls
          .toList()
        ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder)),
);

/// Identifiers of [enabledStorageDomainsProvider], for filtering.
final enabledStorageDomainIdentifiersProvider = Provider<Set<StorageDomainIdentifier>>(
  (ref) => {for (final domain in ref.watch(enabledStorageDomainsProvider)) domain.identifier},
);

/// Domains the app was built with that are switched off right now: their
/// items, places, reminders and minimums pause, and nothing is deleted.
///
/// Empty while the switches are still loading, so nothing flickers away at
/// start; at least one domain always stays on, so an empty enabled list only
/// ever means "not known yet".
final pausedStorageDomainIdentifiersProvider = Provider<Set<StorageDomainIdentifier>>((ref) {
  final enabled = ref.watch(enabledStorageDomainIdentifiersProvider);
  if (enabled.isEmpty) return const {};
  return {
    for (final domain in ref.watch(registeredStorageDomainsProvider))
      if (!enabled.contains(domain.identifier)) domain.identifier,
  };
});

/// Every storage kind by its stored name, from every registered module, so
/// places of a switched-off domain keep their names.
final registeredStorageKindsProvider = Provider<Map<String, StorageKindContribution>>(
  (ref) => {
    for (final module in ref.watch(registeredFeatureModulesProvider))
      for (final kind in module.storageKinds) kind.storageName: kind,
  },
);

/// Every catalog contribution, in registry order. All of them are seeded,
/// switched on or not, so switching a domain on later finds its catalog.
final registeredCatalogContributionsProvider = Provider<List<CatalogContribution>>(
  (ref) =>
      ref.watch(registeredFeatureModulesProvider).map((module) => module.catalog).nonNulls.toList(),
);
