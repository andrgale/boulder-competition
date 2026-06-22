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
}
