import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/statistic_competition_registration_model.dart';

class StatisticCompetitionRegistrationService {
  final supabase = Supabase.instance.client;

  Future<StatisticCompetitionRegistrationModel?>
      getCompetitionStatistics(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_competition_registration_statistics')
        .select()
        .eq('competition_id', competitionId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return StatisticCompetitionRegistrationModel.fromJson(data);
  }
}