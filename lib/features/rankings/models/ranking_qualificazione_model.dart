class RankingQualificazioneModel {
  final String registrationId;
  final String competitionId;
  final String? categoryId;
  final int? pettorale;
  final String cognome;
  final String nome;
  final String? sesso;
  final String? societa;
  final int nrTop;
  final double punteggioTotale;

  RankingQualificazioneModel({
    required this.registrationId,
    required this.competitionId,
    this.categoryId,
    this.pettorale,
    required this.cognome,
    required this.nome,
    this.sesso,
    this.societa,
    required this.nrTop,
    required this.punteggioTotale,
  });

  String get fullName => '$cognome $nome';

  /// Descrizione leggibile del sesso ('Maschio' / 'Femmina' / '—')
  String get sessoLabel {
    switch (sesso) {
      case 'M':
        return 'Maschio';
      case 'F':
        return 'Femmina';
      default:
        return '—';
    }
  }

  factory RankingQualificazioneModel.fromJson(Map<String, dynamic> json) {
    return RankingQualificazioneModel(
      registrationId: json['registration_id'] as String,
      competitionId: json['competition_id'] as String,
      categoryId: json['category_id'] as String?,
      pettorale: json['pettorale'] as int?,
      cognome: json['cognome'] as String,
      nome: json['nome'] as String,
      sesso: json['sesso'] as String?,
      societa: json['societa'] as String?,
      nrTop: json['nr_top'] as int? ?? 0,
      // numeric può arrivare come int o double dal DB
      punteggioTotale: (json['punteggio_totale'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
