import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rolls back every write when the action throws', () async {
    final database = createInMemoryApplicationDatabase();
    final transactionRunner = DriftTransactionRunner(database);
    final updatedAt = DateTime.utc(2026, 10, 2);

    await expectLater(
      transactionRunner.runInTransaction(() async {
        await database.preferencesDao.writeEncodedValue(
          preferenceKey: 'test.first',
          encodedValue: '1',
          updatedAt: updatedAt,
        );
        throw StateError('something went wrong half way');
      }),
      throwsStateError,
    );

    expect(await database.preferencesDao.readEncodedValue('test.first'), isNull);
    await database.close();
  });

  test('preference entries can be watched, overwritten and removed', () async {
    final database = createInMemoryApplicationDatabase();
    final preferencesDao = database.preferencesDao;
    final updatedAt = DateTime.utc(2026, 10, 2);
    Future<String?> currentlyWatchedValue() => preferencesDao.watchEncodedValue('test.theme').first;

    expect(await currentlyWatchedValue(), isNull);
    await preferencesDao.writeEncodedValue(
      preferenceKey: 'test.theme',
      encodedValue: 'dark',
      updatedAt: updatedAt,
    );
    expect(await currentlyWatchedValue(), 'dark');
    await preferencesDao.writeEncodedValue(
      preferenceKey: 'test.theme',
      encodedValue: 'light',
      updatedAt: updatedAt,
    );
    expect(await currentlyWatchedValue(), 'light');
    await preferencesDao.removeEntry('test.theme');
    expect(await currentlyWatchedValue(), isNull);
    await database.close();
  });
}
