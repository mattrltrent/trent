import 'dart:convert';

import 'package:example/constants.dart';
import 'package:trent/trent.dart';
import 'package:http/http.dart' as http;

class WeatherTypes extends Equatable {
  @override
  List<Object> get props => [];
}

class NoData extends WeatherTypes {}

class Loading extends WeatherTypes {}

class Error extends WeatherTypes {
  final String message;
  Error(this.message);

  @override
  List<Object> get props => [message];
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

  void clear() {
    emit(NoData());
  }

  void fetchWeather(double latitude, double longitude) {
    emit(Loading());
    http
        .get(Uri.parse(
            'https://api.tomorrow.io/v4/weather/forecast?location=$latitude,$longitude&apikey=$weatherApiKey'))
        .then((response) {
      if (response.statusCode != 200) {
        alert(Error("Non-200 status code: ${response.statusCode}"));
        emit(NoData());
      } else {
        try {
          final data = jsonDecode(response.body);

          // Grab the first 'hourly' entry:
          final hourly = data['timelines']['hourly'] as List?;
          if (hourly == null || hourly.isEmpty) {
            alert(Error("No hourly data found"));
            emit(NoData());
            return;
          }

          // The first hourly record is the "closest to now" forecast
          final temperature = hourly[0]['values']['temperature'];

          // Emit that single temperature
          emit(Data("$latitude, $longitude", temperature));
        } catch (e) {
          alert(Error("Error parsing response"));
          emit(NoData());
        }
      }
    });
  }
}
