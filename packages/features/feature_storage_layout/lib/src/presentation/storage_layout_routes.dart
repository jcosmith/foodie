import 'package:core_foundation/core_foundation.dart';
import 'package:go_router/go_router.dart';

import '../domain/storage_place.dart';
import 'storage_layout_overview_screen.dart';
import 'storage_place_editor_screen.dart';
import 'storage_template_picker_screen.dart';

/// Paths of the storage layout screens, for other features to link to.
abstract final class StorageLayoutRoutes {
  static const String overview = '/storage_layout';
  static const String newStoragePlace = '/storage_layout/places/new';

  /// Adds a storage place to [domainIdentifier], offering its templates.
  static String newStoragePlaceIn(StorageDomainIdentifier domainIdentifier) =>
      '$newStoragePlace?domain=${Uri.encodeQueryComponent(domainIdentifier.value)}';

  static String storagePlaceEditor(StoragePlaceIdentifier storagePlaceIdentifier) =>
      '/storage_layout/places/${Uri.encodeComponent(storagePlaceIdentifier.value)}';
}

List<RouteBase> buildStorageLayoutRoutes() => [
  GoRoute(
    path: StorageLayoutRoutes.overview,
    builder: (context, state) => const StorageLayoutOverviewScreen(),
    routes: [
      GoRoute(
        path: 'places/new',
        builder: (context, state) => StorageTemplatePickerScreen(
          domainIdentifier: StorageDomainIdentifier(
            state.uri.queryParameters['domain'] ?? StorageDomainIdentifier.freezer.value,
          ),
        ),
      ),
      GoRoute(
        path: 'places/:storagePlaceIdentifier',
        builder: (context, state) => StoragePlaceEditorScreen(
          storagePlaceIdentifier: StoragePlaceIdentifier(
            state.pathParameters['storagePlaceIdentifier']!,
          ),
        ),
      ),
    ],
  ),
];
