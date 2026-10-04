/// How receipt texts and store names are compared and protected.
abstract final class ReceiptText {
  static const Map<String, String> _foldedLetters = {
    'ä': 'ae',
    'ö': 'oe',
    'ü': 'ue',
    'ß': 'ss',
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ô': 'o',
    'ù': 'u',
    'û': 'u',
  };

  static final RegExp _separators = RegExp('[^a-z0-9]+');

  /// Lower case, umlauts and accents folded, anything but letters and digits
  /// turned into single spaces: "BIO VOLLM. 1,5%" becomes "bio vollm 1 5".
  static String normalize(String text) {
    final lowered = text.toLowerCase();
    final folded = StringBuffer();
    for (final character in lowered.split('')) {
      folded.write(_foldedLetters[character] ?? character);
    }
    return folded.toString().replaceAll(_separators, ' ').trim();
  }

  /// Runs of digits that can only be card or loyalty numbers: eight digits
  /// or more (spaces allowed), or digits after masking characters such as
  /// "************4711".
  static final RegExp _longNumber = RegExp(r'\d(?:[ -]?\d){7,}');
  static final RegExp _maskedCardNumber = RegExp(r'(?:[*xX•]{2,}[ -]?)+\d{2,}');

  /// Words that mark a row as carrying a card or loyalty number.
  static final RegExp _cardOrLoyaltyWord = RegExp(
    r'karte|kartennr|card|visa|mastercard|maestro|amex|payback|kunden|customer|loyalty|member|'
    r'clubcard|nectar|deutschlandcard|iban|konto|account',
    caseSensitive: false,
  );

  static final RegExp _shortNumber = RegExp(r'\d{4,}');

  /// The row with card and loyalty numbers replaced by "••••", so they are
  /// never stored or indexed (architecture 10.10, "Privacy on receipts").
  static String maskPrivateNumbers(String row) {
    var masked = row.replaceAll(_maskedCardNumber, '••••').replaceAll(_longNumber, '••••');
    if (_cardOrLoyaltyWord.hasMatch(masked)) {
      masked = masked.replaceAll(_shortNumber, '••••');
    }
    return masked;
  }
}
