import 'dart:io';
import 'dart:typed_data';

import 'package:core_media_storage/core_media_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_codec;

/// A camera-like JPEG: 2400 × 1200 pixels, with a GPS position and an
/// orientation that says "rotate 90° clockwise".
Uint8List _cameraPhoto({int width = 2400, int height = 1200, int orientation = 6}) {
  final photo = image_codec.Image(width: width, height: height);
  image_codec.fill(photo, color: image_codec.ColorRgb8(200, 120, 40));
  photo.exif.imageIfd.orientation = orientation;
  photo.exif.gpsIfd['GPSLatitude'] = image_codec.IfdValueRational(52, 1);
  photo.exif.imageIfd['Make'] = image_codec.IfdValueAscii('Phone maker');
  return image_codec.encodeJpg(photo, quality: 90);
}

bool _containsExifSegment(Uint8List jpegBytes) {
  final exifSignature = 'Exif'.codeUnits;
  for (var index = 0; index + exifSignature.length <= jpegBytes.length; index++) {
    var matches = true;
    for (var offset = 0; offset < exifSignature.length; offset++) {
      if (jpegBytes[index + offset] != exifSignature[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}

void main() {
  group('image processing', () {
    test('resizes to 1600 pixels, applies the orientation and drops EXIF and GPS', () {
      final source = _cameraPhoto();
      expect(_containsExifSegment(source), isTrue);

      final picture = ImageProcessingService.processPictureSynchronously(source)!;

      // Rotated upright: the portrait side is now the long one.
      expect((picture.widthPixels, picture.heightPixels), (800, 1600));
      final decodedPicture = image_codec.decodeJpg(picture.pictureBytes)!;
      expect((decodedPicture.width, decodedPicture.height), (800, 1600));
      expect(_containsExifSegment(picture.pictureBytes), isFalse);
      expect(_containsExifSegment(picture.thumbnailBytes), isFalse);
      expect(decodedPicture.exif.isEmpty, isTrue);

      final thumbnail = image_codec.decodeJpg(picture.thumbnailBytes)!;
      expect((thumbnail.width, thumbnail.height), (256, 256));
    });

    test('keeps small pictures at their size', () {
      final picture = ImageProcessingService.processPictureSynchronously(
        _cameraPhoto(width: 300, height: 200, orientation: 1),
      )!;

      expect((picture.widthPixels, picture.heightPixels), (300, 200));
      expect(image_codec.decodeJpg(picture.thumbnailBytes)!.width, 200);
    });

    test('refuses files that are no picture', () async {
      final result = await const ImageProcessingService().processPicture(
        Uint8List.fromList('not a picture'.codeUnits),
      );

      expect(result.failureOrNull, isA<UnreadableImage>());
    });
  });

  group('product icons', () {
    test('scale a wide photo into a transparent 192-pixel square PNG', () async {
      final result = await const ImageProcessingService().processIcon(
        _cameraPhoto(width: 1200, height: 600, orientation: 1),
      );

      final iconBytes = result.valueOrNull!;
      expect(iconBytes.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final icon = image_codec.decodePng(iconBytes)!;
      expect((icon.width, icon.height), (192, 192));
      // The photo fills the middle band; above and below stay transparent.
      expect(icon.getPixel(96, 96).a, 255);
      expect(icon.getPixel(96, 96).r, closeTo(200, 2));
      expect(icon.getPixel(96, 10).a, 0);
      expect(icon.getPixel(96, 181).a, 0);
    });

    test('enlarge a tiny icon and keep its transparency', () {
      final source = image_codec.Image(width: 16, height: 16, numChannels: 4);
      image_codec.fillRect(
        source,
        x1: 4,
        y1: 4,
        x2: 11,
        y2: 11,
        color: image_codec.ColorRgba8(0, 128, 255, 255),
      );

      final icon = image_codec.decodePng(
        ImageProcessingService.processIconSynchronously(image_codec.encodePng(source))!,
      )!;

      expect((icon.width, icon.height), (192, 192));
      expect(icon.getPixel(96, 96).b, closeTo(255, 2));
      expect(icon.getPixel(5, 5).a, 0);
    });

    test('refuse files that are no picture', () async {
      final result = await const ImageProcessingService().processIcon(
        Uint8List.fromList('not a picture'.codeUnits),
      );

      expect(result.failureOrNull, isA<UnreadableImage>());
    });
  });

  group('encryption', () {
    final cipher = MediaFileCipher();
    final key = MediaEncryptionKey.generate();

    test('round-trips and uses a fresh nonce for every file', () async {
      final clearBytes = Uint8List.fromList(List.generate(1000, (index) => index % 256));

      final firstEncryption = await cipher.encrypt(clearBytes, key);
      final secondEncryption = await cipher.encrypt(clearBytes, key);

      expect(firstEncryption, isNot(secondEncryption));
      expect(String.fromCharCodes(firstEncryption.take(4)), 'FZM1');
      expect(await cipher.decrypt(firstEncryption, key), clearBytes);
    });

    test('rejects another key and changed files', () async {
      final encryptedBytes = await cipher.encrypt([1, 2, 3], key);
      final changedBytes = Uint8List.fromList(encryptedBytes)..[20] ^= 1;

      await expectLater(
        cipher.decrypt(encryptedBytes, MediaEncryptionKey.generate()),
        throwsA(isA<UnreadableMediaFileException>()),
      );
      await expectLater(
        cipher.decrypt(changedBytes, key),
        throwsA(isA<UnreadableMediaFileException>()),
      );
      await expectLater(
        cipher.decrypt([1, 2, 3], key),
        throwsA(isA<UnreadableMediaFileException>()),
      );
    });

    test('never prints the key', () {
      expect(key.toString(), 'MediaEncryptionKey(redacted)');
      expect(MediaEncryptionKey.fromBase64(key.base64), key);
    });
  });

  group('encrypted directory store', () {
    late Directory privateDirectory;
    late EncryptedDirectoryMediaFileStore store;
    late InMemoryMediaEncryptionKeyStore keyStore;

    setUp(() async {
      privateDirectory = await Directory.systemTemp.createTemp('media_store_test');
      keyStore = InMemoryMediaEncryptionKeyStore();
      store = EncryptedDirectoryMediaFileStore(
        keyStore: keyStore,
        privateDirectoryProvider: () async => privateDirectory,
      );
    });
    tearDown(() => privateDirectory.delete(recursive: true));

    test('stores pictures encrypted and reads them back', () async {
      final picture = ImageProcessingService.processPictureSynchronously(_cameraPhoto())!;

      final reference = await store.storePicture(picture);

      expect(MediaFileNames.isValid(reference.fileName), isTrue);
      expect(await store.listFileNames(), reference.allFileNames);
      final storedBytes = await File(
        '${privateDirectory.path}/media/${reference.fileName}',
      ).readAsBytes();
      // A JPEG starts with FF D8; the stored file does not.
      expect(storedBytes.take(2), isNot([0xFF, 0xD8]));
      expect(reference.byteSize, storedBytes.length);
      expect(await store.readFile(reference.fileName), picture.pictureBytes);
      expect(await store.readFile(reference.thumbnailFileName), picture.thumbnailBytes);

      // Another start with the same key reads the same files.
      final storeAfterRestart = EncryptedDirectoryMediaFileStore(
        keyStore: keyStore,
        privateDirectoryProvider: () async => privateDirectory,
      );
      expect(await storeAfterRestart.readFile(reference.fileName), picture.pictureBytes);
    });

    test('the orphan sweep keeps referenced files and removes the rest', () async {
      final picture = ImageProcessingService.processPictureSynchronously(
        _cameraPhoto(width: 40, height: 40),
      )!;
      final keptReference = await store.storePicture(picture);
      final orphanReference = await store.storePicture(picture);
      await File('${privateDirectory.path}/media/interrupted.fzm.partial').writeAsBytes([1]);

      final deletedFileCount = await store.sweepOrphanFiles(keptReference.allFileNames);

      expect(deletedFileCount, 3);
      expect(await store.listFileNames(), keptReference.allFileNames);
      expect((await store.listFileNames()).intersection(orphanReference.allFileNames), isEmpty);
    });

    test('refuses names that could point outside its folder', () async {
      await expectLater(store.writeFile('../database.sqlite', Uint8List(1)), throwsArgumentError);
      final restoredName = createMediaFileName();
      await store.writeFile(restoredName, Uint8List.fromList([4, 5, 6]));
      expect(await store.readFile(restoredName), [4, 5, 6]);
      await store.deleteFiles([restoredName, createMediaFileName()]);
      expect(await store.listFileNames(), isEmpty);
    });
  });
}
