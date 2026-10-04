# Foodie

A multilingual Flutter app for managing a household's inventory: what is in the freezer, fridge, pantry and cupboards, what to use first, and what to buy. It started with the freezer, which is what the app covers today; the other storage places are planned. Your data never leaves the app.

[`docs/README.md`](docs/README.md) describes the mission, principles and scope. The design lives in [`docs/design/`](docs/design): the architecture document is the plan this code follows, and the UI examples show the screens.

## Repository layout

```
pubspec.yaml              workspace root: lists every package, selects the SQLCipher build of SQLite
analysis_options.yaml     shared strict lints
tool/                     architecture check, workspace tasks, feature package template
apps/foodie_app/         app shell: start-up, module registry, router, home dashboard
packages/core/            shared infrastructure (foundation, events, database, preferences,
                          localization, design system, notifications, module contract)
packages/features/        one package per user-facing capability
```

Every feature plugs into the shell through the `FeatureModule` contract in `core_module_contract` and is registered in `apps/foodie_app/lib/src/modules/module_registry.dart`.

## Working on the code

Requires Flutter 3.47 or later.

```sh
flutter pub get                                    # once, at the repository root
dart run tool/check_architecture.dart              # dependency, plugin and privacy rules
dart analyze --fatal-infos
dart run tool/workspace_tasks.dart generate        # Drift code and localizations
dart run tool/workspace_tasks.dart test            # every package's tests
dart run tool/create_feature_package.dart meal_planning MealPlanning
```

Generated files (`*.g.dart`, `lib/src/l10n/generated/`) are committed; CI checks that they are up to date.

### Database changes

The schema lives in `packages/core/core_database`. To change it, edit the tables, bump `schemaVersion` in `application_database.dart`, then run in that package:

```sh
dart run build_runner build
dart run drift_dev make-migrations
```

and add the migration step. The generated tests check every upgrade path.

## Privacy by construction

- The Android release build has no `INTERNET` permission, so the operating system blocks all network access. CI builds the release APK and fails if the permission appears.
- The database is encrypted with SQLCipher; its key stays in the Keychain or Keystore of this device only.
- Android Auto Backup and iCloud device backups are switched off for app data. Data only leaves the phone through the app's own backup export, encrypted with a password unless the user chooses none.
- `tool/allowed_runtime_dependencies.txt` lists every third-party package the app ships; adding one fails CI until it has been reviewed and added.

## Releases

The app version lives in `apps/foodie_app/pubspec.yaml`. To release it, write `docs/release-notes/<version>.md` and push the tag `v<version>` (or create the release with that tag on github.com). The Release workflow checks that the tag matches the app version, builds the Android release APK, applies the same privacy checks as CI, publishes the release with those notes and attaches `freezer-<version>.apk` with its SHA-256 checksum.

The release APK is still signed with the Android debug key. Android only installs an update over an app signed with the same key, so switching to a real release key later means uninstalling, which deletes the data on the phone; export a backup first.
