class AthleteBoulderModel {
  final String boulderId;

  final int numero;

  final int difficolta;

  final String? colore;

  final bool top;
  final bool zone;
  final int tentativiTop;
  final int tentativiZone;


  AthleteBoulderModel({
    required this.boulderId,
    required this.numero,
    required this.difficolta,
    required this.colore,
    required this.top,
    required this.zone,
    required this.tentativiTop,
    required this.tentativiZone,
    
  });

  factory AthleteBoulderModel.fromMap(
    Map<String, dynamic> json,
  ) {
    return AthleteBoulderModel(
      boulderId: json['id'],
      numero: json['numero'] ?? 0,
      difficolta: json['difficolta'] ?? 0,
      colore: json['colore'],
      top: json['top'] ?? false,
      zone: json['zone'] ?? false,
      tentativiTop: json['tentativi_top'] ?? 0,
      tentativiZone: json['tentativi_zone'] ?? 0,

    );
  }
}