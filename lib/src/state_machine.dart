import 'dart:async';

abstract class StateMachineArgs<Name> {}

class StateMachineCore<Name> {
  StateMachineArgs<Name> _currentState;
  final StreamController<StateMachineArgs<Name>> _stateController =
      StreamController<StateMachineArgs<Name>>.broadcast();

  StateMachineCore(this._currentState);

  StateMachineArgs<Name> get currentState => _currentState;

  /// Transition from one state to another
  void transition<U extends StateMachineArgs<Name>>(U newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  Stream<StateMachineArgs<Name>> get stateStream => _stateController.stream;

  void dispose() {
    _stateController.close();
  }
}
