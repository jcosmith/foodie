import 'package:feature_product_catalog/feature_product_catalog.dart';

/// The words of the digest notification, in the app language. Notifications
/// are planned outside any screen, so they cannot use a BuildContext.
abstract interface class StorageReminderNotificationTexts {
  CatalogNames get catalogNames;

  String digestTitle(int itemCount);

  /// For the lock screen: says how much is due, not what.
  String digestBodyWithCount(int itemCount);

  /// Names the first products and counts the rest.
  String digestBodyWithNames(List<String> productNames, int furtherItemCount);
}
