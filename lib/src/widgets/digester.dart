import 'package:flutter/widgets.dart';
import 'package:trent/trent.dart';

/// A generic Digester widget that listens to state changes from a Trent.
class Digester<Trent extends Trents<S>, S> extends StatefulWidget {
  final void Function(DigesterStateWidgetMapper<S> mapper) handlers;

  const Digester({
    super.key,
    required this.handlers,
  });

  @override
  State<Digester<Trent, S>> createState() => _DigesterState<Trent, S>();
}

class _DigesterState<Trent extends Trents<S>, S> extends State<Digester<Trent, S>> {
  late final Trent sm; // Trent instance

  @override
  void initState() {
    super.initState();
    // Initialize Trent instance using context
    sm = read<Trent>(context);
  }

  @override
  Widget build(BuildContext context) {
    final mapper = DigesterStateWidgetMapper<S>();

    // Register handlers for each state type
    widget.handlers(mapper);

    return StreamBuilder<S>(
      stream: sm.stateStream, // Plug into the Trent's stream
      initialData: sm.currState, // Provide the initial state
      builder: (context, snapshot) {
        // Always expect a valid state since the stream is seeded
        final currentState = snapshot.data as S; // Will never be null

        // Use the mapper to build the widget for the current state or call the "all" handler
        return mapper._build(currentState);
      },
    );
  }
}

/// A mapper that dynamically maps states to their corresponding widgets.
class DigesterStateWidgetMapper<State> {
  final Map<Type, Widget Function(State state)> _widgetBuilders = {};
  Widget Function(State state)? _allHandler;

  void as<T extends State>(Widget Function(T state) builder) {
    _widgetBuilders[T] = (state) => builder(state as T);
  }

  void all(Widget Function(State state) builder) {
    _allHandler = builder;
  }

  Widget _build(State state) {
    final builder = _widgetBuilders[state.runtimeType];
    if (builder != null) {
      return builder(state);
    }
    if (_allHandler != null) {
      return _allHandler!(state);
    }
    return const SizedBox.shrink();
  }
}
