class ReservationModel {
  final String idReservation;
  final String idUser;
  final String idChauffeur;
  final String idTrajet;
  final String? idCourse;
  final String idVoiture;
  final DateTime dateCreation;
  final DateTime? dateDerniereModification;
  final String typeReservation; // Peut-être remplacé par un Enum selon le contexte
  final String statutReservation; // Peut-être remplacé par un Enum selon le contexte

  ReservationModel({
    required this.idReservation,
    required this.idUser,
    required this.idChauffeur,
    required this.idTrajet,
    this.idCourse,
    required this.idVoiture,
    required this.dateCreation,
    this.dateDerniereModification,
    required this.typeReservation,
    required this.statutReservation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_reservation': idReservation,
      'id_user': idUser,
      'id_chauffeur': idChauffeur,
      'id_trajet': idTrajet,
      'id_course': idCourse,
      'id_voiture': idVoiture,
      'date_creation': dateCreation.toIso8601String(),
      'date_derniere_modification': dateDerniereModification?.toIso8601String(),
      'type_reservation': typeReservation,
      'statut_reservation': statutReservation,
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      idReservation: map['id_reservation'],
      idUser: map['id_user'],
      idChauffeur: map['id_chauffeur'],
      idTrajet: map['id_trajet'],
      idCourse: map['id_course'],
      idVoiture: map['id_voiture'],
      dateCreation: DateTime.parse(map['date_creation']),
      dateDerniereModification: map['date_derniere_modification'] != null
          ? DateTime.parse(map['date_derniere_modification'])
          : null,
      typeReservation: map['type_reservation'],
      statutReservation: map['statut_reservation'],
    );
  }
}