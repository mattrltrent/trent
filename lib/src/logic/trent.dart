import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trent/src/logic/mappers.dart';
import 'package:trent/src/types/async_completed.dart';
import 'package:trent/src/types/option.dart';
import 'package:async/async.dart';
import 'package:uuid/uuid.dart';

/// A generic, abstract Trent that manages state transitions.
abstract class Trents<Base> extends ChangeNotifier {
  Trents(this._state)
      : _stateSubject = BehaviorSubject<Base>.seeded(_state),
        _alertSubject = BehaviorSubject<Base>(),
        _initialState = _state {
    _updateLastState(_state);
  }

  String _sessionToken = const Uuid().v4();

  /// Under-the-hood session token getter incase it's needed for reference.
  String get sessionToken => _sessionToken;

  final List<CancelableOperation<void>> _ops = [];

  /// The current state.
  Base _state;

  final Base _initialState;

  /// The stream controller for the state.
  final BehaviorSubject<Base> _stateSubject;

  /// The stream controller for the alert stream.
  final BehaviorSubject<Base> _alertSubject;

  /// A map of the last state of each type.
  final Map<Type, Option<Base>> _lastStates = {};

  /// Getter method for the current state.
  Base get state => _state;

  /// Getter method for the current state by type.
  LogicSubTypeMapper<Base> get stateMap => LogicSubTypeMapper<Base>(_state);

  /// Getter method for the state stream. Usually not used directly.
  Stream<Base> get stateStream => _stateSubject.stream;

  /// Getter method for the alert stream. Usually not used directly.
  Stream<Base> get alertStream => _alertSubject.stream;

  /// Set a new state WITHOUT emitting to the stream. This means the UI will not be updated.
  void set(Base newState) {
    _updateLastState(newState);
  }

  /// Reset the Trent to its initial state.
  ///
  /// All last states are cleared.
  void reset({bool cancelAsyncOps = true}) {
    if (cancelAsyncOps) {
      for (var op in _ops) {
        op.cancel();
      }
      _ops.clear();
      _sessionToken = const Uuid().v4();
    }
    clearAllExes();
    emit(_initialState);
    _updateLastState(_initialState);
  }

  /// Wrap any Trent function in this method to ensure it can be
  /// optionally cancelled if the Trent is reset.
  ///
  /// This ensures no "leakage" of async operations that are not cancelled
  /// across Trent resets, and the result is wrapped in an [AsyncCompleted]
  /// to safely distinguish between completed and cancelled/stale executions.
  Future<AsyncCompleted<T>> cancelableAsyncOp<T>(
      Future<T> Function() work) async {
    final captured = _sessionToken;
    final op = CancelableOperation<T>.fromFuture(work());
    _ops.add(op);

    try {
      final result = await op.valueOrCancellation(null);
      final isStale = captured != _sessionToken;

      if (result == null || isStale) {
        return AsyncCompleted.withCancelled();
      } else {
        return AsyncCompleted.withCompleted(result);
      }
    } finally {
      _ops.remove(op);
    }
  }

  /// Emit a new state to the stream. This WILL update the UI.
  ///
  /// Does not emit if and only if the new state is the same as the current state (ie: old: A(val: 55), new A(val: 55)).
  void emit(Base newState) {
    if (_state != newState) {
      _stateSubject.add(newState);
      _state = newState;
      notifyListeners(); // Notify listeners about the change
    }
    _updateLastState(newState);
  }

  /// Sends a one-time alert of some Trent state to an [Alerter] widget.
  ///
  /// This state will NOT be stored in the last state map, nor will it be emitted to the state stream, nor will it update the current state.
  /// This is useful for one-time alerts that do not need to be stored, updated, or otherwise managed, such as a notification.
  void alert(Base newState) {
    _alertSubject.add(newState);
  }

  /// Clears the last state of a specific type.
  void clearEx(Base state) {
    // if in there, remove it
    if (_lastStates[state.runtimeType] != null) {
      _lastStates.remove(state.runtimeType);
    }
  }

  /// Clears all last states.
  void clearAllExes() {
    _lastStates.clear();
  }

  /// Retrieve the last state of a specific type.
  ///
  /// For example if used with [T] as [A], this will return A() if A was used in the past sometime before the current state. It will return None if A was never used.
  ///
  /// This is useful if you don't want to "lose" the last state of a specific state when quickly going to/from different states. For example, if
  /// you have a data state D(value: 10) and you quickly need to switch to state Loading() and back to D, you can use this method to get the last state of D
  /// to return to D(value: 10) instead of D(value: some_value_you_must_define).
  Option<T> getExStateAs<T extends Base>() {
    return _lastStates[T] != null
        ? _lastStates[T]!.match(
            some: (v) => Option.some(v as T), none: () => Option<T>.none())
        : Option<T>.none();
  }

  /// Retrieve the current state as a specific type.
  ///
  /// Will return None if the current state is not of the specified type.
  Option<T> getCurrStateAs<T extends Base>() {
    return _state.runtimeType == T
        ? Option.some(_state as T)
        : Option<T>.none();
  }

  /// Dispose of the Trent.
  @override
  void dispose() {
    _stateSubject.close();
    _alertSubject.close();
    super.dispose();
  }

  /// Updates the last state map with the new state.
  void _updateLastState(Base newState) {
    _lastStates[newState.runtimeType] = Option.some(newState);
    _state = newState;
  }
}

abstract class EquatableCopyable<T> extends Equatable implements Copyable<T> {}

abstract class Copyable<T> {
  T copyWith();
}

/// A generic Trent that manages state transitions.
abstract class Trent<Base extends EquatableCopyable<Base>>
    extends Trents<Base> {
  Trent(super.state);
}
