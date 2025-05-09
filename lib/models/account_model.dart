class AccountModel {
  final String idAccount;
  final String idUser;
  final String statut;
  final DateTime dateCreation;

  AccountModel({
    required this.idAccount,
    required this.idUser,
    required this.statut,
    required this.dateCreation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_account': idAccount,
      'id_user': idUser,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      idAccount: map['id_account'],
      idUser: map['id_user'],
      statut: map['statut'],
      dateCreation: DateTime.parse(map['date_creation']),
    );
  }
}
