import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

/// Builds a localized text; called with a context below the localization delegates.
typedef LocalizedTextBuilder = String Function(BuildContext context);

/// Route paths owned by the app shell that modules may navigate to.
abstract final class ShellRoutePaths {
  /// The Home tab with the dashboard.
  static const String home = '/home';
}

/// A tab in the bottom navigation bar.
///
/// Material allows three to five destinations; with Home, Freezer, List,
/// Insights and Config the app is at the ceiling, so new modules add Config
/// sections instead of tabs. Sort orders in use: Freezer 10, List 20,
/// Insights 30, Config 40 (Home is the shell's own tab at 0).
@immutable
final class NavigationDestinationContribution {
  const NavigationDestinationContribution({
    required this.sortOrder,
    required this.icon,
    required this.selectedIcon,
    required this.labelBuilder,
    required this.initialLocation,
    required this.routes,
  });

  final int sortOrder;
  final IconData icon;
  final IconData selectedIcon;
  final LocalizedTextBuilder labelBuilder;

  /// The path the tab opens, for example `/inventory`.
  final String initialLocation;

  /// The tab's routes; they keep their own navigation stack.
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

/// A section of the Config tab, such as "Freezer layout" or "Reminders".
///
/// Sort orders follow the Config tab table of the architecture document:
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

/// An extra chart on the Insights tab, such as restock's "Runs out in".
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
