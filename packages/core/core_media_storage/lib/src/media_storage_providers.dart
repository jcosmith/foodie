import 'package:riverpod/riverpod.dart';

import 'image_processing_service.dart';
import 'media_file_store.dart';

/// Overridden by the app shell with the encrypted store it opened at start.
final mediaFileStoreProvider = Provider<MediaFileStore>(
  (ref) => throw UnimplementedError('mediaFileStoreProvider must be overridden'),
);

final imageProcessingServiceProvider = Provider<ImageProcessingService>(
  (ref) => const ImageProcessingService(),
);
