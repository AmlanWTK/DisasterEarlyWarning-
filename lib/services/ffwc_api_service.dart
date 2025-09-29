import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station_model.dart';
import '../models/water_level_model.dart';
import '../models/forecast_model.dart';
import '../models/rainfall_model.dart';

class FFWCApiService {
  static const String baseUrl = 'https://api.ffwc.gov.bd/data_load';
  static const Duration timeout = Duration(seconds: 30);

  // Get all monitoring stations
  static Future<List<Station>> getStations() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/stations-2025/'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        List<dynamic> stationsList = [];

        if (data is List) {
          stationsList = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            stationsList = data['data'] as List<dynamic>? ?? [];
          } else if (data.containsKey('stations')) {
            stationsList = data['stations'] as List<dynamic>? ?? [];
          } else if (data.containsKey('results')) {
            stationsList = data['results'] as List<dynamic>? ?? [];
          } else {
            stationsList = [data];
          }
        }

        print('🔍 DEBUG: Found ${stationsList.length} stations in API response');
        if (stationsList.isNotEmpty) {
          print('🔍 DEBUG: First station sample: ${stationsList.first}');
        }

        return stationsList.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getStations: $e');
      throw Exception('Network error loading stations: $e');
    }
  }

  // Get current water levels - CREATE FROM STATIONS DATA
  static Future<List<WaterLevel>> getCurrentWaterLevels() async {
    try {
      // Use stations data to create water levels since FFWC combines them
      final response = await http
          .get(Uri.parse('$baseUrl/stations-2025/'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        List<dynamic> stationsList = [];

        if (data is List) {
          stationsList = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            stationsList = data['data'] as List<dynamic>? ?? [];
          } else if (data.containsKey('stations')) {
            stationsList = data['stations'] as List<dynamic>? ?? [];
          } else {
            stationsList = [data];
          }
        }

        print('🔍 DEBUG: Creating water levels from ${stationsList.length} stations');

        // Convert stations to water levels
        final waterLevels = stationsList.map((json) => WaterLevel.fromStation(json)).toList();

        print('🔍 DEBUG: Created ${waterLevels.length} water levels');
        if (waterLevels.isNotEmpty) {
          print('🔍 DEBUG: First water level: ${waterLevels.first}');
        }

        return waterLevels;
      } else {
        throw Exception('Failed to load water levels: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCurrentWaterLevels: $e');
      throw Exception('Network error loading water levels: $e');
    }
  }

  // Get flood forecasts
  static Future<List<Forecast>> getFloodForecasts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/forecast/'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        List<dynamic> forecastsList = [];

        if (data is List) {
          forecastsList = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            final dataValue = data['data'];
            if (dataValue is List) {
              forecastsList = dataValue;
            }
          } else if (data.containsKey('forecasts')) {
            final forecastsValue = data['forecasts'];
            if (forecastsValue is List) {
              forecastsList = forecastsValue;
            }
          } else {
            for (final value in data.values) {
              if (value is List && value.isNotEmpty) {
                forecastsList = value;
                break;
              }
            }
          }
        }

        return forecastsList.map((json) => Forecast.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error in getFloodForecasts: $e');
    }

    return [];
  }

  // Get rainfall data
  static Future<List<Rainfall>> getRainfallData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/observed-rainfall/'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is List) {
          return data.map((json) => Rainfall.fromJson(json)).toList();
        } else if (data is Map<String, dynamic>) {
          List<dynamic> rainfallList = [];

          if (data.containsKey('data')) {
            final dataValue = data['data'];
            if (dataValue is List) {
              rainfallList = dataValue;
            }
          }

          return rainfallList.map((json) => Rainfall.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error in getRainfallData: $e');
    }

    return [];
  }

  // Get last update time
  static Future<DateTime> getLastUpdateTime() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/update-date/'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          String? timestamp = data['last_updated'] ?? 
                             data['updated_at'] ?? 
                             data['timestamp'] ?? 
                             data['date'];

          if (timestamp != null) {
            return DateTime.parse(timestamp);
          }
        }
      }
    } catch (e) {
      print('Error in getLastUpdateTime: $e');
    }

    return DateTime.now();
  }

  // Check API health
  static Future<bool> checkApiHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/update-date/'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('API health check failed: $e');
      return false;
    }
  }
}
