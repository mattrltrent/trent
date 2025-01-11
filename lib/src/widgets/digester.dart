import 'package:flutter/widgets.dart';
import 'package:trent/trent.dart';

/// A generic Digester widget that maps states of a StateMachine to Widgets.
class Digester<StateMachine extends BaseStateMachine<State>, State> extends StatelessWidget {
  final void Function(DigesterStateWidgetMapper<State> mapper) handlers;

  Digester({
    super.key,
    required this.handlers,
  });

  // Retrieve the state machine dynamically using its Type
  late final sm = get<StateMachine>();

  @override
  Widget build(BuildContext context) {
    final mapper = DigesterStateWidgetMapper<State>();

    // Register handlers for each state type
    handlers(mapper);

    return StreamBuilder<State>(
      stream: sm.stateStream, // Plug into the state machine's stream
      initialData: sm.currState, // Provide the initial state
      builder: (context, snapshot) {
        // Always expect a valid state since the stream is seeded
        final currentState = snapshot.data as State; // will never be null

        // Use the mapper to build the widget for the current state
        return mapper.build(currentState);
      },
    );
  }
}

/// A mapper that dynamically maps states to their corresponding widgets.
class DigesterStateWidgetMapper<State> {
  final Map<Type, Widget Function(State state)> _widgetBuilders = {};

  void state<T extends State>(Widget Function(T state) builder) {
    _widgetBuilders[T] = (state) => builder(state as T);
  }

  Widget build(State state) {
    final builder = _widgetBuilders[state.runtimeType];
    if (builder != null) {
      return builder(state);
    }
    return const SizedBox.shrink();
  }
}
