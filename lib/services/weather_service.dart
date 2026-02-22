import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:examen/models/weather.dart';

class WeatherService {
  static const String _apiKey = 'a458ae934f71b94fd2bb16a3e07397a0';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  /// Villes du Sénégal et d'ailleurs (préférence Sénégal).
  static final List<String> cities = [
    'Dakar',
    'Saint-Louis',
    'Thiès',
    'Ziguinchor',
    'Touba',
  ];

  static Future<Weather> fetchWeather(String city) async {
    final url = Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=fr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Impossible de charger la météo pour $city. Réessayez plus tard.');
    }
  }

  static Future<List<Weather>> fetchAllCities() async {
    List<Weather> results = [];
    for (String city in cities) {
      final weather = await fetchWeather(city);
      results.add(weather);
    }
    return results;
  }
}
