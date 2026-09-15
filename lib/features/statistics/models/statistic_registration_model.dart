class StatisticRegistrationModel {
  final String competitionId;
  final String registrationId;

  final int posizioneGenerale;
  final int posizioneSesso;
  final int posizioneCategoria;

  StatisticRegistrationModel({
    required this.competitionId,
    required this.registrationId,
    required this.posizioneGenerale,
    required this.posizioneSesso,
    required this.posizioneCategoria,
  });

  factory StatisticRegistrationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatisticRegistrationModel(
      competitionId: json['competition_id'] as String,
      registrationId: json['registration_id'] as String,

      posizioneGenerale:
          (json['posizione_generale'] as num?)?.toInt() ?? 0,

      posizioneSesso:
          (json['posizione_sesso'] as num?)?.toInt() ?? 0,

      posizioneCategoria:
          (json['posizione_categoria'] as num?)?.toInt() ?? 0,
    );
  }
}