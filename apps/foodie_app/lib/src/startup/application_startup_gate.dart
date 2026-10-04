import 'dart:async';

import 'package:core_database/core_database.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../foodie_application.dart';
import '../l10n/generated/application_shell_localizations.dart';
import 'application_bootstrapper.dart';

/// Shows a loading screen while the app starts, then the app, or an
/// explanation if the start failed.
class ApplicationStartupGate extends StatefulWidget {
  const ApplicationStartupGate({required this.bootstrapper, super.key});

  final ApplicationBootstrapper bootstrapper;

  @override
  State<ApplicationStartupGate> createState() => _ApplicationStartupGateState();
}

class _ApplicationStartupGateState extends State<ApplicationStartupGate>
    implements ApplicationRestarter {
  BootstrappedApplication? _bootstrappedApplication;
  Object? _startupError;

  @override
  void initState() {
    super.initState();
    unawaited(_startBootstrap());
  }

  /// The loading screen shows until this completes. The state is kept here
  /// rather than in a FutureBuilder, which keeps showing the previous app
  /// while it waits for a new future (issue #4).
  Future<void> _startBootstrap() async {
    try {
      final bootstrappedApplication = await widget.bootstrapper.bootstrap(
        applicationRestarter: this,
      );
      if (!mounted) {
        await bootstrappedApplication.dispose();
        return;
      }
      setState(() {
        _bootstrappedApplication = bootstrappedApplication;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _startupError = error;
      });
    }
  }

  /// Shows the loading screen, closes everything and starts again. Completes
  /// when the new app shows, or the start failed.
  @override
  Future<void> restart() async {
    final runningApplication = _bootstrappedApplication;
    if (runningApplication == null || !mounted) return;
    setState(() {
      _bootstrappedApplication = null;
    });
    // Let the running app, with any dialog it shows, leave the tree before
    // its container is disposed.
    await WidgetsBinding.instance.endOfFrame;
    await runningApplication.dispose();
    await _startBootstrap();
  }

  void _retry() {
    setState(() {
      _startupError = null;
    });
    unawaited(_startBootstrap());
  }

  @override
  void dispose() {
    unawaited(_bootstrappedApplication?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bootstrappedApplication = _bootstrappedApplication;
    if (bootstrappedApplication != null) {
      // A restarted app never reuses the elements of the one before.
      return UncontrolledProviderScope(
        key: ObjectKey(bootstrappedApplication),
        container: bootstrappedApplication.providerContainer,
        child: FoodieApplication(router: bootstrappedApplication.router),
      );
    }
    final startupError = _startupError;
    return _StartupStatusApplication(
      child: startupError == null
          ? const _StartupLoadingScreen()
          : _StartupFailureScreen(startupError: startupError, onRetry: _retry),
    );
  }
}

class _StartupStatusApplication extends StatelessWidget {
  const _StartupStatusApplication({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: FoodieTheme.light(),
    darkTheme: FoodieTheme.dark(),
    supportedLocales: SupportedLocales.all,
    localeListResolutionCallback: (preferredLocales, supportedLocales) =>
        SupportedLocales.resolve(preferredLocales),
    localizationsDelegates: shellLocalizationDelegates,
    home: child,
  );
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Semantics(
        label: ApplicationShellLocalizations.of(context).startupLoadingLabel,
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}

class _StartupFailureScreen extends StatelessWidget {
  const _StartupFailureScreen({required this.startupError, required this.onRetry});

  final Object startupError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = ApplicationShellLocalizations.of(context);
    final isKeyLost = startupError is DatabaseEncryptionKeyLostException;
    return Scaffold(
      body: SafeArea(
        child: EmptyStateView(
          icon: isKeyLost ? Icons.key_off_outlined : Icons.error_outline,
          title: isKeyLost ? localizations.startupKeyLostTitle : localizations.startupFailureTitle,
          message: isKeyLost
              ? localizations.startupKeyLostMessage
              : localizations.startupFailureMessage,
          actionLabel: isKeyLost ? null : CommonLocalizations.of(context).actionRetry,
          onActionPressed: isKeyLost ? null : onRetry,
        ),
      ),
    );
  }
}
