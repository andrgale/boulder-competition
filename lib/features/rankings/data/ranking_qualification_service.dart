import 'package:boulder_competition/features/rankings/models/ranking_category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ranking_qualification_model.dart';

class RankingQualificazioneService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // GET RANKINGS — ordinati per punteggio totale decrescente
  // =========================================================

  Future<List<RankingQualificationModel>> getRankings(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_registration_rankings_qualificazione')
        .select()
        .eq('competition_id', competitionId)
        .order('punteggio_totale', ascending: false);

    return data
        .map<RankingQualificationModel>(
          (e) => RankingQualificationModel.fromJson(e),
        )
        .toList();
  }

  // ── NUOVO ────────────────────────────────────────────────
  Future<List<RankingCategoryModel>> getCategoryRankings(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_category_rankings_qualificazione')
        .select()
        .eq('competition_id', competitionId)
        .order('categoria_eta_min', ascending: true, nullsFirst: false)
        .order('categoria_nome', ascending: true)
        .order('posizione', ascending: true);

    return data
        .map<RankingCategoryModel>(
          (e) => RankingCategoryModel.fromJson(e),
        )
        .toList();
  }
}
