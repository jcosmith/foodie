import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';

import '../theme/foodie_color_tokens.dart';

/// How urgently an item should be eaten, relative to its recommended
/// maximum storage time; [overdue] once that time is used up.
enum StorageAgeLevel { fresh, aging, urgent, overdue }

/// A pill showing the storage age level with a symbol, a colour and a word,
/// so it never relies on colour alone.
class StorageAgeBadge extends StatelessWidget {
  const StorageAgeBadge({required this.level, super.key});

  final StorageAgeLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = context.foodieColors;
    final localizations = context.commonLocalizations;
    final (symbol, label, foreground, background) = switch (level) {
      StorageAgeLevel.fresh => (
        '●',
        localizations.storageAgeFresh,
        colors.statusFresh,
        colors.statusFreshSoft,
      ),
      StorageAgeLevel.aging => (
        '◐',
        localizations.storageAgeAging,
        colors.statusAging,
        colors.statusAgingSoft,
      ),
      StorageAgeLevel.urgent => (
        '▲',
        localizations.storageAgeUrgent,
        colors.statusUrgent,
        colors.statusUrgentSoft,
      ),
      // The strongest signal: the urgent colours swapped, so it stands out
      // from "Eat now" by more than its word and symbol.
      StorageAgeLevel.overdue => (
        '✕',
        localizations.storageAgeOverdue,
        colors.statusUrgentSoft,
        colors.statusUrgent,
      ),
    };
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 1),
          child: Text(
            '$symbol $label',
            style: TextStyle(color: foreground, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
