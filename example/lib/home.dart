import 'package:example/trents/weather_trent.dart';
import 'package:flutter/material.dart';
import 'package:trent/trent.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(watch<WeatherTrent>(context).currState.toString()),
      ),
      floatingActionButton: watch<WeatherTrent>(context).currState is Data
          ? FloatingActionButton(
              onPressed: () => read<WeatherTrent>(context).reset(),
              child: const Icon(Icons.refresh),
            )
          : null,
      body: Center(
        child: Alerter<WeatherTrent, WeatherTypes>(
          handlers: (mapper) => mapper
            ..as<Error>((state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  duration: const Duration(seconds: 2),
                ),
              );
            }),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Digester<WeatherTrent, WeatherTypes>(
                handlers: (mapper) {
                  mapper
                    ..as<NoData>((state) => Column(
                          children: [
                            Text("No data"),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => read<WeatherTrent>(context).fetchWeather(37.7749, -122.4194),
                              child: const Text("Fetch weather for San Francisco"),
                            ),
                            TextButton(
                              onPressed: () => read<WeatherTrent>(context).fetchWeather(999999, 999999),
                              child: const Text("Fetch weather for San Francisco (bad request)"),
                            ),
                          ],
                        ))
                    ..as<Loading>((state) => const CircularProgressIndicator())
                    ..as<Data>((state) => Column(
                          children: [
                            Text("${state.location} has temperature ${state.temperature}"),
                          ],
                        ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
