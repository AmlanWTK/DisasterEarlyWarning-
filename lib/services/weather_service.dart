import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // CORRECTED: Use the NEW API key from your email (the one that works in Postman)
  static const String apiKey = 'bdbc0899bcb6c67a77d6d373576cce49';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    // Check if API key is properly set
    if (apiKey == 'YOUR_OPENWEATHERMAP_API_KEY' || apiKey.isEmpty) {
      throw Exception('OpenWeatherMap API key not configured. Please add your API key.');
    }

    // Use the same URL format that worked in Postman
    final url = '$baseUrl/weather?q=$city,BD&appid=$apiKey&units=metric';

    try {
      print('🌤️ Fetching weather for $city with API key: ${apiKey.substring(0, 8)}...');
      print('🌤️ URL: $url');

      final response = await http.get(Uri.parse(url));

      print('🌤️ Weather API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Weather data loaded successfully for $city');
        print('📊 Temperature: ${data['main']['temp']}°C');
        print('🌤️ Condition: ${data['weather'][0]['description']}');
        return data;
      } else if (response.statusCode == 401) {
        print('❌ API Key Error (401): Invalid or inactive key');
        throw Exception('Invalid API key (401). Please check your OpenWeatherMap API key.');
      } else if (response.statusCode == 404) {
        print('❌ City not found (404): $city');
        throw Exception('City not found (404). Please check the city name: $city');
      } else {
        print('❌ API Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Weather API error for $city: $e');
      throw Exception('Weather API error: $e');
    }
  }

  static Future<Map<String, dynamic>> getForecast(String city) async {
    if (apiKey == 'YOUR_OPENWEATHERMAP_API_KEY' || apiKey.isEmpty) {
      throw Exception('OpenWeatherMap API key not configured');
    }

    final url = '$baseUrl/forecast?q=$city,BD&appid=$apiKey&units=metric';

    try {
      print('🌤️ Fetching forecast for $city...');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('✅ Forecast loaded successfully for $city');
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key (401)');
      } else {
        throw Exception('Failed to load forecast: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Forecast API error for $city: $e');
      throw Exception('Forecast API error: $e');
    }
  }

  // Get weather for major Bangladesh cities
  static Future<List<Map<String, dynamic>>> getWeatherForMajorCities() async {
    final cities = ['Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi', 'Khulna'];
    final List<Map<String, dynamic>> cityWeather = [];

    for (final city in cities) {
      try {
        final weather = await getCurrentWeather(city);
        cityWeather.add({
          'city': city,
          'weather': weather,
        });
      } catch (e) {
        print('❌ Error loading weather for $city: $e');
        cityWeather.add({
          'city': city,
          'weather': null,
          'error': e.toString(),
        });
      }
    }

    return cityWeather;
  }
}
