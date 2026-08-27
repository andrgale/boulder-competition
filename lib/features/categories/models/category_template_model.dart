class CategoryTemplateModel {
  final String id;
  final String nome;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryTemplateModel({
    required this.id,
    required this.nome,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryTemplateModel.fromJson(Map<String, dynamic> json) {
    return CategoryTemplateModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsert() {
    return {
      'nome': nome,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'nome': nome,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}