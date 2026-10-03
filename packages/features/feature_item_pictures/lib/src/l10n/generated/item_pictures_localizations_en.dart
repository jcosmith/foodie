// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'item_pictures_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ItemPicturesLocalizationsEn extends ItemPicturesLocalizations {
  ItemPicturesLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get optionalFeatureTitle => 'Item pictures';

  @override
  String get optionalFeatureDetail => 'Photos of products and leftovers';

  @override
  String get takeOrChoosePhoto => '📷 Take or choose a photo';

  @override
  String get photoOptional => 'Optional. Location data is removed from photos.';

  @override
  String get photoAdded => 'Photo added · location data removed';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromPhotos => 'Choose from your photos';

  @override
  String get viewPhoto => 'View';

  @override
  String get replacePhoto => 'Replace';

  @override
  String get removePhoto => 'Remove';

  @override
  String get removePhotoQuestion => 'Remove this photo?';

  @override
  String get removePhotoExplanation => 'The photo is deleted from this phone.';

  @override
  String get photoNotReadable => 'This photo cannot be read. Try another one.';

  @override
  String get photoSourceUnavailable => 'The camera or your photos are not available.';

  @override
  String get photoProcessing => 'Removing location data…';

  @override
  String get photoSemanticsLabel => 'Photo';

  @override
  String get photoSectionTitle => 'Photo';

  @override
  String get batchPhotoHint => 'Without its own photo, this bag shows the product\'s photo.';
}
