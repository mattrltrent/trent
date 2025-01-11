import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'state_machine_generator.dart';

Builder stateMachineBuilder(BuilderOptions options) {
  return SharedPartBuilder([StateMachineGenerator()], 'state_machine');
}
