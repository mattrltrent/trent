// FULL EXAMPLE OF WEATHER APP USING TRENT: https://github.com/mattrltrent/trent/tree/main/example

import 'package:example/home.dart';
import 'package:example/trents/weather_trent.dart';
import 'package:flutter/material.dart';
import 'package:trent/trent.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    TrentManager(
      trents: [WeatherTrent()],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => WeatherTrent()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather Example App',
        home: HomeScreen(),
      ),
    );
  }
}
