import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:feature_configuration/feature_configuration.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/onboarding_completion.dart';
import '../l10n/generated/onboarding_localizations.dart';

enum _OnboardingStep { language, freezer, privacyAndReminders }

/// The first start: language first (architecture document, section 10.5),
/// then the kind of freezer unless one exists, then privacy and the
/// notification permission with an explanation (section 12).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final List<_OnboardingStep> _steps = [
    _OnboardingStep.language,
    if (!(ref.read(storageLayoutProvider).value?.hasFreezer ?? false)) _OnboardingStep.freezer,
    _OnboardingStep.privacyAndReminders,
  ];
  int _stepIndex = 0;
  FreezerTemplate _freezerTemplate = FreezerTemplate.uprightWithThreeDrawers;
  bool _isFinishing = false;

  _OnboardingStep get _step => _steps[_stepIndex];

  Future<void> _finish({required bool requestNotificationPermission}) async {
    setState(() => _isFinishing = true);
    if (requestNotificationPermission) {
      await ref.read(notificationPermissionServiceProvider).requestPermission();
    }
    if (!mounted) return;
    await ref
        .read(completeOnboardingUseCaseProvider)
        .execute(
          freezerTemplate: _steps.contains(_OnboardingStep.freezer) ? _freezerTemplate : null,
          defaultNames: context.layoutDefaultNames,
        );
    if (mounted) context.go(ShellRoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = OnboardingLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (title, content) = switch (_step) {
      _OnboardingStep.language => (
        localizations.welcomeTitle,
        <Widget>[
          Text(localizations.welcomeMessage, style: textTheme.bodyLarge),
          const SizedBox(height: FoodieSpacing.large),
          Text(localizations.chooseLanguagePrompt, style: textTheme.titleSmall),
          const LanguageChoiceList(),
        ],
      ),
      _OnboardingStep.freezer => (
        localizations.freezerTitle,
        <Widget>[
          Text(localizations.freezerPrompt, style: textTheme.bodyLarge),
          const SizedBox(height: FoodieSpacing.small),
          FreezerTemplateChoiceList(
            selectedTemplate: _freezerTemplate,
            onTemplateSelected: (template) => setState(() => _freezerTemplate = template),
          ),
        ],
      ),
      _OnboardingStep.privacyAndReminders => (
        localizations.privacyTitle,
        <Widget>[
          _ExplanationRow(icon: Icons.lock_outline, text: localizations.privacyMessage),
          _ExplanationRow(icon: Icons.save_alt_outlined, text: localizations.backupHint),
          const SizedBox(height: FoodieSpacing.medium),
          Text(localizations.remindersTitle, style: textTheme.titleMedium),
          const SizedBox(height: FoodieSpacing.small),
          _ExplanationRow(icon: Icons.notifications_outlined, text: localizations.remindersMessage),
        ],
      ),
    };
    final isLastStep = _stepIndex == _steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
                children: [
                  Text(
                    localizations.stepOfSteps(_stepIndex + 1, _steps.length),
                    style: textTheme.labelMedium,
                  ),
                  const SizedBox(height: FoodieSpacing.small),
                  Semantics(header: true, child: Text(title, style: textTheme.headlineSmall)),
                  const SizedBox(height: FoodieSpacing.medium),
                  ...content,
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
              child: Row(
                children: [
                  if (_stepIndex > 0)
                    TextButton(
                      onPressed: _isFinishing ? null : () => setState(() => _stepIndex--),
                      child: Text(localizations.backButton),
                    ),
                  const Spacer(),
                  if (isLastStep) ...[
                    TextButton(
                      onPressed: _isFinishing
                          ? null
                          : () => _finish(requestNotificationPermission: false),
                      child: Text(localizations.notNowButton),
                    ),
                    const SizedBox(width: FoodieSpacing.small),
                    FilledButton(
                      onPressed: _isFinishing
                          ? null
                          : () => _finish(requestNotificationPermission: true),
                      child: Text(localizations.allowNotificationsButton),
                    ),
                  ] else
                    FilledButton(
                      onPressed: () => setState(() => _stepIndex++),
                      child: Text(localizations.continueButton),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationRow extends StatelessWidget {
  const _ExplanationRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: FoodieSpacing.medium),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: FoodieSpacing.medium),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    ),
  );
}
