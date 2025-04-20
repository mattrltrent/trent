class AsyncCompleted<T> {
  final T? value;
  final bool wasCancelled;

  AsyncCompleted._({this.value, required this.wasCancelled});

  static AsyncCompleted<T> withCompleted<T>(T value) =>
      AsyncCompleted._(value: value, wasCancelled: false);

  static AsyncCompleted<T> withCancelled<T>() =>
      AsyncCompleted._(wasCancelled: true);

  /// Match on the result.
  /// - `onCancelled` is called if the operation was cancelled or the value is null.
  /// - `onCompleted` is called with the value if it was completed successfully.
  R match<R>(R Function() onCancelled, R Function(T val) onCompleted) {
    return wasCancelled || value == null
        ? onCancelled()
        : onCompleted(value as T);
  }

  /// Optional helpers
  bool isNothing() => wasCancelled || value == null;

  T unwrap() {
    if (isNothing()) {
      throw StateError('Attempted to access cancelled or stale value');
    }
    return value as T;
  }
}
