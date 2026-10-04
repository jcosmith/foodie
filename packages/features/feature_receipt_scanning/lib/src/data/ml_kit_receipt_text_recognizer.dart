import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../application/receipt_capture.dart';
import '../domain/receipt_rows.dart';

/// ML Kit text recognition with the Latin model bundled into the app
/// (decision D16): it runs on the phone, downloads nothing, and the release
/// build has no network permission anyway.
final class MlKitReceiptTextRecognizer implements ReceiptTextRecognizer {
  const MlKitReceiptTextRecognizer();

  @override
  Future<List<RecognizedTextLine>> recognize(ReceiptPhoto photo) async {
    final recognizer = TextRecognizer();
    try {
      final recognized = await recognizer.processImage(InputImage.fromFilePath(photo.path));
      return [
        for (final block in recognized.blocks)
          for (final line in block.lines)
            RecognizedTextLine(
              text: line.text,
              left: line.boundingBox.left,
              top: line.boundingBox.top,
              right: line.boundingBox.right,
              bottom: line.boundingBox.bottom,
            ),
      ];
    } finally {
      await recognizer.close();
    }
  }
}
