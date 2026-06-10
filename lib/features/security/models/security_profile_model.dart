// Profilo arricchito con i ruoli assegnati — usato nella schermata utenti
class SecurityProfileModel {
  final String id;
  final String authUserId;
  final String email;
  final String nome;
  final String cognome;
  final bool passwordChanged;
  final DateTime createdAt;
  final List<String> roleIds; // popolato in-memory

  SecurityProfileModel({
    required this.id,
    required this.authUserId,
    required this.email,
    required this.nome,
    required this.cognome,
    required this.passwordChanged,
    required this.createdAt,
    this.roleIds = const [],
  });

  String get fullName => '$cognome $nome';

  factory SecurityProfileModel.fromMap(Map<String, dynamic> map) {
    return SecurityProfileModel(
      id: map['id'] as String,
      authUserId: map['auth_user_id'] as String,
      email: map['email'] as String,
      nome: map['nome'] as String,
      cognome: map['cognome'] as String,
      passwordChanged: map['password_changed'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
