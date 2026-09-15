class StatisticCompetitionRegistrationOwnerModel {
  final String competitionId;
  final String ownerRegistration;
  final int nrAtletiIscritti;

  StatisticCompetitionRegistrationOwnerModel({
    required this.competitionId,
    required this.ownerRegistration,
    required this.nrAtletiIscritti,
  });

  factory StatisticCompetitionRegistrationOwnerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatisticCompetitionRegistrationOwnerModel(
      competitionId: json['competition_id'] as String,
      ownerRegistration: json['owner_registration'] as String,
      nrAtletiIscritti:
          (json['nr_atleti_iscritti'] as num?)?.toInt() ?? 0,
    );
  }
}