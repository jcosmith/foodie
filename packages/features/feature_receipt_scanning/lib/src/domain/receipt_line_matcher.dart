import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

import 'receipt_text.dart';

/// Where a receipt line stands on the review list (architecture 10.10, step 4).
enum ReceiptLineStatus {
  /// The product is known; the line is pre-ticked.
  matched,

  /// A likely product that needs a tap to confirm.
  suggested,

  /// Flagged at the top of the review list, never guessed.
  unrecognised,

  /// Not something to add, such as a magazine, as remembered for the store.
  ignored,
}

/// A product the matcher may pick, with its name in the current language.
@immutable
final class ReceiptMatchCandidate {
  const ReceiptMatchCandidate({required this.productIdentifier, required this.name});

  final ProductIdentifier productIdentifier;
  final String name;
}

/// What a store prints for a product, learned from a confirmed or corrected
/// line; without a product, the line is to be ignored at that store.
@immutable
final class ReceiptTextMapping {
  const ReceiptTextMapping({
    required this.storeName,
    required this.lineText,
    this.productIdentifier,
  });

  /// Both normalised with [ReceiptText.normalize].
  final String storeName;
  final String lineText;
  final ProductIdentifier? productIdentifier;

  bool get isIgnored => productIdentifier == null;
}

@immutable
final class ReceiptLineMatch {
  const ReceiptLineMatch(this.status, [this.productIdentifier]);

  static const ReceiptLineMatch unrecognised = ReceiptLineMatch(ReceiptLineStatus.unrecognised);

  final ReceiptLineStatus status;
  final ProductIdentifier? productIdentifier;
}

/// Matches receipt lines to products: a mapping learned for the store first,
/// then the product's name. Only the same name counts as a match; a close
/// name is a suggestion, and anything else is flagged rather than guessed.
final class ReceiptLineMatcher {
  ReceiptLineMatcher({
    required List<ReceiptMatchCandidate> candidates,
    required List<ReceiptTextMapping> mappings,
  }) : _candidates = [
         for (final candidate in candidates) (candidate, ReceiptText.normalize(candidate.name)),
       ],
       _mappings = {for (final mapping in mappings) (mapping.storeName, mapping.lineText): mapping};

  /// How alike two names must be, as a share of shared letter pairs, to be
  /// suggested.
  static const double suggestionSimilarity = 0.6;

  final List<(ReceiptMatchCandidate, String)> _candidates;
  final Map<(String, String), ReceiptTextMapping> _mappings;

  ReceiptLineMatch match(String lineText, {required String? storeName}) {
    final normalizedLine = ReceiptText.normalize(lineText);
    if (normalizedLine.isEmpty) return ReceiptLineMatch.unrecognised;
    if (storeName != null) {
      final mapping = _mappings[(ReceiptText.normalize(storeName), normalizedLine)];
      if (mapping != null) {
        return mapping.isIgnored
            ? const ReceiptLineMatch(ReceiptLineStatus.ignored)
            : ReceiptLineMatch(ReceiptLineStatus.matched, mapping.productIdentifier);
      }
    }
    final lineWords = normalizedLine.split(' ').toSet();
    ReceiptMatchCandidate? best;
    var bestScore = 0.0;
    for (final (candidate, normalizedName) in _candidates) {
      if (normalizedName.isEmpty) continue;
      if (normalizedName == normalizedLine) {
        return ReceiptLineMatch(ReceiptLineStatus.matched, candidate.productIdentifier);
      }
      final containsName = lineWords.containsAll(normalizedName.split(' '));
      final score = containsName ? 1.0 : _similarity(normalizedLine, normalizedName);
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }
    return best != null && bestScore >= suggestionSimilarity
        ? ReceiptLineMatch(ReceiptLineStatus.suggested, best.productIdentifier)
        : ReceiptLineMatch.unrecognised;
  }

  /// The Sørensen–Dice coefficient of the letter pairs of both texts.
  static double _similarity(String first, String second) {
    final firstPairs = _letterPairs(first);
    final secondPairs = _letterPairs(second);
    if (firstPairs.isEmpty || secondPairs.isEmpty) return 0;
    final remaining = <String, int>{};
    for (final pair in secondPairs) {
      remaining[pair] = (remaining[pair] ?? 0) + 1;
    }
    var shared = 0;
    for (final pair in firstPairs) {
      final count = remaining[pair] ?? 0;
      if (count > 0) {
        shared++;
        remaining[pair] = count - 1;
      }
    }
    return 2 * shared / (firstPairs.length + secondPairs.length);
  }

  static List<String> _letterPairs(String text) => [
    for (final word in text.split(' '))
      for (var index = 0; index < word.length - 1; index++) word.substring(index, index + 2),
  ];
}
