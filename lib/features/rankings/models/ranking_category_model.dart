class RankingCategoryModel {
  final int posizione;
  final String registrationId;
  final String competitionId;
  final String categoryId;
  final String categoriaNome;
  final String? categoriaSesso;
  final int? categoriaEtaMin;
  final int? categoriaEtaMax;
  final int? pettorale;
  final String cognome;
  final String nome;
  final String? sesso;
  final String? societa;
  final int nrTop;
  final double punteggioTotale;

  RankingCategoryModel({
    required this.posizione,
    required this.registrationId,
    required this.competitionId,
    required this.categoryId,
    required this.categoriaNome,
    this.categoriaSesso,
    this.categoriaEtaMin,
    this.categoriaEtaMax,
    this.pettorale,
    required this.cognome,
    required this.nome,
    this.sesso,
    this.societa,
    required this.nrTop,
    required this.punteggioTotale,
  });

  String get fullName => '$cognome $nome';

  factory RankingCategoryModel.fromJson(Map<String, dynamic> json) {
    return RankingCategoryModel(
      posizione: json['posizione'] as int,
      registrationId: json['registration_id'] as String,
      competitionId: json['competition_id'] as String,
      categoryId: json['category_id'] as String,
      categoriaNome: json['categoria_nome'] as String,
      categoriaSesso: json['categoria_sesso'] as String?,
      categoriaEtaMin: json['categoria_eta_min'] as int?,
      categoriaEtaMax: json['categoria_eta_max'] as int?,
      pettorale: json['pettorale'] as int?,
      cognome: json['cognome'] as String,
      nome: json['nome'] as String,
      sesso: json['sesso'] as String?,
      societa: json['societa'] as String?,
      nrTop: json['nr_top'] as int? ?? 0,
      punteggioTotale: (json['punteggio_totale'] as num?)?.toDouble() ?? 0.0,
    );
  }
}