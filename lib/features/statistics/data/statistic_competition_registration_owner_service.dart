import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/statistic_competition_registration_owner_model.dart';

class StatisticCompetitionRegistrationOwnerService {
  final supabase = Supabase.instance.client;

  Future<List<StatisticCompetitionRegistrationOwnerModel>>
      getStatistics(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_competition_registration_owner_statistics')
        .select()
        .eq('competition_id', competitionId)
        .order('owner_registration');

    return data
        .map<StatisticCompetitionRegistrationOwnerModel>(
          (e) =>
              StatisticCompetitionRegistrationOwnerModel.fromJson(e),
        )
        .toList();
  }
}