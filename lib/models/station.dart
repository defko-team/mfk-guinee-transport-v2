class StationModel {
  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final String? address;

  StationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory StationModel.fromMap(Map<String, dynamic> map) {
    return StationModel(
      id: map['id'],
      name: map['name'] ?? "",
      latitude: map['latitude'].toDouble() ?? 0.0,
      longitude: map['longitude'].toDouble() ?? 0.0,
      address: map['address'] ?? "test",
    );
  }
}
