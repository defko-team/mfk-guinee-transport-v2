class GareModel {
  final String idGare;
  final String nomGare;
  final double latitude;
  final double longitude;
  final String adresse;

  GareModel({
    required this.idGare,
    required this.nomGare,
    required this.latitude,
    required this.longitude,
    required this.adresse,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_gare': idGare,
      'nom_gare': nomGare,
      'latitude': latitude,
      'longitude': longitude,
      'adresse': adresse,
    };
  }

  factory GareModel.fromMap(Map<String, dynamic> map) {
    return GareModel(
      idGare: map['id_gare'],
      nomGare: map['nom_gare'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      adresse: map['adresse'],
    );
  }
}