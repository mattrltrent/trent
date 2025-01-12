## Trent State Management: Reactive, Simple, Scalable, & Opinionated 🌶️

todo: TESTS BADGE + more

[How To Use: Contrived Calculator Example](#how-to-use-contrived-calculator-example-) • [Full API](#full-api-) • [Example Weather App Code](todo)

### Perks

- 🔥 No `BuildContext` needed — usable in pure Dart.
- 🔥 Built-in dependency injection and service locator.
- 🔥 Utilizes efficient stream-based state management.
- 🔥 Uses [`Equatable`](https://pub.dev/packages/equatable) for customizable equality checks.
- 🔥 Includes custom `Option.Some(...)`/`Option.None()` types for safety.
- 🔥 Clean separation of concerns: UI layer & business logic layer.

### Widget Layer That "Responds" To Your Business Logic States

- `Alerter` widget that listens to one-time state `alert(...)`s from your business logic layer.
- `Digester` widget that builds your UI based on your current business logic state.

### Business Logic Layer

Define custom state classes, then use them in your Trent state manager:

```dart

//
//  Classes A, B, and C defined here 
//

// A single Trent state manager class
class AuthTrent extends Trent<AuthTypes> {
  AuthTrent() : super(A(1)); // Set initial state

  // You can add N number of business logic functions to
  // do logic and alter state
  void businessLogicHere() {
    //
    // Business logic here
    //

    // Based on the business logic, you can alter state
    // using build-in methods like:

    // Emit a new state WITH the UI reacting
    emit(C()); 

    // Set a new state WITHOUT the UI reacting
    set(A(2)); 

    // Alert a temporary state WITHOUT setting it, but
    // being able to listen to it (for things like notifications)
    alert(B(3)); 

    // Switch from one state to the other and back WITHOUT losing
    // the value of the state you transitioned away from
    getExStateAs<A>().match(some: (val) {
      // Do something
    }, none: () {
      // Do something
    });

    // Get the current state as a specific typeg
    getCurrStateAs<A>().match(some: (val) {
      // Do something
    }, none: () {
      // Do something
    });

    // Map over the current state and do things based on the type
    // (not all routes need to be defined)
    currStateMapper
      ..all((state) {
        // Do something
      })
      ..as<A>((state) {
        // Do something
      })
      ..as<B>((state) {
        // Do something
      })
      ..as<C>((state) {
        // Do something
      });

    // Simply access the raw state for custom manipulation
    print(currState); 
  }
  
  /// ... More business functions ...
}
```

## Full API 📚

### Widget Layer Built-in Widgets

- `Alerter` widget that listens to one-time state `alert(...)`s from your business logic layer. This is good if your business logic needs to "quickly send off a state without saving it". An example would be you having `Loading`, `Data`, and `WarningNotification` states. You may be in `Data` state, but want to send off a quick `WarningNotification` state without having to throw away your `Data` state. This is what an `alert(WarningNotification(...))` is good for.

  ```dart
  // AuthTrent is where your business logic is defined, AuthTrentTypes is
  // the type all your business logic types extend from (in this example `A`, `B`, and `C` states)
  Alerter<AuthTrent, AuthTrentTypes>(
      // Not all handlers need to be defined
      handlers: (mapper) => mapper
      ..all((state) {
        // Always called if defined
      })
      ..as<A>((state) {
        // Called if `A` is alerted
      })
      ..as<B>((state) {
        // Called if `B` is alerted
      })
      ..as<C>((_) {
        // Called if `C` is alerted
      }),
      child: Container(),
  );
  ```

- `Digester` widget that builds your UI based on your current business logic state.

  ```dart
  // AuthTrent is where your business logic is defined, AuthTrentTypes is
  // the type all your business logic types extend from (in this example `A`, `B`, and `C` states)
  Digester<AuthTrent, AuthTrentTypes>(
    // Not all handlers need to be defined
    handlers: (mapper) {
      mapper
        ..all((state) => const Text("Rendered if no more specific type is defined"))
        ..as<A>((state) => Text("State is A"))
        ..as<B>((state) => const Text("State is B"))
        ..as<C>((state) => const Text("State is C"));
    },
  ),
  ```

### Business Logic Layer Built-in Functions

- `emit(state)`: Emit a new state **with** the UI reacting.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Emit a new state to update the UI with a calculation result
    void showResult(double result) {
      emit(CalculationResult(result));
    }
  }
  ```

- `set(state)`: Set a new state **without** the UI reacting.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Set the state to prepare for a calculation without triggering a UI update
    void prepareCalculation() {
      set(Division(10, 2));
    }
  }
  ```

- `alert(state)`: Alert a temporary state WITHOUT setting it, but being able to listen to it from the `Alerter` widget (for things like notifications).

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Send an alert to notify of an error without changing the current state
    void alertError(String message) {
      alert(InvalidCalculation(message));
    }
  }
  ```

- `getExStateAs<T>()`: This will return the last state of type `T`. Useful for accessing a state you transitioned away from.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Access the previous Division state if it exists
    void reusePreviousDivision() {
      getExStateAs<Division>().match(
        some: (state) {
          print("Resuming division: ${state.numerator} / ${state.denominator}");
        },
        none: () {
          print("No previous division found.");
        },
      );
    }
  }
  ```

- `getCurrStateAs<T>()`: Returns the current state as type `T`. Useful for specific state operations.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Log the current result if the state is a CalculationResult
    void logCurrentResult() {
      getCurrStateAs<CalculationResult>().match(
        some: (state) {
          print("Current result: ${state.result}");
        },
        none: () {
          print("Not in result state.");
        },
      );
    }
  }
  ```

- `currStateMapper`: Maps over the current state and performs actions based on its type.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Perform different actions depending on the current state type
    void handleState() {
      currStateMapper
        ..all((state) {
          print("Generic state handler.");
        })
        ..as<BlankScreen>((_) {
          print("Calculator is blank.");
        })
        ..as<InvalidCalculation>((state) {
          print("Error: ${state.message}");
        })
        ..as<CalculationResult>((state) {
          print("Result: ${state.result}");
        });
    }
  }
  ```

- `currState`: Access the raw state for custom manipulation.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Print the raw state for debugging or custom handling
    void printRawState() {
      print("Raw state: $currState");
    }
  }
  ```

- `clearEx(state)`: Clears the memory of the last state of a specific type.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Forget the last Division state
    void forgetPreviousDivision() {
      clearEx<Division>();
    }
  }
  ```

- `clearAllExes()`: Clears the memory of all previous states.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Clear the memory of all previous states
    void resetMemory() {
      clearAllExes();
    }
  }
  ```

- `reset()`: Resets the Trent to its initial state.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Reset the Trent to its initial state
    void resetCalculator() {
      reset();
    }
  }
  ```

- `dispose()`: Disposes the Trent, closing its state streams.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Clean up resources by disposing of the Trent
    void cleanup() {
      dispose();
    }
  }
  ```

- Access `stateStream` and `alertStream` for custom handling of streams.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Listen to state and alert streams for real-time updates
    void listenToStates() {
      stateStream.listen((state) {
        print("State updated: $state");
      });

      alertStream.listen((state) {
        print("Alert received: $state");
      });
    }
  }
  ```

### General Utilities

- `get<YOUR_TYPE_OF_TRENT>()`: Get a Trent instance from the service locator. This is how you access your business logic functions from the UI layer.

  ```dart
  // Get the CalculatorTrent instance
  get<CalculatorTrent>().divide(10, 2);
  ```
- `TrentManager([Trent1(), Trent2(), ...])`: Initialize multiple Trents at once. This should be done as high-up in the widget tree as possible, preferably, in the `main.dart`'s `void main()` function.

  ```dart
  // Initialize multiple Trents at once
  TrentManager([AuthTrent(), CalculatorTrent(), FeedTrent(), ...]).init();
  ```

- `TrentManager([Trent1(), Trent2(), ...]).dispose()`: Dispose of multiple Trents at once.

  ```dart
  // Dispose of multiple Trents at once
  TrentManager([AuthTrent(), CalculatorTrent(), FeedTrent(), ...]).dispose();
  ```

## How to Use: Contrived Calculator Example 🚀

### 1/4: Organize Your Project

For better organization, consider somewhere creating a `trents` directory to store multiple Trent files for different features:

```txt
~/lib/trents/
  calculator_trent.dart
```

For example, if your app needs to manage calculator logic and authentication logic, you may have:

```txt
~/lib/trents/
  calculator_trent.dart
  auth_trent.dart
```

For this example, we'll just focus on the calculator logic.

Remember to always add `import 'package:trent/trent.dart';` at the top of each file you create to gain access to the Trent package.

### 2/4: Create The Business Layer

Inside `calculator_trent.dart`, we need to define custom state classes. First, we must define the base state that all other states will extend from.

This state will have no logic, and only includes a default [`Equatable`](https://pub.dev/packages/equatable) implementation that subclasses can override. This is useful for custom equality checks. You put every field you want to compare in the `props` list. For example, if `A(field1: "hello", field2: "world")` and `A(field1: "hello", field2: "world")` should be considered equal, you would override the `props` getter in `A` to return `[field1, field2]`. If only `field1` should be considered, you would return `[field1]`.


```dart
class CalculatorStates extends Equatable {
  @override
  List<Object> get props => [];
}
```

After defining the base state, we can define the states that extend from it. These are the states our calculator will use. They contain our business logic's *data*:

```dart
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
```

This means that our calculator's "state" can be one of the following:

- `BlankScreen`: The calculator is empty.
- `InvalidCalculation`: The calculator has an invalid calculation, we may want to alert the user of this!
- `Division`: The calculator is currently dividing two numbers.
- `CalculationResult`: The calculator has a result.

Now that we have our states, we can create the Trent class that will manage them. This class will contain our business logic's *logic*. The value inside `super(...)` is the initial state of our calculator.

```dart
class CalculatorTrent extends Trent<CalculatorStates> {
  CalculatorTrent() : super(BlankScreen());
}
```

We can add methods inside this class to manipulate our calculator's state. For example, we can add a method to divide two numbers:

```dart
class CalculatorTrent extends Trent<CalculatorStates> {
  CalculatorTrent() : super(BlankScreen());

  void divide(int numerator, int denominator) async {
    if (denominator == 0) {
      // Divide by zero error!

      // We should alert the user of this error
      alert(InvalidCalculation("Cannot divide by zero!"));

      // We emit the blank screen state so the UI can reset
      emit(BlankScreen());
    } else {
      // We will emit the division state, so perhaps the UI
      // can show "currently doing expensive division"
      emit(Division(numerator, denominator));

      // We pretend this calculation takes time... (perhaps
      // it's an API call)
      await Future.delayed(const Duration(seconds: 2));

      // Once we have the result, we emit it, so that the UI
      // can show the result
      emit(CalculationResult(numerator / denominator));
    }
  }
}
```

This function can be called from the UI layer to divide two numbers. It will emit the appropriate states based on the result of the division. As you can see, it uses multiple built-in functions such as `alert(...)` and `emit(...)`. There are several of these that have nuanced differences. They are explained in the [Full API](#full-api-) section. In short, `alert(...)` allows us to send an ephemeral state without changing the current state such that the UI can display something like a notification without havint to lose the state it's currently in. `emit(...)` changes the current state and triggers the UI to update. This is ideal for our calculator because we want to show the user the result of the division.

We may also want to add a method to reset the calculator. It would look like this:

```dart
void clear() {
  // We emit the blank screen state so the UI can reset
  emit(BlankScreen());
}
```

### 3/4: Initalize The Business Layer

Now that we have our business logic layer set up, we need to actually use it. First, however, we need to initialize our `CalculatorTrent`. We can do this in our `main.dart` file:

```dart
void main() {
  TrentManager([AuthTrent()]).init();
  runApp(const MyApp());
}
```

This will initialize our `CalculatorTrent` so that it can be used in our UI layer. If we had multiple Trents, we would pass them all in the list like so:

```dart
void main() {
  TrentManager([AuthTrent(), CalculatorTrent(), FeedTrent(), ...]).init();
  runApp(const MyApp());
}
```

You are also able to dispose Trents if you somehow find yourself needing to do so. This can be done anywhere like so:

```dart
TrentManager([AuthTrent(), CalculatorTrent(), FeedTrent(), ...]).dispose();
```

### 4/4: Use The Business Layer In The UI Layer

With our business logic layer set up and initialized, we can now use it in our UI layer. There are 2 primary ways of doing this:

- Using the `Digester` widget.
- Using the `Alerter` widget.

The `Digester` widget is for building the UI dynamically based on the current state of the business logic. The `Alerter` widget is for listening to one-time ephemeral states that the business logic may send off.

In our case, we might set up our calculator like this (including simplifications):

```dart
void main() {
  TrentManager([CalculatorTrent()]).init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Alerter<CalculatorTrent, CalculatorStates>(
                handlers: (mapper) => mapper
                  ..as<InvalidCalculation>((state) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Notification: ${state.message}")),
                    );
                  }),
                child: Digester<CalculatorTrent, CalculatorStates>(
                  handlers: (mapper) {
                    mapper
                      ..as<BlankScreen>((_) => const Text("Blank screen"))
                      ..as<InvalidCalculation>((state) => Text("Error: ${state.message}"))
                      ..as<Division>((state) => Text("Currently dividing: ${state.numerator} / ${state.denominator}"))
                      ..as<CalculationResult>((state) => Text("Result: ${state.result}"));
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => get<CalculatorTrent>().divide(10, 2),
                child: const Text("Divide 10 by 2"),
              ),
              TextButton(
                onPressed: () => get<CalculatorTrent>().divide(10, 0),
                child: const Text("Divide by 0 (will show notification)"),
              ),
              TextButton(
                onPressed: () => get<CalculatorTrent>().clear(),
                child: const Text("Clear"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

If we try to divide by zero, we will see a notification appear at the top of the screen because of the `alert(InvalidCalculation("Cannot divide by zero!"))` call. Then, because of the later `emit(BlankScreen())` call, the UI will reset to the blank screen. If we divide 10 by 2, we will see the UI update to show "Currently dividing: 10 / 2" and then after 2 seconds, it will show "Result: 5.0". We can then also use the `clear()` method to reset the calculator to the blank screen.

You might notice that we use `get<CalculatorTrent>()` to get the `CalculatorTrent` instance. This is because we have initialized it in the `main.dart` file. If we had multiple Trents, we would use `get<AuthTrent>()`, `get<CalculatorTrent>()`, etc. to get the specific Trent instance we want. This allows us to call our business logic functions from the UI layer and then have the UI update based on the state changes.

## Additional Info 📣

- The package is always open to [improvements](https://github.com/mattrltrent/trent/issues), [suggestions](mailto:me@matthewtrent.me), and [additions](https://github.com/mattrltrent/trent/pulls)!

- I'll look through PRs and issues as soon as I can!

- [Learn about me](https://matthewtrent.me).
