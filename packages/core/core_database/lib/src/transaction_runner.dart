import 'application_database.dart';

/// Runs work atomically. Use cases depend on this interface, not on Drift.
abstract interface class TransactionRunner {
  /// Runs [action] in a transaction; any exception rolls everything back.
  Future<TResult> runInTransaction<TResult>(Future<TResult> Function() action);
}

final class DriftTransactionRunner implements TransactionRunner {
  const DriftTransactionRunner(this._database);

  final ApplicationDatabase _database;

  @override
  Future<TResult> runInTransaction<TResult>(Future<TResult> Function() action) =>
      _database.transaction(action);
}
