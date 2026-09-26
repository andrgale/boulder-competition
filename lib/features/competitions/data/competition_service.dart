import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/competition_model.dart';

class CompetitionService {
  final supabase = Supabase.instance.client;

  // =======================================================
  // REALTIME STREAM
  // =======================================================

  Stream<List<CompetitionModel>>
      watchCompetitions() {
    return supabase
        .from('competitions')
        .stream(
          primaryKey: ['id'],
        )
        .order('dt_gara')
        .handleError((error) {
          // Connessione Realtime persa temporaneamente, verrà riconnessa automaticamente
          debugPrint('Realtime stream error (ignorato): $error');
        })
        .map(
          (rows) => rows
              .map(
                (row) =>
                    CompetitionModel.fromMap(row),
              )
              .toList(),
        );
  }

  // =======================================================
  // GET ALL
  // =======================================================

  Future<List<CompetitionModel>>
      getCompetitions() async {
    final response = await supabase
        .from('competitions')
        .select()
        .order('dt_gara');

    return response
        .map<CompetitionModel>(
          (row) =>
              CompetitionModel.fromMap(row),
        )
        .toList();
  }

  // =======================================================
  // GET BY ID
  // =======================================================

  Future<CompetitionModel?>
      getCompetitionById(
    String id,
  ) async {
    final response = await supabase
        .from('competitions')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return CompetitionModel.fromMap(
      response,
    );
  }

  // =======================================================
  // CREATE
  // =======================================================

  Future<CompetitionModel> createCompetition({
    required String descrizione,
    required DateTime dtGara,
    required int nrBoulder,
    required double quotaIscrizione,
    required int nrFinalisti,
    String? note,
    required int nrMaxRegistrations,
    required bool isTurn,
    required int nrMaxFirstTurn,
    required int nrMaxSecondTurn,
    bool flGaraChiusa = false,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utente non autenticato');
    }

    final profile = await supabase
        .from('profiles')
        .select('id')
        .eq('auth_user_id', user.id)
        .single();

    try {
      final data = await supabase
          .from('competitions')
          .insert({
            'descrizione': descrizione,
            'dt_gara': dtGara.toIso8601String(),
            'nr_boulder': nrBoulder,
            'quota_iscrizione': quotaIscrizione,
            'nr_finalisti': nrFinalisti,
            'note': note,
            'nr_max_registrations': nrMaxRegistrations,
            'is_turn': isTurn,
            'nr_max_first_turn': nrMaxFirstTurn,
            'nr_max_second_turn': nrMaxSecondTurn,
            'created_by': profile['id'],
          })
          .select()
          .single();

      return CompetitionModel.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('OPEN_COMPETITION_CONFLICT');
      }
      rethrow;
    }
  }
  // =======================================================
  // UPDATE
  // =======================================================

  Future<void> updateCompetition({
    required String id,
    required String descrizione,
    required DateTime dtGara,
    required int nrBoulder,
    required double quotaIscrizione,
    required int nrFinalisti,
    String? note,
    required bool flIscrizioniChiuse,
    required bool flGaraChiusa,
    required bool flGestionePresenze,
    required bool flGestionePagamenti,
    required bool flGestioneOmaggi,
    required int nrMaxRegistrations,
    required bool isTurn,
    required int nrMaxFirstTurn,
    required int nrMaxSecondTurn,
  }) async {
    try {
      await supabase.from('competitions').update({
        'descrizione': descrizione,
        'dt_gara': dtGara.toIso8601String(),
        'nr_boulder': nrBoulder,
        'quota_iscrizione': quotaIscrizione,
        'nr_finalisti': nrFinalisti,
        'note': note,
        'fl_iscrizioni_chiuse': flIscrizioniChiuse,
        'fl_gara_chiusa': flGaraChiusa,
        'fl_gestione_presenze': flGestionePresenze,
        'fl_gestione_pagamenti': flGestionePagamenti,
        'fl_gestione_omaggi': flGestioneOmaggi,
        'updated_at': DateTime.now().toIso8601String(),
        'nr_max_registrations': nrMaxRegistrations,
        'is_turn': isTurn,
        'nr_max_first_turn': nrMaxFirstTurn,
        'nr_max_second_turn': nrMaxSecondTurn,
      }).eq('id', id);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('OPEN_COMPETITION_CONFLICT');
      }
      rethrow;
    }
  }

  // =======================================================
  // DELETE
  // =======================================================

  Future<void> deleteCompetition(
    String id,
  ) async {
    await supabase
        .from('competitions')
        .delete()
        .eq('id', id);
  }

  // =======================================================
  // CLOSE
  // =======================================================

  Future<void> closeCompetition(
    String id,
  ) async {
    await supabase
        .from('competitions')
        .update({
      'fl_gara_chiusa': true,
    }).eq('id', id);
  }

  // =======================================================
  // CHECK OPEN COMPETITION
  // =======================================================

  /// Verifica se esiste già una gara aperta (fl_gara_chiusa = false),
  /// escludendo opzionalmente una gara specifica (utile in modifica,
  /// per non confrontare la gara con se stessa).
  Future<bool> hasOpenCompetition({String? excludeId}) async {
    var query = supabase
        .from('competitions')
        .select('id')
        .eq('fl_gara_chiusa', false);

    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }

    final result = await query;
    return (result as List).isNotEmpty;
  }

  // =======================================================
  // REOPEN
  // =======================================================

  Future<void> reopenCompetition(
    String id,
  ) async {
    await supabase
        .from('competitions')
        .update({
      'fl_gara_chiusa': false,
    }).eq('id', id);
  }
}