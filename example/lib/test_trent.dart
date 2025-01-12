import 'package:trent/trent.dart';

class TestTrentTypes extends Equatable {
  @override
  List<Object> get props => [];
}

class A extends TestTrentTypes {
  final int value;
  A(this.value);

  @override
  List<Object> get props => [value];
}

class B extends TestTrentTypes {
  final int value;
  B(this.value);

  @override
  List<Object> get props => [];
}

class C extends TestTrentTypes {
  final int value;
  C(this.value);

  @override
  List<Object> get props => [];
}

class AuthTrent extends Trent<TestTrentTypes> {
  AuthTrent() : super(A(1));

  void testBizFunc1() {
    emit(A(2));
  }

  void testBizFunc2() {
    emit(B(3));
  }

  void testBizFunc3() {
    emit(C(4));
  }
}
