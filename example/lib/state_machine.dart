import 'package:trent/trent.dart';

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

class B extends TestStateMachineTypes {
  final int value;
  B(this.value);

  @override
  List<Object> get props => [];
}

class C extends TestStateMachineTypes {}

class TestStateMachine extends Trent<TestStateMachineTypes> {
  TestStateMachine() : super(A(1));

  void incAState() => getExStateAs<A>().match(some: (val) {
        print("incing!");
        emit(A(val.value + 1));
      }, none: () {
        print("none!");
      });

  void incA99() => emit(A(99));

  void incAFresh() => getCurrStateAs<A>().match(some: (val) {
        print("incing!");
        emit(A(val.value + 1));
      }, none: () {
        print("none!");
      });
  void switchToB() => emit(B(2));

  void alertA55() => alert(A(55));

  void setA200() => set(A(200));

  void alertCurrentStateIfA() => getCurrStateAs<A>().match(some: (val) {
        alert(val);
      }, none: () {
        print("none!");
      });
}
