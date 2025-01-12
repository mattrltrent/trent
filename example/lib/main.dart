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
          child: Alerter<AuthTrent, TestTrentTypes>(
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
                Digester<AuthTrent, TestTrentTypes>(
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
                  onPressed: () => get<AuthTrent>().testBizFunc1(),
                  child: const Text("test biz func 1"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().testBizFunc2(),
                  child: const Text("test biz func 2"),
                ),
                TextButton(
                  onPressed: () => get<AuthTrent>().testBizFunc3(),
                  child: const Text("test biz func 3"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
