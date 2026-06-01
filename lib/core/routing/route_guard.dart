import 'package:go_router/go_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/menu_service.dart';

import '../services/permission_service.dart';

class RouteGuard {
  static final supabase =
      Supabase.instance.client;

  // =======================================================
  // ROUTE → REQUIRED PERMISSION
  // =======================================================

  static final Map<String, String>
      routePermissions = {
    // =====================================================
    // DASHBOARD
    // =====================================================

    '/dashboard': 'menu.read',

    // =====================================================
    // COMPETITIONS
    // =====================================================

    '/competitions':
        'competition.read',

    '/competitions/new':
        'competition.write',

    // dynamic edit route
    '/competitions/edit':
        'competition.write',

    '/competitions/delete':
        'competition.write',

    // =====================================================
    // REGISTRATIONS
    // =====================================================

    '/registrations':
        'registration.read',

    '/registrations/new':
        'registration.write',

    '/registrations/edit':
        'registration.write',

    // =====================================================
    // BOULDERS
    // =====================================================

    '/boulders':
        'boulder.read',

    '/boulders/new':
        'boulder.write',

    '/boulders/edit':
        'boulder.write',

    // =====================================================
    // RANKINGS
    // =====================================================

    '/rankings':
        'ranking.read',
    // =====================================================
    // IMPORT CSV
    // =====================================================

    '/import-jobs': 'admin.panel',
    '/import-job-rows': 'admin.panel',

    // =====================================================
    // ADMIN
    // =====================================================

    '/admin': 'admin.panel',
  };

  // =======================================================
  // CHECK AUTH
  // =======================================================

  static bool isLogged() {
    return supabase.auth.currentSession !=
        null;
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
    // LOGIN
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

   // final allowed =
   //     await hasRoutePermission(location);
    final baseRoute = _extractBaseRoute(location);

    final allowed =
        await hasRoutePermission(baseRoute);

    if (!allowed) {
      return '/forbidden';
    }

    return null;
  }

  // =======================================================
  // CHECK ROUTE ACCESS
  // =======================================================

  static Future<bool> hasRoutePermission(
    String route,
  ) async {
    try {
      // ===================================================
      // DYNAMIC ROUTES NORMALIZATION
      // ===================================================

      final normalizedRoute =
          normalizeRoute(route);

      // ===================================================
      // MENU ROUTES
      // ===================================================

      final menus =
          await MenuService().getMenus();

      final allowedRoutes =
          menus.map((m) => m.route).toList();

      // ===================================================
      // ROUTE EXISTS IN MENU
      // ===================================================

      if (allowedRoutes.contains(
        normalizedRoute,
      )) {
        return true;
      }

      // ===================================================
      // PERMISSION-BASED ROUTES
      // ===================================================

      final permission =
          routePermissions[
              normalizedRoute];

      if (permission == null) {
        return false;
      }

      return await PermissionService
          .hasPermission(permission);
    } catch (e) {
      return false;
    }
  }

  // =======================================================
  // NORMALIZE DYNAMIC ROUTES
  // =======================================================

  static String normalizeRoute(
    String route,
  ) {
    // =====================================================
    // COMPETITIONS EDIT
    // =====================================================

    if (route.startsWith(
      '/competitions/edit/',
    )) {
      return '/competitions/edit';
    }

    // =====================================================
    // REGISTRATIONS EDIT
    // =====================================================

    if (route.startsWith(
      '/registrations/edit/',
    )) {
      return '/registrations/edit';
    }

    // =====================================================
    // BOULDERS EDIT
    // =====================================================

    if (route.startsWith(
      '/boulders/edit/',
    )) {
      return '/boulders/edit';
    }

    return route;
  }
  static String _extractBaseRoute(String route) {
    final segments = Uri.parse(route).pathSegments;

    if (segments.isEmpty) return route;

    return '/${segments.first}';
  }

}