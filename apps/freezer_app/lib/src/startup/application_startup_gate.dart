import 'dart:async';

import 'package:core_database/core_database.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../freezer_application.dart';
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
  late Future<BootstrappedApplication> _bootstrapFuture = _startBootstrap();
  BootstrappedApplication? _bootstrappedApplication;

  Future<BootstrappedApplication> _startBootstrap() async =>
      _bootstrappedApplication = await widget.bootstrapper.bootstrap(applicationRestarter: this);

  /// Shows the loading screen, closes everything and starts again.
  @override
  Future<void> restart() async {
    final runningApplication = _bootstrappedApplication;
    _bootstrappedApplication = null;
    final restartCompleter = Completer<BootstrappedApplication>();
    setState(() => _bootstrapFuture = restartCompleter.future);
    // Let the running app leave the tree before its container is disposed.
    await WidgetsBinding.instance.endOfFrame;
    await runningApplication?.dispose();
    try {
      restartCompleter.complete(await _startBootstrap());
    } on Object catch (error, stackTrace) {
      restartCompleter.completeError(error, stackTrace);
    }
  }

  @override
  void dispose() {
    unawaited(_bootstrappedApplication?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<BootstrappedApplication>(
    future: _bootstrapFuture,
    builder: (context, snapshot) {
      final bootstrappedApplication = snapshot.data;
      if (bootstrappedApplication != null) {
        return UncontrolledProviderScope(
          container: bootstrappedApplication.providerContainer,
          child: FreezerApplication(router: bootstrappedApplication.router),
        );
      }
      final startupError = snapshot.error;
      return _StartupStatusApplication(
        child: startupError == null
            ? const _StartupLoadingScreen()
            : _StartupFailureScreen(
                startupError: startupError,
                onRetry: () => setState(() => _bootstrapFuture = _startBootstrap()),
              ),
      );
    },
  );
}

class _StartupStatusApplication extends StatelessWidget {
  const _StartupStatusApplication({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: FreezerTheme.light(),
    darkTheme: FreezerTheme.dark(),
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
