import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/checkin_competition_model.dart';
import 'package:flutter/material.dart';

class CheckinCompetitionService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // REALTIME STREAM
  // =========================================================

  Stream<List<CheckinCompetitionModel>> watchCompetitions() {
    return supabase
        .from('competitions')
        .stream(primaryKey: ['id'])
        .order('dt_gara')
        .handleError((error) {
          debugPrint(
            'Checkin realtime stream error (ignorato): $error',
          );
        })
        .map(
          (rows) => rows
              .map((row) => CheckinCompetitionModel.fromMap(row))
              .toList(),
        );
  }

  // =========================================================
  // GET ALL
  // =========================================================

  Future<List<CheckinCompetitionModel>> getCompetitions() async {
    final response = await supabase
        .from('competitions')
        .select()
        .order('dt_gara');

    return response
        .map<CheckinCompetitionModel>(
          (row) => CheckinCompetitionModel.fromMap(row),
        )
        .toList();
  }

  // =========================================================
  // TOGGLE FL_GESTIONE_PRESENZE
  // =========================================================

  Future<void> toggleGestionePresenze({
    required String id,
    required bool currentValue,
  }) async {
    await supabase.from('competitions').update({
      'fl_gestione_presenze': !currentValue,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // =========================================================
  // TOGGLE FL_GESTIONE_PAGAMENTI
  // =========================================================

  Future<void> toggleGestionePagamenti({
    required String id,
    required bool currentValue,
  }) async {
    await supabase.from('competitions').update({
      'fl_gestione_pagamenti': !currentValue,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // =========================================================
  // TOGGLE FL_GESTIONE_OMAGGI
  // =========================================================

  Future<void> toggleGestioneOmaggi({
    required String id,
    required bool currentValue,
  }) async {
    await supabase.from('competitions').update({
      'fl_gestione_omaggi': !currentValue,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
  // =========================================================
  // TOGGLE FL_GARA_CHIUSA
  // =========================================================

  Future<void> toggleGaraChiusa({
    required String id,
    required bool currentValue,
  }) async {
    await supabase.from('competitions').update({
      'fl_gara_chiusa': !currentValue,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}
