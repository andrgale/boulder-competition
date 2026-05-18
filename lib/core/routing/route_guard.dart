import 'package:go_router/go_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/menu_service.dart';

class RouteGuard {
  static final supabase =
      Supabase.instance.client;

  // =======================================================
  // CHECK AUTH
  // =======================================================

  static bool isLogged() {
    return supabase.auth.currentSession != null;
  }

  // =======================================================
  // GLOBAL REDIRECT
  // =======================================================

  static Future<String?> redirect(
    GoRouterState state,
  ) async {
    final logged = isLogged();

    final location = state.uri.path;

    // =====================================================
    // LOGIN PAGE
    // =====================================================

    if (location == '/login') {
      if (logged) {
        return '/dashboard';
      }

      return null;
    }

    // =====================================================
    // NOT LOGGED
    // =====================================================

    if (!logged) {
      return '/login';
    }

    // =====================================================
    // CHECK ROUTE PERMISSIONS
    // =====================================================

    final allowed =
        await hasRoutePermission(location);

    if (!allowed) {
      return '/forbidden';
    }

    return null;
  }

  // =======================================================
  // ROUTE PERMISSION
  // =======================================================

  static Future<bool> hasRoutePermission(
    String route,
  ) async {
    try {
      final menus =
          await MenuService().getMenus();

      final allowedRoutes =
          menus.map((m) => m.route).toList();

      return allowedRoutes.contains(route);
    } catch (_) {
      return false;
    }
  }
}