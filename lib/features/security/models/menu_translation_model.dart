class MenuTranslationModel {
  final String id;
  final String menuId;
  final String locale;
  final String label;
  final DateTime createdAt;

  MenuTranslationModel({
    required this.id,
    required this.menuId,
    required this.locale,
    required this.label,
    required this.createdAt,
  });

  factory MenuTranslationModel.fromMap(Map<String, dynamic> map) {
    return MenuTranslationModel(
      id: map['id'] as String,
      menuId: map['menu_id'] as String,
      locale: map['locale'] as String,
      label: map['label'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'menu_id': menuId,
      'locale': locale,
      'label': label,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'locale': locale,
      'label': label,
    };
  }
}