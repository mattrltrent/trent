import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:trent/trent.dart';

/// Retrieve a Trent by its type with 1-time value (non-reactive).
T read<T extends Trents>(BuildContext context) {
  return Provider.of<T>(context, listen: false);
}

/// Retrieve a Trent by its type reactively.
T watch<T extends Trents>(BuildContext context) {
  return Provider.of<T>(context, listen: true);
}
