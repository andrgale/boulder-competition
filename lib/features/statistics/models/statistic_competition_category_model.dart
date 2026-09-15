class StatisticCompetitionCategoryModel {
  final String categoryId;
  final String competitionId;
  final String nome;

  final int nrAtletiIscritti;
  final int nrAtletiPartecipanti;

  StatisticCompetitionCategoryModel({
    required this.categoryId,
    required this.competitionId,
    required this.nome,
    required this.nrAtletiIscritti,
    required this.nrAtletiPartecipanti,
  });

  factory StatisticCompetitionCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatisticCompetitionCategoryModel(
      categoryId: json['category_id'] as String,
      competitionId: json['competition_id'] as String,
      nome: json['nome'] as String,

      nrAtletiIscritti:
          (json['nr_atleti_iscritti'] as num?)?.toInt() ?? 0,

      nrAtletiPartecipanti:
          (json['nr_atleti_partecipanti'] as num?)?.toInt() ?? 0,
    );
  }
}