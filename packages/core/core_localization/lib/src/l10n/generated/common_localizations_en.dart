// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'common_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CommonLocalizationsEn extends CommonLocalizations {
  CommonLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionDone => 'Done';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSeeAll => 'See all';

  @override
  String quantityGrams(String amount) {
    return '$amount g';
  }

  @override
  String quantityKilograms(String amount) {
    return '$amount kg';
  }

  @override
  String quantityMilliliters(String amount) {
    return '$amount ml';
  }

  @override
  String quantityLiters(String amount) {
    return '$amount l';
  }

  @override
  String quantityPieces(String amount) {
    return '$amount pcs';
  }

  @override
  String quantityPortions(String amount, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'portions',
      one: 'portion',
    );
    return '$amount $_temp0';
  }

  @override
  String get unitGram => 'Grams';

  @override
  String get unitMilliliter => 'Millilitres';

  @override
  String get unitPiece => 'Pieces';

  @override
  String get unitPortion => 'Portions';

  @override
  String get unitSymbolGram => 'g';

  @override
  String get unitSymbolMilliliter => 'ml';

  @override
  String get unitSymbolPiece => 'pcs';

  @override
  String get unitSymbolPortion => 'portions';

  @override
  String get relativeAgeToday => 'today';

  @override
  String get relativeAgeYesterday => 'yesterday';

  @override
  String relativeAgeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String relativeAgeWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String relativeAgeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String relativeAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeAboutWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'about $count weeks',
      one: 'about 1 week',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeAboutMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'about $count months',
      one: 'about 1 month',
    );
    return '$_temp0';
  }

  @override
  String get shelfLifeUnitDays => 'days';

  @override
  String get shelfLifeUnitWeeks => 'weeks';

  @override
  String get shelfLifeUnitMonths => 'months';

  @override
  String get shelfLifeUnitLabel => 'Unit';

  @override
  String get shelfLifeOutOfRange => 'Enter between 1 day and 36 months.';

  @override
  String get shelfLifeNone => 'No shelf life';

  @override
  String get storageAgeFresh => 'Fresh';

  @override
  String get storageAgeAging => 'Use soon';

  @override
  String get storageAgeUrgent => 'Use now';

  @override
  String get storageAgeOverdue => 'Overdue';

  @override
  String get emptyStateNothingHereYet => 'Nothing here yet';

  @override
  String get privacyPromise => 'Your data never leaves this phone';

  @override
  String get chartShowTable => 'Table';

  @override
  String get chartShowChart => 'Chart';
}
