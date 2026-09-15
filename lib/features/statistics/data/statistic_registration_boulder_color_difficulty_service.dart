import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/statistic_registration_boulder_color_difficulty_model.dart';

class StatisticRegistrationBoulderColorDifficultyService {
  final supabase = Supabase.instance.client;

  Future<List<StatisticRegistrationBoulderColorDifficultyModel>>
      getStatistics(
    String competitionId,
    String registrationId,
  ) async {
    final data = await supabase
        .from('v_registration_boulder_color_difficulty_statistics')
        .select()
        .eq('competition_id', competitionId)
        .eq('registration_id', registrationId)
        .order('difficolta');

    return data
        .map<StatisticRegistrationBoulderColorDifficultyModel>(
          (e) =>
              StatisticRegistrationBoulderColorDifficultyModel
                  .fromJson(e),
        )
        .toList();
  }
}