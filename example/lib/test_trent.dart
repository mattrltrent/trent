import 'package:trent/trent.dart';

class AuthTrentTypes extends Equatable {
  @override
  List<Object> get props => [];
}

class A extends AuthTrentTypes {
  final int value;
  A(this.value);

  @override
  List<Object> get props => [value];
}

class B extends AuthTrentTypes {
  final int value;
  B(this.value);

  @override
  List<Object> get props => [];
}

class C extends AuthTrentTypes {}

// class AuthTrent extends Trent<AuthTrentTypes> {
//   AuthTrent() : super(A(1)); // Set initial state

//   void businessLogicHere() {
//     //
//     // Business logic here
//     //

//     // Based on the business logic, you can alter state
//     // using build-in methods like:
//     emit(C());
//     set(A(2));
//     alert(B(3));
//     getExStateAs<A>().match(some: (val) {
//       // Do something
//     }, none: () {
//       // Do something
//     });
//     getCurrStateAs<A>().match(some: (val) {
//       // Do something
//     }, none: () {
//       // Do something
//     });
//     currStateMapper
//       ..all((state) {
//         // Do something
//       })
//       ..as<A>((state) {
//         // Do something
//       })
//       ..as<B>((state) {
//         // Do something
//       })
//       ..as<C>((state) {
//         // Do something
//       });

//     print(currState); // You can also access the raw state
//   }

//   /// ... More business functions ...
// }

class AuthTrent extends Trent<AuthTrentTypes> {
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
