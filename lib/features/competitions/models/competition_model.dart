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
  });

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

  Map<String, dynamic> toInsertMap({
    required String profileId,
  }) {
    return {
      'descrizione': descrizione,

      'dt_gara':
          dtGara.toIso8601String(),

      'nr_boulder': nrBoulder,

      'quota_iscrizione':
          quotaIscrizione,

      'nr_finalisti': nrFinalisti,

      'fl_iscrizioni_chiuse':
          flIscrizioniChiuse,

      'fl_gara_chiusa':
          flGaraChiusa,

      'fl_gestione_presenze':
          flGestionePresenze,

      'fl_gestione_pagamenti':
          flGestionePagamenti,

      'fl_gestione_omaggi':
          flGestioneOmaggi,

      'note': note,

      'created_by': profileId,

      'nr_max_registrations': nrMaxRegistrations,

      'is_turn':
          isTurn,

      'nr_max_first_turn': nrMaxFirstTurn,

      'nr_max_second_turn': nrMaxSecondTurn,      
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'descrizione': descrizione,

      'dt_gara':
          dtGara.toIso8601String(),

      'nr_boulder': nrBoulder,

      'quota_iscrizione':
          quotaIscrizione,

      'nr_finalisti': nrFinalisti,

      'fl_iscrizioni_chiuse':
          flIscrizioniChiuse,

      'fl_gara_chiusa':
          flGaraChiusa,

      'fl_gestione_presenze':
          flGestionePresenze,

      'fl_gestione_pagamenti':
          flGestionePagamenti,

      'fl_gestione_omaggi':
          flGestioneOmaggi,

      'note': note,

      'updated_at':
          DateTime.now().toIso8601String(),

      'nr_max_registrations': nrMaxRegistrations,

      'is_turn':
          isTurn,

      'nr_max_first_turn': nrMaxFirstTurn,

      'nr_max_second_turn': nrMaxSecondTurn,      

    };
  }
}