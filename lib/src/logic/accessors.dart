import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:trent/src/logic/mappers.dart';
import 'package:trent/trent.dart';

/// Retrieve a Trent by its type with 1-time value (non-reactive).
T get<T extends Trents>(BuildContext context) {
  return Provider.of<T>(context, listen: false);
}

/// Retrieve a Trent by its type reactively.
T watch<T extends Trents>(BuildContext context) {
  return Provider.of<T>(context, listen: true);
}

/// Retrieve a map over the current state of a Trent reactively.
Widget watchMap<T extends Trents<S>, S>(
    BuildContext context, void Function(WidgetSubtypeMapper<S>) configure) {
  final trent = Provider.of<T>(context, listen: true);
  final mapper = WidgetSubtypeMapper<S>(trent.state);

  // Configure the mapper with handlers
  configure(mapper);

  // Return the resolved widget
  return mapper.resolve();
}
