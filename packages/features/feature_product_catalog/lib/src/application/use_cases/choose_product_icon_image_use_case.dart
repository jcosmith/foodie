import 'package:core_foundation/core_foundation.dart';
import 'package:core_media_storage/core_media_storage.dart';

import '../../domain/product_catalog_failure.dart';
import '../../domain/product_icon_image.dart';
import '../product_icon_image_file_picker.dart';

/// Lets the user pick a picture file and turns it into a product icon: any
/// format the app can read becomes a small square PNG
/// ([ImageProcessingService.processIcon]). Nothing is stored until the
/// product is saved.
final class ChooseProductIconImageUseCase {
  const ChooseProductIconImageUseCase({
    required ProductIconImageFilePicker filePicker,
    required ImageProcessingService imageProcessing,
  }) : _filePicker = filePicker,
       _imageProcessing = imageProcessing;

  final ProductIconImageFilePicker _filePicker;
  final ImageProcessingService _imageProcessing;

  /// The new icon, or `null` when the user cancelled the dialog.
  Future<Result<ProductIconImage?, ProductCatalogFailure>> execute() async {
    final sourceBytes = await _filePicker.pickImageFile();
    if (sourceBytes == null) return const Result.success(null);
    return switch (await _imageProcessing.processIcon(sourceBytes)) {
      SuccessfulResult(value: final pngBytes) => Result.success(ProductIconImage(pngBytes)),
      FailedResult() => const Result.failure(UnreadableIconImage()),
    };
  }
}
