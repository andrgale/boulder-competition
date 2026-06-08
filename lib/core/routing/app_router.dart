import 'package:go_router/go_router.dart';

import '../../features/auth/login_page.dart';

import '../../features/competitions/models/competition_model.dart';
import '../../features/dashboard/dashboard_page.dart';

import '../../features/competitions/pages/competitions_page.dart';

import '../../features/registrations/pages/registrations_page.dart';

import '../../features/registrations/pages/registration_form_page.dart';

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

import '../../features/import_jobs/pages/importjobrow_page.dart';

import '../../features/import_jobs/pages/importjobs_page.dart';

import '../../features/import_jobs/models/import_job_model.dart';

import '../../features/athlete/pages/athlete_login_page.dart';
import '../../features/athlete/pages/athlete_change_password_page.dart';
import '../../features/athlete/pages/athlete_boulders_page.dart';
import '../../config/app_mode.dart';

import '../../features/ascents/pages/ascents_boulders_page.dart';

final GoRouter appRouter = GoRouter(
 // initialLocation: '/dashboard',
    initialLocation: AppConfig.isAthlete
        ? '/athlete-login'
        : '/dashboard',

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
    // ATHLETE LOGIN
    // =====================================================

    GoRoute(
      path: '/athlete-login',
      name: 'athlete_login',
      builder: (context, state) {
        return const AthleteLoginPage();
      },
    ),

    // =====================================================
    // ATHLETE CHANGE PASSWORD
    // =====================================================

    GoRoute(
      path: '/athlete-change-password',
      name: 'athlete_change_password',
      builder: (context, state) {
        return const AthleteChangePasswordPage();
      },
    ),

    // =====================================================
    // ATHLETE BOULDERS
    // =====================================================

    GoRoute(
      path: '/athlete-boulders',
      name: 'athlete_boulders',
      builder: (context, state) {
        return const AthleteBouldersPage();
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
// ======================================================
// REGISTRATIONS
// ======================================================

        GoRoute(
          path: '/competitions/:id/registrations',
          name: 'registrations_list',
          builder: (context, state) {
            final competitionId = state.pathParameters['id']!;
            final competition = state.extra as CompetitionModel?;

            return RegistrationsPage(
              competitionId: competitionId,
              competitionName: competition?.descrizione ?? '',
            );
          },
        ),

        GoRoute(
          path: '/registrations/new',
          name: 'registration_create',
          builder: (context, state) {
            final competitionId = state.extra as String;

            return RegistrationFormPage(
              competitionId: competitionId,
            );
          },
        ),

        GoRoute(
          path: '/registrations/edit',
          name: 'registration_edit',
          builder: (context, state) {
            final data = state.extra as Map;

            return RegistrationFormPage(
              competitionId: data['competitionId'],
              registration: data['registration'],
            );
          },
        ),

// ======================================================
// REALIZZAZIONI BOULDER
// =====================================================

        GoRoute(
          path: '/ascents-boulders',
          name: 'ascents_boulders',
          builder: (context, state) {
            final data =
                state.extra as Map<String, dynamic>;

            return AscentsBouldersPage(
              registrationId:
                  data['registrationId'],
              athleteName:
                  data['athleteName'],
            );
          },
        ),
// ======================================================
// RISULTATI IMPORT
// =====================================================

        GoRoute(
          path: '/import-jobs',
          builder: (context, state) {
            return const ImportJobsPage();
          },
        ),

        GoRoute(
          path: '/import-job-rows',
          builder: (context, state) {
            final job =
                state.extra as ImportJobModel;

            return ImportJobRowsPage(
              job: job,
            );
          },
        ),
      ],
    ),
  ],
);