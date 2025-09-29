import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecast;
  List<Map<String, dynamic>> _cityWeather = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCity = 'Dhaka';

  // Getters
  Map<String, dynamic>? get currentWeather => _currentWeather;
  Map<String, dynamic>? get forecast => _forecast;
  List<Map<String, dynamic>> get cityWeather => _cityWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCity => _selectedCity;

  // Load weather data - FIXED: Use addPostFrameCallback to avoid setState during build
  Future<void> loadWeatherData(String city) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _performLoadWeatherData(city);
    });
  }

  // Actual weather loading implementation
  Future<void> _performLoadWeatherData(String city) async {
    _isLoading = true;
    _error = null;
    _selectedCity = city;
    notifyListeners();

    try {
      print('🌤️ Loading weather data for \$city...');

      final results = await Future.wait([
        WeatherService.getCurrentWeather(city),
        WeatherService.getForecast(city),
      ]);

      _currentWeather = results[0];
      _forecast = results[1];
      _error = null;

      print('✅ Weather data loaded successfully for \$city');

    } catch (e) {
      _error = e.toString();
      print('❌ Weather error for \$city: \$e');

      if (kDebugMode) {
        print('Weather API error details: \$e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load weather for all major cities
  Future<void> loadAllCitiesWeather() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _performLoadAllCitiesWeather();
    });
  }

  Future<void> _performLoadAllCitiesWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cityWeather = await WeatherService.getWeatherForMajorCities();
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading cities weather: \$e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh current weather - SAFE: Called from user actions, not build
  Future<void> refreshWeather() async {
    if (_selectedCity.isNotEmpty) {
      await _performLoadWeatherData(_selectedCity);
    }
  }

  // Load weather immediately (for manual refresh) - SAFE
  Future<void> loadWeatherDataImmediate(String city) async {
    await _performLoadWeatherData(city);
  }

  // Set selected city - SAFE
  void setSelectedCity(String city) {
    if (_selectedCity != city) {
      _selectedCity = city;
      loadWeatherData(city);
    }
  }

  // Get temperature in Celsius
  double? getTemperature() {
    if (_currentWeather != null && _currentWeather!['main'] != null) {
      return _currentWeather!['main']['temp']?.toDouble();
    }
    return null;
  }

  // Get weather description
  String getWeatherDescription() {
    if (_currentWeather != null && 
        _currentWeather!['weather'] != null && 
        _currentWeather!['weather'].isNotEmpty) {
      return _currentWeather!['weather'][0]['description'] ?? 'Unknown';
    }
    return 'No data';
  }

  // Get weather icon
  String? getWeatherIcon() {
    if (_currentWeather != null && 
        _currentWeather!['weather'] != null && 
        _currentWeather!['weather'].isNotEmpty) {
      return _currentWeather!['weather'][0]['icon'];
    }
    return null;
  }

  // Check if there are any weather alerts
  bool hasWeatherAlerts() {
    // Check for severe weather conditions
    final description = getWeatherDescription().toLowerCase();
    return description.contains('storm') || 
           description.contains('heavy rain') ||
           description.contains('thunderstorm') ||
           description.contains('cyclone');
  }

  // Initialize weather data (call this once when app starts) - SAFE
  Future<void> initializeWeatherData(String city) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _performLoadWeatherData(city);
  }
}
