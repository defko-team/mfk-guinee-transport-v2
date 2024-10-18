class VoitureModel {
  final String idVoiture;
  final String? photo; // Nullable, car une voiture peut ne pas avoir de photo
  final String marque;
  final int nombreDePlace;
  final String idChauffeur;

  VoitureModel({
    required this.idVoiture,
    this.photo, // photo est nullable
    required this.marque,
    required this.nombreDePlace,
    required this.idChauffeur,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_voiture': idVoiture,
      'photo': photo ?? '', // Si photo est null, on retourne une chaîne vide
      'marque': marque,
      'nombre_de_place': nombreDePlace,
      'id_chauffeur': idChauffeur,
    };
  }

  factory VoitureModel.fromMap(Map<String, dynamic> map) {
    return VoitureModel(
      idVoiture:
          map['id_voiture'] ?? '', // Sécurisation au cas où la clé est absente
      photo: map['photo'] ??
          '', // Si photo est null dans la map, on retourne une chaîne vide
      marque:
          map['marque'] ?? '', // On s'assure que marque est toujours une chaîne
      nombreDePlace: map['nombre_de_place'] ?? 0, // Par défaut 0 si absent
      idChauffeur:
          map['id_chauffeur'] ?? '', // Par défaut chaîne vide si absent
    );
  }
}
