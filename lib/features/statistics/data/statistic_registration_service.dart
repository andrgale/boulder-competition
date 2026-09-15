import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/statistic_registration_model.dart';

class StatisticRegistrationService {
  final supabase = Supabase.instance.client;

  Future<StatisticRegistrationModel?> getStatistics(
    String competitionId,
    String registrationId,
  ) async {
    final data = await supabase
        .from('v_registration_statistics')
        .select()
        .eq('competition_id', competitionId)
        .eq('registration_id', registrationId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return StatisticRegistrationModel.fromJson(data);
  }
}