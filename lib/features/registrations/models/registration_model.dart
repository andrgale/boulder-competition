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
      'updated_at':
          DateTime.now().toIso8601String(),
    };
  }
}