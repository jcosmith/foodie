import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';

import 'application/item_picture_providers.dart';
import 'application/picture_source.dart';
import 'data/drift_item_picture_repository.dart';
import 'data/image_picker_picture_source.dart';
import 'l10n/generated/item_pictures_localizations.dart';
import 'presentation/item_pictures_visual_provider.dart';

/// Item pictures (build order phase 6, architecture document section 10.2):
/// photos of products and of single batches, stored encrypted outside the
/// database. Optional and on by default; the inventory and the catalog
/// never import this package and fall back to icons when it is off.
final class ItemPicturesFeatureModule extends FeatureModuleBase {
  const ItemPicturesFeatureModule({this.pictureSourceOverride});

  static const String identifier = 'item_pictures';

  /// Replaces the camera and photo picker, for tests.
  final PictureSource? pictureSourceOverride;

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    ItemPicturesLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    itemPictureRepositoryProvider.overrideWith(
      (ref) => DriftItemPictureRepository(
        itemPicturesDao: ref.watch(applicationDatabaseProvider).itemPicturesDao,
      ),
    ),
    pictureSourceProvider.overrideWith(
      (ref) => pictureSourceOverride ?? ImagePickerPictureSource(),
    ),
  ];

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: true);

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => ItemPicturesLocalizations.of(context).optionalFeatureTitle,
    detailBuilder: (context) => ItemPicturesLocalizations.of(context).optionalFeatureDetail,
  );

  @override
  ItemVisualProvider get itemVisualProvider => const ItemPicturesVisualProvider();

  /// Removes pictures of items that went away and files without a row, then
  /// follows removals as they happen.
  @override
  Future<void> initializeModule(ModuleInitializationContext context) async {
    final report = await context.read(cleanUpItemPicturesUseCaseProvider).execute();
    if (report.removedPictures > 0 || report.removedFiles > 0) {
      context.logger.log(
        LogSeverity.info,
        'Picture clean-up removed ${report.removedPictures} pictures '
        'and ${report.removedFiles} files',
      );
    }
    context.read(itemPictureCleanupSubscriptionProvider);
  }
}
