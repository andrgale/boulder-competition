import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_model.dart';

class MenuServiceAdmin {
  final supabase = Supabase.instance.client;

  Future<List<MenuModel>> getMenus() async {
    final response = await supabase
        .from('menus')
        .select()
        .order('display_order');

    return response
        .map<MenuModel>((row) => MenuModel.fromMap(row))
        .toList();
  }

  Future<void> createMenu({
    required String label,
    required String route,
    String? icon,
    required int displayOrder,
    String? parentId,
    required bool visible,
    required bool mobile,
    required bool desktop,
  }) async {
    await supabase.from('menus').insert({
      'label': label.trim(),
      'route': route.trim(),
      if (icon != null && icon.isNotEmpty) 'icon': icon.trim(),
      'display_order': displayOrder,
      'parent_id': ?parentId,
      'visible': visible,
      'mobile': mobile,
      'desktop': desktop,
    });
  }

  Future<void> updateMenu({
    required String id,
    required String label,
    required String route,
    String? icon,
    required int displayOrder,
    String? parentId,
    required bool visible,
    required bool mobile,
    required bool desktop,
  }) async {
    await supabase.from('menus').update({
      'label': label.trim(),
      'route': route.trim(),
      'icon': (icon != null && icon.isNotEmpty) ? icon.trim() : null,
      'display_order': displayOrder,
      'parent_id': parentId,
      'visible': visible,
      'mobile': mobile,
      'desktop': desktop,
    }).eq('id', id);
  }

  Future<void> deleteMenu(String id) async {
    await supabase.from('menus').delete().eq('id', id);
  }
}
