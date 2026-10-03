import 'package:feature_product_catalog/feature_product_catalog.dart';

import '../l10n/generated/storage_reminders_localizations.dart';
import 'storage_reminder_notification_texts.dart';

final class LocalizedStorageReminderNotificationTexts implements StorageReminderNotificationTexts {
  LocalizedStorageReminderNotificationTexts(
    this._localizations,
    ProductCatalogLocalizations catalogLocalizations,
  ) : catalogNames = LocalizedCatalogNames(catalogLocalizations);

  final StorageRemindersLocalizations _localizations;

  @override
  final CatalogNames catalogNames;

  @override
  String digestTitle(int itemCount) => _localizations.digestTitle;

  @override
  String digestBodyWithCount(int itemCount) => _localizations.digestBodyWithCount(itemCount);

  @override
  String digestBodyWithNames(List<String> productNames, int furtherItemCount) {
    final names = productNames.join(_localizations.productNameSeparator);
    return furtherItemCount == 0
        ? names
        : _localizations.productNamesWithMore(names, furtherItemCount);
  }
}
