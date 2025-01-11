import 'package:trent/trent.dart';

class AuthTypes extends Equatable {
  @override
  List<Object> get props => [];
}

class A extends AuthTypes {
  final int value;
  A(this.value);

  @override
  List<Object> get props => [value];
}

class B extends AuthTypes {
  final int value;
  B(this.value);

  @override
  List<Object> get props => [];
}

class C extends AuthTypes {}

class AuthTrent extends Trent<AuthTypes> {
  AuthTrent() : super(A(1));

  void callSomeBizLogic() {
    print("Doing some biz logic");
    // data calls
    emit(C());
  }

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

  void alertB55() => alert(B(55));

  void setA200() => set(A(200));

  void alertCurrentStateIfA() => getCurrStateAs<A>().match(some: (val) {
        alert(val);
      }, none: () {
        print("none!");
      });

  void doDiffThingsIfABC() {
    currStateMapper
      ..all((state) {
        print("Doing all things");
      })
      ..as<A>((state) {
        print("Doing A things");
      })
      ..as<B>((state) {
        print("Doing B things");
      })
      ..as<C>((state) {
        print("Doing C things");
      });
  }
}
