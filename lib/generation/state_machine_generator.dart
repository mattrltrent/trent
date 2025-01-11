import 'dart:async';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:trent/generation/state_machine_annotation.dart';

class StateMachineGenerator extends GeneratorForAnnotation<StateMachine> {
  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@StateMachine() can only be applied to classes.',
        element: element,
      );
    }

    final buffer = StringBuffer();
    final className = element.name;
    final stateMachineName = annotation.peek('name')?.stringValue ?? 'DefaultStateMachine';

    // Generate state class with equatable logic
    final fields = element.fields
        .map((field) => 'final ${field.type.getDisplayString(withNullability: false)} ${field.name};')
        .join('\n');
    final equatableProps = element.fields.map((field) => field.name).join(', ');

    buffer.writeln('class $className {');
    buffer.writeln(fields);
    buffer.writeln('const $className({${element.fields.map((field) => "required this.${field.name}").join(", ")}});');
    buffer.writeln('@override List<Object?> get props => [$equatableProps];');
    buffer.writeln('}');

    // Generate transition extensions
    buffer.writeln('extension ${className}StateMachineExtensions on StateMachineCore<$stateMachineName> {');
    buffer.writeln('  void transitionTo$className($className newState) {');
    buffer.writeln('    transition<$className>(newState);');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }
}
