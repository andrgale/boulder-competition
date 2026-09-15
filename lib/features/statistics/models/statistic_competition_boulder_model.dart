class StatisticCompetitionBoulderModel {
  final String competitionId;
  final int nrBoulder;
  final int nrBoulderFinale;

  StatisticCompetitionBoulderModel({
    required this.competitionId,
    required this.nrBoulder,
    required this.nrBoulderFinale,
  });

  factory StatisticCompetitionBoulderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatisticCompetitionBoulderModel(
      competitionId: json['competition_id'] as String,
      nrBoulder: (json['nr_boulder'] as num?)?.toInt() ?? 0,
      nrBoulderFinale:
          (json['nr_boulder_finale'] as num?)?.toInt() ?? 0,
    );
  }
}