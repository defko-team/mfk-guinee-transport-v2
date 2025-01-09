class UserModel {
  final String idUser;
  final String prenom;
  final String nom;
  final String? photoProfil;
  final String telephone;
  final String idRole;
  String? fcmToken;

  UserModel(
      {required this.idUser,
      required this.prenom,
      required this.nom,
      this.photoProfil,
      required this.telephone,
      required this.idRole,
      this.fcmToken});
  String? role;

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'prenom': prenom,
      'nom': nom,
      'photo_profil': photoProfil,
      'telephone': telephone,
      'id_role': idRole,
      'fcm_token': fcmToken
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
        fcmToken: map['fcm_token'] ?? '');
  }

  @override
  String toString() {
    return 'UserModel{idUser: $idUser, prenom: $prenom, nom: $nom, photoProfil: $photoProfil, telephone: $telephone, idRole: $idRole, fcmToken: $fcmToken}';
  }
}
