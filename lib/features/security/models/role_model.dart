class RoleModel {
  final String id;
  final String code;
  final String name;
  final DateTime createdAt;

  RoleModel({
    required this.id,
    required this.code,
    required this.name,
    required this.createdAt,
  });

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'code': code,
      'name': name,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'code': code,
      'name': name,
    };
  }
}
