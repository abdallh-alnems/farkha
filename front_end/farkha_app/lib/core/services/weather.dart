import 'dart:convert';
import 'package:http/http.dart' as http;
import 'env.dart';

class WeatherService {
  final String apiKey = EnvService.weatherApi; 

  Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
    final url = Uri.parse(
        "http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception('فشل في تحميل البيانات');
    }
  }
}
