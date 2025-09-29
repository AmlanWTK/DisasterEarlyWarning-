class Rainfall {
  final String stationId;
  final String stationName;
  final String location;
  final DateTime timestamp;
  final double rainfall24h; // 24-hour rainfall in mm
  final double rainfallDaily; // Daily rainfall in mm
  final double rainfallMonthly; // Monthly rainfall in mm
  final String intensity; // 'Light', 'Moderate', 'Heavy', 'Very Heavy'

  Rainfall({
    required this.stationId,
    required this.stationName,
    required this.location,
    required this.timestamp,
    required this.rainfall24h,
    this.rainfallDaily = 0.0,
    this.rainfallMonthly = 0.0,
    this.intensity = 'Light',
  });

  factory Rainfall.fromJson(Map<String, dynamic> json) {
    return Rainfall(
      stationId: json['station_id']?.toString() ?? '',
      stationName: json['station_name'] ?? '',
      location: json['location'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      rainfall24h: double.tryParse(json['rainfall_24h']?.toString() ?? '0') ?? 0.0,
      rainfallDaily: double.tryParse(json['rainfall_daily']?.toString() ?? '0') ?? 0.0,
      rainfallMonthly: double.tryParse(json['rainfall_monthly']?.toString() ?? '0') ?? 0.0,
      intensity: json['intensity'] ?? _calculateIntensity(
        double.tryParse(json['rainfall_24h']?.toString() ?? '0') ?? 0.0
      ),
    );
  }

  // Calculate intensity based on 24-hour rainfall
  static String _calculateIntensity(double rainfall24h) {
    if (rainfall24h >= 200) return 'Extremely Heavy';
    if (rainfall24h >= 115) return 'Very Heavy';
    if (rainfall24h >= 65) return 'Heavy';
    if (rainfall24h >= 15) return 'Moderate';
    if (rainfall24h >= 2.5) return 'Light';
    return 'No Rain';
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'station_name': stationName,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'rainfall_24h': rainfall24h,
      'rainfall_daily': rainfallDaily,
      'rainfall_monthly': rainfallMonthly,
      'intensity': intensity,
    };
  }

  // Check if rainfall is at warning level (>50mm in 24h)
  bool get isWarningLevel => rainfall24h > 50;

  // Check if rainfall is at danger level (>100mm in 24h)
  bool get isDangerLevel => rainfall24h > 100;

  // Get rainfall status color
  String get statusColor {
    if (isDangerLevel) return 'red';
    if (isWarningLevel) return 'orange';
    if (rainfall24h > 15) return 'yellow';
    return 'green';
  }

  // Format rainfall for display
  String get formattedRainfall => '${rainfall24h.toStringAsFixed(1)}mm';

  @override
  String toString() {
    return 'Rainfall{station: $stationName, 24h: ${rainfall24h}mm, intensity: $intensity}';
  }
}
