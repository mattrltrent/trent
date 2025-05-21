import 'package:trent/trent.dart';
import 'package:meta/meta.dart';

class OptimisticAttempt<TState extends EquatableCopyable<TState>, TValue> {
  final TState Function(TState, TValue) _forward;
  final TState Function(TState, TValue) _reverse;
  final Trent<TState> _trent;
  final String tag;
  final String _compositeKey;

  bool _started = false;
  bool _finished = false;

  late TValue? _value;

  DateTime? _createdAt;

  OptimisticAttempt({
    required Trent<TState> trent,
    required this.tag,
    required TState Function(TState, TValue) forward,
    required TState Function(TState, TValue) reverse,
  })  : _trent = trent,
        _reverse = reverse,
        _forward = forward,
        _compositeKey = "${trent.runtimeType}_$tag";

  /// Call this to apply the optimistic update with a value.
  void execute([TValue? value]) {
    if (_started) return;
    _started = true;
    _value = value;
    _createdAt = DateTime.now();

    // Revert previous attempt with the same tag if it exists and is not this
    final prev = registry[_compositeKey];
    if (prev != null && prev != this && prev._started && !prev._finished) {
      final typedPrev = prev as OptimisticAttempt<TState, TValue>;
      _trent.emit(typedPrev._reverse(_trent.state, typedPrev._value as TValue));
      typedPrev._finish();
    }

    _trent.emit(_forward(_trent.state, value as TValue));
    registry[_compositeKey] = this;
  }

  /// Accept the optimistic update with a new value (runs reverse then forward with new value).
  void acceptAs(TValue value) {
    if (!_started || _finished) return;
    if (_isLatest()) {
      // revert optimistic
      _trent.emit(_reverse(_trent.state, _value as TValue));
      // apply new value
      _trent.emit(_forward(_trent.state, value));
      _finish();
    }
  }

  /// Reject the optimistic update and revert the state.
  void reject() {
    if (!_started || _finished) return;
    if (_isLatest()) {
      _trent.emit(_reverse(_trent.state, _value as TValue));
      _finish();
    }
  }

  /// Accepts the optimistic update as committed (locks in the current value).
  void accept() {
    if (!_started || _finished) return;
    if (_isLatest()) {
      _finish();
    }
  }

  void _finish() {
    _finished = true;
    registry.remove(_compositeKey);
  }

  bool _isLatest() => registry[_compositeKey] == this;

  static final Map<String, OptimisticAttempt> registry = {};

  bool get isFinished => _finished;

  /// For internal use by Trent only. Not for public consumption.
  DateTime? get createdAtForTrent => _createdAt;

  @visibleForTesting
  set createdAtForTest(DateTime dt) => _createdAt = dt;
}
