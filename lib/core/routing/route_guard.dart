import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../services/permission_service.dart';

class RouteGuard {
  static final supabase = Supabase.instance.client;

  // =======================================================
  // ROUTE → REQUIRED PERMISSION
  // =======================================================

  static final Map<String, String> routePermissions = {
    // =====================================================
    // DASHBOARD
    // =====================================================

    '/dashboard': 'menu.read',
    '/change-password': 'menu.read',

    // =====================================================
    // COMPETITIONS
    // =====================================================

    '/competitions': 'competition.read',

    '/competitions/new': 'competition.write',

    '/competitions/edit': 'competition.write',

    '/competitions/delete': 'competition.write',

    '/competitions/categories'    : 'competition.read',
    '/competitions/registrations' : 'registration.read',
    '/competitions/boulders'      : 'boulder.read',


    // =====================================================
    // REGISTRATIONS
    // =====================================================

    '/registrations': 'registration.read',

    '/registrations/new': 'registration.write',

    '/registrations/edit': 'registration.write',

    // =====================================================
    // BOULDERS
    // =====================================================

    '/boulders': 'boulder.read',

    '/boulders/new': 'boulder.write',

    '/boulders/edit': 'boulder.write',

    // =====================================================
    // CATEGORIES
    // =====================================================

    '/categories/new': 'category.write',

    '/categories/edit': 'category.write',

    // =====================================================
    // ASCENTS
    // =====================================================


    '/ascents-boulders': 'ascent.write',
    // =====================================================
    // RANKINGS
    // =====================================================

    '/rankings': 'ranking.read',
    '/rankings/qualifications':'qualifications.read',
    '/rankings/final':'final.read',
    '/rankings/top-zone':'top.read',
    // =====================================================
    // IMPORT
    // =====================================================

    '/import-jobs': 'import.read',

    '/import-job-rows': 'import.read',

    // =====================================================
    // ADMIN
    // =====================================================

    '/admin': 'admin.panel',

    // =====================================================
    // SECURITY
    // =====================================================
    '/security':                    'security.admin',
    '/security/roles':              'security.admin',
    '/security/roles/new':          'security.admin',
    '/security/roles/edit':         'security.admin',
    '/security/roles/manage':       'security.admin',
    '/security/permissions':        'security.admin',
    '/security/permissions/new':    'security.admin',
    '/security/permissions/edit':   'security.admin',
    '/security/menus':              'security.admin',
    '/security/menus/new':          'security.admin',
    '/security/menus/edit':         'security.admin',
    '/security/profiles':           'security.admin',
    '/security/profiles/roles':     'security.admin',
    '/security/profiles/new':       'security.admin',
    '/security/profiles/delete':    'security.admin',


    '/check-in': 'checkin.read',
  };

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

    final isAthleteRoute =
    location == '/athlete-login' ||
    location == '/athlete-change-password' ||
    location == '/athlete-boulder-scan' ||    
    location == '/athlete-boulders';    

    // =====================================================
    // ROTTE ATLETA
    // =====================================================

    if (isAthleteRoute) {
      if (location == '/athlete-login') {
        if (!logged) {
          return null;
        }

        final isAthlete =
            await PermissionService.hasRole(
          'athlete',
        );

        if (isAthlete) {
          return '/athlete-boulders';
        }

        return '/dashboard';
      }

      if (location ==
          '/athlete-change-password') {
        return null;
      }

      if (!logged) {
        return '/athlete-login';
      }

      final isAthlete =
          await PermissionService.hasRole(
        'athlete',
      );

      if (!isAthlete) {
        return '/forbidden';
      }

      return null;
    }

    // =====================================================
    // LOGIN ADMIN
    // =====================================================

    if (location == '/login') {
      if (!logged) {
        return null;
      }

      final isAthlete =
          await PermissionService.hasRole(
        'athlete',
      );

      if (isAthlete) {
        return '/athlete-boulders';
      }

      return '/dashboard';
    }

    // =====================================================
    // ROTTE ADMIN
    // =====================================================

    if (!logged) {
      return '/login';
    }

    final isAthlete =
        await PermissionService.hasRole(
      'athlete',
    );

    if (isAthlete) {
      return '/athlete-boulders';
    }

    // final baseRoute =
    //     _extractBaseRoute(location);

    // final allowed =
    //     await hasRoutePermission(
    //   baseRoute,
    // );

    final normalizedRoute =
        normalizeRoute(location);

    final allowed =
        await hasRoutePermission(
          normalizedRoute,
        );


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
      final normalizedRoute =
          normalizeRoute(route);

      final permission =
          routePermissions[
              normalizedRoute];

      if (permission == null) {
        debugPrint(
          'ATTENZIONE: route non configurata: $route'
        );
        return false;
     //   return true;
      }

      return await PermissionService
          .hasPermission(permission);
    } catch (_) {
      return false;
    }
  }

  // =======================================================
  // NORMALIZE ROUTES
  // =======================================================

  static String normalizeRoute(
    String route,
  ) {
    if (route.startsWith(
      '/competitions/edit/',
    )) {
      return '/competitions/edit';
    }

    if (route.startsWith(
      '/registrations/edit/',
    )) {
      return '/registrations/edit';
    }

    if (route.startsWith(
      '/boulders/edit/',
    )) {
      return '/boulders/edit';
    }
    if (RegExp(r'^/competitions/[^/]+/categories$')
        .hasMatch(route)) {
      return '/competitions/categories';
    }

    if (RegExp(r'^/competitions/[^/]+/registrations$')
        .hasMatch(route)) {
      return '/competitions/registrations';
    }

    if (RegExp(r'^/competitions/[^/]+/boulders$')
        .hasMatch(route)) {
      return '/competitions/boulders';
    } 

    if (RegExp(r'^/rankings/[^/]+/qualifications$')
        .hasMatch(route)) {
      return '/rankings/qualifications';
    } 

    if (RegExp(r'^/rankings/[^/]+/final$')
        .hasMatch(route)) {
      return '/rankings/final';
    } 

    if (RegExp(r'^/rankings/[^/]+/top-zone$')
        .hasMatch(route)) {
      return '/rankings/top-zone';
    } 


    // Security routes con segmenti dinamici (attualmente nessuno,
    // ma pronti per future estensioni)
    if (route.startsWith('/security/')) {
      return route; // già normalizzata, nessun id dinamico
    }

    return route;
  }

  // =======================================================
  // BASE ROUTE
  // =======================================================

  // static String _extractBaseRoute(
  //   String route,
  // ) {
  //   final segments =
  //       Uri.parse(route).pathSegments;

  //   if (segments.isEmpty) {
  //     return route;
  //   }

  //   return '/${segments.first}';
  // }
}