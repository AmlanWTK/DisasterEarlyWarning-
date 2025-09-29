class Station {
  final String id;
  final String name;
  final String riverName;
  final String division;
  final String district;
  final double dangerLevel;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final String? upazilla;
  final String? basin;

  Station({
    required this.id,
    required this.name,
    required this.riverName,
    required this.division,
    required this.district,
    required this.dangerLevel,
    this.isActive = true,
    this.latitude,
    this.longitude,
    this.upazilla,
    this.basin,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      // FFWC API uses "st_id" for station ID
      id: json['st_id']?.toString() ?? 
          json['station_id']?.toString() ?? 
          json['id']?.toString() ?? 
          '',

      // FFWC API uses "station" for station name
      name: json['station']?.toString() ?? 
            json['station_name']?.toString() ?? 
            json['name']?.toString() ?? 
            'Unknown Station',

      // FFWC API uses "river" for river name
      riverName: json['river']?.toString() ?? 
                 json['river_name']?.toString() ?? 
                 'Unknown River',

      // Division mapping
      division: json['division']?.toString() ?? 
                json['h_division']?.toString() ?? 
                'Unknown Division',

      // District mapping
      district: json['district']?.toString() ?? 
                'Unknown District',

      // FFWC API uses "dl" for danger level
      dangerLevel: _parseDouble(json['dl'] ?? 
                               json['danger_level'] ?? 
                               json['dangerLevel'] ?? 
                               0),

      isActive: json['is_active'] ?? 
                json['active'] ?? 
                true,

      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'river_name': riverName,
      'division': division,
      'district': district,
      'danger_level': dangerLevel,
      'is_active': isActive,
      'latitude': latitude,
      'longitude': longitude,
      'upazilla': upazilla,
      'basin': basin,
    };
  }

  @override
  String toString() {
    return 'Station{id: $id, name: $name, river: $riverName, division: $division, district: $district, dangerLevel: $dangerLevel}';
  }
}
