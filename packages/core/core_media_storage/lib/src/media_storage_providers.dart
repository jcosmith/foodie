import 'package:riverpod/riverpod.dart';

import 'image_processing_service.dart';
import 'media_file_store.dart';

/// Overridden by the app shell with the encrypted store it opened at start.
final mediaFileStoreProvider = Provider<MediaFileStore>(
  (ref) => throw UnimplementedError('mediaFileStoreProvider must be overridden'),
);

/// The encrypted store for receipt page images, in a folder of its own;
/// overridden by the app shell.
final receiptMediaFileStoreProvider = Provider<MediaFileStore>(
  (ref) => throw UnimplementedError('receiptMediaFileStoreProvider must be overridden'),
);

final imageProcessingServiceProvider = Provider<ImageProcessingService>(
  (ref) => const ImageProcessingService(),
);
