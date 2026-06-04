class AthleteCompetitionModel {
  final String id;

  final String descrizione;

  final DateTime dataGara;

  final int nrBoulder;

  final bool flGaraChiusa;

  AthleteCompetitionModel({
    required this.id,
    required this.descrizione,
    required this.dataGara,
    required this.nrBoulder,
    required this.flGaraChiusa,
  });

  factory AthleteCompetitionModel.fromMap(
    Map<String, dynamic> json,
  ) {
    return AthleteCompetitionModel(
      id: json['id'],
      descrizione: json['descrizione'],
      dataGara: DateTime.parse(
        json['dt_gara'],
      ),
      nrBoulder:
          json['nr_boulder'] ?? 0,
      flGaraChiusa:
          json['fl_gara_chiusa'] ??
          false,
    );
  }
}