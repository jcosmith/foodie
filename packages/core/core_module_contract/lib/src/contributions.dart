import 'package:core_foundation/core_foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

/// Builds a localized text; called with a context below the localization delegates.
typedef LocalizedTextBuilder = String Function(BuildContext context);

/// Route paths owned by the app shell that modules may navigate to.
abstract final class ShellRoutePaths {
  /// The Home tab with the dashboard.
  static const String home = '/home';

  /// The Lists tab: the shopping list and, later, the receipts.
  static const String lists = '/lists';

  /// The More tab: Statistics, Options and future entries.
  static const String more = '/more';

  /// The tab of a storage domain; its module is named after the domain.
  static String domainTab(StorageDomainIdentifier domainIdentifier) => '/${domainIdentifier.value}';
}

/// A tab in the bottom navigation bar. Only storage domains contribute tabs
/// (architecture 10.7): Home · Freezer · Fridge · Pantry · Household · Lists
/// · More, each domain tab only while it is switched on. Everything else adds
/// a Lists segment, a More entry or an Options section instead. The sort
/// order is the domain's.
@immutable
final class NavigationDestinationContribution {
  const NavigationDestinationContribution({
    required this.sortOrder,
    required this.iconEmoji,
    required this.labelBuilder,
    required this.initialLocation,
    required this.routes,
  });

  final int sortOrder;

  /// Every tab has a colour icon in the same style, such as "❄️".
  final String iconEmoji;

  /// One short word: "Freezer".
  final LocalizedTextBuilder labelBuilder;

  /// The path the tab opens, for example `/inventory`.
  final String initialLocation;

  /// The tab's routes; they keep their own navigation stack.
  final List<RouteBase> routes;
}

/// One of the lists in the Lists tab, such as the shopping list. With more
/// than one, the tab shows them as segments at the top.
@immutable
final class ListsSegmentContribution {
  const ListsSegmentContribution({
    required this.identifier,
    required this.sortOrder,
    required this.labelBuilder,
    required this.builder,
    this.subtitleBuilder,
  });

  final String identifier;

  /// Shopping list 10, receipts 20.
  final int sortOrder;

  /// The segment's name: "Shopping list".
  final LocalizedTextBuilder labelBuilder;

  /// One line under the tab's title while the segment is shown.
  final LocalizedTextBuilder? subtitleBuilder;

  /// The list below the tab's title bar; a [Scaffold] without an app bar
  /// when it needs a floating button or snack bars.
  final WidgetBuilder builder;
}

/// An entry in the More tab, such as Statistics or Options. Its screens are
/// pushed inside the tab, so the bottom bar stays.
@immutable
final class MoreEntryContribution {
  const MoreEntryContribution({
    required this.identifier,
    required this.sortOrder,
    required this.iconEmoji,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.location,
    required this.routes,
  });

  final String identifier;

  /// Statistics 10, Options 20.
  final int sortOrder;

  final String iconEmoji;
  final LocalizedTextBuilder titleBuilder;

  /// What the entry holds: "Tabs, optional features, language, …".
  final LocalizedTextBuilder subtitleBuilder;

  /// The path the entry opens, one of [routes].
  final String location;

  /// The entry's screens. Paths start with `/<moduleIdentifier>`.
  final List<RouteBase> routes;
}

/// An entry in the floating "add" menu, such as "Scan to add".
@immutable
final class QuickActionContribution {
  const QuickActionContribution({
    required this.identifier,
    required this.sortOrder,
    required this.icon,
    required this.labelBuilder,
    required this.onSelected,
  });

  final String identifier;
  final int sortOrder;
  final IconData icon;
  final LocalizedTextBuilder labelBuilder;
  final void Function(BuildContext context) onSelected;
}

/// A card on the home dashboard, such as "Eat soon" or "Running low".
@immutable
final class DashboardCardContribution {
  const DashboardCardContribution({
    required this.identifier,
    required this.sortOrder,
    required this.builder,
    this.isVisible,
  });

  final String identifier;
  final int sortOrder;
  final WidgetBuilder builder;

  /// Whether the card has something to say right now, for example "Eat
  /// soon" only while something should be eaten soon; `null` means always.
  /// Home shows its empty state when no card is visible.
  final ProviderListenable<bool>? isVisible;
}

/// A section of Options in the More tab, such as "Freezer layout" or "Reminders".
///
/// Sort orders follow the Options table of the architecture document:
/// Language 10, Freezer layout 20, Appearance 30, Reminders 40, Restock 50,
/// Optional features 60, Backup and export 70, About and privacy 80.
@immutable
final class ConfigSectionContribution {
  const ConfigSectionContribution({
    required this.identifier,
    required this.sortOrder,
    required this.titleBuilder,
    required this.builder,
  });

  final String identifier;
  final int sortOrder;
  final LocalizedTextBuilder titleBuilder;
  final WidgetBuilder builder;
}

/// What the shared statistics filter currently selects, in terms every
/// module understands. Contributed charts must respect it.
@immutable
final class InsightFilterSnapshot {
  const InsightFilterSnapshot({
    required this.periodStart,
    required this.periodEnd,
    this.categoryIdentifiers = const {},
    this.productIdentifiers = const {},
    this.compartmentIdentifiers = const {},
  });

  /// Inclusive start, UTC.
  final DateTime periodStart;

  /// Exclusive end, UTC.
  final DateTime periodEnd;

  /// Empty means "all".
  final Set<String> categoryIdentifiers;
  final Set<String> productIdentifiers;
  final Set<String> compartmentIdentifiers;
}

/// An extra chart on the Statistics screens, such as restock's "Runs out in".
@immutable
final class InsightChartContribution {
  const InsightChartContribution({
    required this.identifier,
    required this.sortOrder,
    required this.builder,
  });

  final String identifier;
  final int sortOrder;
  final Widget Function(BuildContext context, InsightFilterSnapshot filter) builder;
}

/// What an item visual is requested for.
@immutable
sealed class ItemVisualSubject {
  const ItemVisualSubject({required this.productIdentifier});

  final String productIdentifier;
}

/// The catalog picture of a product.
final class ProductItemVisualSubject extends ItemVisualSubject {
  const ProductItemVisualSubject({required super.productIdentifier});
}

/// The picture of one stock batch, falling back to its product's picture.
final class StockBatchItemVisualSubject extends ItemVisualSubject {
  const StockBatchItemVisualSubject({
    required this.stockBatchIdentifier,
    required super.productIdentifier,
  });

  final String stockBatchIdentifier;
}

/// Supplies pictures for items in lists and detail screens. Without an
/// enabled provider, lists show the product's icon.
abstract interface class ItemVisualProvider {
  /// The item's picture, or [fallback] (the product's icon) while it has
  /// none. Returning a widget either way lets the provider switch between
  /// the two as pictures are added and removed.
  Widget buildItemVisual(
    BuildContext context,
    ItemVisualSubject subject, {
    required double size,
    required Widget fallback,
  });

  /// A place to take or choose a picture in a form whose item does not
  /// exist yet, such as the add form; the form attaches the [draft] once it
  /// has saved the item. `null` when this provider offers no capture.
  Widget? buildPictureSlot(BuildContext context, ItemPictureDraft draft);

  /// The picture of an existing item with ways to view it full screen,
  /// replace and remove it, such as in the product editor.
  Widget? buildPictureEditor(BuildContext context, ItemVisualSubject subject);
}

/// Attaches a picture staged in a form to the item the form created.
typedef ItemPictureAttacher = Future<void> Function(ItemVisualSubject subject);

/// A picture chosen in a form before its item exists. The module that
/// offers pictures stages it with [stage]; the form calls [attachTo] after
/// saving. A staged picture that is never attached is removed by the
/// picture module's clean-up at the next start.
final class ItemPictureDraft extends ChangeNotifier {
  ItemPictureAttacher? _attacher;

  bool get hasPicture => _attacher != null;

  void stage(ItemPictureAttacher attacher) {
    _attacher = attacher;
    notifyListeners();
  }

  void clear() {
    if (_attacher == null) return;
    _attacher = null;
    notifyListeners();
  }

  /// Attaches the staged picture, if any, to [subject].
  Future<void> attachTo(ItemVisualSubject subject) async {
    final attacher = _attacher;
    if (attacher == null) return;
    _attacher = null;
    await attacher(subject);
  }
}

/// How an optional module presents itself next to its switch in the Config
/// tab's "Optional features" section.
@immutable
final class OptionalFeatureDescription {
  const OptionalFeatureDescription({required this.titleBuilder, required this.detailBuilder});

  final LocalizedTextBuilder titleBuilder;

  /// One line, such as "Uses the camera, on this phone only".
  final LocalizedTextBuilder detailBuilder;
}
