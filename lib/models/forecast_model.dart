class Forecast {
  final String stationId;
  final String stationName;
  final String riverName;
  final DateTime forecastDate;
  final double predictedLevel;
  final double dangerLevel;
  final String forecastType; // '24h', '48h', '72h'
  final String confidence; // 'High', 'Medium', 'Low'
  final String trend; // 'Rising', 'Falling', 'Steady'

  Forecast({
    required this.stationId,
    required this.stationName,
    required this.riverName,
    required this.forecastDate,
    required this.predictedLevel,
    required this.dangerLevel,
    required this.forecastType,
    this.confidence = 'Medium',
    this.trend = 'Steady',
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      stationId: json['station_id']?.toString() ?? '',
      stationName: json['station_name'] ?? '',
      riverName: json['river_name'] ?? '',
      forecastDate: DateTime.tryParse(json['forecast_date'] ?? '') ?? DateTime.now(),
      predictedLevel: double.tryParse(json['predicted_level']?.toString() ?? '0') ?? 0.0,
      dangerLevel: double.tryParse(json['danger_level']?.toString() ?? '0') ?? 0.0,
      forecastType: json['forecast_type'] ?? '24h',
      confidence: json['confidence'] ?? 'Medium',
      trend: json['trend'] ?? 'Steady',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'station_name': stationName,
      'river_name': riverName,
      'forecast_date': forecastDate.toIso8601String(),
      'predicted_level': predictedLevel,
      'danger_level': dangerLevel,
      'forecast_type': forecastType,
      'confidence': confidence,
      'trend': trend,
    };
  }

  // Check if forecast shows danger level will be exceeded
  bool get willExceedDanger => predictedLevel > dangerLevel;

  // Get risk level based on predicted vs danger level
  String get riskLevel {
    final difference = predictedLevel - dangerLevel;
    if (difference > 1.0) return 'Critical';
    if (difference > 0.0) return 'High';
    if (difference > -0.5) return 'Medium';
    return 'Low';
  }

  // Get hours until forecast
  int get hoursUntilForecast {
    final now = DateTime.now();
    return forecastDate.difference(now).inHours;
  }

  @override
  String toString() {
    return 'Forecast{station: $stationName, predicted: ${predictedLevel}m, danger: ${dangerLevel}m, type: $forecastType}';
  }
}
