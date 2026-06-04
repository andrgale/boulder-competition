class AthleteBoulderModel {
  final String boulderId;

  final int numero;

  final int difficolta;

  final String? colore;

  final bool top;

  AthleteBoulderModel({
    required this.boulderId,
    required this.numero,
    required this.difficolta,
    required this.colore,
    required this.top,
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
    );
  }
}