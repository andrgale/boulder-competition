class AthleteStatisticModel {
  final int? pettorale;
  final String? cognome;
  final String? nome;
  final String? societa;
  final DateTime? dataNascita;

  AthleteStatisticModel({
    this.pettorale,
    this.cognome,
    this.nome,
    this.societa,
    this.dataNascita,
  });

  String get fullName => '${cognome ?? ''} ${nome ?? ''}'.trim();

  factory AthleteStatisticModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AthleteStatisticModel();
    }

    return AthleteStatisticModel(
      pettorale: json['pettorale'] as int?,
      cognome: json['cognome'] as String?,
      nome: json['nome'] as String?,
      societa: json['societa'] as String?,
      dataNascita: json['data_nascita'] != null
          ? DateTime.tryParse(json['data_nascita'].toString())
          : null,
    );
  }
}

class StatisticCompetitionRegistrationModel {
  final String competitionId;

  final int nrAtletiIscritti;
  final int nrAtletiPartecipanti;

  final int nrAtletiMaschiIscritti;
  final int nrAtleteFemmineIscritte;

  final int nrAtletiMaschiPartecipanti;
  final int nrAtleteFemminePartecipanti;

  final AthleteStatisticModel atletaMaschioPartecipantePiuGiovane;
  final AthleteStatisticModel atletaFemminaPartecipantePiuGiovane;

  final AthleteStatisticModel atletaMaschioPartecipantePiuVecchio;
  final AthleteStatisticModel atletaFemminaPartecipantePiuVecchia;

  StatisticCompetitionRegistrationModel({
    required this.competitionId,
    required this.nrAtletiIscritti,
    required this.nrAtletiPartecipanti,
    required this.nrAtletiMaschiIscritti,
    required this.nrAtleteFemmineIscritte,
    required this.nrAtletiMaschiPartecipanti,
    required this.nrAtleteFemminePartecipanti,
    required this.atletaMaschioPartecipantePiuGiovane,
    required this.atletaFemminaPartecipantePiuGiovane,
    required this.atletaMaschioPartecipantePiuVecchio,
    required this.atletaFemminaPartecipantePiuVecchia,
  });

  factory StatisticCompetitionRegistrationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatisticCompetitionRegistrationModel(
      competitionId: json['competition_id'] as String,

      nrAtletiIscritti:
          (json['nr_atleti_iscritti'] as num?)?.toInt() ?? 0,

      nrAtletiPartecipanti:
          (json['nr_atleti_partecipanti'] as num?)?.toInt() ?? 0,

      nrAtletiMaschiIscritti:
          (json['nr_atleti_maschi_iscritti'] as num?)?.toInt() ?? 0,

      nrAtleteFemmineIscritte:
          (json['nr_atlete_femmine_iscritte'] as num?)?.toInt() ?? 0,

      nrAtletiMaschiPartecipanti:
          (json['nr_atleti_maschi_partecipanti'] as num?)?.toInt() ?? 0,

      nrAtleteFemminePartecipanti:
          (json['nr_atlete_femmine_partecipanti'] as num?)?.toInt() ?? 0,

      atletaMaschioPartecipantePiuGiovane:
          AthleteStatisticModel.fromJson(
            json['atleta_maschio_partecipante_piu_giovane']
                as Map<String, dynamic>?,
          ),

      atletaFemminaPartecipantePiuGiovane:
          AthleteStatisticModel.fromJson(
            json['atleta_femmina_partecipante_piu_giovane']
                as Map<String, dynamic>?,
          ),

      atletaMaschioPartecipantePiuVecchio:
          AthleteStatisticModel.fromJson(
            json['atleta_maschio_partecipante_piu_vecchio']
                as Map<String, dynamic>?,
          ),

      atletaFemminaPartecipantePiuVecchia:
          AthleteStatisticModel.fromJson(
            json['atleta_femmina_partecipante_piu_vecchia']
                as Map<String, dynamic>?,
          ),
    );
  }
}