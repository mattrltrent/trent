import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trent/src/logic/mappers.dart';
import 'package:trent/trent.dart';

// ===== Simple States =====

class SimpleState extends EquatableCopyable<SimpleState> {
  @override
  List<Object?> get props => [];

  @override
  SimpleState copyWith() {
    throw UnimplementedError();
  }
}

class A extends SimpleState {
  final int value;

  A(this.value);

  @override
  List<Object?> get props => [value];

  @override
  A copyWith({int? value}) => A(value ?? this.value);
}

class B extends SimpleState {
  final int value;

  B(this.value);

  @override
  List<Object?> get props => [value];

  @override
  B copyWith({int? value}) => B(value ?? this.value);
}

class C extends SimpleState {
  final int value;

  C(this.value);

  @override
  List<Object?> get props => [value];

  @override
  C copyWith({int? value}) => C(value ?? this.value);
}

class D extends SimpleState {
  final int value;

  D(this.value);

  @override
  List<Object?> get props => [value];

  @override
  D copyWith({int? value}) => D(value ?? this.value);
}

// ===== Simple Trent =====

class SimpleTrent extends Trent<SimpleState> {
  SimpleTrent() : super(A(0));

  void incrementA() {
    getCurrStateAs<A>().match(
      some: (state) => emit(state.copyWith(value: state.value + 1)),
      none: () {},
    );
  }

  void alertB() => alert(B(42));

  void switchToB() => emit(B(42));

  void switchToC() => emit(C(99));

  void triggerDAlert() => alert(D(999));
}

// ===== Test Widgets =====

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ScaffoldMessenger(child: child!),
      home: Scaffold(
        appBar: AppBar(
          title: Digester<SimpleTrent, SimpleState>(
            child: (mapper) {
              mapper
                ..as<A>((state) => Text("Digester State A: ${state.value}"))
                ..as<B>((state) => Text("Digester State B: ${state.value}"))
                ..as<C>((state) => Text("Digester State C: ${state.value}"))
                ..orElse((state) => const Text("Unknown State"));
            },
          ),
        ),
        body: Column(
          children: [
            watchMap<SimpleTrent, SimpleState>(context, (mapper) {
              mapper
                ..as<A>((state) => Text("WatchMap State A: ${state.value}"))
                ..as<B>((state) => Text("WatchMap State B: ${state.value}"))
                ..as<C>((state) => Text("WatchMap State C: ${state.value}"))
                ..as<D>((state) => Text("WatchMap Alert D: ${state.value}"));
            }),
            Text("Watch state: ${watch<SimpleTrent>(context).state}"),
            Alerter<SimpleTrent, SimpleState>(
              listenAlerts: (mapper) {
                mapper.as<B>((state) {
                  _counter = 1;
                });
              },
              listenStates: (mapper) {
                mapper
                  ..as<A>((state) => _counter = 2)
                  ..as<B>((state) => _counter = 3)
                  ..as<C>((state) => _counter = 4);
              },
              listenAlertsIf: (oldAlert, newAlert) =>
                  newAlert is D || newAlert is B,
              listenStatesIf: (oldState, newState) =>
                  newState is A || newState is B || newState is C,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => get<SimpleTrent>().incrementA(),
                      child: const Text("Increment A"),
                    ),
                    ElevatedButton(
                      onPressed: () => get<SimpleTrent>().switchToB(),
                      child: const Text("Switch to B"),
                    ),
                    ElevatedButton(
                      onPressed: () => get<SimpleTrent>().switchToC(),
                      child: const Text("Switch to C"),
                    ),
                    ElevatedButton(
                      onPressed: () => get<SimpleTrent>().triggerDAlert(),
                      child: const Text("Trigger D Alert"),
                    ),
                    ElevatedButton(
                      onPressed: () => get<SimpleTrent>().alertB(),
                      child: const Text("Alert B"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Test Cases =====

void main() {
  group('trent package', () {
    testWidgets('Digester updates UI on state change', (tester) async {
      await tester.pumpWidget(
        TrentManager(
          trents: [register(SimpleTrent())],
          child: const TestApp(),
        ),
      );

      expect(find.text("Digester State A: 0"), findsOneWidget);

      await tester.tap(find.text("Increment A"));
      await tester.pumpAndSettle();
      expect(find.text("Digester State A: 1"), findsOneWidget);

      await tester.tap(find.text("Switch to B"));
      await tester.pumpAndSettle();
      expect(find.text("Digester State B: 42"), findsOneWidget);

      await tester.tap(find.text("Switch to C"));
      await tester.pumpAndSettle();
      expect(find.text("Digester State C: 99"), findsOneWidget);
    });

    testWidgets('Alerter updates _counter on alert and state changes',
        (tester) async {
      await tester.pumpWidget(
        TrentManager(
          trents: [register(SimpleTrent())],
          child: const TestApp(),
        ),
      );

      // Initially, the _counter should not have been updated.
      final state = tester.state<_TestAppState>(find.byType(TestApp));
      expect(state._counter, 0);

      // Tap the button to trigger B alert
      await tester.tap(find.text("Alert B"));
      await tester.pumpAndSettle(); // Allow state update

      // Check that _counter is updated by B alert
      expect(state._counter, 1);
    });

    test('SimpleTrent state management', () {
      final trent = SimpleTrent();

      expect(trent.state, isA<A>());
      expect((trent.state as A).value, 0);

      trent.incrementA();
      expect(trent.state, isA<A>());
      expect((trent.state as A).value, 1);

      trent.switchToB();
      expect(trent.state, isA<B>());
      expect((trent.state as B).value, 42);

      trent.switchToC();
      expect(trent.state, isA<C>());
      expect((trent.state as C).value, 99);
    });

    test('SimpleTrent alerts', () async {
      final trent = SimpleTrent();
      final alerts = <SimpleState>[];
      final completer = Completer<void>();

      trent.alertStream.listen((alert) {
        alerts.add(alert);
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      trent.triggerDAlert();
      await completer.future.timeout(const Duration(seconds: 4));

      expect(alerts, [isA<D>()]);
      expect((alerts.first as D).value, 999);
    });

    test('SimpleTrent advanced functions', () {
      final trent = SimpleTrent();

      expect(trent.getCurrStateAs<A>().isSome, true);
      expect(trent.getExStateAs<A>().isSome, true);

      trent.switchToB();
      expect(trent.getCurrStateAs<A>().isSome, false);
      expect(trent.getCurrStateAs<B>().isSome, true);

      trent.reset();
      expect(trent.state, isA<A>());
    });

    test('Trents functionality', () {
      final trent = SimpleTrent();

      // Test set
      trent.set(B(10));
      expect(trent.state, isA<B>());
      expect((trent.state as B).value, 10);

      // Test reset
      trent.reset();
      expect(trent.state, isA<A>());
      expect((trent.state as A).value, 0);

      // Test clearEx
      trent.switchToB();
      trent.clearEx(B(42));
      expect(trent.getExStateAs<B>().isSome, false);

      // Test clearAllExes
      trent.switchToC();
      trent.clearAllExes();
      expect(trent.getExStateAs<C>().isSome, false);

      // Test getExStateAs
      trent.switchToB();
      expect(trent.getExStateAs<B>().isSome, true);

      // Test getCurrStateAs
      expect(trent.getCurrStateAs<B>().isSome, true);
      expect(trent.getCurrStateAs<A>().isSome, false);
    });

    testWidgets('Alerter handles alerts and state transitions', (tester) async {
      await tester.pumpWidget(
        TrentManager(
          trents: [register(SimpleTrent())],
          child: const TestApp(),
        ),
      );

      final state = tester.state<_TestAppState>(find.byType(TestApp));

      // Trigger state listeners
      await tester.tap(find.text("Switch to B"));
      await tester.pumpAndSettle();
      expect(state._counter, 3);

      // Trigger alert listener
      await tester.tap(find.text("Alert B"));
      await tester.pumpAndSettle();
      expect(state._counter, 1);
    });

    test('LogicSubTypeMapper handlers', () {
      final mapper = LogicSubTypeMapper<A>(A(5));
      var called = false;

      mapper.as<A>((state) {
        called = true;
        expect(state.value, 5);
      });

      expect(called, true);
    });

    test('LogicSubTypeMapper orElse handler', () {
      final mapper = LogicSubTypeMapper<B>(B(42));
      var called = false;

      mapper.orElse((state) {
        called = true;
        expect(state, isA<B>());
      });

      expect(called, true);
    });
  });

  test('WidgetSubtypeMapper resolves widgets', () {
    final mapper = WidgetSubtypeMapper<A>(A(10));

    mapper.as<A>((state) => Text("State A: ${state.value}"));
    mapper.orElse((state) => const Text("Unknown State"));

    final widget = mapper.resolve();
    expect(widget, isA<Text>());
  });

  test('Trents emit handles repeated states', () {
    final trent = SimpleTrent();
    var notificationCount = 0;

    trent.addListener(() {
      notificationCount++;
    });

    trent.emit(A(0)); // Same as initial state
    trent.emit(A(0)); // Should not notify
    expect(notificationCount, 0);

    trent.emit(A(1)); // Should notify
    expect(notificationCount, 1);
  });

  test('Trents alert handles multiple alerts', () async {
    final trent = SimpleTrent();
    final alerts = <SimpleState>[];
    final completer = Completer<void>();

    trent.alertStream.listen((alert) {
      alerts.add(alert);
      if (alerts.length == 2 && !completer.isCompleted) {
        completer.complete();
      }
    });

    trent.alert(D(999));
    trent.alert(B(42));

    await completer.future.timeout(const Duration(seconds: 2));

    expect(alerts.length, 2);
    expect(alerts[0], isA<D>());
    expect(alerts[1], isA<B>());
  });

  testWidgets('Digester gracefully handles no handlers', (tester) async {
    await tester.pumpWidget(
      TrentManager(
        trents: [register(SimpleTrent())],
        child: Digester<SimpleTrent, SimpleState>(
          child: (mapper) {}, // No handlers registered
        ),
      ),
    );

    final mapper = WidgetSubtypeMapper<A>(A(0));
    expect(mapper.resolve(), isA<SizedBox>());
  });

  test('Option.some throws exception with null', () {
    expect(() => Option.some(null), throwsException);
  });

  test('State copyWith and equality', () {
    final a1 = A(10);
    final a2 = A(10);
    final a3 = a1.copyWith(value: 20);

    // Test equality with same values
    expect(a1, a2);
    expect(a1 == a2, true);

    // Test equality with different values
    expect(a1 == a3, false);

    // Test copyWith produces new instance
    expect(a3.value, 20);
    expect(a1.value, 10);
  });

  test('Option utility handles states correctly', () {
    final someOption = Option.some(A(10));
    final noneOption = Option<A>.none();

    // Test isSome and isNone
    expect(someOption.isSome, true);
    expect(someOption.isNone, false);
    expect(noneOption.isSome, false);
    expect(noneOption.isNone, true);

    // Test unwrap
    expect(someOption.unwrap, A(10));
    expect(() => noneOption.unwrap, throwsException);

    // Test match
    expect(
      someOption.match(
        some: (value) => value.value,
        none: () => 0,
      ),
      10,
    );
    expect(
      noneOption.match(
        some: (value) => value.value,
        none: () => 0,
      ),
      0,
    );
  });

  test('getExStateAs retrieves last state of a specific type', () {
    final trent = SimpleTrent();

    // Initially, there is no previous state of type B
    expect(trent.getExStateAs<B>().isSome, false);

    // Emit a B state
    trent.switchToB();
    expect(trent.getExStateAs<B>().isSome, true);
    expect(trent.getExStateAs<B>().unwrap.value, 42);

    // Switch to C and verify B remains retrievable
    trent.switchToC();
    expect(trent.getExStateAs<B>().isSome, true);
  });

  test('clearEx removes specific type from last states', () {
    final trent = SimpleTrent();

    // Emit B state and verify it is retrievable
    trent.switchToB();
    expect(trent.getExStateAs<B>().isSome, true);

    // Clear B state and verify it is removed
    trent.clearEx(B(42));
    expect(trent.getExStateAs<B>().isSome, false);
  });

  test('clearAllExes removes all stored states', () {
    final trent = SimpleTrent();

    // Emit multiple states
    trent.switchToB();
    trent.switchToC();

    // Verify all states are retrievable
    expect(trent.getExStateAs<B>().isSome, true);
    expect(trent.getExStateAs<C>().isSome, true);

    // Clear all states
    trent.clearAllExes();

    // Verify no states are retrievable
    expect(trent.getExStateAs<B>().isSome, false);
    expect(trent.getExStateAs<C>().isSome, false);
  });

  test('set updates the state but does not notify listeners', () {
    final trent = SimpleTrent();
    var notificationCount = 0;

    trent.addListener(() {
      notificationCount++;
    });

    // Set state without emitting
    trent.set(B(10));

    // Verify state is updated but no notification occurred
    expect(trent.state, isA<B>());
    expect((trent.state as B).value, 10);
    expect(notificationCount, 0);
  });

  test('LogicSubTypeMapper handles unmatched states gracefully', () {
    final mapper = LogicSubTypeMapper<SimpleState>(A(10)); // Use base type
    var handlerCalled = false;

    // Register handler for B
    mapper.as<B>((state) {
      handlerCalled = true;
      expect(state.value, 42);
    });

    // Use orElse as a fallback
    mapper.orElse((state) {
      expect(state, isA<A>());
    });

    expect(handlerCalled, false); // Handler for B should not have been called
  });

  test("dashboard", () {
    register(SimpleTrent(), debug: true);
    final trent = get<SimpleTrent>();
    trent.emit(A(10));
    expect(trent.state, isA<A>());
  });

  test('cancelableAsyncOp returns correct AsyncCompleted', () async {
    final trent = SimpleTrent();

    // Complete normally
    final result1 = await trent.cancelableAsyncOp(() async {
      await Future.delayed(Duration(milliseconds: 10));
      return 'done';
    });

    expect(result1.isNothing(), false);
    expect(result1.unwrap(), 'done');

    // Trigger session reset during async op
    final result2Future = trent.cancelableAsyncOp(() async {
      await Future.delayed(Duration(milliseconds: 50));
      return 'should be stale';
    });

    trent.reset(); // cancels and changes sessionToken

    // should have returned and updated state now
    await Future.delayed(Duration(milliseconds: 75));

    final result2 = await result2Future;
    expect(result2.isNothing(), true);

    // Match-style handling
    final result3 = await trent.cancelableAsyncOp(() async {
      await Future.delayed(Duration(milliseconds: 10));
      return 123;
    });

    final matchOutput = result3.match(
      () => 'cancelled',
      (val) => 'value: $val',
    );
    expect(matchOutput, 'value: 123');
  });

  test(
      'reset(cancelAsyncOps: true) cancels inflight ops and invalidates session',
      () async {
    final trent = SimpleTrent();

    final future = trent.cancelableAsyncOp(() async {
      await Future.delayed(Duration(milliseconds: 50));
      return 'should not complete';
    });

    // Trigger reset before the future completes
    await Future.delayed(Duration(milliseconds: 10));
    trent.reset(cancelAsyncOps: true);

    final result = await future;
    expect(result.isNothing(), true); // Result discarded due to session flip
  });

  test(
      'reset(cancelAsyncOps: false) preserves session and allows ops to complete',
      () async {
    final trent = SimpleTrent();

    final capturedToken = trent.sessionToken; // assume you expose this for test
    final future = trent.cancelableAsyncOp(() async {
      await Future.delayed(Duration(milliseconds: 30));
      return 'survives reset';
    });

    // Reset WITHOUT canceling ops
    await Future.delayed(Duration(milliseconds: 10));
    trent.reset(cancelAsyncOps: false);

    final result = await future;
    expect(result.isNothing(), false);
    expect(result.unwrap(), 'survives reset');

    // Ensure session token didn't change
    expect(trent.sessionToken, capturedToken);
  });
}
