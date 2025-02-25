import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

final GetIt _serviceLocator = GetIt.instance;

/// Registers a `Trent` instance for later usage.
///
/// This should be done higher up in the widget tree, such as in the `main` function.
ChangeNotifierProvider register<T extends ChangeNotifier>(
  T trent,
) {
  _serviceLocator.registerSingleton<T>(trent);
  return ChangeNotifierProvider<T>(
    create: (_) => _serviceLocator.get<T>(),
  );
}

/// Retrieve a `Trent` by its type with 1-time value (non-reactive).
T get<T extends ChangeNotifier>() {
  return _serviceLocator.get<T>();
}

/// A manager that dynamically registers any number of `Trent` instances.
class TrentManager extends StatelessWidget {
  final Widget child;

  /// A list of functions that return typed `Trent` instances.
  final List<ChangeNotifierProvider> trents;

  const TrentManager({
    super.key,
    required this.child,
    required this.trents,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: trents,
      child: child,
    );
  }
}
