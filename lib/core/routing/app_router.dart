// //import 'package:flutter/material.dart';

// import 'package:go_router/go_router.dart';

// import '../../core/layout/app_shell.dart';

// import '../../features/auth/login_page.dart';

// import '../../features/dashboard/dashboard_page.dart';

// import '../../features/competitions/competitions_page.dart';

// import '../../features/registrations/registrations_page.dart';

// import '../../features/boulders/boulders_page.dart';

// import '../../features/rankings/rankings_page.dart';

// import '../../features/administration/administration_page.dart';

// final GoRouter appRouter = GoRouter(
//   initialLocation: '/dashboard',

//   routes: [
//     // =====================================================
//     // LOGIN
//     // =====================================================

//     GoRoute(
//       path: '/login',

//       builder: (context, state) {
//         return const LoginPage();
//       },
//     ),

//     // =====================================================
//     // MAIN SHELL
//     // =====================================================

//     ShellRoute(
//       builder: (context, state, child) {
//         return AppShell(child: child);
//       },

//       routes: [
//         GoRoute(
//           path: '/dashboard',

//           builder: (context, state) {
//             return const DashboardPage();
//           },
//         ),

//         GoRoute(
//           path: '/competitions',

//           builder: (context, state) {
//             return const CompetitionsPage();
//           },
//         ),

//         GoRoute(
//           path: '/registrations',

//           builder: (context, state) {
//             return const RegistrationsPage();
//           },
//         ),

//         GoRoute(
//           path: '/boulders',

//           builder: (context, state) {
//             return const BouldersPage();
//           },
//         ),

//         GoRoute(
//           path: '/rankings',

//           builder: (context, state) {
//             return const RankingsPage();
//           },
//         ),

//         GoRoute(
//           path: '/admin',

//           builder: (context, state) {
//             return const AdministrationPage();
//           },
//         ),
//       ],
//     ),
//   ],
// );
import 'package:go_router/go_router.dart';

import '../../features/auth/login_page.dart';

import '../../features/dashboard/dashboard_page.dart';

import '../../features/competitions/competitions_page.dart';

import '../../features/registrations/registrations_page.dart';

import '../../features/boulders/boulders_page.dart';

import '../../features/rankings/rankings_page.dart';

import '../../features/administration/administration_page.dart';

import '../../features/errors/forbidden_page.dart';

import '../../shared/widgets/app_shell.dart';

import 'route_guard.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',

  redirect: (context, state) async {
    return await RouteGuard.redirect(
      state,
    );
  },

  routes: [
    // =====================================================
    // LOGIN
    // =====================================================

    GoRoute(
      path: '/login',

      builder: (context, state) {
        return const LoginPage();
      },
    ),

    // =====================================================
    // FORBIDDEN
    // =====================================================

    GoRoute(
      path: '/forbidden',

      builder: (context, state) {
        return const ForbiddenPage();
      },
    ),

    // =====================================================
    // APP SHELL
    // =====================================================

    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          child: child,
        );
      },

      routes: [
        GoRoute(
          path: '/dashboard',

          builder: (context, state) {
            return const DashboardPage();
          },
        ),

        GoRoute(
          path: '/competitions',

          builder: (context, state) {
            return const CompetitionsPage();
          },
        ),

        GoRoute(
          path: '/registrations',

          builder: (context, state) {
            return const RegistrationsPage();
          },
        ),

        GoRoute(
          path: '/boulders',

          builder: (context, state) {
            return const BouldersPage();
          },
        ),

        GoRoute(
          path: '/rankings',

          builder: (context, state) {
            return const RankingsPage();
          },
        ),

        GoRoute(
          path: '/admin',

          builder: (context, state) {
            return const AdministrationPage();
          },
        ),
      ],
    ),
  ],
);