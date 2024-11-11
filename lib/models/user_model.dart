class UserModel {
  final String idUser;
  final String prenom;
  final String nom;
  final String? photoProfil;
  final String telephone;
  final String idRole;
  String? role;

  UserModel({
    required this.idUser,
    required this.prenom,
    required this.nom,
    this.photoProfil,
    required this.telephone,
    required this.idRole,
    this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'prenom': prenom,
      'nom': nom,
      'photo_profil': photoProfil,
      'telephone': telephone,
      'id_role': idRole,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'],
      prenom: map['prenom'],
      nom: map['nom'],
      photoProfil: map['photo_profil'],
      telephone: map['telephone'],
      idRole: map['id_role'],
    );
  }
}
