class TrajetModel {
  final String idTrajet;
  final String idGareDepart;
  final String idGareArrivee;
  final String lieuDepart;
  final String lieuArrivee;
  final DateTime dateHeureDepart;
  final DateTime dateHeureArrivee;
  final int placesRestantes;
  final double prix;

  TrajetModel({
    required this.idTrajet,
    required this.idGareDepart,
    required this.idGareArrivee,
    required this.lieuDepart,
    required this.lieuArrivee,
    required this.dateHeureDepart,
    required this.dateHeureArrivee,
    required this.placesRestantes,
    required this.prix,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_trajet': idTrajet,
      'id_gare_depart': idGareDepart,
      'id_gare_arrivee': idGareArrivee,
      'lieu_depart': lieuDepart,
      'lieu_arrivee': lieuArrivee,
      'date_heure_depart': dateHeureDepart.toIso8601String(),
      'date_heure_arrivee': dateHeureArrivee.toIso8601String(),
      'places_restantes': placesRestantes,
      'prix': prix,
    };
  }

  factory TrajetModel.fromMap(Map<String, dynamic> map) {
    return TrajetModel(
      idTrajet: map['id_trajet'],
      idGareDepart: map['id_gare_depart'],
      idGareArrivee: map['id_gare_arrivee'],
      lieuDepart: map['lieu_depart'],
      lieuArrivee: map['lieu_arrivee'],
      dateHeureDepart: DateTime.parse(map['date_heure_depart']),
      dateHeureArrivee: DateTime.parse(map['date_heure_arrivee']),
      placesRestantes: map['places_restantes'],
      prix: map['prix'],
    );
  }
}
