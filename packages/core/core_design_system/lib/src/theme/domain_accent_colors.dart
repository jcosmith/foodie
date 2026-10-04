import 'package:core_foundation/core_foundation.dart';
import 'package:flutter/material.dart';

/// The accent colour of each storage domain, for its tab and its storage
/// place headers (architecture 10.7, "Tab icons and colours"). Every accent
/// reads as text on the theme's surface; colour is never the only cue.
@immutable
final class DomainAccentColors extends ThemeExtension<DomainAccentColors> {
  const DomainAccentColors({
    required this.freezer,
    required this.fridge,
    required this.pantry,
    required this.household,
    required this.fallback,
  });

  static const DomainAccentColors light = DomainAccentColors(
    freezer: Color(0xFF1769C2),
    fridge: Color(0xFF0F7B7B),
    pantry: Color(0xFF9A5B00),
    household: Color(0xFF2E7D32),
    fallback: Color(0xFF5D6879),
  );

  static const DomainAccentColors dark = DomainAccentColors(
    freezer: Color(0xFF7DB3F0),
    fridge: Color(0xFF5FD0CF),
    pantry: Color(0xFFF2B65A),
    household: Color(0xFF81C784),
    fallback: Color(0xFF9BA6B7),
  );

  /// Blue.
  final Color freezer;

  /// Teal.
  final Color fridge;

  /// Amber.
  final Color pantry;

  /// Green.
  final Color household;

  /// For domains a later module brings without a token of their own.
  final Color fallback;

  Color forDomain(StorageDomainIdentifier domain) => switch (domain) {
    StorageDomainIdentifier.freezer => freezer,
    StorageDomainIdentifier.fridge => fridge,
    StorageDomainIdentifier.pantry => pantry,
    StorageDomainIdentifier.household => household,
    _ => fallback,
  };

  @override
  DomainAccentColors copyWith({
    Color? freezer,
    Color? fridge,
    Color? pantry,
    Color? household,
    Color? fallback,
  }) => DomainAccentColors(
    freezer: freezer ?? this.freezer,
    fridge: fridge ?? this.fridge,
    pantry: pantry ?? this.pantry,
    household: household ?? this.household,
    fallback: fallback ?? this.fallback,
  );

  @override
  DomainAccentColors lerp(covariant DomainAccentColors? other, double t) {
    if (other == null) return this;
    return DomainAccentColors(
      freezer: Color.lerp(freezer, other.freezer, t)!,
      fridge: Color.lerp(fridge, other.fridge, t)!,
      pantry: Color.lerp(pantry, other.pantry, t)!,
      household: Color.lerp(household, other.household, t)!,
      fallback: Color.lerp(fallback, other.fallback, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DomainAccentColors &&
      other.freezer == freezer &&
      other.fridge == fridge &&
      other.pantry == pantry &&
      other.household == household &&
      other.fallback == fallback;

  @override
  int get hashCode => Object.hash(freezer, fridge, pantry, household, fallback);
}

extension DomainAccentColorsContext on BuildContext {
  DomainAccentColors get domainAccents =>
      Theme.of(this).extension<DomainAccentColors>() ?? DomainAccentColors.light;
}
