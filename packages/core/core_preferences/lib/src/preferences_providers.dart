import 'package:core_database/core_database.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:riverpod/riverpod.dart';

import 'preferences_store.dart';

final preferencesStoreProvider = Provider<PreferencesStore>(
  (ref) => DatabasePreferencesStore(
    preferencesDao: ref.watch(preferencesDaoProvider),
    clock: ref.watch(clockProvider),
    logger: ref.watch(localLoggerProvider),
  ),
);
