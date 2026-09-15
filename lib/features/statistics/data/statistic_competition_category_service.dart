import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/statistic_competition_category_model.dart';

class StatisticCompetitionCategoryService {
  final supabase = Supabase.instance.client;

  Future<List<StatisticCompetitionCategoryModel>>
      getStatistics(
    String competitionId,
  ) async {
    final data = await supabase
        .from('v_competition_category_statistics')
        .select()
        .eq('competition_id', competitionId)
        .order('nome');

    return data
        .map<StatisticCompetitionCategoryModel>(
          (e) =>
              StatisticCompetitionCategoryModel.fromJson(e),
        )
        .toList();
  }
}