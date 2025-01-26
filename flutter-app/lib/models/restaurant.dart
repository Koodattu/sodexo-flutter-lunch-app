/// Represents a Restaurant entry parsed from JSON.
class Restaurant {
  final String? jsonId;
  final String urlId;
  final String name;
  final String location;
  final String? lunchHours;
  final String? openHours;
  final List<String> type;
  final double? lat; // Latitude
  final double? lon; // Longitude

  Restaurant({
    this.jsonId,
    required this.urlId,
    required this.name,
    required this.location,
    this.lunchHours,
    this.openHours,
    required this.type,
    this.lat,
    this.lon,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      jsonId: json['json_id'],
      urlId: json['url_id'],
      name: json['name'].trim(),
      location: json['location'],
      lunchHours: json['lunch_hours'],
      openHours: json['open_hours'],
      type: List<String>.from(json['type']),
      lat: json['lat'] != null ? double.tryParse(json['lat']) : null,
      lon: json['lon'] != null ? double.tryParse(json['lon']) : null,
    );
  }
}
