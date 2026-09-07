class RankingCategoryTopZoneModel {
  final int posizione;
  final String registrationId;
  final String competitionId;
  final String? categoryId;
  final String? categoriaNome;
  final String? categoriaSesso;
  final int? categoriaEtaMin;
  final int? categoriaEtaMax;
  final int? pettorale;
  final String cognome;
  final String nome;
  final String? sesso;
  final String? societa;
  final int nrTop;
  final int nrZone;
  final int tentativiTop;
  final int tentativiZone;
  final double punteggioTotale;

  RankingCategoryTopZoneModel({
    required this.posizione,
    required this.registrationId,
    required this.competitionId,
    this.categoryId,
    this.categoriaNome,
    this.categoriaSesso,
    this.categoriaEtaMin,
    this.categoriaEtaMax,
    this.pettorale,
    required this.cognome,
    required this.nome,
    this.sesso,
    this.societa,
    required this.nrTop,
    required this.nrZone,
    required this.tentativiTop,
    required this.tentativiZone,
    required this.punteggioTotale,
  });

  String get fullName => '$cognome $nome';

  factory RankingCategoryTopZoneModel.fromJson(Map<String, dynamic> json) {
    return RankingCategoryTopZoneModel(
      posizione: json['posizione'] as int,
      registrationId: json['registration_id'] as String,
      competitionId: json['competition_id'] as String,
      categoryId: json['category_id'] as String?,
      categoriaNome: json['categoria_nome'] as String?,
      categoriaSesso: json['categoria_sesso'] as String?,
      categoriaEtaMin: json['categoria_eta_min'] as int?,
      categoriaEtaMax: json['categoria_eta_max'] as int?,
      pettorale: json['pettorale'] as int?,
      cognome: json['cognome'] as String,
      nome: json['nome'] as String,
      sesso: json['sesso'] as String?,
      societa: json['societa'] as String?,
      nrTop: json['nr_top'] as int? ?? 0,
      nrZone: json['nr_zone'] as int? ?? 0,
      tentativiTop: json['tentativi_top'] as int? ?? 0,
      tentativiZone: json['tentativi_zone'] as int? ?? 0,
      punteggioTotale: (json['punteggio_totale'] as num?)?.toDouble() ?? 0.0,
    );
  }
}