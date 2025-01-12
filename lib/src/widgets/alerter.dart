import 'package:flutter/widgets.dart';
import 'package:trent/src/logic/mappers.dart';
import 'package:trent/trent.dart';

/// A generic Alerter widget that listens to alert events and state changes from a Trent.
class Alerter<TrentType extends Trents<StateType>, StateType> extends StatefulWidget {
  /// Called when an alert state is emitted, using a mapper.
  final void Function(LogicSubTypeMapper<StateType> mapper)? listenAlerts;

  /// Determines whether `listenAlerts` should trigger for a given alert.
  final bool Function(StateType oldAlert, StateType newAlert)? listenAlertsIf;

  /// Called when the normal state changes, using a mapper.
  final void Function(LogicSubTypeMapper<StateType> mapper)? listenStates;

  /// Determines whether `listenStates` should trigger for a given state transition.
  final bool Function(StateType oldState, StateType newState)? listenStatesIf;

  final Widget child;

  const Alerter({
    super.key,
    this.listenAlerts,
    this.listenAlertsIf,
    this.listenStates,
    this.listenStatesIf,
    required this.child,
  });

  @override
  AlerterState<TrentType, StateType> createState() => AlerterState<TrentType, StateType>();
}

class AlerterState<TrentType extends Trents<StateType>, StateType> extends State<Alerter<TrentType, StateType>> {
  late final TrentType sm = get<TrentType>(context);
  late StateType _previousAlert; // Tracks the previous alert state
  late StateType _previousState; // Tracks the previous normal state

  @override
  void initState() {
    super.initState();
    _previousAlert = sm.currState;
    _previousState = sm.currState;

    // Listen to the alert stream
    sm.alertStream.listen((alert) {
      if (widget.listenAlerts != null) {
        final shouldTrigger = widget.listenAlertsIf?.call(_previousAlert, alert) ?? true;
        if (shouldTrigger) {
          final mapper = LogicSubTypeMapper<StateType>(alert);
          widget.listenAlerts!(mapper);
        }
      }
      _previousAlert = alert;
    });

    // Listen to the state stream
    sm.stateStream.listen((state) {
      if (widget.listenStates != null) {
        final shouldTrigger = widget.listenStatesIf?.call(_previousState, state) ?? true;
        if (shouldTrigger) {
          final mapper = LogicSubTypeMapper<StateType>(state);
          widget.listenStates!(mapper);
        }
      }
      _previousState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
