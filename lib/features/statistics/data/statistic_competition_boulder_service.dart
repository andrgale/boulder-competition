import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/statistic_competition_boulder_model.dart';

class StatisticCompetitionBoulderService {
  final supabase = Supabase.instance.client;

  Future<StatisticCompetitionBoulderModel?> getStatistics(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_competition_boulder_statistics')
        .select()
        .eq('competition_id', competitionId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return StatisticCompetitionBoulderModel.fromJson(data);
  }
}