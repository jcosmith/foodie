import 'package:core_foundation/core_foundation.dart';
import 'package:drift/native.dart';

import '../application_database.dart';

/// An unencrypted in-memory database for repository and widget tests.
ApplicationDatabase createInMemoryApplicationDatabase({Clock? clock}) => ApplicationDatabase(
  NativeDatabase.memory(),
  clock: clock ?? FixedClock(DateTime.utc(2026, 10, 2, 12)),
  applicationVersion: 'test',
);
