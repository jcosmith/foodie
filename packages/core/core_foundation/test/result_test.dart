import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

final class _NotEnoughLeftFailure extends Failure {
  const _NotEnoughLeftFailure();

  @override
  String get debugDescription => 'not enough left';
}

void main() {
  group('Result', () {
    test('success exposes its value and maps it', () {
      const Result<int, Failure> result = Result.success(800);
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 800);
      expect(result.mapValue((value) => value * 2).valueOrNull, 1600);
    });

    test('failure exposes its failure and skips mapping', () {
      const Result<int, Failure> result = Result.failure(_NotEnoughLeftFailure());
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<_NotEnoughLeftFailure>());
      expect(result.mapValue((value) => value * 2).isFailure, isTrue);
    });

    test('fold picks the matching branch', () {
      const Result<int, Failure> result = Result.failure(_NotEnoughLeftFailure());
      final description = result.fold(
        onSuccess: (value) => 'ok $value',
        onFailure: (failure) => failure.debugDescription,
      );
      expect(description, 'not enough left');
    });
  });
}
