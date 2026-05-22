class CategoryModel {
  final String id;
  final String competitionId;
  final String nome;
  final String? sesso;
  final int? etaMin;
  final int? etaMax;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.competitionId,
    required this.nome,
    this.sesso,
    this.etaMin,
    this.etaMax,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      competitionId: json['competition_id'] as String,
      nome: json['nome'] as String,
      sesso: json['sesso'] as String?,
      etaMin: json['eta_min'] != null ? json['eta_min'] as int : null,
      etaMax: json['eta_max'] != null ? json['eta_max'] as int : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsert() {
    return {
      'competition_id': competitionId,
      'nome': nome,
      'sesso': sesso,
      'eta_min': etaMin,
      'eta_max': etaMax,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'nome': nome,
      'sesso': sesso,
      'eta_min': etaMin,
      'eta_max': etaMax,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}