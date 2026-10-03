import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'media_encryption_key.dart';

/// A stored file that cannot be decrypted: another key, or damaged.
final class UnreadableMediaFileException implements Exception {
  const UnreadableMediaFileException(this.reason);

  final String reason;

  @override
  String toString() => 'UnreadableMediaFileException: $reason';
}

/// Encrypts picture files with AES-256-GCM (decision D11).
///
/// File layout: the 4-byte format marker "FZM1", a random 12-byte nonce,
/// the cipher text and the 16-byte authentication tag. A fresh nonce per
/// file means the same key can safely encrypt every picture.
final class MediaFileCipher {
  MediaFileCipher({AesGcm? algorithm}) : _algorithm = algorithm ?? AesGcm.with256bits();

  static final Uint8List _formatMarker = Uint8List.fromList('FZM1'.codeUnits);

  final AesGcm _algorithm;

  Future<Uint8List> encrypt(List<int> clearBytes, MediaEncryptionKey key) async {
    final secretBox = await _algorithm.encrypt(clearBytes, secretKey: SecretKey(key.bytes));
    return Uint8List.fromList([..._formatMarker, ...secretBox.concatenation()]);
  }

  Future<Uint8List> decrypt(List<int> encryptedBytes, MediaEncryptionKey key) async {
    final markerLength = _formatMarker.length;
    if (encryptedBytes.length < markerLength + _algorithm.nonceLength + 16 ||
        !_startsWithFormatMarker(encryptedBytes)) {
      throw const UnreadableMediaFileException('Not a freezer media file');
    }
    final secretBox = SecretBox.fromConcatenation(
      encryptedBytes.sublist(markerLength),
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
      copy: false,
    );
    try {
      return Uint8List.fromList(
        await _algorithm.decrypt(secretBox, secretKey: SecretKey(key.bytes)),
      );
    } on SecretBoxAuthenticationError {
      throw const UnreadableMediaFileException('Wrong key, or the file was changed');
    }
  }

  static bool _startsWithFormatMarker(List<int> bytes) {
    for (final (index, markerByte) in _formatMarker.indexed) {
      if (bytes[index] != markerByte) return false;
    }
    return true;
  }
}
