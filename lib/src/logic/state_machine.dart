import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trent/src/types/option_type.dart';

abstract class BaseStateMachine<Base> {
  BaseStateMachine(this._state)
      : _stateSubject = BehaviorSubject<Base>.seeded(_state),
        _alertSubject = BehaviorSubject<Base>() {
    _updateLastState(_state);
  }

  Base _state;
  final BehaviorSubject<Base> _stateSubject;
  final BehaviorSubject<Base> _alertSubject;
  final Map<Type, Option<Base>> _lastStates = {};

  // Public getters
  Base get currState => _state;
  Stream<Base> get stateStream => _stateSubject.stream;
  Stream<Base> get alertStream => _alertSubject.stream;

  /// Set new state
  void set(Base newState) {
    _updateLastState(newState);
  }

  /// Set new state and emit to stream if the state has changed
  void emit(Base newState) {
    if (_state != newState) {
      _stateSubject.add(newState); // Emit the new state
    }
    _updateLastState(newState); // Update the state and last state
  }

  void alert(Base newState) {
    _alertSubject.add(newState);
  }

  void clearEx(Base state) {
    _lastStates[state.runtimeType] = Option<Base>.none();
  }

  void clearAllExes() {
    _lastStates.clear();
  }

  /// Retrieve the last state of a specific type
  Option<T> getExStateAs<T extends Base>() {
    return _lastStates[T] != null
        ? _lastStates[T]!.match(some: (v) => Option.some(v as T), none: () => Option<T>.none())
        : Option<T>.none();
  }

  Option<T> getCurrStateAs<T extends Base>() {
    return _state.runtimeType == T ? Option.some(_state as T) : Option<T>.none();
  }

  void dispose() {
    _stateSubject.close();
    _alertSubject.close();
  }

  // Private helper to update the last state map
  void _updateLastState(Base newState) {
    _lastStates[newState.runtimeType] = Option.some(newState);
    _state = newState; // Update the current state
  }
}

abstract class Trent<Base extends Equatable> extends BaseStateMachine<Base> {
  Trent(
    super.state,
  );
}
