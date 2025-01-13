import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trent/trent.dart';

// ====== main.dart ======

void main() {
  runApp(
    TrentManager(
      trents: [
        register(WeatherTrent()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Example App',
      home: const HomeScreen(),
    );
  }
}

// ====== home_screen.dart ======

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final weatherTrent = get<WeatherTrent>(context);

    return Scaffold(
      appBar: AppBar(
        title: watchMap<WeatherTrent, WeatherTypes>(context, (mapper) {
          mapper
            ..as<NoData>((state) => const Text("Enter Location"))
            ..as<Loading>((state) => const Text("Fetching Weather..."))
            ..orElse((state) => const Text("Weather App"));
        }),
      ),
      floatingActionButton: watch<WeatherTrent>(context).state is Data
          ? FloatingActionButton(
              onPressed: () => weatherTrent.clear(),
              child: const Icon(Icons.clear),
            )
          : null,
      body: Center(
        child: Alerter<WeatherTrent, WeatherTypes>(
          listenAlerts: (mapper) => mapper
            ..as<Error>((state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${state.message}"),
                  duration: const Duration(seconds: 2),
                ),
              );
            }),
          listenStates: (mapper) => mapper
            ..as<NoData>((state) {
              print("HELLO!");
              _latitudeController.clear();
              _longitudeController.clear();
            }),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Latitude",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Longitude",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    final latitude = double.tryParse(_latitudeController.text);
                    final longitude = double.tryParse(_longitudeController.text);

                    if (latitude != null && longitude != null) {
                      weatherTrent.fetchWeather(latitude, longitude);
                    } else {
                      weatherTrent.alert(Error("Invalid Latitude/Longitude"));
                    }
                  },
                  child: const Text("Fetch Weather"),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: BoxConstraints(minHeight: 200),
                  child: Digester<WeatherTrent, WeatherTypes>(
                    child: (mapper) {
                      mapper
                        ..as<NoData>((state) => const Text("Please enter location to fetch weather."))
                        ..as<Loading>((state) => const CupertinoActivityIndicator())
                        ..as<Data>((state) => Text(
                              "${state.location} has temperature ${state.temperature}°C",
                              style: const TextStyle(fontSize: 18),
                            ))
                        ..orElse((state) => const Text("Unknown state"));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====== trents/weather_trent.dart ======

class WeatherTypes extends EquatableCopyable<WeatherTypes> {
  @override
  List<Object> get props => [];

  @override
  WeatherTypes copyWith() {
    return this;
  }
}

class NoData extends WeatherTypes {}

class Loading extends WeatherTypes {}

class Error extends WeatherTypes {
  final String message;
  Error(this.message);

  @override
  List<Object> get props => [message];

  @override
  Error copyWith({String? message}) {
    return Error(message ?? this.message);
  }
}

class Data extends WeatherTypes {
  final String location;
  final double temperature;
  Data(this.location, this.temperature);

  @override
  List<Object> get props => [location, temperature];
}

class WeatherTrent extends Trent<WeatherTypes> {
  WeatherTrent() : super(NoData());

  /// Clears the current state and resets to NoData
  void clear() {
    emit(NoData());
  }

  /// Fetch mock weather data for a given latitude and longitude
  void fetchWeather(double latitude, double longitude) {
    emit(Loading());
    Future.delayed(const Duration(milliseconds: 500), () {
      final mockData = {
        "temperature": double.parse((15 + (latitude % 10) + Random().nextDouble() * 5).toStringAsFixed(1)),
        "location": "$latitude, $longitude",
      };

      try {
        final temperature = mockData['temperature'] as double;
        final location = mockData['location'] as String;
        emit(Data(location, temperature));
      } catch (e) {
        alert(Error("Error parsing mock data: $e"));
        emit(NoData());
      }
    });
  }
}
