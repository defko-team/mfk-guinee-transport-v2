class Driver {
  final String id;
  final String prenom;
  final String nom;
  final String telephone;
  final String? photoUrl;
  final DateTime createdAt;

  Driver({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
    this.photoUrl,
    required this.createdAt,
  });

  String get fullName => '$prenom $nom'.trim();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'telephone': telephone,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] ?? '',
      prenom: map['prenom'] ?? '',
      nom: map['nom'] ?? '',
      telephone: map['telephone'] ?? '',
      photoUrl: map['photo_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
