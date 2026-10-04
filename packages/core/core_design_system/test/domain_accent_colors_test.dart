import 'dart:math' as math;

import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _relativeLuminance(Color color) {
  double channel(double value) =>
      value <= 0.03928 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);
}

double _contrastRatio(Color first, Color second) {
  final lighter = math.max(_relativeLuminance(first), _relativeLuminance(second));
  final darker = math.min(_relativeLuminance(first), _relativeLuminance(second));
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('each domain has its own accent: freezer blue, fridge teal, pantry amber, household green', () {
    for (final accents in [DomainAccentColors.light, DomainAccentColors.dark]) {
      final colors = {
        accents.freezer,
        accents.fridge,
        accents.pantry,
        accents.household,
      };
      expect(colors, hasLength(4));
      final freezerHue = HSLColor.fromColor(accents.freezer).hue;
      final fridgeHue = HSLColor.fromColor(accents.fridge).hue;
      final pantryHue = HSLColor.fromColor(accents.pantry).hue;
      final householdHue = HSLColor.fromColor(accents.household).hue;
      expect(freezerHue, inInclusiveRange(200, 230), reason: 'blue');
      expect(fridgeHue, inInclusiveRange(170, 190), reason: 'teal');
      expect(pantryHue, inInclusiveRange(30, 45), reason: 'amber');
      expect(householdHue, inInclusiveRange(100, 140), reason: 'green');
    }
  });

  test('accents are readable as text on the surfaces of both themes', () {
    for (final (theme, accents) in [
      (FoodieTheme.light(), DomainAccentColors.light),
      (FoodieTheme.dark(), DomainAccentColors.dark),
    ]) {
      final surface = theme.colorScheme.surface;
      for (final accent in [accents.freezer, accents.fridge, accents.pantry, accents.household]) {
        expect(_contrastRatio(accent, surface), greaterThanOrEqualTo(4.5));
      }
    }
  });

  test('looks accents up by domain and falls back for domains without a token', () {
    const accents = DomainAccentColors.light;
    expect(accents.forDomain(StorageDomainIdentifier.fridge), accents.fridge);
    expect(accents.forDomain(StorageDomainIdentifier.household), accents.household);
    expect(accents.forDomain(const StorageDomainIdentifier('wine_cellar')), accents.fallback);
  });

  testWidgets('the themes carry the accents and context reads them', (tester) async {
    late DomainAccentColors darkAccents;
    await tester.pumpWidget(
      MaterialApp(
        theme: FoodieTheme.dark(),
        home: Builder(
          builder: (context) {
            darkAccents = context.domainAccents;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(darkAccents, DomainAccentColors.dark);
  });

  testWidgets('a colour tab icon shows its emoji at the given size, for screen readers too', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ColourTabIcon(emoji: '🧊', size: 24))),
    );
    final text = tester.widget<Text>(find.text('🧊'));
    expect(text.style?.fontSize, 24);
    expect(tester.getSize(find.byType(ColourTabIcon)), const Size(24, 24));
    // The tab label carries the meaning, so the emoji is not read out twice.
    expect(find.bySemanticsLabel('🧊'), findsNothing);
  });
}
