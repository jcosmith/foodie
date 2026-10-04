// Architecture checks run in CI (architecture document, sections 5, 11 and 14).
//
// Usage: dart run tool/check_architecture.dart
//
// Fails with a list of violations when:
// - a core package depends on a feature package, or features depend on each
//   other in a cycle;
// - a package imports another package's private `src/` files;
// - a platform plugin is used outside the one package allowed to use it;
// - domain code imports Flutter, Drift, Riverpod or the database, or another
//   feature other than through its pure Dart `domain.dart`;
// - `DateTime.now()` is called outside the Clock in core_foundation;
// - the app's runtime dependencies contain a package that is not on the
//   reviewed allowlist, or one that is never allowed (network clients,
//   analytics, crash reporting, the unencrypted SQLite bundle);
// - the workspace no longer selects the SQLCipher build of SQLite;
// - the release Android manifest declares the INTERNET permission.
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Packages that may only be used by one specific workspace package.
const Map<String, Set<String>> _pluginConfinement = {
  'drift': {'core_database'},
  'drift_dev': {'core_database'},
  'sqlite3': {'core_database'},
  'flutter_secure_storage': {'core_database', 'core_media_storage'},
  'path_provider': {'core_database', 'core_media_storage', 'feature_data_portability'},
  'flutter_local_notifications': {'core_notifications'},
  'flutter_timezone': {'core_notifications'},
  'timezone': {'core_notifications'},
  'image_picker': {'core_media_storage', 'feature_item_pictures', 'feature_receipt_scanning'},
  'image': {'core_media_storage'},
  'cryptography': {'core_media_storage', 'feature_data_portability'},
  'cryptography_flutter': {'core_media_storage', 'feature_data_portability'},
  'mobile_scanner': {'feature_barcode_scanning'},
  // On-device text recognition with the bundled Latin model (decision D16).
  'google_mlkit_text_recognition': {'feature_receipt_scanning'},
  'google_mlkit_commons': {'feature_receipt_scanning'},
  'file_picker': {'feature_data_portability', 'feature_product_catalog'},
  'fl_chart': {'core_design_system'},
};

/// Packages that must never be part of the app, whatever the allowlist says.
final List<RegExp> _forbiddenRuntimePackages = [
  RegExp(r'^dio'),
  RegExp(r'^firebase'),
  RegExp(r'^sentry'),
  RegExp(r'analytics'),
  RegExp(r'crashlytics'),
  RegExp(r'^sqlite3_flutter_libs$'),
  RegExp(r'^sqlcipher_flutter_libs$'),
  // Every other ML Kit plugin, among them ones that download models; text
  // recognition is confined to receipt scanning above.
  RegExp(r'^google_mlkit_(?!text_recognition$|commons$)'),
  RegExp(r'^webview'),
];

/// Imports that the domain layer of a feature must not use (decision D1 and section 4).
final List<RegExp> _forbiddenDomainImports = [
  RegExp(r'''^import\s+['"]package:flutter/'''),
  RegExp(r'''^import\s+['"]package:flutter_riverpod/'''),
  RegExp(r'''^import\s+['"]package:riverpod/'''),
  RegExp(r'''^import\s+['"]package:drift/'''),
  RegExp(r'''^import\s+['"]package:core_database/'''),
];

final RegExp _dateTimeNowPattern = RegExp(r'DateTime\.now\(\)');

/// Network APIs our own code must never use. (The OS blocks sockets in release
/// builds anyway, because the manifest has no INTERNET permission.)
final List<RegExp> _forbiddenNetworkUsage = [
  RegExp(r'''^import\s+['"]package:http/'''),
  RegExp(r'''^import\s+['"]package:dio/'''),
  RegExp(r'''^import\s+['"]package:web_socket'''),
  RegExp(r'\bHttpClient\s*\('),
  RegExp(r'\b(?:Raw)?Socket\.connect\b'),
  RegExp(r'\bWebSocket\.connect\b'),
];
final RegExp _packageImportPattern = RegExp(
  r'''^(?:import|export)\s+['"]package:([a-z0-9_]+)/(.*?)['"]''',
);

void main() {
  final workspaceRoot = Directory.current;
  final violations = <String>[];
  final workspacePackages = _readWorkspacePackages(workspaceRoot);

  _checkPackageDependencyRules(workspacePackages, violations);
  _checkPluginConfinement(workspacePackages, violations);
  _checkDartSources(workspacePackages, violations);
  _checkRuntimeDependencies(workspaceRoot, workspacePackages, violations);
  _checkSqlCipherSelection(workspaceRoot, violations);
  _checkAndroidReleaseManifest(workspaceRoot, violations);

  if (violations.isEmpty) {
    stdout.writeln('Architecture check passed for ${workspacePackages.length} packages.');
    return;
  }
  stderr.writeln('Architecture check found ${violations.length} problem(s):');
  for (final violation in violations) {
    stderr.writeln('  - $violation');
  }
  exitCode = 1;
}

final class _WorkspacePackage {
  _WorkspacePackage({
    required this.name,
    required this.directory,
    required this.dependencies,
    required this.devDependencies,
  });

  final String name;
  final Directory directory;
  final Set<String> dependencies;
  final Set<String> devDependencies;

  bool get isCore => name.startsWith('core_');

  bool get isFeature => name.startsWith('feature_');
}

List<_WorkspacePackage> _readWorkspacePackages(Directory workspaceRoot) {
  final rootPubspec =
      loadYaml(File(path.join(workspaceRoot.path, 'pubspec.yaml')).readAsStringSync()) as YamlMap;
  final memberPaths = (rootPubspec['workspace'] as YamlList).cast<String>();
  return [
    for (final memberPath in memberPaths)
      _readPackage(Directory(path.join(workspaceRoot.path, memberPath))),
  ];
}

_WorkspacePackage _readPackage(Directory packageDirectory) {
  final pubspec =
      loadYaml(File(path.join(packageDirectory.path, 'pubspec.yaml')).readAsStringSync())
          as YamlMap;
  Set<String> keysOf(Object? section) =>
      section is YamlMap ? section.keys.cast<String>().toSet() : <String>{};
  return _WorkspacePackage(
    name: pubspec['name'] as String,
    directory: packageDirectory,
    dependencies: keysOf(pubspec['dependencies']),
    devDependencies: keysOf(pubspec['dev_dependencies']),
  );
}

void _checkPackageDependencyRules(List<_WorkspacePackage> packages, List<String> violations) {
  final packagesByName = {for (final package in packages) package.name: package};
  for (final package in packages) {
    if (!package.isCore) continue;
    for (final dependency in package.dependencies) {
      if (dependency.startsWith('feature_')) {
        violations.add('${package.name} is a core package but depends on $dependency');
      }
    }
  }

  // The feature graph must stay acyclic.
  final visitState = <String, int>{}; // 1 = visiting, 2 = done
  void visit(String packageName, List<String> trail) {
    final state = visitState[packageName];
    if (state == 2) return;
    if (state == 1) {
      violations.add('Dependency cycle: ${[...trail, packageName].join(' -> ')}');
      return;
    }
    visitState[packageName] = 1;
    final package = packagesByName[packageName];
    if (package != null) {
      for (final dependency in package.dependencies.where(packagesByName.containsKey)) {
        visit(dependency, [...trail, packageName]);
      }
    }
    visitState[packageName] = 2;
  }

  for (final package in packages) {
    visit(package.name, const []);
  }
}

void _checkPluginConfinement(List<_WorkspacePackage> packages, List<String> violations) {
  for (final package in packages) {
    for (final dependency in {...package.dependencies, ...package.devDependencies}) {
      final allowedUsers = _pluginConfinement[dependency];
      if (allowedUsers != null && !allowedUsers.contains(package.name)) {
        violations.add(
          '${package.name} depends on $dependency, which only ${allowedUsers.join(' or ')} may use',
        );
      }
    }
  }
}

void _checkDartSources(List<_WorkspacePackage> packages, List<String> violations) {
  final workspacePackageNames = packages.map((package) => package.name).toSet();
  for (final package in packages) {
    for (final sourceFile in _dartSourceFiles(package.directory)) {
      final relativePath = path.relative(sourceFile.path, from: package.directory.path);
      if (relativePath.endsWith('.g.dart') ||
          relativePath.contains('${path.separator}generated${path.separator}')) {
        continue;
      }
      final isDomainFile = relativePath.contains(path.join('lib', 'src', 'domain'));
      final isClockFile =
          package.name == 'core_foundation' &&
          relativePath == path.join('lib', 'src', 'clock.dart');
      final lines = sourceFile.readAsLinesSync();
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        final line = lines[lineIndex].trim();
        final location = '${package.name}/$relativePath:${lineIndex + 1}';
        if (line.startsWith('//')) continue;
        if (!isClockFile && _dateTimeNowPattern.hasMatch(line)) {
          violations.add('$location calls DateTime.now(); use the Clock from core_foundation');
        }
        final importMatch = _packageImportPattern.firstMatch(line);
        if (importMatch != null) {
          final importedPackage = importMatch.group(1)!;
          final importedPath = importMatch.group(2)!;
          if (importedPackage != package.name &&
              workspacePackageNames.contains(importedPackage) &&
              importedPath.startsWith('src/')) {
            violations.add('$location imports private file package:$importedPackage/$importedPath');
          }
        }
        if (_forbiddenNetworkUsage.any((pattern) => pattern.hasMatch(line))) {
          violations.add('$location uses a network API; the app never talks to the network');
        }
        if (isDomainFile && _forbiddenDomainImports.any((pattern) => pattern.hasMatch(line))) {
          violations.add('$location: domain code must stay pure Dart (found "$line")');
        }
        if (isDomainFile &&
            importMatch != null &&
            importMatch.group(1)!.startsWith('feature_') &&
            importMatch.group(1) != package.name &&
            importMatch.group(2) != 'domain.dart') {
          violations.add(
            '$location: domain code may use other features only through their domain.dart',
          );
        }
      }
    }
  }
}

Iterable<File> _dartSourceFiles(Directory packageDirectory) sync* {
  for (final folderName in ['lib', 'test', 'integration_test']) {
    final folder = Directory(path.join(packageDirectory.path, folderName));
    if (!folder.existsSync()) continue;
    yield* folder
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
  }
}

void _checkRuntimeDependencies(
  Directory workspaceRoot,
  List<_WorkspacePackage> workspacePackages,
  List<String> violations,
) {
  final packageConfigFile = File(
    path.join(workspaceRoot.path, '.dart_tool', 'package_config.json'),
  );
  if (!packageConfigFile.existsSync()) {
    violations.add('Run "flutter pub get" first: .dart_tool/package_config.json is missing');
    return;
  }
  final packageConfig = jsonDecode(packageConfigFile.readAsStringSync()) as Map<String, Object?>;
  final packageRootByName = <String, String>{
    for (final entry in (packageConfig['packages']! as List<Object?>).cast<Map<String, Object?>>())
      entry['name']! as String: path.normalize(
        path.join(
          path.dirname(packageConfigFile.path),
          Uri.parse(entry['rootUri']! as String).toFilePath(),
        ),
      ),
  };
  final workspacePackageNames = workspacePackages.map((package) => package.name).toSet();

  // Collect everything the app ships: dependencies of foodie_app, recursively,
  // ignoring dev dependencies.
  final runtimePackages = <String>{};
  final pending = ['foodie_app'];
  while (pending.isNotEmpty) {
    final packageName = pending.removeLast();
    if (!runtimePackages.add(packageName)) continue;
    final packageRoot = packageRootByName[packageName];
    if (packageRoot == null) continue;
    final pubspecFile = File(path.join(packageRoot, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) continue;
    final pubspec = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final dependencies = pubspec['dependencies'];
    if (dependencies is YamlMap) pending.addAll(dependencies.keys.cast<String>());
  }
  final thirdPartyRuntimePackages = runtimePackages.difference(workspacePackageNames);

  for (final packageName in thirdPartyRuntimePackages) {
    if (_forbiddenRuntimePackages.any((pattern) => pattern.hasMatch(packageName))) {
      violations.add('The app must never ship $packageName (privacy, section 11)');
    }
  }

  final allowlistFile = File(
    path.join(workspaceRoot.path, 'tool', 'allowed_runtime_dependencies.txt'),
  );
  final allowedPackages = allowlistFile
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toSet();
  for (final packageName
      in thirdPartyRuntimePackages.difference(allowedPackages).toList()..sort()) {
    violations.add(
      'New runtime dependency $packageName: review it for network access, then add it to '
      'tool/allowed_runtime_dependencies.txt',
    );
  }
  for (final packageName
      in allowedPackages.difference(thirdPartyRuntimePackages).toList()..sort()) {
    violations.add('$packageName is allowlisted but no longer used; remove it from the allowlist');
  }
}

void _checkSqlCipherSelection(Directory workspaceRoot, List<String> violations) {
  final rootPubspec =
      loadYaml(File(path.join(workspaceRoot.path, 'pubspec.yaml')).readAsStringSync()) as YamlMap;
  final hooks = rootPubspec['hooks'];
  final userDefines = hooks is YamlMap ? hooks['user_defines'] : null;
  final sqliteDefines = userDefines is YamlMap ? userDefines['sqlite3'] : null;
  final source = sqliteDefines is YamlMap ? sqliteDefines['source'] : null;
  if (source != 'sqlcipher') {
    violations.add(
      'pubspec.yaml must set hooks.user_defines.sqlite3.source: sqlcipher (decision D2)',
    );
  }
}

void _checkAndroidReleaseManifest(Directory workspaceRoot, List<String> violations) {
  final mainManifest = File(
    path.join(
      workspaceRoot.path,
      'apps',
      'foodie_app',
      'android',
      'app',
      'src',
      'main',
      'AndroidManifest.xml',
    ),
  );
  final manifestText = mainManifest.readAsStringSync();
  final internetDeclarations = RegExp(
    r'<uses-permission[^>]*android\.permission\.INTERNET[^>]*>',
  ).allMatches(manifestText);
  for (final declaration in internetDeclarations) {
    if (!declaration.group(0)!.contains('tools:node="remove"')) {
      violations.add('The main AndroidManifest.xml must not request INTERNET (section 11)');
    }
  }
  if (!manifestText.contains('android:allowBackup="false"')) {
    violations.add('The main AndroidManifest.xml must set android:allowBackup="false"');
  }
}
