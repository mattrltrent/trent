import 'package:flutter/widgets.dart';
import 'package:trent/src/logic/mappers.dart';
import 'package:trent/trent.dart';

/// A generic Digester widget that listens to state changes from a Trent.
class Digester<TrentType extends Trents<StateType>, StateType> extends StatelessWidget {
  /// A callback to build widgets dynamically for each state type.
  final void Function(WidgetSubtypeMapper<StateType> mapper) child;

  const Digester({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Retrieve the Trent instance dynamically from the context
    final sm = get<TrentType>(context);
    final mapper = WidgetSubtypeMapper<StateType>(sm.currState);

    // Register handlers for each state type
    child(mapper);

    return StreamBuilder<StateType>(
      stream: sm.stateStream, // Plug into the Trent's state stream
      initialData: sm.currState, // Provide the initial state
      builder: (context, snapshot) {
        // Resolve the widget for the current state
        return mapper.resolve();
      },
    );
  }
}
