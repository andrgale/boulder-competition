class MenuModel {
  final String id;
  final String label;
  final String route;
  final String? icon;
  final int displayOrder;
  final String? parentId;
  final bool visible;
  final bool mobile;
  final bool desktop;
  final DateTime createdAt;

  // populated in-memory for tree rendering
  List<MenuModel> children;

  MenuModel({
    required this.id,
    required this.label,
    required this.route,
    this.icon,
    required this.displayOrder,
    this.parentId,
    required this.visible,
    required this.mobile,
    required this.desktop,
    required this.createdAt,
    this.children = const [],
  });

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'] as String,
      label: map['label'] as String,
      route: map['route'] as String,
      icon: map['icon'] as String?,
      displayOrder: map['display_order'] as int? ?? 0,
      parentId: map['parent_id'] as String?,
      visible: map['visible'] as bool? ?? true,
      mobile: map['mobile'] as bool? ?? true,
      desktop: map['desktop'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'label': label,
      'route': route,
      if (icon != null) 'icon': icon,
      'display_order': displayOrder,
      if (parentId != null) 'parent_id': parentId,
      'visible': visible,
      'mobile': mobile,
      'desktop': desktop,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'label': label,
      'route': route,
      'icon': icon,
      'display_order': displayOrder,
      'parent_id': parentId,
      'visible': visible,
      'mobile': mobile,
      'desktop': desktop,
    };
  }
}
