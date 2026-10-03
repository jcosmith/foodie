import 'dart:typed_data';

import 'package:core_media_storage/core_media_storage.dart';
import 'package:feature_data_portability/src/data/media_file_backup_file_access.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a missing file is left out of the backup', () async {
    final access = MediaFileBackupFileAccess(InMemoryMediaFileStore());

    expect(await access.readFileForBackup(createMediaFileName()), isNull);
  });

  test('a backup cannot write outside the picture folder', () async {
    final mediaFileStore = InMemoryMediaFileStore();
    final access = MediaFileBackupFileAccess(mediaFileStore);
    final validFileName = createMediaFileName();

    for (final fileName in ['../../freezer.sqlite', 'picture.jpg', validFileName]) {
      await access.restoreFileFromBackup(fileName, Uint8List.fromList([1]));
    }

    expect(mediaFileStore.filesByName.keys, [validFileName]);
  });
}
