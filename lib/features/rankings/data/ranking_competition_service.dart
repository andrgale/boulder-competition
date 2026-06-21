import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ranking_competition_model.dart';

class RankingsCompetitionService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // REALTIME STREAM
  // =========================================================

  Stream<List<RankingCompetitionModel>> watchCompetitions() {
    return supabase
        .from('competitions')
        .stream(primaryKey: ['id'])
        .order('dt_gara')
        .handleError((error) {
          debugPrint(
            'Rankings realtime stream error (ignorato): $error',
          );
        })
        .map(
          (rows) => rows
              .map((row) => RankingCompetitionModel.fromMap(row))
              .toList(),
        );
  }

  // =========================================================
  // GET ALL
  // =========================================================

  Future<List<RankingCompetitionModel>> getCompetitions() async {
    final response =
        await supabase.from('competitions').select().order('dt_gara');

    return response
        .map<RankingCompetitionModel>(
          (row) => RankingCompetitionModel.fromMap(row),
        )
        .toList();
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
