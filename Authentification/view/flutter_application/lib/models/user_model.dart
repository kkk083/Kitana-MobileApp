class User {
  final int? idUser;
  final String nom;
  final String email;
  final String role;
  final String? token;
  final String? dateCreation;

  User({
    this.idUser,
    required this.nom,
    required this.email,
    required this.role,
    this.token,
    this.dateCreation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_user'],
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'etudiant',
      token: json['token'],
      dateCreation: json['date_creation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nom': nom,
      'email': email,
      'role': role,
      'token': token,
      'date_creation': dateCreation,
    };
  }
}
