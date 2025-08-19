class CommentaireModel {
  final String idUser;
  final String idReservation;
  final String objet;
  final String commentaire;
  final double note;

  CommentaireModel({
    required this.idUser,
    required this.idReservation,
    required this.objet,
    required this.commentaire,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'id_reservation': idReservation,
      'objet': objet,
      'commentaire': commentaire,
      'note': note,
    };
  }

  factory CommentaireModel.fromMap(Map<String, dynamic> map) {
    return CommentaireModel(
      idUser: map['id_user'],
      idReservation: map['id_reservation'],
      objet: map['objet'],
      commentaire: map['commentaire'],
      note: map['note'],
    );
  }
}
