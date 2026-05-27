import 'package:go_router/go_router.dart';

import '../../features/auth/login_page.dart';

import '../../features/competitions/models/competition_model.dart';
import '../../features/dashboard/dashboard_page.dart';

import '../../features/competitions/pages/competitions_page.dart';

import '../../features/registrations/registrations_page.dart';

import '../../features/rankings/rankings_page.dart';

import '../../features/administration/administration_page.dart';

import '../../features/errors/forbidden_page.dart';

import '../../shared/widgets/app_shell.dart';

import 'route_guard.dart';

import '../../features/competitions/pages/competition_form_page.dart';

import '../../features/competitions/pages/competition_form_loader_page.dart';

import '../../features/categories/pages/categories_page.dart';

import '../../features/categories/pages/category_form_page.dart';

import '../../features/boulders/pages/boulders_page.dart';

import '../../features/boulders/pages/boulder_form_page.dart';



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
          path: '/competitions/:id/boulders',
          builder: (context, state) {
            final competition =
                state.extra as CompetitionModel;

            return BouldersPage(
              competitionId: competition.id,
              competitionName:
                  competition.descrizione,
            );
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

        GoRoute(
          path: '/competitions/new',

          builder: (context, state) {
            return const CompetitionFormPage();
          },
        ),

        GoRoute(
          path: '/competitions/edit/:id',

          builder: (context, state) {
            final id = state.pathParameters['id']!;

            return CompetitionFormLoaderPage(
              competitionId: id,
            );
          },
        ),
        GoRoute(
          path: '/competitions/:id/categories',
          builder: (context, state) {
            final competitionId = state.pathParameters['id']!;
            final competition = state.extra as CompetitionModel?;

            return CategoriesPage(
              competitionId: competitionId,
              competitionName: competition?.descrizione ?? '',
            );
          },
        ),
        GoRoute(
          path: '/categories/new',
          name: 'category_create',
          builder: (context, state) {
            final competitionId = state.extra as String;

            return CategoryFormPage(
              competitionId: competitionId,
            );
          },
        ),

        GoRoute(
          path: '/categories/edit',
          name: 'category_edit',
          builder: (context, state) {
            final data = state.extra as Map;

            return CategoryFormPage(
              competitionId: data['competitionId'],
              category: data['category'],
            );
          },
        ),
// ======================================================
// BOULDERS
// ======================================================

        GoRoute(
          path: '/boulders/new',
          name: 'boulder_create',
          builder: (context, state) {
            final competitionId = state.extra as String;

            return BoulderFormPage(
              competitionId: competitionId,
            );
          },
        ),

        GoRoute(
          path: '/boulders/edit',
          name: 'boulder_edit',
          builder: (context, state) {
            final data = state.extra as Map;

            return BoulderFormPage(
              competitionId: data['competitionId'],
              boulder: data['boulder'],
            );
          },
        ),

      ],
    ),
  ],
);