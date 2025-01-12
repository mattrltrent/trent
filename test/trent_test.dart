import 'package:flutter_test/flutter_test.dart';
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

class TestTrent extends Trent<TestTrentTypes> {
  TestTrent() : super(A(1));
}

void main() {
  test('service locator', () {
    TrentManager([TestTrent()]).init();
    expect(get<TestTrent>().currState, A(1));
  });
}
