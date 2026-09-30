import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';
import 'weather_model.dart';

class WeatherService {
  Future<WeatherModel> _get(Map<String, String> query) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      ...query,
      'appid': kApiKey,
      'units': 'metric',
      'lang': 'vi',
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Lỗi ${res.statusCode}');
    }
    return WeatherModel.fromJson(jsonDecode(res.body));
  }

  Future<WeatherModel> byLocation(double lat, double lon) =>
      _get({'lat': '$lat', 'lon': '$lon'});

  Future<WeatherModel> byCity(String city) => _get({'q': city});
}