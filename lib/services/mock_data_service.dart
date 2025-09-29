import '../models/station_model.dart';
import '../models/water_level_model.dart';
import '../models/forecast_model.dart';

class MockDataService {
  // Provide mock data when real APIs fail
  static List<Station> getMockStations() {
    return [
      Station(
        id: '1',
        name: 'Dhaka (Buriganga)',
        riverName: 'Buriganga',
        division: 'Dhaka',
        district: 'Dhaka',
        dangerLevel: 5.55,
        isActive: true,
      ),
      Station(
        id: '2',
        name: 'Khulna (Rupsa)',
        riverName: 'Rupsa',
        division: 'Khulna',
        district: 'Khulna',
        dangerLevel: 2.60,
        isActive: true,
      ),
      Station(
        id: '3',
        name: 'Rajshahi (Ganges)',
        riverName: 'Ganges',
        division: 'Rajshahi',
        district: 'Rajshahi',
        dangerLevel: 18.05,
        isActive: true,
      ),
    ];
  }

  static List<WaterLevel> getMockWaterLevels() {
    return [
      WaterLevel(
        stationId: '1',
        stationName: 'Dhaka (Buriganga)',
        riverName: 'Buriganga',
        currentLevel: 3.53,
        dangerLevel: 5.55,
        status: 'Below Danger',
        statusCm: -202,
        trend: 'Steady',
        timestamp: DateTime.now(),
      ),
      WaterLevel(
        stationId: '2',
        stationName: 'Khulna (Rupsa)',
        riverName: 'Rupsa',
        currentLevel: 2.52,
        dangerLevel: 2.60,
        status: 'Below Danger',
        statusCm: -8,
        trend: 'Rising',
        timestamp: DateTime.now(),
      ),
      WaterLevel(
        stationId: '3',
        stationName: 'Rajshahi (Ganges)',
        riverName: 'Ganges',
        currentLevel: 16.49,
        dangerLevel: 18.05,
        status: 'Below Danger',
        statusCm: -156,
        trend: 'Falling',
        timestamp: DateTime.now(),
      ),
    ];
  }

  static List<Forecast> getMockForecasts() {
    return [
      Forecast(
        stationId: '1',
        stationName: 'Dhaka (Buriganga)',
        riverName: 'Buriganga',
        forecastDate: DateTime.now().add(const Duration(hours: 24)),
        predictedLevel: 3.60,
        dangerLevel: 5.55,
        forecastType: '24h',
        confidence: 'High',
        trend: 'Rising',
      ),
    ];
  }
}
