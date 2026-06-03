class AppMenu {
  final String id;
  final String label;
  final String route;
  final String? icon;
  final int displayOrder;

  final bool visible;
  final bool mobile;
  final bool desktop;

  AppMenu({
    required this.id,
    required this.label,
    required this.route,
    this.icon,
    required this.displayOrder,
    required this.visible,
    required this.mobile,
    required this.desktop,
  });

  factory AppMenu.fromMap(Map<String, dynamic> map) {
    return AppMenu(
      id: map['id'],
      label: map['label'],
      route: map['route'],
      icon: map['icon'],
      displayOrder: map['display_order'] ?? 0,
      visible: map['visible'] ?? true,
      mobile: map['mobile'] ?? true,
      desktop: map['desktop'] ?? true,
    );
  }
}