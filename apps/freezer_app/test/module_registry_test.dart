import 'dart:io';

import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_app/src/application_version.dart';
import 'package:freezer_app/src/modules/module_registry.dart';
import 'package:go_router/go_router.dart';

final class _ModuleWithRoute extends FeatureModuleBase {
  const _ModuleWithRoute(this.moduleIdentifier, this.routePath);

  @override
  final String moduleIdentifier;
  final String routePath;

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(path: routePath, builder: (context, state) => const SizedBox()),
  ];
}

void main() {
  test('the registered modules are consistent', () {
    expect(() => verifyModuleRegistry(createRegisteredFeatureModules()), returnsNormally);
  });

  test('rejects duplicate module identifiers', () {
    expect(
      () => verifyModuleRegistry(const [
        _ModuleWithRoute('inventory', '/inventory'),
        _ModuleWithRoute('inventory', '/inventory/other'),
      ]),
      throwsA(isA<ModuleRegistryException>()),
    );
  });

  test('rejects routes outside the module prefix', () {
    expect(
      () => verifyModuleRegistry(const [_ModuleWithRoute('restock', '/shopping')]),
      throwsA(isA<ModuleRegistryException>()),
    );
    expect(
      () => verifyModuleRegistry(const [_ModuleWithRoute('restock', '/restocking')]),
      throwsA(isA<ModuleRegistryException>()),
    );
  });

  test('the application version matches pubspec.yaml', () {
    final pubspecText = File('pubspec.yaml').readAsStringSync();
    final versionMatch = RegExp(r'^version: ([0-9.]+)\+', multiLine: true).firstMatch(pubspecText);
    expect(versionMatch?.group(1), applicationVersion);
  });
}
