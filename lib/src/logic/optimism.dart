import 'package:trent/trent.dart';

class OptimisticAttempt<TState extends EquatableCopyable<TState>, TValue> {
  final TState Function(TState, TValue) forward;
  final TState Function(TState, TValue) reverse;
  final Trent<TState> trent;
  final String tag;
  final String compositeKey;

  bool _started = false;
  bool _finished = false;

  late TValue? _value;

  OptimisticAttempt({
    required this.trent,
    required this.tag,
    required this.forward,
    required this.reverse,
  }) : compositeKey = "${trent.runtimeType}_$tag";

  /// Call this to apply the optimistic update with a value.
  void execute([TValue? value]) {
    if (_started) return;
    _started = true;
    _value = value;

    // Revert previous attempt with the same tag if it exists and is not this
    final prev = registry[compositeKey];
    if (prev != null && prev != this && prev._started && !prev._finished) {
      final typedPrev = prev as OptimisticAttempt<TState, TValue>;
      trent.emit(typedPrev.reverse(trent.state, typedPrev._value as TValue));
      typedPrev._finish();
    }

    trent.emit(forward(trent.state, value as TValue));
    registry[compositeKey] = this;
  }

  /// Accept the optimistic update with a new value (runs reverse then forward with new value).
  void acceptAs(TValue value) {
    if (!_started || _finished) return;
    if (_isLatest()) {
      // revert optimistic
      trent.emit(reverse(trent.state, _value as TValue));
      // apply new value
      trent.emit(forward(trent.state, value));
      _finish();
    }
  }

  /// Reject the optimistic update and revert the state.
  void reject() {
    if (!_started || _finished) return;
    if (_isLatest()) {
      trent.emit(reverse(trent.state, _value as TValue));
      _finish();
    }
  }

  void _finish() {
    _finished = true;
    registry.remove(compositeKey);
  }

  bool _isLatest() => registry[compositeKey] == this;

  static final Map<String, OptimisticAttempt> registry = {};
}
