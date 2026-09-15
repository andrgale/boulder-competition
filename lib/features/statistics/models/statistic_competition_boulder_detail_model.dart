class StatisticCompetitionBoulderDetailModel {
  final String boulderId;
  final String competitionId;

  final int numero;
  final int? difficolta;
  final String? colore;
  final bool isFinale;

  final double valoreTeorico;
  final double valoreAttuale;

  final int nrSalite;
  final int nrSaliteMaschili;
  final int nrSaliteFemminili;

  StatisticCompetitionBoulderDetailModel({
    required this.boulderId,
    required this.competitionId,
    required this.numero,
    this.difficolta,
    this.colore,
    required this.isFinale,
    required this.valoreTeorico,
    required this.valoreAttuale,
    required this.nrSalite,
    required this.nrSaliteMaschili,
    required this.nrSaliteFemminili,
  });

  factory StatisticCompetitionBoulderDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatisticCompetitionBoulderDetailModel(
      boulderId: json['boulder_id'] as String,
      competitionId: json['competition_id'] as String,

      numero: (json['numero'] as num?)?.toInt() ?? 0,
      difficolta: (json['difficolta'] as num?)?.toInt(),
      colore: json['colore'] as String?,
      isFinale: json['is_finale'] as bool? ?? false,

      valoreTeorico:
          (json['valore_teorico'] as num?)?.toDouble() ?? 0.0,

      valoreAttuale:
          (json['valore_attuale'] as num?)?.toDouble() ?? 0.0,

      nrSalite:
          (json['nr_salite'] as num?)?.toInt() ?? 0,

      nrSaliteMaschili:
          (json['nr_salite_maschili'] as num?)?.toInt() ?? 0,

      nrSaliteFemminili:
          (json['nr_salite_femminili'] as num?)?.toInt() ?? 0,
    );
  }
}