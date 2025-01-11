import 'package:flutter/widgets.dart';
import 'package:trent/trent.dart';

/// A generic Alerter widget that listens to alert events from a StateMachine.
class Alerter<StateMachine extends BaseStateMachine<State>, State> extends StatelessWidget {
  final void Function(AlerterStateWidgetMapper<State> mapper) handlers;
  final Widget child;

  Alerter({
    super.key,
    required this.handlers,
    required this.child,
  });

  // Retrieve the state machine dynamically using its Type
  late final sm = get<StateMachine>();

  @override
  Widget build(BuildContext context) {
    final mapper = AlerterStateWidgetMapper<State>();

    // Register handlers for each alert type
    handlers(mapper);

    return StreamBuilder<State>(
      stream: sm.alertStream, // Plug into the alert stream
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final alertState = snapshot.data as State;

          // Trigger the appropriate handler for the alert
          mapper.handle(alertState);
        }

        // Return the child widget unchanged
        return child;
      },
    );
  }
}

/// A mapper that dynamically maps alert states to callback functions.
class AlerterStateWidgetMapper<State> {
  final Map<Type, void Function(State state)> _alertHandlers = {};

  /// Register a callback for a specific state type
  void alert<T extends State>(void Function(T state) callback) {
    _alertHandlers[T] = (state) => callback(state as T);
  }

  /// Handle an alert state by invoking the corresponding callback
  void handle(State state) {
    final handler = _alertHandlers[state.runtimeType];
    if (handler != null) {
      handler(state);
    }
  }
}
