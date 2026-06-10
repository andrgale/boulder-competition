class PermissionModel {
  final String id;
  final String permissionCode;
  final String activity;
  final DateTime createdAt;

  PermissionModel({
    required this.id,
    required this.permissionCode,
    required this.activity,
    required this.createdAt,
  });

  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      id: map['id'] as String,
      permissionCode: map['permission_code'] as String,
      activity: map['activity'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'permission_code': permissionCode,
      'activity': activity,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'permission_code': permissionCode,
      'activity': activity,
    };
  }
}
