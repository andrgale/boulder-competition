import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/statistic_competition_boulder_detail_model.dart';

class StatisticCompetitionBoulderDetailService {
  final supabase = Supabase.instance.client;

  Future<List<StatisticCompetitionBoulderDetailModel>>
      getStatistics(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_competition_boulder_details')
        .select()
        .eq('competition_id', competitionId)
        .order('numero');

    return data
        .map<StatisticCompetitionBoulderDetailModel>(
          (e) =>
              StatisticCompetitionBoulderDetailModel.fromJson(e),
        )
        .toList();
  }
}