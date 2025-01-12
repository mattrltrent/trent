import 'package:trent/trent.dart';

class CalculatorStates extends Equatable {
  @override
  List<Object> get props => [];
}

class BlankScreen extends CalculatorStates {}

class InvalidCalculation extends CalculatorStates {
  final String message;
  InvalidCalculation(this.message);

  @override
  List<Object> get props => [message];
}

class Division extends CalculatorStates {
  final int numerator;
  final int denominator;
  Division(this.numerator, this.denominator);

  @override
  List<Object> get props => [numerator, denominator];
}

class CalculationResult extends CalculatorStates {
  final double result;
  CalculationResult(this.result);

  @override
  List<Object> get props => [result];
}

class CalculatorTrent extends Trent<CalculatorStates> {
  CalculatorTrent() : super(BlankScreen());

  void divide(int numerator, int denominator) {
    if (denominator == 0) {
      emit(InvalidCalculation('Cannot divide by zero'));
    } else {
      emit(Division(numerator, denominator));
      set(CalculationResult(numerator / denominator));
    }
  }
}
