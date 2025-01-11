import 'package:get_it/get_it.dart';

import '../../trent.dart';

final GetIt _sl = GetIt.instance;

class StateMachineManager {
  final List<BaseStateMachine> stateMachines;

  StateMachineManager(this.stateMachines);

  void init() {
    for (final sm in stateMachines) {
      final type = sm.runtimeType;
      _sl.registerLazySingleton<BaseStateMachine>(
        () => sm,
        instanceName: type.toString(),
        dispose: (instance) => instance.dispose(),
      );
    }
  }
}

T get<T>() {
  final typeName = T.toString();
  return _sl.get<BaseStateMachine>(instanceName: typeName) as T;
}
