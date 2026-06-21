import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ranking_qualificazione_model.dart';

class RankingQualificazioneService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // GET RANKINGS — ordinati per punteggio totale decrescente
  // =========================================================

  Future<List<RankingQualificazioneModel>> getRankings(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_registration_rankings_qualificazione')
        .select()
        .eq('competition_id', competitionId)
        .order('punteggio_totale', ascending: false);

    return data
        .map<RankingQualificazioneModel>(
          (e) => RankingQualificazioneModel.fromJson(e),
        )
        .toList();
  }
}
