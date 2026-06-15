class BoulderModel {
  final String id;
  final String competitionId;

  final int numero;
  final int difficolta;

  final String? colore;

  final double valoreTeorico;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFinale;

  BoulderModel({
    required this.id,
    required this.competitionId,
    required this.numero,
    required this.difficolta,
    this.colore,
    required this.valoreTeorico,
    required this.createdAt,
    required this.updatedAt,
    required this.isFinale,
  });

  factory BoulderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BoulderModel(
      id: json['id'] as String,

      competitionId:
          json['competition_id'] as String,

      numero: json['numero'] as int,

      difficolta:
          json['difficolta'] as int,

      colore: json['colore'] as String?,

      valoreTeorico:
          (json['valore_teorico'] as num)
              .toDouble(),

      createdAt: DateTime.parse(
        json['created_at'],
      ),

      updatedAt: DateTime.parse(
        json['updated_at'],
      ),

      isFinale: json['is_finale'] ?? false,
    );
  }

  // =====================================================
  // INSERT
  // =====================================================

  Map<String, dynamic> toInsert() {
    return {
      'competition_id': competitionId,
      'numero': numero,
      'difficolta': difficolta,
      'colore': colore,
      'valore_teorico': valoreTeorico,
    };
  }

  // =====================================================
  // UPDATE
  // =====================================================

  Map<String, dynamic> toUpdate() {
    return {
      'numero': numero,
      'difficolta': difficolta,
      'colore': colore,
      'valore_teorico': valoreTeorico,
      'updated_at':
          DateTime.now().toIso8601String(),
      'is_finale': isFinale,    
    };
  }
}