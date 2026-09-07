import 'package:boulder_competition/features/rankings/models/ranking_category_top_zone_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ranking_top_zone_model.dart';

class RankingTopZoneService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // GET RANKINGS — ordinati secondo la regola classifica top/zone:
  // nr_top desc, nr_zone desc, punteggio_totale desc, cognome, nome
  // =========================================================

  Future<List<RankingTopZoneModel>> getRankings(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_registration_top_zone')
        .select()
        .eq('competition_id', competitionId)
        .order('nr_top', ascending: false)
        .order('nr_zone', ascending: false)
        .order('punteggio_totale', ascending: false)
        .order('cognome', ascending: true)
        .order('nome', ascending: true);

    return data
        .map<RankingTopZoneModel>(
          (e) => RankingTopZoneModel.fromJson(e),
        )
        .toList();
  }
    // =========================================================
  // GET CATEGORY RANKINGS — ordinati per fascia età, categoria,
  // posizione (già calcolata dalla vista)
  // =========================================================

  Future<List<RankingCategoryTopZoneModel>> getCategoryRankings(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_category_rankings_top_zone')
        .select()
        .eq('competition_id', competitionId)
        .order('categoria_eta_min', ascending: true, nullsFirst: false)
        .order('categoria_nome', ascending: true)
        .order('posizione', ascending: true);

    return data
        .map<RankingCategoryTopZoneModel>(
          (e) => RankingCategoryTopZoneModel.fromJson(e),
        )
        .toList();
  }


}
