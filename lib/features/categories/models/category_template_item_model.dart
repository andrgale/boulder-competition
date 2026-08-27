class CategoryTemplateItemModel {
  final String id;
  final String templateId;
  final String nome;
  final String? sesso;
  final int? etaMin;
  final int? etaMax;
  final int ordine;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryTemplateItemModel({
    required this.id,
    required this.templateId,
    required this.nome,
    this.sesso,
    this.etaMin,
    this.etaMax,
    required this.ordine,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryTemplateItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryTemplateItemModel(
      id: json['id'] as String,
      templateId: json['template_id'] as String,
      nome: json['nome'] as String,
      sesso: json['sesso'] as String?,
      etaMin: json['eta_min'] != null ? json['eta_min'] as int : null,
      etaMax: json['eta_max'] != null ? json['eta_max'] as int : null,
      ordine: json['ordine'] as int,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsert() {
    return {
      'template_id': templateId,
      'nome': nome,
      'sesso': sesso,
      'eta_min': etaMin,
      'eta_max': etaMax,
      'ordine': ordine,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'nome': nome,
      'sesso': sesso,
      'eta_min': etaMin,
      'eta_max': etaMax,
      'ordine': ordine,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}