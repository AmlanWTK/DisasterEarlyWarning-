class WaterLevel {
  final String stationId;
  final String stationName;
  final String riverName;
  final double currentLevel;
  final double dangerLevel;
  final String status;
  final int statusCm;
  final String trend;
  final DateTime timestamp;
  final String? division;
  final String? district;
  final String? upazilla;
  final String? basin;

  WaterLevel({
    required this.stationId,
    required this.stationName,
    required this.riverName,
    required this.currentLevel,
    required this.dangerLevel,
    required this.status,
    required this.statusCm,
    required this.trend,
    required this.timestamp,
    this.division,
    this.district,
    this.upazilla,
    this.basin,
  });

  // Create WaterLevel from Station data (FFWC stations contain water level info)
  factory WaterLevel.fromStation(Map<String, dynamic> json) {
    final stationName = json['station']?.toString() ?? 'Unknown Station';
    final riverName = json['river']?.toString() ?? 'Unknown River';

    // For now, use danger level as current level (until we find current level field)
    final dangerLevel = _parseDouble(json['dl'] ?? 0);
    final currentLevel = _parseDouble(json['current_wl'] ?? 
                                    json['water_level'] ?? 
                                    json['wl'] ?? 
                                    dangerLevel * 0.8); // Estimate 80% of danger level

    final statusCm = ((currentLevel - dangerLevel) * 100).round();

    return WaterLevel(
      stationId: json['st_id']?.toString() ?? 
                json['station_id']?.toString() ?? 
                DateTime.now().millisecondsSinceEpoch.toString(),
      stationName: stationName,
      riverName: riverName,
      currentLevel: currentLevel,
      dangerLevel: dangerLevel,
      status: _formatStatus(currentLevel, dangerLevel),
      statusCm: statusCm,
      trend: json['trend']?.toString() ?? 
             json['tendency']?.toString() ?? 
             'Steady',
      timestamp: DateTime.now(),
      division: json['division']?.toString(),
      district: json['district']?.toString(),
      upazilla: json['upazilla']?.toString(),
      basin: json['basin']?.toString(),
    );
  }

  factory WaterLevel.fromJson(Map<String, dynamic> json) {
    final stationName = json['station']?.toString() ?? 
                       json['station_name']?.toString() ?? 
                       'Unknown Station';

    final riverName = json['river']?.toString() ?? 
                     json['river_name']?.toString() ?? 
                     'Unknown River';

    final currentLevel = _parseDouble(json['water_level'] ?? 
                                    json['current_level'] ?? 
                                    json['level'] ?? 
                                    json['wl'] ?? 
                                    0);

    final dangerLevel = _parseDouble(json['dl'] ?? 
                                   json['danger_level'] ?? 
                                   json['dangerLevel'] ?? 
                                   0);

    final statusCm = ((currentLevel - dangerLevel) * 100).round();

    return WaterLevel(
      stationId: json['st_id']?.toString() ?? 
                json['station_id']?.toString() ?? 
                json['id']?.toString() ?? 
                DateTime.now().millisecondsSinceEpoch.toString(),
      stationName: stationName,
      riverName: riverName,
      currentLevel: currentLevel,
      dangerLevel: dangerLevel,
      status: _formatStatus(currentLevel, dangerLevel),
      statusCm: statusCm,
      trend: json['trend']?.toString() ?? 
             json['tendency']?.toString() ?? 
             'Steady',
      timestamp: _parseTimestamp(json['timestamp'] ?? 
                               json['time'] ?? 
                               json['date'] ?? 
                               json['updated_at']),
      division: json['division']?.toString(),
      district: json['district']?.toString(),
      upazilla: json['upazilla']?.toString(),
      basin: json['basin']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  static String _formatStatus(double current, double danger) {
    final diff = current - danger;
    if (diff > 0.5) return 'Above Danger';
    if (diff > 0) return 'Near Danger';
    if (diff > -0.5) return 'Warning';
    return 'Below Danger';
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'station_name': stationName,
      'river_name': riverName,
      'current_level': currentLevel,
      'danger_level': dangerLevel,
      'status': status,
      'status_cm': statusCm,
      'trend': trend,
      'timestamp': timestamp.toIso8601String(),
      'division': division,
      'district': district,
      'upazilla': upazilla,
      'basin': basin,
    };
  }

  // Computed properties for easier use in UI
  bool get isAboveDanger => currentLevel > dangerLevel;
  bool get isWarningLevel => !isAboveDanger && (dangerLevel - currentLevel) < 1.0;
  bool get isRising => trend.toLowerCase().contains('rising') || trend.toLowerCase().contains('up');
  bool get isFalling => trend.toLowerCase().contains('falling') || trend.toLowerCase().contains('down');

  String get alertLevel {
    if (isAboveDanger) return 'Critical';
    if (isWarningLevel) return 'Warning';
    return 'Normal';
  }

  @override
  String toString() {
    return 'WaterLevel{station: $stationName, river: $riverName, current: ${currentLevel}m, danger: ${dangerLevel}m, division: $division, district: $district}';
  }
}
