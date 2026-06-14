class CheckinRegistrationModel {
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

  CheckinRegistrationModel({
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

  String get fullName => '$cognome $nome';

  factory CheckinRegistrationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CheckinRegistrationModel(
      id: json['id'] as String,
      competitionId: json['competition_id'] as String,
      profileId: json['profile_id'] as String?,
      categoryId: json['category_id'] as String?,
      pettorale: json['pettorale'] as int?,
      cognome: json['cognome'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      societa: json['societa'] as String?,
      dataNascita: json['data_nascita'] != null
          ? DateTime.parse(json['data_nascita'] as String)
          : null,
      sesso: json['sesso'] as String?,
      flPresente: json['fl_presente'] as bool? ?? false,
      flPagato: json['fl_pagato'] as bool? ?? false,
      flOmaggio: json['fl_omaggio'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Copia con uno o più flag aggiornati — usata per
  /// l'aggiornamento ottimistico nella UI
  CheckinRegistrationModel copyWith({
    bool? flPresente,
    bool? flPagato,
    bool? flOmaggio,
  }) {
    return CheckinRegistrationModel(
      id: id,
      competitionId: competitionId,
      profileId: profileId,
      categoryId: categoryId,
      pettorale: pettorale,
      cognome: cognome,
      nome: nome,
      email: email,
      societa: societa,
      dataNascita: dataNascita,
      sesso: sesso,
      flPresente: flPresente ?? this.flPresente,
      flPagato: flPagato ?? this.flPagato,
      flOmaggio: flOmaggio ?? this.flOmaggio,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
