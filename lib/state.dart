import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:trent/src/functional_programming.dart';

// ===== PKG SIDE =====

// class StateFor {
//   final Type logicClass;
//   const StateFor(this.logicClass);
// }

abstract class BaseStateMachine<Base> {
  BaseStateMachine(this._state) {
    _updateLastState(_state);
  }

  Base _state;
  final _stateController = StreamController<Base>.broadcast();
  final Map<Type, Option<Base>> _lastStates = {};

  Base get currentState => _state;

  Stream<Base> get stateStream => _stateController.stream;

  /// Set new state
  void set(Base newState) {
    _updateLastState(newState);
  }

  /// Set new state and emit to stream if the state has changed
  void emit(Base newState) {
    if (_state != newState) {
      _stateController.add(newState); // Emit the new state
      _updateLastState(newState); // Update the state and last state
    } else {
      print('State has not changed');
    }
  }

  /// Retrieve the last state of a specific type
  Option<T> lastStateOf<T extends Base>() {
    return _lastStates[T] as Option<T>? ?? Option.none();
  }

  void dispose() {
    _stateController.close();
  }

  // Private helper to update the last state map
  void _updateLastState(Base newState) {
    _lastStates[newState.runtimeType] = Option.some(newState);
    _state = newState;
  }
}

// todo: a way to force the user to implement the logic
abstract class StateMachineLogic {
  void test();
}

abstract class Trent<Base extends Equatable> extends BaseStateMachine<Base> implements StateMachineLogic {
  Trent(
    super.state,
  );
}

// extension Transitions<Base> on BaseStateMachine<Base> {
//   // function that returns all subclasses of Base
//   // so I can do things like TestStateMachine.states((a) => {}, (b) => {}, (c) => {});
// }

// // ===== USER SIDE =====

// class TestStateMachineTypes extends Equatable {
//   @override
//   List<Object> get props => [];
// }

// class A extends TestStateMachineTypes {
//   final int value;
//   A(this.value);

//   @override
//   List<Object> get props => [value];
// }

// class B extends TestStateMachineTypes {}

// class C extends TestStateMachineTypes {}

// class TestStateMachine extends Trent<TestStateMachineTypes> {
//   TestStateMachine() : super(A(1));

//   @override
//   void test() {
//     print('Test');
//     emit(B());
//     // emit(32);
//   }

//   void login() {
//     // do business logic, based on states and logic, emit states
//     emit(C());
//   }
// }

// void main() {
//   final machine = TestStateMachine();

//   // Listen to state changes
//   machine.stateStream.listen((state) {
//     print('New state: $state');
//   });

//   // Emit new states
//   machine.emit(A(1)); // Emits because the state changed
//   machine.emit(B()); // Emits a new state
//   machine.emit(C()); // Updates the state but doesn't notify

//   // Retrieve the last state of a specific type
//   final lastA = machine.lastStateOf<A>();
//   if (lastA.isSome) {
//     print('Last A: ${lastA.unwrap}');
//   } else {
//     print('No last state of type A');
//   }

//   final lastB = machine.lastStateOf<B>();
//   if (lastB.isSome) {
//     print('Last B: ${lastB.unwrap}');
//   }

//   machine.dispose();
// }
