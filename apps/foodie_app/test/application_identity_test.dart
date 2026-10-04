import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The app is called Foodie everywhere a user or a developer sees its name,
// including its Android application id and iOS bundle id, so installing it
// no longer offers to update the former Freezer app (architecture 10.7,
// "App shell"). Data from Freezer moves over with a backup.
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

  test('the Android and iOS ids are Foodie ids, not the former Freezer app', () {
    final gradle = read('android/app/build.gradle.kts');
    expect(gradle, contains('applicationId = "io.github.jcosmith.foodie"'));
    expect(gradle, contains('namespace = "io.github.jcosmith.foodie"'));
    expect(gradle, isNot(contains('freezer')));
    expect(
      File('android/app/src/main/kotlin/io/github/jcosmith/foodie/MainActivity.kt').existsSync(),
      isTrue,
    );
    expect(read('ios/Runner.xcodeproj/project.pbxproj'), isNot(contains('freezerApp')));
  });

  test('the release build tolerates the ML Kit models it leaves out', () {
    expect(read('android/app/build.gradle.kts'), contains('proguardFiles("proguard-rules.pro")'));
    final rules = read('android/app/proguard-rules.pro');
    for (final script in ['chinese', 'devanagari', 'japanese', 'korean']) {
      expect(rules, contains('-dontwarn com.google.mlkit.vision.text.$script.**'));
    }
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
