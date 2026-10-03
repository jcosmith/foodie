import 'package:go_router/go_router.dart';

import '../domain/freezer.dart';
import 'freezer_layout_editor_screen.dart';
import 'freezer_template_picker_screen.dart';
import 'storage_layout_overview_screen.dart';

/// Paths of the storage layout screens, for other features to link to.
abstract final class StorageLayoutRoutes {
  static const String overview = '/storage_layout';
  static const String newFreezer = '/storage_layout/freezers/new';

  static String freezerEditor(FreezerIdentifier freezerIdentifier) =>
      '/storage_layout/freezers/${Uri.encodeComponent(freezerIdentifier.value)}';
}

List<RouteBase> buildStorageLayoutRoutes() => [
  GoRoute(
    path: StorageLayoutRoutes.overview,
    builder: (context, state) => const StorageLayoutOverviewScreen(),
    routes: [
      GoRoute(
        path: 'freezers/new',
        builder: (context, state) => const FreezerTemplatePickerScreen(),
      ),
      GoRoute(
        path: 'freezers/:freezerIdentifier',
        builder: (context, state) => FreezerLayoutEditorScreen(
          freezerIdentifier: FreezerIdentifier(state.pathParameters['freezerIdentifier']!),
        ),
      ),
    ],
  ),
];
