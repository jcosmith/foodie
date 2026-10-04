import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapInApp(Widget child, {Locale locale = SupportedLocales.english, ThemeData? theme}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: SupportedLocales.all,
      localizationsDelegates: const [
        CommonLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme ?? FoodieTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('age badge shows a symbol and a word, not only a colour', (tester) async {
    await tester.pumpWidget(_wrapInApp(const StorageAgeBadge(level: StorageAgeLevel.urgent)));
    expect(find.text('▲ Use now'), findsOneWidget);
  });

  testWidgets('age badge can say when to use the item instead', (tester) async {
    await tester.pumpWidget(
      _wrapInApp(const StorageAgeBadge(level: StorageAgeLevel.urgent, label: 'Use today')),
    );
    expect(find.text('▲ Use today'), findsOneWidget);
    expect(find.bySemanticsLabel('Use today'), findsOneWidget);
  });

  testWidgets('an overdue item says so instead of "Use now"', (tester) async {
    await tester.pumpWidget(_wrapInApp(const StorageAgeBadge(level: StorageAgeLevel.overdue)));
    expect(find.text('✕ Overdue'), findsOneWidget);
    expect(find.textContaining('Use now'), findsNothing);
  });

  testWidgets('age badge is translated', (tester) async {
    await tester.pumpWidget(
      _wrapInApp(
        const StorageAgeBadge(level: StorageAgeLevel.aging),
        locale: SupportedLocales.german,
      ),
    );
    expect(find.text('◐ Bald verbrauchen'), findsOneWidget);
  });

  testWidgets('quantity stepper respects its limits', (tester) async {
    var currentValue = const Quantity(amountInBaseUnits: 50, unit: QuantityUnit.gram);
    await tester.pumpWidget(
      _wrapInApp(
        StatefulBuilder(
          builder: (context, setState) => QuantityStepper(
            value: currentValue,
            step: const Quantity(amountInBaseUnits: 50, unit: QuantityUnit.gram),
            minimum: const Quantity(amountInBaseUnits: 50, unit: QuantityUnit.gram),
            maximum: const Quantity(amountInBaseUnits: 100, unit: QuantityUnit.gram),
            onChanged: (newValue) => setState(() => currentValue = newValue),
          ),
        ),
      ),
    );

    expect(find.text('50 g'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('100 g'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('100 g'), findsOneWidget);
  });

  testWidgets('dark theme carries the dark colour tokens', (tester) async {
    late FoodieColorTokens resolvedTokens;
    await tester.pumpWidget(
      _wrapInApp(
        Builder(
          builder: (context) {
            resolvedTokens = context.foodieColors;
            return const SizedBox();
          },
        ),
        theme: FoodieTheme.dark(),
      ),
    );
    expect(resolvedTokens, FoodieColorTokens.dark);
  });

  group('shelf life field', () {
    testWidgets('shows a stored shelf life in its unit and reads back what is typed', (
      tester,
    ) async {
      final controller = ShelfLifeFieldController(initialDays: 14);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapInApp(ShelfLifeField(controller: controller, labelText: 'Keeps for')),
      );
      expect(find.text('Keeps for'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);
      expect(_selectedShelfLifeUnit(tester), ShelfLifeUnit.weeks);

      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.text('days'));
      await tester.pumpAndSettle();
      expect(controller.shelfLife, const ShelfLife(3, ShelfLifeUnit.days));
      expect(controller.inDays, 3);
      expect(controller.isValid, isTrue);
    });

    testWidgets('empty means none; out of range or not a number is invalid', (tester) async {
      final controller = ShelfLifeFieldController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapInApp(ShelfLifeField(controller: controller, labelText: 'Keeps for')),
      );
      expect(_selectedShelfLifeUnit(tester), ShelfLifeUnit.months, reason: 'unless told otherwise');
      expect(controller.shelfLife, isNull);
      expect(controller.isValid, isTrue);

      await tester.enterText(find.byType(TextField), '40');
      expect(controller.isValid, isFalse);
      await tester.enterText(find.byType(TextField), '0');
      expect(controller.isValid, isFalse);
    });

    testWidgets('the units are translated', (tester) async {
      final controller = ShelfLifeFieldController(initialDays: 1);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrapInApp(
          ShelfLifeField(controller: controller, labelText: 'Haltbar'),
          locale: SupportedLocales.german,
        ),
      );
      expect(find.text('Tage'), findsOneWidget);
      expect(find.text('Wochen'), findsOneWidget);
      expect(_selectedShelfLifeUnit(tester), ShelfLifeUnit.days);
      expect(find.widgetWithText(TextField, '1'), findsOneWidget);
    });
  });
}

ShelfLifeUnit _selectedShelfLifeUnit(WidgetTester tester) => tester
    .widget<SegmentedButton<ShelfLifeUnit>>(find.byType(SegmentedButton<ShelfLifeUnit>))
    .selected
    .single;
