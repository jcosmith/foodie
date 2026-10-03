import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/src/domain/layout_name_policy.dart';
import 'package:feature_storage_layout/src/domain/storage_layout_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an empty name goes back to the default name', () {
    final result = LayoutNamePolicy.validate(enteredName: '   ', siblingDisplayNames: const []);

    expect(result, const Result<String?, StorageLayoutFailure>.success(null));
  });

  test('trims the name the user typed', () {
    final result = LayoutNamePolicy.validate(
      enteredName: '  Bread & sweets ',
      siblingDisplayNames: const ['Drawer 1'],
    );

    expect(result.valueOrNull, 'Bread & sweets');
  });

  test('refuses names longer than 30 characters', () {
    final result = LayoutNamePolicy.validate(enteredName: 'x' * 31, siblingDisplayNames: const []);

    expect(result.failureOrNull, isA<LayoutNameTooLong>());
  });

  test('counts an emoji as one character', () {
    final result = LayoutNamePolicy.validate(
      enteredName: '${'x' * 29}🍦',
      siblingDisplayNames: const [],
    );

    expect(result.isSuccess, isTrue);
  });

  test('refuses a name a sibling already shows, ignoring case', () {
    final result = LayoutNamePolicy.validate(
      enteredName: 'drawer 2',
      siblingDisplayNames: const ['Drawer 2', 'Drawer 3'],
    );

    expect(result.failureOrNull, isA<LayoutNameAlreadyTaken>());
  });
}
