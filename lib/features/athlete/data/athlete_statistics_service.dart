import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/athlete_competition_model.dart';
import '../models/athlete_statistics_item_model.dart';

class AthleteStatisticsService {
  final supabase = Supabase.instance.client;

  // =====================================================
  // PROFILO ATLETA
  // =====================================================

  Future<String?> _getProfileId() async {
    final authUser = supabase.auth.currentUser;

    if (authUser == null) {
      return null;
    }

    final profile = await supabase
        .from('profiles')
        .select('id')
        .eq('auth_user_id', authUser.id)
        .maybeSingle();

    if (profile == null) {
      return null;
    }

    return profile['id'] as String;
  }

  // =====================================================
  // GARE A CUI L'ATLETA HA PARTECIPATO
  // =====================================================

  Future<List<AthleteStatisticsItemModel>> loadStatistics() async {
    final profileId = await _getProfileId();

    if (profileId == null) {
      return [];
    }

    // Nota: qui NON filtriamo su fl_gara_chiusa, a differenza
    // di getOpenCompetition() nell'AthleteBoulderService.
    final registrations = await supabase
        .from('registrations')
        .select('id, competition_id')
        .eq('profile_id', profileId)
        .eq('fl_presente', true);

    if (registrations.isEmpty) {
      return [];
    }

    final List<AthleteStatisticsItemModel> items = [];

    for (final registration in registrations) {
      final competitionId = registration['competition_id'] as String;
      final registrationId = registration['id'] as String;

      final competitionResponse = await supabase
          .from('competitions')
          .select()
          .eq('id', competitionId)
          .maybeSingle();

      if (competitionResponse == null) continue;

      final competition =
          AthleteCompetitionModel.fromMap(competitionResponse);

      // ===================================================
      // BOULDER TOTALI DELLA GARA (NON FINALE)
      // ===================================================
      final boulders = await supabase
          .from('boulders')
          .select('id')
          .eq('competition_id', competitionId)
          .eq('is_finale', false);

      // ===================================================
      // ASCENTS DELL'ATLETA (TOP) PER QUESTA REGISTRAZIONE
      // ===================================================
      final ascents = await supabase
          .from('ascents')
          .select('boulder_id')
          .eq('registration_id', registrationId)
          .eq('top', true);

      items.add(
        AthleteStatisticsItemModel(
          competition: competition,
          registrationId: registrationId,
          completedBoulders: ascents.length,
          totalBoulders: boulders.length,
        ),
      );    }

    items.sort(
      (a, b) => b.competition.dataGara.compareTo(a.competition.dataGara),
    );

    return items;
  }
}