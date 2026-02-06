import 'dart:convert';
import 'package:http/http.dart' as http;
import 'env.dart';

class WeatherService {
  final String apiKey = EnvService.weatherApi; 

  Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
    final url = Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('فشل في تحميل البيانات');
    }
  }

  /// توقعات الطقس للأيام القادمة (forecast.json) - 7 أيام
  Future<Map<String, dynamic>> getForecastData(double lat, double lon, {int days = 7}) async {
    final url = Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lat,$lon&days=$days');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('فشل في تحميل التوقعات');
    }
  }
}
