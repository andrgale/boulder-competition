class StatisticRegistrationBoulderColorDifficultyModel {
  final String competitionId;
  final String registrationId;

  final String? colore;
  final int? difficolta;

  final int nrBoulderSaliti;

  StatisticRegistrationBoulderColorDifficultyModel({
    required this.competitionId,
    required this.registrationId,
    this.colore,
    this.difficolta,
    required this.nrBoulderSaliti,
  });

  factory StatisticRegistrationBoulderColorDifficultyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatisticRegistrationBoulderColorDifficultyModel(
      competitionId: json['competition_id'] as String,
      registrationId: json['registration_id'] as String,

      colore: json['colore'] as String?,
      difficolta: (json['difficolta'] as num?)?.toInt(),

      nrBoulderSaliti:
          (json['nr_boulder_saliti'] as num?)?.toInt() ?? 0,
    );
  }
}