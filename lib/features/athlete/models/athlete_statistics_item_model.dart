import 'athlete_competition_model.dart';

class AthleteStatisticsItemModel {
  final AthleteCompetitionModel competition;
  final String registrationId;
  final int completedBoulders;
  final int totalBoulders;

  AthleteStatisticsItemModel({
    required this.competition,
    required this.registrationId,
    required this.completedBoulders,
    required this.totalBoulders,
  });
}