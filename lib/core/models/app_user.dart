class AppUser {
  final String id;
  final String email;
  final String nome;
  final String cognome;

  AppUser({
    required this.id,
    required this.email,
    required this.nome,
    required this.cognome,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      nome: map['nome'] ?? '',
      cognome: map['cognome'] ?? '',
    );
  }
}