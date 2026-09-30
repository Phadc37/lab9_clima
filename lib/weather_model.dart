import 'package:flutter/material.dart';
class WeatherModel {
  final String city;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double wind;
  final int condition;
  final String description;

  WeatherModel({
    required this.city,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.wind,
    required this.condition,
    required this.description,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'] ?? '',
      temp: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      wind: (json['wind']['speed'] as num).toDouble(),
      condition: json['weather'][0]['id'] as int,
      description: json['weather'][0]['description'] as String,
    );
  }

  IconData get icon => _iconFor(condition);
}
IconData _iconFor(int id) {
  if (id < 300) return Icons.thunderstorm;
  if (id < 600) return Icons.grain;
  if (id < 700) return Icons.ac_unit;
  if (id < 800) return Icons.foggy;
  if (id == 800) return Icons.wb_sunny;
  return Icons.cloud;
}