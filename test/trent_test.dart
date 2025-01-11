import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trent/state.dart';

class TestStateMachineTypes extends Equatable {
  @override
  List<Object> get props => [];
}

class A extends TestStateMachineTypes {
  final int value;
  A(this.value);

  @override
  List<Object> get props => [value];
}

class B extends TestStateMachineTypes {}

class C extends TestStateMachineTypes {}

class TestStateMachine extends Trent<TestStateMachineTypes> {
  TestStateMachine() : super(A(1));

  @override
  void test() {
    print('Test');
    emit(B());
    // emit(32);
  }

  void simulateC() {
    // do business logic, based on states and logic, emit states
    emit(C());
  }

  void incAState() => lastStateOf<A>().match(some: (val) => emit(A(val.value + 1)), none: () {});
}

void main() {
  test('Generated StateMachine transitions', () async {
    final sm = TestStateMachine();

    final completer1 = Completer();

    List<TestStateMachineTypes> emittedStates = [];
    int expectedStates = 3;

    final subscription = sm.stateStream.listen((state) {
      emittedStates.add(state);
      if (emittedStates.length == expectedStates) {
        completer1.complete();
      }
    });

    expect(sm.currentState, A(1));

    sm.emit(B());
    expect(sm.currentState, B());

    sm.simulateC();
    expect(sm.currentState, C());

    sm.emit(A(42));
    expect(sm.currentState, A(42));

    await completer1.future;

    expect(emittedStates, [B(), C(), A(42)]);

    await subscription.cancel();
    sm.dispose();
  });
}
