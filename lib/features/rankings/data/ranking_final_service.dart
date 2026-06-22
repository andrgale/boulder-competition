import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ranking_final_model.dart';

class RankingFinalService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // GET RANKINGS — ordinati secondo la regola classifica finale:
  // nr_top desc, nr_zone desc, tentativi_top asc, tentativi_zone asc,
  // cognome, nome
  // =========================================================

  Future<List<RankingFinalModel>> getRankings(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_registration_rankings_finale')
        .select()
        .eq('competition_id', competitionId)
        .order('nr_top', ascending: false)
        .order('nr_zone', ascending: false)
        .order('tentativi_top', ascending: true)
        .order('tentativi_zone', ascending: true)
        .order('cognome', ascending: true)
        .order('nome', ascending: true);

    return data
        .map<RankingFinalModel>(
          (e) => RankingFinalModel.fromJson(e),
        )
        .toList();
  }
}
