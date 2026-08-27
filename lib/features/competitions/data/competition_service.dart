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
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Utente non autenticato',
      );
    }

    // ===============================================
    // PROFILE
    // ===============================================

    final profile = await supabase
        .from('profiles')
        .select('id')
        .eq('auth_user_id', user.id)
        .single();

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
    await supabase
        .from('competitions')
        .update({
      'descrizione': descrizione,

      'dt_gara':
          dtGara.toIso8601String(),

      'nr_boulder': nrBoulder,

      'quota_iscrizione':
          quotaIscrizione,

      'nr_finalisti': nrFinalisti,

      'note': note,

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

      'updated_at':
          DateTime.now()
              .toIso8601String(),

      'nr_max_registrations':
        nrMaxRegistrations,

      'is_turn':
        isTurn,

      'nr_max_first_turn':
        nrMaxFirstTurn,

      'nr_max_second_turn':
        nrMaxSecondTurn,

    })
        .eq('id', id);
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