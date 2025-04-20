import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trent/src/logic/mappers.dart';
import 'package:trent/trent.dart';

final GetIt _serviceLocator = GetIt.instance;

/// Instead of a `List<Object>` that loses type info,
/// we'll store typed providers directly:
final List<SingleChildWidget> _allTrentProviders = [];

ChangeNotifierProvider register<T extends ChangeNotifier>(T trent,
    {bool debug = false}) {
  if (!_serviceLocator.isRegistered<T>()) {
    _serviceLocator.registerSingleton<T>(trent);
  }

  // Also add a typed provider for this T to our list.
  _allTrentProviders.add(
    ChangeNotifierProvider<T>.value(value: trent),
  );

  // if debug is true, we want to start listening to the trent in my web server?
  if (debug) {
    trent.addListener(() {
      debugPrint('Trent updated: $trent');
    });
  }

  return ChangeNotifierProvider<T>.value(
    value: _serviceLocator.get<T>(),
  );
}

/// Retrieve a Trent synchronously from GetIt
T get<T extends ChangeNotifier>() => _serviceLocator.get<T>();

/// A manager widget that injects all registered trents into the widget tree.
class TrentManager extends StatefulWidget {
  final Widget child;

  /// A list of functions that return typed `Trent` instances.
  final List<ChangeNotifierProvider>? trents;

  const TrentManager({super.key, required this.child, this.trents});

  @override
  State<TrentManager> createState() => _TrentManagerState();
}

class _TrentManagerState extends State<TrentManager> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ..._allTrentProviders,
        if (widget.trents != null) ...widget.trents!,
      ],
      child: widget.child,
    );
  }
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
