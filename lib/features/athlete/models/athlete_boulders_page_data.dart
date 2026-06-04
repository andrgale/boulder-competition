import 'athlete_boulder_model.dart';
import 'athlete_competition_model.dart';

class AthleteBouldersPageData {
  final AthleteCompetitionModel?
      competition;

  final String? registrationId;

  final List<AthleteBoulderModel>
      boulders;

  final int completedBoulders;

  const AthleteBouldersPageData({
    required this.competition,
    required this.registrationId,
    required this.boulders,
    required this.completedBoulders,
  });
}