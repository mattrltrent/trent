import 'package:get_it/get_it.dart';

import '../../trent.dart';

final GetIt _sl = GetIt.instance;

/// A manager that initializes and registers all Trents.
class TrentManager {
  final List<Trents> _trents;

  TrentManager(this._trents);

  /// Initialize and register all Trents.
  void init() {
    for (final sm in _trents) {
      final type = sm.runtimeType;
      _sl.registerLazySingleton<Trents>(
        () => sm,
        instanceName: type.toString(),
        dispose: (instance) => instance.dispose(),
      );
    }
  }

  /// Dispose all Trents.
  void dispose() {
    for (final sm in _trents) {
      sm.dispose();
    }
  }
}

/// Retrieve a Trent by its type.
T get<T>() {
  final typeName = T.toString();
  return _sl.get<Trents>(instanceName: typeName) as T;
}
