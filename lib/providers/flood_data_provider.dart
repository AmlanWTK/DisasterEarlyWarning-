import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/station_model.dart';
import '../models/water_level_model.dart';
import '../models/forecast_model.dart';
import '../services/ffwc_api_service.dart';
import '../services/notification_service.dart';
import '../services/mock_data_service.dart';

class FloodDataProvider with ChangeNotifier {
  List<Station> _stations = [];
  List<WaterLevel> _waterLevels = [];
  List<Forecast> _forecasts = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;
  bool _usingMockData = false;

  // Getters
  List<Station> get stations => _stations;
  List<WaterLevel> get waterLevels => _waterLevels;
  List<Forecast> get forecasts => _forecasts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  bool get usingMockData => _usingMockData;

  // Get critical alerts
  List<WaterLevel> get criticalAlerts => 
      _waterLevels.where((wl) => wl.isAboveDanger).toList();

  // Get warning level stations
  List<WaterLevel> get warningLevels => 
      _waterLevels.where((wl) => wl.isWarningLevel && !wl.isAboveDanger).toList();

  // Load all flood data - FIXED with better error handling
  Future<void> loadFloodData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _performLoadFloodData();
    });
  }

  // Actual data loading implementation with fallback to mock data
  Future<void> _performLoadFloodData() async {
    _isLoading = true;
    _error = null;
    _usingMockData = false;
    notifyListeners();

    try {
      // Try to load real data first
      final results = await Future.wait([
        FFWCApiService.getStations(),
        FFWCApiService.getCurrentWaterLevels(),
        FFWCApiService.getFloodForecasts(),
      ]);

      _stations = results[0] as List<Station>;
      _waterLevels = results[1] as List<WaterLevel>;
      _forecasts = results[2] as List<Forecast>;
      _lastUpdated = DateTime.now();
      _usingMockData = false;

      // Check for critical alerts
      await _checkForAlerts();

      _error = null;

      if (kDebugMode) {
        print('✅ Successfully loaded real FFWC data');
        print('   Stations: ${_stations.length}');
        print('   Water Levels: ${_waterLevels.length}');
        print('   Forecasts: ${_forecasts.length}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading real data: $e');
        print('🔄 Falling back to mock data for demonstration');
      }

      // Fallback to mock data for demonstration purposes
      _stations = MockDataService.getMockStations();
      _waterLevels = MockDataService.getMockWaterLevels();
      _forecasts = MockDataService.getMockForecasts();
      _lastUpdated = DateTime.now();
      _usingMockData = true;

      _error = 'Using demo data - API connection failed: ${e.toString()}';

      if (kDebugMode) {
        print('✅ Loaded mock data for demonstration');
        print('   Mock Stations: ${_stations.length}');
        print('   Mock Water Levels: ${_waterLevels.length}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh water levels only
  Future<void> refreshWaterLevels() async {
    try {
      final newWaterLevels = await FFWCApiService.getCurrentWaterLevels();

      // Check for new alerts
      final previousCritical = criticalAlerts.map((wl) => wl.stationId).toSet();
      final newCritical = newWaterLevels
          .where((wl) => wl.isAboveDanger)
          .map((wl) => wl.stationId)
          .toSet();

      // Find stations that just became critical
      final newlyAlert = newCritical.difference(previousCritical);

      _waterLevels = newWaterLevels;
      _lastUpdated = DateTime.now();
      _usingMockData = false;
      _error = null;

      // Send notifications for new alerts
      for (final stationId in newlyAlert) {
        final station = _waterLevels.firstWhere((wl) => wl.stationId == stationId);
        await NotificationService.showFloodAlert(
          stationName: station.stationName,
          riverName: station.riverName,
          waterLevel: station.currentLevel,
          dangerLevel: station.dangerLevel,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = 'Refresh failed: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load data immediately (for manual refresh)
  Future<void> loadFloodDataImmediate() async {
    await _performLoadFloodData();
  }

  // Check for alerts and send notifications
  Future<void> _checkForAlerts() async {
    for (final waterLevel in criticalAlerts) {
      await NotificationService.showFloodAlert(
        stationName: waterLevel.stationName,
        riverName: waterLevel.riverName,
        waterLevel: waterLevel.currentLevel,
        dangerLevel: waterLevel.dangerLevel,
      );
    }
  }

  // Get water level for specific station
  WaterLevel? getWaterLevelForStation(String stationId) {
    try {
      return _waterLevels.firstWhere((wl) => wl.stationId == stationId);
    } catch (e) {
      return null;
    }
  }

  // Get stations by division
  List<Station> getStationsByDivision(String division) {
    return _stations.where((s) => s.division == division).toList();
  }

  // Get stations by alert level
  List<WaterLevel> getStationsByAlertLevel(String alertLevel) {
    return _waterLevels.where((wl) => wl.alertLevel == alertLevel).toList();
  }

  // Initialize data (call this once when app starts)
  Future<void> initializeData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _performLoadFloodData();
  }

}
