class RegistrationModel {
  final String id;
  final String competitionId;

  final String? profileId;
  final String? categoryId;

  final int? pettorale;

  final String cognome;
  final String nome;
  final String email;

  final String? societa;

  final DateTime? dataNascita;

  final String? sesso;

  final bool flPresente;
  final bool flPagato;
  final bool flOmaggio;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isFirstTurn;
  final bool isSecondTurn;
  final String ownerRegistration;

  RegistrationModel({
    required this.id,
    required this.competitionId,
    this.profileId,
    this.categoryId,
    this.pettorale,
    required this.cognome,
    required this.nome,
    required this.email,
    this.societa,
    this.dataNascita,
    this.sesso,
    required this.flPresente,
    required this.flPagato,
    required this.flOmaggio,
    this.isFirstTurn = false,
    this.isSecondTurn = false,
    this.ownerRegistration = 'admin', 
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegistrationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RegistrationModel(
      id: json['id'] as String,

      competitionId:
          json['competition_id'] as String,

      profileId:
          json['profile_id'] as String?,

      categoryId:
          json['category_id'] as String?,

      pettorale:
          json['pettorale'] != null
              ? json['pettorale'] as int
              : null,

      cognome:
          json['cognome'] as String,

      nome:
          json['nome'] as String,

      email:
          json['email'] as String,

      societa:
          json['societa'] as String?,

      dataNascita:
          json['data_nascita'] != null
              ? DateTime.parse(
                  json['data_nascita'],
                )
              : null,

      sesso:
          json['sesso'] as String?,

      flPresente:
          json['fl_presente'] as bool? ??
          false,

      flPagato:
          json['fl_pagato'] as bool? ??
          false,

      flOmaggio:
          json['fl_omaggio'] as bool? ??
          false,

      isFirstTurn:
          json['is_first_turn'] as bool? ?? false,

      isSecondTurn:
          json['is_second_turn'] as bool? ?? false,

      ownerRegistration:
          json['owner_registration'] as String? ??
          'admin',

      createdAt: DateTime.parse(
        json['created_at'],
      ),

      updatedAt: DateTime.parse(
        json['updated_at'],
      ),
    );
  }

  Map<String, dynamic> toInsert() {
    return {
      'competition_id': competitionId,
      'profile_id': profileId,
      'category_id': categoryId,
      'pettorale': pettorale,
      'cognome': cognome,
      'nome': nome,
      'email': email,
      'societa': societa,
      'data_nascita': dataNascita
          ?.toIso8601String()
          .split('T')
          .first,
      'sesso': sesso,
      'fl_presente': flPresente,
      'fl_pagato': flPagato,
      'fl_omaggio': flOmaggio,
      'is_first_turn': isFirstTurn,
      'is_second_turn': isSecondTurn,
      'owner_registration': ownerRegistration,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'profile_id': profileId,
      'category_id': categoryId,
      'pettorale': pettorale,
      'cognome': cognome,
      'nome': nome,
      'email': email,
      'societa': societa,
      'data_nascita': dataNascita
          ?.toIso8601String()
          .split('T')
          .first,
      'sesso': sesso,
      'fl_presente': flPresente,
      'fl_pagato': flPagato,
      'fl_omaggio': flOmaggio,
      'is_first_turn': isFirstTurn,
      'is_second_turn': isSecondTurn,
      'owner_registration': ownerRegistration,
      'updated_at':
          DateTime.now().toIso8601String(),
    };
  }
}