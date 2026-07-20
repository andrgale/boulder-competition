import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_menu.dart';

class MenuService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<AppMenu>> getMenus({required String locale}) async {
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

    // recupera menu + traduzioni disponibili
    final response = await client
        .from('user_roles')
        .select('''
          roles (
            role_menus (
              menus (
                *,
                menu_translations (
                  locale,
                  label
                )
              )
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
          menus.add(AppMenu.fromMap(_resolveLabel(menu, locale)));
        }
      }
    }

    // remove duplicates
    final uniqueMenus = {
      for (var m in menus) m.id: m
    }.values.toList();

    uniqueMenus.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return uniqueMenus;
  }

  /// Sostituisce menu['label'] con la traduzione trovata per [locale],
  /// se presente; altrimenti lascia la label originale della tabella menus.
  Map<String, dynamic> _resolveLabel(Map<String, dynamic> menu, String locale) {
    final translations = menu['menu_translations'] as List<dynamic>?;

    if (translations != null && translations.isNotEmpty) {
      final match = translations.cast<Map<String, dynamic>>().firstWhere(
            (t) => t['locale'] == locale,
            orElse: () => const {},
          );

      if (match.isNotEmpty && (match['label'] as String?)?.isNotEmpty == true) {
        // creo una copia per non mutare l'oggetto originale
        return {
          ...menu,
          'label': match['label'],
        };
      }
    }

    // fallback: label già presente in menus
    return menu;
  }
}