import 'dart:async';

/// Emits [combine] of the latest values of [first] and [second] once both
/// have emitted, and again whenever either emits.
Stream<TResult> combineLatestOfTwo<TFirst, TSecond, TResult>(
  Stream<TFirst> first,
  Stream<TSecond> second,
  TResult Function(TFirst first, TSecond second) combine,
) => Stream.multi((controller) {
  late TFirst latestFirst;
  late TSecond latestSecond;
  var hasFirst = false;
  var hasSecond = false;
  var openStreamCount = 2;

  void emitIfReady() {
    if (hasFirst && hasSecond) controller.add(combine(latestFirst, latestSecond));
  }

  void handleDone() {
    openStreamCount--;
    if (openStreamCount == 0) controller.close();
  }

  final firstSubscription = first.listen(
    (value) {
      latestFirst = value;
      hasFirst = true;
      emitIfReady();
    },
    onError: controller.addError,
    onDone: handleDone,
  );
  final secondSubscription = second.listen(
    (value) {
      latestSecond = value;
      hasSecond = true;
      emitIfReady();
    },
    onError: controller.addError,
    onDone: handleDone,
  );
  controller.onCancel = () async {
    await firstSubscription.cancel();
    await secondSubscription.cancel();
  };
});
