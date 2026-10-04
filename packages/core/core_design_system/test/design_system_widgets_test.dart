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
    expect(find.text('▲ Eat now'), findsOneWidget);
  });

  testWidgets('an overdue item says so instead of "Eat now"', (tester) async {
    await tester.pumpWidget(_wrapInApp(const StorageAgeBadge(level: StorageAgeLevel.overdue)));
    expect(find.text('✕ Overdue'), findsOneWidget);
    expect(find.textContaining('Eat now'), findsNothing);
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
            resolvedTokens = context.freezerColors;
            return const SizedBox();
          },
        ),
        theme: FoodieTheme.dark(),
      ),
    );
    expect(resolvedTokens, FoodieColorTokens.dark);
  });
}
