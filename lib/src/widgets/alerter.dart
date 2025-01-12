import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trent/trent.dart';

/// A generic Alerter widget that listens to alert events from a Trent.
class Alerter<TrentType extends Trents<StateType>, StateType> extends StatefulWidget {
  final void Function(AlerterStateWidgetMapper<StateType> mapper) handlers;
  final Widget child;

  const Alerter({
    super.key,
    required this.handlers,
    required this.child,
  });

  @override
  AlerterState<TrentType, StateType> createState() => AlerterState<TrentType, StateType>();
}

class AlerterState<TrentType extends Trents<StateType>, StateType> extends State<Alerter<TrentType, StateType>> {
  late final TrentType sm = read<TrentType>(context);
  late final AlerterStateWidgetMapper<StateType> mapper;

  @override
  void initState() {
    super.initState();
    mapper = AlerterStateWidgetMapper<StateType>();
    widget.handlers(mapper);

    // Listen to the alert stream
    sm.alertStream.listen((state) {
      // Handle the alert state
      if (!mapper._handle(state)) {
        mapper._handleAll(state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// A mapper that dynamically maps alert states to callback functions.
class AlerterStateWidgetMapper<StateType> {
  final Map<Type, void Function(StateType state)> _alertHandlers = {};
  void Function(StateType state)? _allHandler;

  /// Register a callback for a specific state type
  void as<T extends StateType>(void Function(T state) callback) {
    _alertHandlers[T] = (state) => callback(state as T);
  }

  /// Register a catch-all handler
  void all(void Function(StateType state) callback) {
    _allHandler = callback;
  }

  /// Handle an alert state by invoking the corresponding callback
  bool _handle(StateType state) {
    final handler = _alertHandlers[state.runtimeType];
    if (handler != null) {
      handler(state);
      return true;
    }
    return false;
  }

  /// Handle an alert with the "all" handler
  void _handleAll(StateType state) {
    _allHandler?.call(state);
  }
}
