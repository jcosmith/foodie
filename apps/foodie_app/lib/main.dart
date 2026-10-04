import 'package:flutter/widgets.dart';

import 'src/modules/module_registry.dart';
import 'src/startup/application_bootstrapper.dart';
import 'src/startup/application_platform_services.dart';
import 'src/startup/application_startup_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ApplicationStartupGate(
      bootstrapper: ApplicationBootstrapper(
        platformServices: const DevicePlatformServices(),
        registeredModules: createRegisteredFeatureModules(),
      ),
    ),
  );
}
