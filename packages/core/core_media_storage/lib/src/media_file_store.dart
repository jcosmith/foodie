import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'image_processing_service.dart';
import 'media_encryption_key.dart';
import 'media_encryption_key_store.dart';
import 'media_file_cipher.dart';
import 'stored_media_reference.dart';

/// Stores picture files outside the database (decision D11). Callers write
/// the files first and their database row second; [sweepOrphanFiles] at
/// start-up removes files whose row never arrived.
abstract interface class MediaFileStore {
  /// Encrypts and writes a processed picture and its thumbnail.
  Future<StoredMediaReference> storePicture(ProcessedPicture picture);

  /// The decrypted contents of a stored file.
  Future<Uint8List> readFile(String fileName);

  /// Writes a file under a given name, such as a picture restored from a
  /// backup; replaces a file of the same name.
  Future<void> writeFile(String fileName, Uint8List contents);

  /// Deletes files; names that do not exist are ignored.
  Future<void> deleteFiles(Iterable<String> fileNames);

  /// Every stored file name.
  Future<Set<String>> listFileNames();

  /// Deletes every stored file not in [referencedFileNames] and returns how
  /// many were deleted.
  Future<int> sweepOrphanFiles(Set<String> referencedFileNames);
}

/// Creates names that cannot collide and reveal nothing about the picture.
String createMediaFileName({Random? random, String extension = MediaFileNames.extension}) {
  final secureRandom = random ?? Random.secure();
  final hexadecimal = List<String>.generate(
    16,
    (_) => secureRandom.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  return '$hexadecimal$extension';
}

abstract final class MediaFileNames {
  static const String extension = '.fzm';
  static final RegExp pattern = RegExp(r'^[0-9a-f]{32}\.fzm$');

  /// Names this store writes; anything else (such as a backup's file
  /// names) is rejected, so a name can never point outside the folder.
  static bool isValid(String fileName) => pattern.hasMatch(fileName);
}

/// Encrypted files in the app's private Application Support folder, which
/// is excluded from iCloud and Android backups like the database.
final class EncryptedDirectoryMediaFileStore implements MediaFileStore {
  EncryptedDirectoryMediaFileStore({
    required MediaEncryptionKeyStore keyStore,
    MediaFileCipher? cipher,
    Future<Directory> Function()? privateDirectoryProvider,
    Random? random,
    this.folderName = mediaFolderName,
  }) : _keyStore = keyStore,
       _cipher = cipher ?? MediaFileCipher(),
       _privateDirectoryProvider = privateDirectoryProvider ?? getApplicationSupportDirectory,
       _random = random ?? Random.secure();

  static const String mediaFolderName = 'media';

  /// Receipt page images live apart from item pictures, so neither feature's
  /// orphan sweep can delete the other's files.
  static const String receiptFolderName = 'receipts';

  final String folderName;

  final MediaEncryptionKeyStore _keyStore;
  final MediaFileCipher _cipher;
  final Future<Directory> Function() _privateDirectoryProvider;
  final Random _random;
  Future<MediaEncryptionKey>? _key;
  Future<Directory>? _mediaDirectory;

  Future<MediaEncryptionKey> get _encryptionKey => _key ??= _keyStore.readOrCreateKey();

  Future<Directory> get _directory => _mediaDirectory ??= () async {
    final privateDirectory = await _privateDirectoryProvider();
    return Directory(path.join(privateDirectory.path, folderName)).create(recursive: true);
  }();

  Future<File> _fileNamed(String fileName) async {
    if (!MediaFileNames.isValid(fileName)) {
      throw ArgumentError.value(fileName, 'fileName', 'Not a media file name');
    }
    return File(path.join((await _directory).path, fileName));
  }

  @override
  Future<StoredMediaReference> storePicture(ProcessedPicture picture) async {
    final fileName = createMediaFileName(random: _random);
    final thumbnailFileName = createMediaFileName(random: _random);
    final encryptedPicture = await _writeEncrypted(fileName, picture.pictureBytes);
    await _writeEncrypted(thumbnailFileName, picture.thumbnailBytes);
    return StoredMediaReference(
      fileName: fileName,
      thumbnailFileName: thumbnailFileName,
      widthPixels: picture.widthPixels,
      heightPixels: picture.heightPixels,
      byteSize: encryptedPicture.length,
    );
  }

  @override
  Future<Uint8List> readFile(String fileName) async {
    final file = await _fileNamed(fileName);
    return _cipher.decrypt(await file.readAsBytes(), await _encryptionKey);
  }

  @override
  Future<void> writeFile(String fileName, Uint8List contents) async {
    await _writeEncrypted(fileName, contents);
  }

  /// Written under a temporary name and renamed when complete, so a crash
  /// never leaves half a file under a real name.
  Future<Uint8List> _writeEncrypted(String fileName, Uint8List clearBytes) async {
    final file = await _fileNamed(fileName);
    final encryptedBytes = await _cipher.encrypt(clearBytes, await _encryptionKey);
    final partialFile = File('${file.path}.partial');
    await partialFile.writeAsBytes(encryptedBytes, flush: true);
    await partialFile.rename(file.path);
    return encryptedBytes;
  }

  @override
  Future<void> deleteFiles(Iterable<String> fileNames) async {
    for (final fileName in fileNames) {
      final file = await _fileNamed(fileName);
      if (file.existsSync()) await file.delete();
    }
  }

  @override
  Future<Set<String>> listFileNames() async => {
    await for (final entity in (await _directory).list())
      if (entity is File && MediaFileNames.isValid(path.basename(entity.path)))
        path.basename(entity.path),
  };

  @override
  Future<int> sweepOrphanFiles(Set<String> referencedFileNames) async {
    var deletedFileCount = 0;
    await for (final entity in (await _directory).list()) {
      if (entity is! File) continue;
      final fileName = path.basename(entity.path);
      // Leftovers of interrupted writes go too.
      if (MediaFileNames.isValid(fileName) && referencedFileNames.contains(fileName)) continue;
      await entity.delete();
      deletedFileCount++;
    }
    return deletedFileCount;
  }
}

/// Keeps files in memory without encryption; for tests.
final class InMemoryMediaFileStore implements MediaFileStore {
  InMemoryMediaFileStore({Random? random}) : _random = random ?? Random(7);

  final Random _random;
  final Map<String, Uint8List> filesByName = {};

  @override
  Future<StoredMediaReference> storePicture(ProcessedPicture picture) async {
    final fileName = createMediaFileName(random: _random);
    final thumbnailFileName = createMediaFileName(random: _random);
    filesByName[fileName] = picture.pictureBytes;
    filesByName[thumbnailFileName] = picture.thumbnailBytes;
    return StoredMediaReference(
      fileName: fileName,
      thumbnailFileName: thumbnailFileName,
      widthPixels: picture.widthPixels,
      heightPixels: picture.heightPixels,
      byteSize: picture.pictureBytes.length,
    );
  }

  @override
  Future<Uint8List> readFile(String fileName) async =>
      filesByName[fileName] ?? (throw FileSystemException('No such media file', fileName));

  @override
  Future<void> writeFile(String fileName, Uint8List contents) async =>
      filesByName[fileName] = contents;

  @override
  Future<void> deleteFiles(Iterable<String> fileNames) async =>
      fileNames.forEach(filesByName.remove);

  @override
  Future<Set<String>> listFileNames() async => filesByName.keys.toSet();

  @override
  Future<int> sweepOrphanFiles(Set<String> referencedFileNames) async {
    final orphanFileNames = filesByName.keys.where(
      (fileName) => !referencedFileNames.contains(fileName),
    );
    final deletedFileCount = orphanFileNames.length;
    filesByName.removeWhere((fileName, _) => !referencedFileNames.contains(fileName));
    return deletedFileCount;
  }
}
