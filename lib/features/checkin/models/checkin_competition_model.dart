class CheckinCompetitionModel {
  final String id;
  final String descrizione;
  final DateTime dtGara;
  final int nrBoulder;
  final double quotaIscrizione; // ← aggiunto
  final int nrFinalisti;
  final bool flIscrizioniChiuse;
  final bool flGaraChiusa;
  final bool flGestionePresenze;
  final bool flGestionePagamenti;
  final bool flGestioneOmaggi;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  CheckinCompetitionModel({
    required this.id,
    required this.descrizione,
    required this.dtGara,
    required this.nrBoulder,
    required this.quotaIscrizione, // ← aggiunto
    required this.nrFinalisti,
    required this.flIscrizioniChiuse,
    required this.flGaraChiusa,
    required this.flGestionePresenze,
    required this.flGestionePagamenti,
    required this.flGestioneOmaggi,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CheckinCompetitionModel.fromMap(Map<String, dynamic> map) {
    return CheckinCompetitionModel(
      id: map['id'] as String,
      descrizione: map['descrizione'] as String,
      dtGara: DateTime.parse(map['dt_gara'] as String),
      nrBoulder: map['nr_boulder'] as int? ?? 0,
      // ← aggiunto: gestisce sia int che double restituiti da Supabase
      quotaIscrizione: (map['quota_iscrizione'] as num?)?.toDouble() ?? 0.0,
      nrFinalisti: map['nr_finalisti'] as int? ?? 0,
      flIscrizioniChiuse: map['fl_iscrizioni_chiuse'] as bool? ?? false,
      flGaraChiusa: map['fl_gara_chiusa'] as bool? ?? false,
      flGestionePresenze: map['fl_gestione_presenze'] as bool? ?? false,
      flGestionePagamenti: map['fl_gestione_pagamenti'] as bool? ?? false,
      flGestioneOmaggi: map['fl_gestione_omaggi'] as bool? ?? false,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  CheckinCompetitionModel copyWith({
    bool? flGestionePresenze,
    bool? flGestionePagamenti,
    bool? flGestioneOmaggi,
  }) {
    return CheckinCompetitionModel(
      id: id,
      descrizione: descrizione,
      dtGara: dtGara,
      nrBoulder: nrBoulder,
      quotaIscrizione: quotaIscrizione, // ← propagato
      nrFinalisti: nrFinalisti,
      flIscrizioniChiuse: flIscrizioniChiuse,
      flGaraChiusa: flGaraChiusa,
      flGestionePresenze: flGestionePresenze ?? this.flGestionePresenze,
      flGestionePagamenti: flGestionePagamenti ?? this.flGestionePagamenti,
      flGestioneOmaggi: flGestioneOmaggi ?? this.flGestioneOmaggi,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}