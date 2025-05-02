// Define an enum for the allowed roles
enum UserRole {
  Chauffeur,
  Client,
  Admin,
}

class UserModel {
  final String idUser;
  final String prenom;
  final String nom;
  final String? photoProfil;
  final String telephone;
  final UserRole role;  // Changed from String to UserRole
  String? fcmToken;

  UserModel({
    required this.idUser,
    required this.prenom,
    required this.nom,
    this.photoProfil,
    required this.telephone,
    required this.role,
    this.fcmToken
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'prenom': prenom,
      'nom': nom,
      'photo_profil': photoProfil,
      'telephone': telephone,
      'role': role.name,  // Convert enum to string
      'fcm_token': fcmToken
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Convert string to enum
    String roleStr = map['role'] ?? 'Client';
    UserRole userRole;
    
    try {
      userRole = UserRole.values.firstWhere(
        (e) => e.name == roleStr,
        orElse: () => UserRole.Client
      );
    } catch (_) {
      userRole = UserRole.Client;  // Default to Client if conversion fails
    }
    
    return UserModel(
      idUser: map['id_user'],
      prenom: map['prenom'],
      nom: map['nom'],
      photoProfil: map['photo_profil'],
      telephone: map['telephone'],
      role: userRole,
      fcmToken: map['fcm_token'] ?? ''
    );
  }

  @override
  String toString() {
    return 'UserModel{idUser: $idUser, prenom: $prenom, nom: $nom, photoProfil: $photoProfil, telephone: $telephone, role: ${role.name}, fcmToken: $fcmToken}';
  }
}
