class Beach {
  final String id;
  final String name;
  final String location;
  final double temperature;
  final double waveHeight;
  final String oceanCurrents;
  final bool isSafe;
  final String description;
  final double latitude;
  final double longitude;

  Beach({
    required this.id,
    required this.name,
    required this.location,
    required this.temperature,
    required this.waveHeight,
    required this.oceanCurrents,
    required this.isSafe,
    required this.latitude,
    required this.longitude,
    this.description = '',
  });

  factory Beach.fromJson(Map<String, dynamic> json) {
    return Beach(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      temperature: json['temperature'].toDouble(),
      waveHeight: json['waveHeight'].toDouble(),
      oceanCurrents: json['oceanCurrents'],
      isSafe: json['isSafe'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'temperature': temperature,
      'waveHeight': waveHeight,
      'oceanCurrents': oceanCurrents,
      'isSafe': isSafe,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
    };
  }
}
