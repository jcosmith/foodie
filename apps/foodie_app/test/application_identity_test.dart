import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The app is called Foodie everywhere a user or a developer sees its name,
// while the Android application id stays, so an installed app updates in
// place without losing its data (architecture 10.7, "App shell").
void main() {
  String read(String relativePath) => File(relativePath).readAsStringSync();

  test('the app package is foodie_app in apps/foodie_app', () {
    expect(Directory.current.path, endsWith('apps/foodie_app'));
    expect(read('pubspec.yaml'), startsWith('name: foodie_app\n'));
    expect(read('../../pubspec.yaml'), contains('  - apps/foodie_app\n'));
  });

  test('the localized application title is Foodie in every language', () {
    for (final locale in ['en', 'de']) {
      final arb = jsonDecode(read('lib/src/l10n/application_shell_$locale.arb')) as Map;
      expect(arb['applicationTitle'], 'Foodie', reason: locale);
    }
  });

  test('the launcher shows Foodie on Android and iOS', () {
    expect(read('android/app/src/main/res/values/strings.xml'), contains('>Foodie<'));
    expect(read('android/app/src/main/res/values-de/strings.xml'), contains('>Foodie<'));
    final infoPlist = read('ios/Runner/Info.plist');
    expect(infoPlist, contains('<key>CFBundleDisplayName</key>\n\t<string>Foodie</string>'));
    expect(infoPlist, contains('<key>CFBundleName</key>\n\t<string>foodie_app</string>'));
  });

  test('the Android application id is unchanged so updates install over 0.1.x', () {
    expect(
      read('android/app/build.gradle.kts'),
      contains('applicationId = "io.github.jcosmith.freezer_app"'),
    );
  });

  test('the release workflow builds foodie-<version>.apk from apps/foodie_app', () {
    final workflow = read('../../.github/workflows/release.yml');
    expect(workflow, isNot(contains('freezer_app')));
    expect(workflow, contains(r'apk_name="foodie-${version}.apk"'));
    expect(workflow, contains(r'--title "Foodie ${version}"'));
    expect(read('../../.github/workflows/ci.yml'), isNot(contains('freezer_app')));
  });

  test('no Dart code in the shell still uses the freezer name for the app', () {
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart') && !file.path.contains('/generated/'))
        .where(
          (file) => RegExp(
            'Freezer(Application|Theme|Spacing|ColorTokens|ChartColors)',
          ).hasMatch(file.readAsStringSync()),
        )
        .map((file) => file.path)
        .toList();
    expect(offenders, isEmpty);
  });
}
