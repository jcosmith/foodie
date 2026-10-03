// Runs a task in every package of the workspace (decision D3: plain
// workspace scripts instead of melos).
//
// Usage:
//   dart run tool/workspace_tasks.dart generate   # Drift code and localizations
//   dart run tool/workspace_tasks.dart test       # every package's tests
//   dart run tool/workspace_tasks.dart test core_database feature_inventory
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty || !{'generate', 'test'}.contains(arguments.first)) {
    stderr.writeln('Usage: dart run tool/workspace_tasks.dart <generate|test> [package names]');
    exitCode = 64;
    return;
  }
  final task = arguments.first;
  final selectedPackageNames = arguments.skip(1).toSet();
  final packages = _workspacePackages().where(
    (package) => selectedPackageNames.isEmpty || selectedPackageNames.contains(package.name),
  );

  final failedPackages = <String>[];
  for (final package in packages) {
    final commands = switch (task) {
      'generate' => package.generateCommands,
      _ => package.testCommands,
    };
    for (final command in commands) {
      stdout.writeln('\n▶ ${package.name}: ${command.join(' ')}');
      final process = await Process.start(
        command.first,
        command.skip(1).toList(),
        workingDirectory: package.directory.path,
        mode: ProcessStartMode.inheritStdio,
        runInShell: Platform.isWindows,
      );
      if (await process.exitCode != 0) {
        failedPackages.add(package.name);
        break;
      }
    }
  }

  if (failedPackages.isNotEmpty) {
    stderr.writeln('\n$task failed in: ${failedPackages.join(', ')}');
    exitCode = 1;
  } else {
    stdout.writeln('\n$task succeeded.');
  }
}

final class _Package {
  _Package({required this.name, required this.directory, required this.usesFlutter});

  final String name;
  final Directory directory;
  final bool usesFlutter;

  bool _has(String relativePath) =>
      FileSystemEntity.typeSync(path.join(directory.path, relativePath)) !=
      FileSystemEntityType.notFound;

  List<List<String>> get generateCommands => [
    if (_has('build.yaml'))
      ['dart', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    if (_has('l10n.yaml')) ['flutter', 'gen-l10n'],
  ];

  List<List<String>> get testCommands => [
    if (_has('test')) usesFlutter ? ['flutter', 'test'] : ['dart', 'test'],
  ];
}

List<_Package> _workspacePackages() {
  final rootPubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
  return [
    for (final memberPath in (rootPubspec['workspace'] as YamlList).cast<String>())
      _readPackage(Directory(memberPath)),
  ];
}

_Package _readPackage(Directory directory) {
  final pubspec =
      loadYaml(File(path.join(directory.path, 'pubspec.yaml')).readAsStringSync()) as YamlMap;
  final dependencies = pubspec['dependencies'];
  final devDependencies = pubspec['dev_dependencies'];
  bool mentionsFlutter(Object? section) =>
      section is YamlMap && (section.containsKey('flutter') || section.containsKey('flutter_test'));
  return _Package(
    name: pubspec['name'] as String,
    directory: directory,
    usesFlutter: mentionsFlutter(dependencies) || mentionsFlutter(devDependencies),
  );
}
