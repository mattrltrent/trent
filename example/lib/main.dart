import 'package:example/state_machine.dart';
import 'package:flutter/material.dart';
import 'package:trent/trent.dart';

void main() {
  StateMachineManager([TestStateMachine()]).init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'example',
      home: Scaffold(
        body: Center(
          child: Alerter<TestStateMachine, TestStateMachineTypes>(
            handlers: (mapper) => mapper
              ..alert<A>((state) {
                print("Alert A with value: ${state.value}");
              })
              ..alert<B>((state) {
                print("Alert B");
              })
              ..alert<C>((_) {
                print("Alert C");
              }),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Digester<TestStateMachine, TestStateMachineTypes>(
                  handlers: (mapper) {
                    mapper
                      ..state<A>((state) => Text('State A with value: ${state.value}'))
                      ..state<B>((_) => Text('State B'))
                      ..state<C>((_) => const Text('State C'));
                  },
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => get<TestStateMachine>().incAFresh(),
                  child: const Text("emit A, start fresh"),
                ),
                TextButton(
                  onPressed: () => get<TestStateMachine>().incAState(),
                  child: const Text("emit A, continue where leftoff"),
                ),
                TextButton(
                  onPressed: () => get<TestStateMachine>().incA99(),
                  child: const Text("emit A 99"),
                ),
                TextButton(
                  onPressed: () => get<TestStateMachine>().setA200(),
                  child: const Text("SET A 200"),
                ),
                TextButton(
                  onPressed: () => get<TestStateMachine>().switchToB(),
                  child: const Text("switch to B"),
                ),
                TextButton(
                  onPressed: () => get<TestStateMachine>().alertA55(),
                  child: const Text("alert A 55"),
                ),
                TextButton(
                  onPressed: () => get<TestStateMachine>().alertCurrentStateIfA(),
                  child: const Text("alert current state if A"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
