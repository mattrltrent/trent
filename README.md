<div align="center">
  
  <img src="https://raw.githubusercontent.com/mattrltrent/random_assets/refs/heads/main/chili.png" height="100px"></img>

  _Simple, Reactive, Scalable, & Opinionated State Management Library_

  [How to Use Full Example](#how-to-use) • [API Docs](#full-api-) • [Simple Weather App Using Trent](https://github.com/mattrltrent/trent/tree/main/example) • [Blog Post With More Info/Examples (written for v0.0.7)](https://matthewtrent.me/articles/trent)

  [![codecov](https://codecov.io/github/mattrltrent/trent/graph/badge.svg?token=VJN63BHZ95)](https://codecov.io/github/mattrltrent/trent) [![unit tests](https://github.com/mattrltrent/trent/actions/workflows/unit_tests.yml/badge.svg)](https://github.com/mattrltrent/trent/actions/workflows/unit_tests.yml)

---

</div>

### Why would you use Trent over other state management libraries?

- Ease of use:
  - Built-in dependency injection and service locators.
  - Built-in optimistic update functionality.
  - Boasts simple `Alerter` and `Digester` widgets for managing UI layer reactively.
- Fine-grained control:
  - Includes special shorthand `watch<T>`, `watchMap<T, S>`, and `get<T>` functions for reduced-boilerplate managing of UI layer.
  - State output for widgets and functions is "mapped", meaning instead of requiring exhaustive checks like `if (state is A) {...} else if (state is B) {...} else {...}` you just chain `..as<A>((state) {...}..as<B>((state) {...})` etc. invocations non-exhaustively. If you want a catch-all route, chain an `orElse`. If a state isn't included, it's ignored.
  - Allows listening to one-off "ephemeral" states with `alert` that you don't want saved (ie: sending off a quick notification state without replacing your current state).
  - Access the last state of a specific type with `getExStateAs<T>`, ensuring you don't lose the value of the state you transitioned away from (ie: Data state -> Loading state -> Reloading Data state with its past data saved).
  - Uses [`Equatable`](https://pub.dev/packages/equatable) for customizable equality checks.
- Performance & safety:
  - Efficient stream-based state management.
  - Utilizes custom `Option.Some(...)`/`Option.None()` types.
  - Clean separation of concerns: UI layer & business logic layer.
  - You can wrap Trent handler functions in `cancelableAsyncOp`s to ensure async calls don't leak across multiple state resets. Further, you can cancel any in-flight async operations that were wrapped in `cancelableAsyncOp` with a Trent's handler functions by calling `reset({bool cancelInFlightAsyncOps = true})` or `cancelInFlightAsyncOps`.

### UI Layer That "Responds" To Your Business Logic States

- **`Alerter` widget**: 
  - Listens for **alert states** emitted by your business logic using the `alert(...)` method.
  - Can also listen for **normal state changes** reactively from the business logic layer.
  - Provides a declarative way to handle temporary or one-time notifications (e.g., error messages or toast notifications) without changing the current state.

- **`Digester` widget**: 
  - Dynamically builds your UI based on the **current state** of your business logic.
  - Provides an intuitive, type-safe way to map each state to a corresponding UI representation.

- **(Main) utility functions**:
  - **`watch<T>`**: Reactively listens to state changes and rebuilds widgets dynamically.
  - **`get<T>`**: Retrieves a Trent instance without listening for state changes. The method used for invoking business logic functions.
  - **`watchMap<T, S>`**: Reactively maps state to specific widgets dynamically based on type.

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
    stateMap
      ..orElse((state) {
        // Do something (doElse run if nothing else more specific hit)
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
    print(state); 
  }
  
  // ... More business functions ...
}
```

## Full API 📚

### UI Layer: Built-in Widgets

- `Alerter` widget that listens to one-time state `alert(...)`s from your business logic layer in `listenAlerts`. This is good if your business logic needs to "quickly send off a state without saving it". An example would be you having `Loading`, `Data`, and `WarningNotification` states. You may be in `Data` state, but want to send off a quick `WarningNotification` state without having to throw away your `Data` state. This is what an `alert(WarningNotification(...))` is good for. `Alerter` can also can listen to regular state updates in `listenStates`. Both can have their listeners programmatically toggled on/off with `listenAlertsIf` and `listenStatesIf` respectively.

  ```dart
  // AuthTrent is where your business logic is defined, AuthTrentTypes is
  // the type all your business logic types extend from (in this example `A`, `B`, and `C` states)
  Alerter<AuthTrent, AuthTrentTypes>(
      // Not all handlers need to be defined
      //
      // This only listens to alerts
      listenAlerts: (mapper) => mapper
        ..orElse((state) {
          // Triggered if nothing more specific is defined
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
      // Not all handlers need to be defined
      //
      // This only listens to states emitted
      listenStates: (mapper) => mapper
        ..orElse((state) {
          // Triggered if nothing more specific is defined
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
        // Only trigger listens if...
        listenAlertsIf: (oldAlert, newAlert) => true, // oldAlert is wrapped in an Option type because it may not exist
        listenStatesIf: (oldState, newState) => true, // Both of these are pure types since there will always be an old and new state
      child: Container(),
  );
  ```

- `Digester` widget that builds your UI based on your current business logic state.

  ```dart
  // AuthTrent is where your business logic is defined, AuthTrentTypes is
  // the type all your business logic types extend from (in this example `A`, `B`, and `C` states)
  Digester<AuthTrent, AuthTrentTypes>(
    // Not all handlers need to be defined
    child: (mapper) {
      mapper
        ..orElse((state) => const Text("Rendered if no more specific type is defined"))
        ..as<A>((state) => Text("State is A"))
        ..as<B>((state) => const Text("State is B"))
        ..as<C>((state) => const Text("State is C"));
    },
  ),
  ```

### Business Logic Layer: Built-in Functions

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

- `alert(state)`: Alert a temporary state WITHOUT setting/saving it, but being able to listen to it from the `Alerter` widget (for things like notifications).

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Send an alert to notify of an error without changing the current state
    void alertError(String message) {
      alert(InvalidCalculation(message));
    }
  }
  ```

- `getExStateAs<T>()`: This will return the last state of type `T`. Useful for accessing a state you transitioned away from. For example, if you transitioned from `Division` to `Multiplication`, you can still access the last value of the `Division` state after transitioning away from it.

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

- `stateMap`: Maps over the current state and performs actions based on its type.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Perform different actions depending on the current state type
    void handleState() {
      stateMap
        ..orElse((state) {
          print("Generic state handler. Called if nothing more specific defined.");
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

- `state`: Access the raw state for custom manipulation.

  ```dart
  class CalculatorTrent extends Trent<CalculatorStates> {
    CalculatorTrent() : super(BlankScreen());

    // Print the raw state for debugging or custom handling
    void printRawState() {
      print("Raw state: $state");
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

- `reset({bool cancelInFlightAsyncOps = true})`: Resets the Trent to its initial state. Optionally, you can cancel any in-flight async operations that were wrapped in `cancelableAsyncOp` with a Trent's handler functions. This is to prevent async calls from leaking across multiple state resets.

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

- `cancelInFlightAsyncOps`: Wraps async operations to ensure they don't leak across multiple state resets. This makes them cancelable if you call either `reset({bool cancelInFlightAsyncOps = true})` or `cancelInFlightAsyncOps`.

```dart
class CalculatorTrent extends Trent<CalculatorStates> {
  CalculatorTrent() : super(BlankScreen());

  // Perform an async operation safely
  void performAsyncOperation() {
    cancelableAsyncOp(() async {
      // Your async code here
      await Future.delayed(Duration(seconds: 2));
      emit(CalculationResult(42));
    });
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
- `watchMap<T, S>()`: Map state to specific UI widgets dynamically and reactively.

  ```dart
  watchMap<WeatherTrent, WeatherTypes>(context, (mapper) {
    mapper
      ..as<Sunny>((state) => Text("Sunny: ${state.temperature}°C"))
      ..as<Rainy>((state) => Text("Rainy: ${state.rainfall}mm"))
      ..orElse((_) => const Text("No Data"));
  });```
- `watch<T>()`: Reactive Trent retrieval. Use this when the UI needs to rebuild reactively based on state changes.

  ```dart
  Copy code
  final weatherTrent = watch<WeatherTrent>(context);
  print(weatherTrent.state);
  ```
- `TrentManager` widget's `trents` field using `register` function: Initialize multiple Trents at once. This should be done as high-up in the widget tree as possible, preferably in the `main.dart`'s `void main()` function. Trents need to be registered, else things won't work. Alternatively, you can call `register` with your Trents *before* `runApp` is called, however, you still need to wrap your app in a `TrentManager` widget. You can mix and match both techniques.

  ```dart
  // Initialize multiple Trents at once
  void main() {
    // OPTION #1: Call register before runApp
    register(WeatherTrent()),
    register(OtherTrent()),
    register(AnotherTrent()),
    runApp(
      TrentManager(
        trents: [
          // OPTION #2: Pass Trents directly to TrentManager
          register(WeatherTrent()),
          register(OtherTrent()),
          register(AnotherTrent()),
          // ...
        ],
        child: const MyApp(),
      ),
    );
  }
  ```

### Optimistic Updates

Optimistic updates let you immediately reflect a change in your UI before an async operation (like a network request) completes. This makes your app feel faster and more responsive. If the async operation fails, the optimistic update can be reverted.

Trent provides a built-in API for optimistic updates via the `optimisticUpdate<T>(...)` method, available on any Trent instance. Optimistic updates are tracked by tag, can be explicitly accepted or rejected, and are automatically cleaned up on `reset()`.

#### Tags
A tag is a string that identifies the optimistic update. If you run multiple optimistic updates with the same tag, only the latest effect for that tag is present; previous effects are fully reverted before the new one is applied. This ensures repeated or colliding updates don't stack up and cause state confusion. If you don't provide a tag, Trent will generate a universally unique tag for you.

```dart
// In your Trent subclass:
optimisticUpdate<int>(
  tag: "counter",
  forward: (state, value) => state.copyWith(value: state.value + value),
  reverse: (state, value) => state.copyWith(value: state.value - value),
).execute(5); // Immediately applies +5 optimistically
```

#### Resolving Optimistic Updates
There are three main ways to resolve an optimistic update:

1. **Accept**: Call `accept()` on the attempt to confirm the optimistic update (e.g., after a successful async operation). This makes the update permanent and removes it from the pending list.
2. **Accept As**: Call `acceptAs(newValue)` to accept the update but with a new value (runs revert, then applies the new value as a new optimistic update).
3. **Reject**: Call `reject()` to revert the optimistic update (e.g., if the async operation fails). This will undo the effect and remove it from the pending list.

All of these methods are available on the returned `OptimisticAttempt`:

```dart
final attempt = optimisticUpdate<int>(
  tag: "counter",
  forward: (state, value) => state.copyWith(value: state.value + value),
  reverse: (state, value) => state.copyWith(value: state.value - value),
);
attempt.execute(10); // Apply +10 optimistically

// Later, after async completes:
attempt.accept(); // Accepts and finalizes
// or
attempt.reject(); // Reverts the update
// or
attempt.acceptAs(42); // Reverts +10, then applies +42
```

Optimistic updates are async-safe: if you run multiple with the same tag before accepting, acceptingAs, or rejecting, only the latest is kept and previous ones are reverted before the new one is applied. This prevents flooding/collision issues.

If you always resolve each optimistic attempt (by calling `accept()`, `acceptAs(...)`, or `reject()` on every attempt you create), you will not leak memory or state. The additional cleanup methods (like `rejectAllUnresolvedOptimisticUpdates`) are provided as extra safety for cases where you might forget to resolve, or for bulk cleanup after network failures, app suspends, or other edge cases.

#### Cleanup

To prevent memory leaks or stale updates, Trent provides a cleanup method:

- `rejectAllUnresolvedOptimisticUpdates({Duration? olderThan})`: Rejects all unresolved optimistic updates, or only those older than a given duration. This is useful for cleaning up after network failures, app suspends, or just to ensure your state is fresh.

```dart
// Reject all unresolved optimistic updates
trent.rejectAllUnresolvedOptimisticUpdates();

// Reject only those older than 30 seconds
trent.rejectAllUnresolvedOptimisticUpdates(olderThan: Duration(seconds: 30));
```

Optimistic updates are also automatically cleaned up on a Trent's `reset(...)` being called.

**Example:**

```dart
final attempt = optimisticUpdate<int>(
  tag: "saveDraft",
  forward: (state, value) => state.copyWith(value: value),
  reverse: (state, value) => state.copyWith(value: state.value - value),
);
attempt.execute(123);

// If the save fails after 10 seconds
Future.delayed(Duration(seconds: 10), () {
  attempt.reject();
});

// Or, to clean up all stale attempts after a while
trent.rejectAllUnresolvedOptimisticUpdates(olderThan: Duration(seconds: 10));
```

This system ensures your UI remains responsive, your state stays consistent, and you have full control over optimistic updates and their lifecycle.


## How to Use

### 1. Define Your State Types

Use `EquatableCopyable` for your state types to enable equality comparison and state copying. Implement the `copyWith` method to allow partial updates.

```dart
abstract class WeatherTypes extends EquatableCopyable<WeatherTypes> {
  @override
  List<Object?> get props => [];
}

class NoData extends WeatherTypes {
  @override
  WeatherTypes copyWith() {
    return this;
  }
}

class Sunny extends WeatherTypes {
  final double temperature;

  Sunny(this.temperature);

  @override
  List<Object?> get props => [temperature];

  @override
  WeatherTypes copyWith({double? temperature}) {
    return Sunny(temperature ?? this.temperature);
  }
}

class Rainy extends WeatherTypes {
  final double rainfall;

  Rainy(this.rainfall);

  @override
  List<Object?> get props => [rainfall];

  @override
  WeatherTypes copyWith({double? rainfall}) {
    return Rainy(rainfall ?? this.rainfall);
  }
}
```

### 2. Create Your Trent

Extend `Trent` to define your state manager and initialize it with an initial state.

```dart
class WeatherTrent extends Trent<WeatherTypes> {
  WeatherTrent() : super(NoData());

  void updateToSunny(double temperature) {
    emit(Sunny(temperature));
  }

  void updateToRainy(double rainfall) {
    emit(Rainy(rainfall));
  }

  void resetState() {
    reset();
  }
}
```

### 3. Organize Your Files

For better organization, consider creating a `trents` directory to store Trent files for each feature.

```plaintext
lib/
├── main.dart
├── trents/
│   ├── weather_trent.dart
│   ├── auth_trent.dart
│   ├── etc. 
```

### 4. Initialize Your Trents

Initialize your Trents at the top of your widget tree using `TrentManager` and `register`. 

```dart
void main() {
  // OPTION #1: Call register before runApp
  register(WeatherTrent());
  runApp(TrentManager(
    // OPTION #2: Register Trents directly in TrentManager
    trents: [register(WeatherTrent())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Weather App')),
        body: WeatherScreen(),
      ),
    );
  }
}
```

### 5. Call Business Logic Functions From UI

To call business logic functions from the UI, use the `get<T>()` utility to retrieve your Trent instance. This allows you to trigger state changes or logic directly from the UI layer. This, of course, is assuming you have a `Trent` instance registered in the `TrentManager`.

#### Example

Suppose we have the following Trent class:

```dart
class WeatherTrent extends Trent<WeatherTypes> {
  WeatherTrent() : super(NoData());

  void updateToSunny(double temperature) {
    emit(Sunny(temperature));
  }

  void updateToRainy(double rainfall) {
    emit(Rainy(rainfall));
  }

  void resetState() {
    reset();
  }
}
```

Here’s how you can invoke its methods from the UI:

```dart
class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            final weatherTrent = get<WeatherTrent>();
            weatherTrent.updateToSunny(30.0);
          },
          child: const Text("Set to Sunny"),
        ),
        ElevatedButton(
          onPressed: () {
            final weatherTrent = get<WeatherTrent>();
            weatherTrent.updateToRainy(100.0);
          },
          child: const Text("Set to Rainy"),
        ),
        ElevatedButton(
          onPressed: () {
            final weatherTrent = get<WeatherTrent>();
            weatherTrent.resetState();
          },
          child: const Text("Reset Weather State"),
        ),
      ],
    );
  }
}
```

#### How It Works

1. Retrieve the Trent instance: Use `get<T>()` to fetch the Trent instance. We use `get` instead of `watch` because `get` retrieves the Trent instance directly, while `watch` is used for reactive UI updates.
2. Call methods: Trigger the desired business logic function, such as `updateToSunny`, `updateToRainy`, or `resetState`.
3. UI updates: The UI automatically reacts to the state changes if `Digester`, `watch`, `watchMap`, or `Alerter` are used in the widget tree below where the Trent was registered.

### 6. Use `Alerter`, `Digester`, `watch`, and `watchMap` in Your UI

These widgets and functions provide a declarative and flexible way to respond to state changes and alerts. `Alerter` is for listening to alert states, `Digester` for building UI based on the current state, while `watch` and `watchMap` give you more granular control for reactive or dynamic updates.

#### Example UI Implementation with `Alerter` and `Digester`

```dart
class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Alerter<WeatherTrent, WeatherTypes>(
      listenAlerts: (mapper) {
        mapper
          ..as<WeatherAlert>((alert) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Alert: ${alert.message}")),
            );
          });
      },
      listenAlertsIf: (oldState, newState) => true,
      listenStates: (mapper) {
        mapper
          ..as<Sunny>((state) => print(state))
          ..as<Rainy>((state) => print(state))
          ..orElse((_) => const Text("No Data"));
      },
      child: Digester<WeatherTrent, WeatherTypes>(
        child: (mapper) {
          mapper
            ..as<Sunny>((state) => Text("Sunny: ${state.temperature}°C"))
            ..as<Rainy>((state) => Text("Rainy: ${state.rainfall}mm"))
            ..orElse((_) => const Text("No Data"));
        },
      ),
    );
  }
}
```

#### Example with `watch`

```dart
class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherTrent = watch<WeatherTrent>(context);
    final state = weatherTrent.state;

    if (state is Sunny) {
      return Text("Sunny: ${state.temperature}°C");
    } else if (state is Rainy) {
      return Text("Rainy: ${state.rainfall}mm");
    } else {
      return const Text("No Data");
    }
  }
}
```

#### Example with `watchMap`

```dart
class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return watchMap<WeatherTrent, WeatherTypes>(context, (mapper) {
      mapper
        ..as<Sunny>((state) => Text("Sunny: ${state.temperature}°C"))
        ..as<Rainy>((state) => Text("Rainy: ${state.rainfall}mm"))
        ..orElse((_) => const Text("No Data"));
    });
  }
}
```

### 7. Testing Your Trent

Add tests to ensure your Trent works as expected. Existing tests can be found [here](https://github.com/mattrltrent/trent/tree/main/test).

```dart
void main() {
  test('WeatherTrent state transitions', () {
    final trent = WeatherTrent();

    // Initial state
    expect(trent.state, isA<NoData>());

    // Update to Sunny
    trent.updateToSunny(25.0);
    expect(trent.state, isA<Sunny>());
    expect((trent.state as Sunny).temperature, 25.0);

    // Update to Rainy
    trent.updateToRainy(50.0);
    expect(trent.state, isA<Rainy>());
    expect((trent.state as Rainy).rainfall, 50.0);

    // Reset state
    trent.resetState();
    expect(trent.state, isA<NoData>());
  });
}
```

## Additional Info 📣

- The package is always open to improvements, suggestions, and additions! Feel free to open issues or pull requests on [GitHub](https://github.com/mattrltrent/trent).

- I'll look through PRs and issues as soon as I can!

- [Learn about me](https://matthewtrent.me).
