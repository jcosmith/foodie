import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late CommonLocalizations english;
  late CommonLocalizations german;

  setUpAll(() async {
    await initializeDateFormatting();
    english = await CommonLocalizations.delegate.load(SupportedLocales.english);
    german = await CommonLocalizations.delegate.load(SupportedLocales.german);
  });

  group('QuantityFormatter', () {
    test('formats grams and switches to kilograms from 1000 g', () {
      final formatter = QuantityFormatter(english);
      expect(
        formatter.format(const Quantity(amountInBaseUnits: 200, unit: QuantityUnit.gram)),
        '200 g',
      );
      expect(
        formatter.format(const Quantity(amountInBaseUnits: 1500, unit: QuantityUnit.gram)),
        '1.5 kg',
      );
    });

    test('uses the German decimal comma', () {
      final formatter = QuantityFormatter(german);
      expect(
        formatter.format(const Quantity(amountInBaseUnits: 1250, unit: QuantityUnit.milliliter)),
        '1,25 l',
      );
      expect(
        formatter.format(const Quantity(amountInBaseUnits: 500, unit: QuantityUnit.piece)),
        '0,5 Stück',
      );
    });

    test('pluralises portions', () {
      final formatter = QuantityFormatter(english);
      expect(
        formatter.format(const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.portion)),
        '1 portion',
      );
      expect(
        formatter.format(const Quantity(amountInBaseUnits: 3000, unit: QuantityUnit.portion)),
        '3 portions',
      );
    });

    test('formats amounts for input fields without grouping', () {
      expect(
        QuantityFormatter(
          english,
        ).formatAmountForInput(const Quantity(amountInBaseUnits: 1500, unit: QuantityUnit.gram)),
        '1500',
      );
      expect(
        QuantityFormatter(
          german,
        ).formatAmountForInput(const Quantity(amountInBaseUnits: 500, unit: QuantityUnit.piece)),
        '0,5',
      );
      expect(QuantityFormatter(german).unitSymbol(QuantityUnit.piece), 'Stück');
    });

    test('reads typed amounts with a decimal point or comma', () {
      expect(
        QuantityFormatter.parseDisplayAmount('1,5', QuantityUnit.piece),
        const Quantity(amountInBaseUnits: 1500, unit: QuantityUnit.piece),
      );
      expect(
        QuantityFormatter.parseDisplayAmount(' 250.4 ', QuantityUnit.gram),
        const Quantity(amountInBaseUnits: 250, unit: QuantityUnit.gram),
      );
      expect(QuantityFormatter.parseDisplayAmount('', QuantityUnit.gram), isNull);
      expect(QuantityFormatter.parseDisplayAmount('-3', QuantityUnit.gram), isNull);
      expect(QuantityFormatter.parseDisplayAmount('abc', QuantityUnit.gram), isNull);
    });
  });

  group('StorageAgeFormatter', () {
    final today = CalendarDate(2026, 10, 2);

    test('uses days, weeks, months and years', () {
      final formatter = StorageAgeFormatter(english);
      expect(formatter.formatRelativeAge(since: today, today: today), 'today');
      expect(formatter.formatRelativeAge(since: today.addDays(-1), today: today), 'yesterday');
      expect(formatter.formatRelativeAge(since: today.addDays(-5), today: today), '5 days ago');
      expect(formatter.formatRelativeAge(since: today.addDays(-21), today: today), '3 weeks ago');
      expect(
        formatter.formatRelativeAge(since: CalendarDate(2026, 3, 3), today: today),
        '7 months ago',
      );
      expect(formatter.formatRelativeAge(since: today.addDays(-800), today: today), '2 years ago');
    });

    test('speaks German', () {
      final formatter = StorageAgeFormatter(german);
      expect(formatter.formatAgeInDays(21), 'vor 3 Wochen');
    });
  });

  group('SupportedLocales', () {
    test('resolves by language and falls back to English', () {
      expect(SupportedLocales.resolve(const [Locale('de', 'AT')]), SupportedLocales.german);
      expect(SupportedLocales.resolve(const [Locale('fr'), Locale('de')]), SupportedLocales.german);
      expect(SupportedLocales.resolve(const [Locale('ja')]), SupportedLocales.english);
    });

    test('every supported language has a name in its own language', () {
      for (final locale in SupportedLocales.all) {
        expect(SupportedLocales.languageNamesInOwnLanguage[locale.languageCode], isNotNull);
      }
    });
  });

  test('formats dates per locale', () async {
    final date = CalendarDate(2026, 3, 3);
    expect(DateDisplayFormatter('en').formatMediumDate(date), 'Mar 3, 2026');
    expect(DateDisplayFormatter('de').formatMediumDate(date), '3. März 2026');
  });
}
