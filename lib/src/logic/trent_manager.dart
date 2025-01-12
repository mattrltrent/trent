import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../trent.dart';

/// A manager that initializes and registers all Trents.
class TrentManager extends StatelessWidget {
  const TrentManager({
    super.key,
    required this.child,
    required this.trents,
  });

  final Widget child;
  final List<Trent> trents;

  @override
  Widget build(BuildContext context) {
    for (final sm in trents) {
      debugPrint('Registering Trent: ${sm.runtimeType}');
    }
    return MultiProvider(
      providers: [
        for (final sm in trents) ChangeNotifierProvider(create: (_) => sm),
      ],
      child: child,
    );
  }
}
