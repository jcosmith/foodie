// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'item_pictures_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ItemPicturesLocalizationsDe extends ItemPicturesLocalizations {
  ItemPicturesLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get optionalFeatureTitle => 'Fotos';

  @override
  String get optionalFeatureDetail => 'Fotos von Produkten und Resten';

  @override
  String get takeOrChoosePhoto => '📷 Foto aufnehmen oder auswählen';

  @override
  String get photoOptional => 'Optional. Standortdaten werden aus Fotos entfernt.';

  @override
  String get photoAdded => 'Foto hinzugefügt · Standortdaten entfernt';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromPhotos => 'Aus deinen Fotos wählen';

  @override
  String get viewPhoto => 'Ansehen';

  @override
  String get replacePhoto => 'Ersetzen';

  @override
  String get removePhoto => 'Entfernen';

  @override
  String get removePhotoQuestion => 'Dieses Foto entfernen?';

  @override
  String get removePhotoExplanation => 'Das Foto wird von diesem Telefon gelöscht.';

  @override
  String get photoNotReadable => 'Dieses Foto kann nicht gelesen werden. Versuche ein anderes.';

  @override
  String get photoSourceUnavailable => 'Die Kamera oder deine Fotos sind nicht verfügbar.';

  @override
  String get photoProcessing => 'Standortdaten werden entfernt …';

  @override
  String get photoSemanticsLabel => 'Foto';

  @override
  String get photoSectionTitle => 'Foto';

  @override
  String get batchPhotoHint => 'Ohne eigenes Foto zeigt diese Packung das Foto des Produkts.';
}
