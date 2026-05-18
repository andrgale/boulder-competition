import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_menu.dart';

class MenuService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<AppMenu>> getMenus() async {
    final authUser = client.auth.currentUser;

    if (authUser == null) {
      return [];
    }

    // recupera profile
    final profile = await client
        .from('profiles')
        .select('id')
        .eq('auth_user_id', authUser.id)
        .single();

    final profileId = profile['id'];

    // recupera menu
    final response = await client
        .from('user_roles')
        .select('''
          roles (
            role_menus (
              menus (*)
            )
          )
        ''')
        .eq('profile_id', profileId);

    final List<AppMenu> menus = [];

    for (final role in response) {
      final roleData = role['roles'];

      if (roleData == null) continue;

      final roleMenus = roleData['role_menus'] as List<dynamic>;

      for (final rm in roleMenus) {
        final menu = rm['menus'];

        if (menu != null) {
          menus.add(AppMenu.fromMap(menu));
        }
      }
    }

    // remove duplicates
    final uniqueMenus = {
      for (var m in menus) m.id: m
    }.values.toList();

    uniqueMenus.sort((a, b) => a.displayOrder.compareTo(b.displayOrder),);
    return uniqueMenus;
  }
}