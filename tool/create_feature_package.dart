// Creates the skeleton of a new feature package (decision D3: a package
// template keeps the per-package overhead low).
//
// Usage: dart run tool/create_feature_package.dart meal_planning MealPlanning
//
// Creates packages/features/feature_meal_planning with the four layers,
// localization files, a FeatureModule and a test folder, and adds the package
// to the workspace. Register the module in
// apps/foodie_app/lib/src/modules/module_registry.dart afterwards.
import 'dart:io';

import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  if (arguments.length != 2 || !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(arguments[0])) {
    stderr.writeln(
      'Usage: dart run tool/create_feature_package.dart <snake_case_name> <PascalCaseName>',
    );
    exitCode = 64;
    return;
  }
  final snakeCaseName = arguments[0];
  final pascalCaseName = arguments[1];
  final packageName = 'feature_$snakeCaseName';
  final packageDirectory = Directory(path.join('packages', 'features', packageName));
  if (packageDirectory.existsSync()) {
    stderr.writeln('${packageDirectory.path} already exists');
    exitCode = 1;
    return;
  }

  final files = <String, String>{
    'pubspec.yaml':
        '''
name: $packageName
description: TODO describe what the $pascalCaseName feature does.
publish_to: none
version: 0.1.0
resolution: workspace

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

dependencies:
  core_design_system: any
  core_events: any
  core_foundation: any
  core_localization: any
  core_module_contract: any
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.4.0
  go_router: ^18.0.0
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  generate: true
''',
    'l10n.yaml':
        '''
arb-dir: lib/src/l10n
template-arb-file: ${snakeCaseName}_en.arb
output-dir: lib/src/l10n/generated
output-localization-file: ${snakeCaseName}_localizations.dart
output-class: ${pascalCaseName}Localizations
nullable-getter: false
''',
    'lib/src/l10n/${snakeCaseName}_en.arb': '{\n  "@@locale": "en"\n}\n',
    'lib/src/l10n/${snakeCaseName}_de.arb': '{\n  "@@locale": "de"\n}\n',
    'lib/$packageName.dart':
        '''
/// Public API of the $pascalCaseName feature.
library;

export 'src/${snakeCaseName}_feature_module.dart';
''',
    'lib/src/${snakeCaseName}_feature_module.dart':
        '''
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';

import 'l10n/generated/${snakeCaseName}_localizations.dart';

final class ${pascalCaseName}FeatureModule extends FeatureModuleBase {
  const ${pascalCaseName}FeatureModule();

  static const String identifier = '$snakeCaseName';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    ${pascalCaseName}Localizations.delegate,
  ];
}
''',
    'lib/src/domain/.gitkeep': '',
    'lib/src/application/.gitkeep': '',
    'lib/src/data/.gitkeep': '',
    'lib/src/presentation/.gitkeep': '',
    'test/.gitkeep': '',
  };
  files.forEach((relativePath, content) {
    final file = File(path.join(packageDirectory.path, relativePath));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content.trimLeft());
  });

  final rootPubspecFile = File('pubspec.yaml');
  final rootPubspecText = rootPubspecFile.readAsStringSync();
  final workspaceEntry = '  - packages/features/$packageName\n';
  final lastWorkspaceEntry = RegExp(r'^  - .*\n', multiLine: true).allMatches(rootPubspecText).last;
  rootPubspecFile.writeAsStringSync(
    rootPubspecText.replaceRange(lastWorkspaceEntry.end, lastWorkspaceEntry.end, workspaceEntry),
  );

  stdout
    ..writeln('Created ${packageDirectory.path}.')
    ..writeln('Next: flutter pub get, flutter gen-l10n in the package, and register')
    ..writeln(
      '${pascalCaseName}FeatureModule in apps/foodie_app/lib/src/modules/module_registry.dart.',
    );
}
