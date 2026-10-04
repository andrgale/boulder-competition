import '../../liberatoria/models/liberatoria_mode.dart';
class CompetitionModel {
  final String id;

  final String descrizione;

  final DateTime dtGara;

  final int nrBoulder;

  final double quotaIscrizione;

  final int nrFinalisti;

  final bool flIscrizioniChiuse;

  final bool flGaraChiusa;

  final bool flGestionePresenze;

  final bool flGestionePagamenti;

  final bool flGestioneOmaggi;

  final String? note;

  final String createdBy;

  final DateTime createdAt;

  final DateTime updatedAt;

  final int nrMaxRegistrations;

  final bool isTurn;

  final int nrMaxFirstTurn;

  final int nrMaxSecondTurn;

  final LiberatoriaMode modalitaLiberatoria;

  CompetitionModel({
    required this.id,
    required this.descrizione,
    required this.dtGara,
    required this.nrBoulder,
    required this.quotaIscrizione,
    required this.nrFinalisti,
    required this.flIscrizioniChiuse,
    required this.flGaraChiusa,
    required this.flGestionePresenze,
    required this.flGestionePagamenti,
    required this.flGestioneOmaggi,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.nrMaxRegistrations,
    required this.isTurn,
    required this.nrMaxFirstTurn,
    required this.nrMaxSecondTurn,
    this.note,
    this.modalitaLiberatoria = LiberatoriaMode.nessuna,
  });

  factory CompetitionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompetitionModel.fromMap(json);
  }

  factory CompetitionModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CompetitionModel(
      id: map['id'],

      descrizione: map['descrizione'],

      dtGara: DateTime.parse(
        map['dt_gara'],
      ),

      nrBoulder:
          map['nr_boulder'] ?? 0,

      quotaIscrizione:
          double.tryParse(
                map['quota_iscrizione']
                    .toString(),
              ) ??
              0,

      nrFinalisti:
          map['nr_finalisti'] ?? 0,

      flIscrizioniChiuse:
          map['fl_iscrizioni_chiuse'] ??
              false,

      flGaraChiusa:
          map['fl_gara_chiusa'] ??
              false,

      flGestionePresenze:
          map['fl_gestione_presenze'] ??
              false,

      flGestionePagamenti:
          map['fl_gestione_pagamenti'] ??
              false,

      flGestioneOmaggi:
          map['fl_gestione_omaggi'] ??
              false,

      note: map['note'],

      modalitaLiberatoria: LiberatoriaMode.fromDb(
        map['modalita_liberatoria'] as String?,
      ),

      createdBy: map['created_by'],

      createdAt: DateTime.parse(
        map['created_at'],
      ),

      updatedAt: DateTime.parse(
        map['updated_at'],
      ),

      nrMaxRegistrations:
          map['nr_max_registrations'] ?? 0,

      isTurn:
          map['is_turn'] ??
              false,

      nrMaxFirstTurn:
          map['nr_max_first_turn'] ?? 0,

      nrMaxSecondTurn:
          map['nr_max_second_turn'] ?? 0,
    );
  }

  // ... resto invariato
}