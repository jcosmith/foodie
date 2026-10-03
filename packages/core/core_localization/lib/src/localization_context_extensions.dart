import 'package:flutter/widgets.dart';

import 'date_display_formatter.dart';
import 'l10n/generated/common_localizations.dart';
import 'quantity_formatter.dart';
import 'storage_age_formatter.dart';

/// Shortcuts for widgets: `context.commonLocalizations`, `context.quantityFormatter`.
extension LocalizationContextExtensions on BuildContext {
  CommonLocalizations get commonLocalizations => CommonLocalizations.of(this);

  QuantityFormatter get quantityFormatter => QuantityFormatter(CommonLocalizations.of(this));

  StorageAgeFormatter get storageAgeFormatter => StorageAgeFormatter(CommonLocalizations.of(this));

  DateDisplayFormatter get dateDisplayFormatter =>
      DateDisplayFormatter(CommonLocalizations.of(this).localeName);
}
