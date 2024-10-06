class VoitureModel {
  final String idVoiture;
  final String? photo;
  final String marque;
  final int nombreDePlace;
  final String idChauffeur;

  VoitureModel({
    required this.idVoiture,
    this.photo,
    required this.marque,
    required this.nombreDePlace,
    required this.idChauffeur,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_voiture': idVoiture,
      'photo': photo,
      'marque': marque,
      'nombre_de_place': nombreDePlace,
      'id_chauffeur': idChauffeur,
    };
  }

  factory VoitureModel.fromMap(Map<String, dynamic> map) {
    return VoitureModel(
      idVoiture: map['id_voiture'],
      photo: map['photo'],
      marque: map['marque'],
      nombreDePlace: map['nombre_de_place'],
      idChauffeur: map['id_chauffeur'],
    );
  }
}
