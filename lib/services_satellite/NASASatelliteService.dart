import 'dart:convert';
import 'package:http/http.dart' as http;

class NASASatelliteService {
  // NASA GIBS - Global Imagery Browse Services
  // FREE - No API key or registration required!
  static const String gibsBaseUrl =
      'https://gibs.earthdata.nasa.gov/wms/epsg4326/best/wms.cgi';

  // Get NASA satellite image URL
  static String getSatelliteImageUrl({
    required double latitude,
    required double longitude,
    String layer = 'MODIS_Aqua_CorrectedReflectance_TrueColor',
    String? date,
    double zoomKm = 15.0,
    int width = 512,
    int height = 512,
  }) {
    // ✅ Use yesterday’s date by default (today’s images may not be ready yet)
    final today = DateTime.now().subtract(const Duration(days: 1));
    final defaultDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final zoomDeg = zoomKm / 111.0;
    final minLat = latitude - zoomDeg;
    final maxLat = latitude + zoomDeg;
    final minLon = longitude - zoomDeg;
    final maxLon = longitude + zoomDeg;

    final params = {
      'service': 'WMS',
      'version': '1.1.1',
      'request': 'GetMap',
      'layers': layer,
      'bbox': '$minLon,$minLat,$maxLon,$maxLat', // ✅ fixed interpolation
      'width': width.toString(),
      'height': height.toString(),
      'format': 'image/jpeg',
      'srs': 'EPSG:4326',
      'time': date ?? defaultDate,
    };

    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$gibsBaseUrl?$queryString'; // ✅ fixed interpolation
  }

  // ✅ Only layers that are confirmed working with EPSG:4326
  static Map<String, String> getNASASatelliteLayers() {
    return {
      'True Color (Aqua)': 'MODIS_Aqua_CorrectedReflectance_TrueColor',
      'True Color (Terra)': 'MODIS_Terra_CorrectedReflectance_TrueColor',
      'Floods Detection (Aqua)': 'MODIS_Aqua_CorrectedReflectance_Bands721',
      'Floods Detection (Terra)': 'MODIS_Terra_CorrectedReflectance_Bands721',
    };
  }

  // Bangladesh major cities with coordinates
  static Map<String, Map<String, double>> getBangladeshCityCoordinates() {
    return {
      'Dhaka': {'lat': 23.8103, 'lon': 90.4125},
      'Chittagong': {'lat': 22.3569, 'lon': 91.7832},
      'Sylhet': {'lat': 24.8949, 'lon': 91.8687},
      'Rajshahi': {'lat': 24.3745, 'lon': 88.6042},
      'Khulna': {'lat': 22.8456, 'lon': 89.5403},
      'Barisal': {'lat': 22.7010, 'lon': 90.3535},
      'Rangpur': {'lat': 25.7439, 'lon': 89.2752},
      'Cox\'s Bazar': {'lat': 21.4272, 'lon': 92.0058},
      'Comilla': {'lat': 23.4607, 'lon': 91.1809},
      'Mymensingh': {'lat': 24.7471, 'lon': 90.4203},
    };
  }

  // For compatibility with existing code
  static Map<String, String> getProfessionalSatelliteLayers() {
    return getNASASatelliteLayers();
  }

  // Test NASA GIBS service availability
  static Future<bool> testNASAService() async {
    try {
      final testUrl = getSatelliteImageUrl(
        latitude: 23.8103, // Dhaka
        longitude: 90.4125,
        width: 100,
        height: 100,
      );

      final response = await http.head(Uri.parse(testUrl));
      final success = response.statusCode == 200;

      if (success) {
        print('NASA GIBS service is working perfectly!');
      } else {
        print('NASA GIBS test failed: ${response.statusCode}');
      }

      return success;
    } catch (e) {
      print('NASA GIBS service test error: $e');
      return false;
    }
  }

  // Test all APIs availability
  static Future<Map<String, bool>> testAPIsAvailability() async {
    print('Testing NASA GIBS satellite service...');

    final nasaAvailable = await testNASAService();

    return {
      'nasa_gibs': nasaAvailable,
      'sentinel': false,
      'usgs': false,
    };
  }

  // Setup instructions for NASA GIBS
  static String getAPISetupInstructions() {
    return 'NASA GIBS SATELLITE IMAGERY - NO SETUP REQUIRED!\n\n'
        'READY TO USE: No API keys, no registration, no authentication!\n'
        'FREE FOREVER: NASA public service, completely free\n'
        'REAL SATELLITE DATA: MODIS Aqua/Terra satellites\n'
        'DAILY UPDATES: Fresh satellite imagery every day\n'
        'GLOBAL COVERAGE: Complete Bangladesh coverage\n\n'
        'AVAILABLE LAYERS:\n'
        '- True Color (Aqua/Terra) - Natural satellite imagery\n'
        '- Floods Detection (Bands 7-2-1) - Enhanced water body detection\n\n'
        'YOUR SATELLITE SERVICE IS READY!\n'
        'Just select a city and layer - no configuration needed!';
  }
}
