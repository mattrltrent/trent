import 'package:example/test_trent.dart';
import 'package:flutter/material.dart';
import 'package:trent/trent.dart';

void main() {
  TrentManager([AuthTrent()]).init();
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
          child: Alerter<AuthTrent, AuthTrentTypes>(
            handlers: (mapper) => mapper
              ..all((state) {
                print("Alert received");
              })
              ..as<A>((state) {
                print("Alert received of type A");
              })
              ..as<B>((state) {
                print("Alert received of type B");
              })
              ..as<C>((_) {
                print("Alert received of type C");
              }),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Digester<AuthTrent, AuthTrentTypes>(
                  handlers: (mapper) {
                    // get<AuthTrent>().currState = // show this example directly
                    mapper
                      ..all((state) => const Text("All states"))
                      ..as<A>((state) => Text('State A with value: ${state.value}'))
                      ..as<B>((state) => const Text('State B'))
                      ..as<C>((state) => const Text('State C'));
                  },
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => get<AuthTrent>().incAFresh(),
                  child: const Text("emit A, start fresh"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().incAState(),
                  child: const Text("emit A, continue where leftoff"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().incA99(),
                  child: const Text("emit A 99"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().setA200(),
                  child: const Text("SET A 200"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().switchToB(),
                  child: const Text("switch to B"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().alertA55(),
                  child: const Text("alert A 55"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().alertA55(),
                  child: const Text("alert B 55"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().alertCurrentStateIfA(),
                  child: const Text("alert current state if A"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().doDiffThingsIfABC(),
                  child: const Text("doDiffThingsIfABC"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
