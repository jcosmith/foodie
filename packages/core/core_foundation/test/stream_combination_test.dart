import 'dart:async';

import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

void main() {
  test('emits once both streams have values and on every later change', () async {
    final batches = StreamController<int>();
    final names = StreamController<String>();
    final combined = <String>[];
    final subscription = combineLatestOfTwo(
      batches.stream,
      names.stream,
      (count, name) => '$count $name',
    ).listen(combined.add);

    batches.add(1);
    await Future<void>.delayed(Duration.zero);
    expect(combined, isEmpty);
    names.add('spinach');
    batches.add(2);
    await Future<void>.delayed(Duration.zero);

    expect(combined, ['1 spinach', '2 spinach']);
    await subscription.cancel();
    await batches.close();
    await names.close();
  });
}
