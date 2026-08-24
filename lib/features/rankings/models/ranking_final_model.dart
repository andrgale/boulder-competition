class RankingFinalModel {
  final String registrationId;
  final String competitionId;
  final String? categoryId;
  final int? pettorale;
  final String cognome;
  final String nome;
  final String? sesso; // 'M' | 'F' | null
  final String? societa;
  final int nrTop;
  final int nrZone;
  final int tentativiTop;
  final int tentativiZone;

  RankingFinalModel({
    required this.registrationId,
    required this.competitionId,
    this.categoryId,
    this.pettorale,
    required this.cognome,
    required this.nome,
    this.sesso,
    this.societa,
    required this.nrTop,
    required this.nrZone,
    required this.tentativiTop,
    required this.tentativiZone,
  });

  String get fullName => '$cognome $nome';

  /// Enum helper per il sesso — utile per localizzare in UI senza toccare il model.
  Sesso get sessoEnum {
    switch (sesso) {
      case 'M':
        return Sesso.male;
      case 'F':
        return Sesso.female;
      default:
        return Sesso.unknown;
    }
  }

  factory RankingFinalModel.fromJson(Map<String, dynamic> json) {
    return RankingFinalModel(
      registrationId: json['registration_id'] as String,
      competitionId: json['competition_id'] as String,
      categoryId: json['category_id'] as String?,
      pettorale: json['pettorale'] as int?,
      cognome: json['cognome'] as String,
      nome: json['nome'] as String,
      sesso: json['sesso'] as String?,
      societa: json['societa'] as String?,
      nrTop: json['nr_top'] as int? ?? 0,
      nrZone: json['nr_zone'] as int? ?? 0,
      tentativiTop: json['tentativi_top'] as int? ?? 0,
      tentativiZone: json['tentativi_zone'] as int? ?? 0,
    );
  }
}

enum Sesso { male, female, unknown }