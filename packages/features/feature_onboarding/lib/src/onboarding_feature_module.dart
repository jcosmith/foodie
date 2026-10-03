import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'application/onboarding_completion.dart';
import 'l10n/generated/onboarding_localizations.dart';
import 'presentation/onboarding_screen.dart';

/// The first start: language, kind of freezer, privacy and notifications.
final class OnboardingFeatureModule extends FeatureModuleBase {
  const OnboardingFeatureModule();

  static const String identifier = 'onboarding';

  static const String onboardingRoutePath = '/$identifier';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    OnboardingLocalizations.delegate,
  ];

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(path: onboardingRoutePath, builder: (context, state) => const OnboardingScreen()),
  ];

  @override
  Future<String?> resolveLaunchRoutePath(ModuleInitializationContext context) async {
    final isCompleted = await context
        .read(preferencesStoreProvider)
        .read(OnboardingPreferenceKeys.isCompleted);
    return isCompleted ? null : onboardingRoutePath;
  }
}
