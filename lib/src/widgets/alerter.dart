import 'package:flutter/widgets.dart';
import 'package:trent/trent.dart';

/// A generic Alerter widget that listens to alert events from a Trent.
class Alerter<Trent extends Trents<State>, State> extends StatelessWidget {
  final void Function(AlerterStateWidgetMapper<State> mapper) _handlers;
  final Widget child;

  Alerter({
    super.key,
    required void Function(AlerterStateWidgetMapper<State>) handlers,
    required this.child,
  }) : _handlers = handlers;

  // Retrieve the Trent dynamically using its Type
  late final sm = get<Trent>();

  @override
  Widget build(BuildContext context) {
    final mapper = AlerterStateWidgetMapper<State>();

    // Register handlers for each alert type
    _handlers(mapper);

    return StreamBuilder<State>(
      stream: sm.alertStream, // Plug into the alert stream
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final alertState = snapshot.data as State;

          mapper._handle(alertState);
          mapper._handleAll(alertState);
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
  void Function(State state)? _allHandler;

  /// Register a callback for a specific state type
  void as<T extends State>(void Function(T state) callback) {
    _alertHandlers[T] = (state) => callback(state as T);
  }

  /// Register a catch-all handler
  void all(void Function(State state) callback) {
    _allHandler = callback;
  }

  /// Handle an alert state by invoking the corresponding callback
  bool _handle(State state) {
    final handler = _alertHandlers[state.runtimeType];
    if (handler != null) {
      handler(state);
      return true;
    }
    return false;
  }

  /// Handle an alert with the "all" handler
  void _handleAll(State state) {
    _allHandler?.call(state);
  }
}
