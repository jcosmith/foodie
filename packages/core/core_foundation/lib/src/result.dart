import 'package:meta/meta.dart';

/// Base class for expected, recoverable failures such as "not enough left in the bag".
///
/// Failures are values, not exceptions: use cases return them inside a [Result]
/// so callers must handle them. Exceptions stay reserved for programming errors
/// and broken infrastructure.
@immutable
abstract base class Failure {
  const Failure();

  /// A developer-facing explanation; never shown to users (screens map
  /// failures to localized messages).
  String get debugDescription;

  @override
  String toString() => '$runtimeType: $debugDescription';
}

/// Either a successful value or a failure.
@immutable
sealed class Result<TValue, TFailure extends Failure> {
  const Result();

  const factory Result.success(TValue value) = SuccessfulResult<TValue, TFailure>;

  const factory Result.failure(TFailure failure) = FailedResult<TValue, TFailure>;

  bool get isSuccess => this is SuccessfulResult<TValue, TFailure>;

  bool get isFailure => this is FailedResult<TValue, TFailure>;

  /// The value, or `null` for a failure.
  TValue? get valueOrNull => switch (this) {
    SuccessfulResult(:final value) => value,
    FailedResult() => null,
  };

  /// The failure, or `null` for a success.
  TFailure? get failureOrNull => switch (this) {
    SuccessfulResult() => null,
    FailedResult(:final failure) => failure,
  };

  /// Calls [onSuccess] or [onFailure] and returns what it returns.
  TOutput fold<TOutput>({
    required TOutput Function(TValue value) onSuccess,
    required TOutput Function(TFailure failure) onFailure,
  }) => switch (this) {
    SuccessfulResult(:final value) => onSuccess(value),
    FailedResult(:final failure) => onFailure(failure),
  };

  /// Transforms the value of a success; failures pass through unchanged.
  Result<TMapped, TFailure> mapValue<TMapped>(TMapped Function(TValue value) transform) =>
      switch (this) {
        SuccessfulResult(:final value) => Result.success(transform(value)),
        FailedResult(:final failure) => Result.failure(failure),
      };
}

final class SuccessfulResult<TValue, TFailure extends Failure> extends Result<TValue, TFailure> {
  const SuccessfulResult(this.value);

  final TValue value;

  @override
  bool operator ==(Object other) =>
      other is SuccessfulResult<TValue, TFailure> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SuccessfulResult($value)';
}

final class FailedResult<TValue, TFailure extends Failure> extends Result<TValue, TFailure> {
  const FailedResult(this.failure);

  final TFailure failure;

  @override
  bool operator ==(Object other) =>
      other is FailedResult<TValue, TFailure> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'FailedResult($failure)';
}

/// Value of a [Result] that carries no data, such as a completed deletion.
final class Unit {
  const Unit._();
}

/// The only [Unit] value.
const Unit unit = Unit._();
