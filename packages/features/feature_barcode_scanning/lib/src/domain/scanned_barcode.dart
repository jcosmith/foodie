import 'package:meta/meta.dart';

/// The kinds of codes the scanner tells apart; stored with a learned code.
enum BarcodeSymbology {
  ean13('ean13'),
  ean8('ean8'),
  upcA('upc_a'),
  upcE('upc_e'),
  code128('code128'),
  qrCode('qr_code'),
  other('other');

  const BarcodeSymbology(this.storageName);

  final String storageName;

  static BarcodeSymbology fromStorage(String storageName) =>
      values.firstWhere((symbology) => symbology.storageName == storageName, orElse: () => other);
}

/// A code as the camera decoded it, before any interpretation.
@immutable
final class ScannedBarcode {
  const ScannedBarcode({required this.value, required this.symbology});

  final String value;
  final BarcodeSymbology symbology;

  @override
  bool operator ==(Object other) =>
      other is ScannedBarcode && other.value == value && other.symbology == symbology;

  @override
  int get hashCode => Object.hash(value, symbology);

  @override
  String toString() => 'ScannedBarcode(${symbology.storageName}: $value)';
}
