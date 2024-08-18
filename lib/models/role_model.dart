class RoleModel {
  final String idRole;
  final String nom;

  RoleModel({
    required this.idRole,
    required this.nom,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_role': idRole,
      'nom': nom,
    };
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      idRole: map['id_role'],
      nom: map['nom'],
    );
  }
}
