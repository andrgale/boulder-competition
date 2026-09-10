import 'package:boulder_competition/features/athlete/pages/athlete_check_in_scan_page.dart';
import 'package:boulder_competition/features/categories/models/category_template_item_model.dart';
import 'package:boulder_competition/features/categories/models/category_template_model.dart';
import 'package:boulder_competition/features/category_templates/pages/category_template_items_form_page.dart';
import 'package:boulder_competition/features/category_templates/pages/category_template_items_page.dart';
import 'package:boulder_competition/features/category_templates/pages/category_template_page.dart';
import 'package:boulder_competition/features/email/pages/email_templates_page.dart';
import 'package:boulder_competition/features/registrations/models/registration_model.dart';
import 'package:boulder_competition/features/security/models/menu_translation_model.dart';
import 'package:boulder_competition/features/security/pages/menus/menu_translation_form_page.dart';
import 'package:boulder_competition/features/security/pages/menus/menu_translations_list_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/athlete/pages/athlete_boulder_scan_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/change_password_page.dart';


import '../../features/competitions/models/competition_model.dart';
import '../../features/dashboard/dashboard_page.dart';

import '../../features/competitions/pages/competitions_page.dart';

import '../../features/registrations/pages/registrations_page.dart';

import '../../features/registrations/pages/registration_form_page.dart';

import '../../features/rankings/pages/ranking_competition_page.dart';

import '../../features/rankings/pages/ranking_final_page.dart';

import '../../features/rankings/pages/ranking_qualification_page.dart';

import '../../features/rankings/pages/ranking_top_zone_page.dart';

import '../../features/administration/administration_page.dart';

import '../../features/errors/forbidden_page.dart';

import '../../features/security/pages/profiles/profile_form_page.dart';
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

import '../../features/security/pages/security_dashboard_page.dart';
import '../../features/security/pages/roles/roles_list_page.dart';
import '../../features/security/pages/roles/role_form_page.dart';
import '../../features/security/pages/roles/role_manage_page.dart';
import '../../features/security/pages/permissions/permissions_list_page.dart';
import '../../features/security/pages/permissions/permission_form_page.dart';
import '../../features/security/pages/menus/menus_list_page.dart';
import '../../features/security/pages/menus/menu_form_page.dart';
import '../../features/security/pages/profiles/profiles_list_page.dart';
import '../../features/security/pages/profiles/profile_roles_page.dart';
import '../../features/security/models/role_model.dart';
import '../../features/security/models/permission_model.dart';
import '../../features/security/models/menu_model.dart';
import '../../features/security/models/security_profile_model.dart';
import '../../features/checkin/pages/checkin_competitions_page.dart';
import '../../features/athlete/pages/athlete_home_page.dart';
import '../../features/athlete/pages/athlete_competition_registration_page.dart';
import '../../features/athlete/pages/athlete_checkin_page.dart';
import '../../features/athlete/pages/athlete_registration_page.dart';


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

    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordPage(),
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
    // ATHLETE REGISTRATION
    // =====================================================

    GoRoute(
      path: '/athlete-registration',
      name: 'athlete_registration',
      builder: (context, state) {
        return const AthleteRegistrationPage();
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

    GoRoute(
      path: '/athlete-boulder-scan',
      name: 'athlete_boulder_scan',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final competitionId = extra?['competitionId'] as String? ?? '';
        final registrationId = extra?['registrationId'] as String? ?? '';

        return AthleteBoulderScanPage(
          competitionId: competitionId,
          registrationId: registrationId,
        );
      },
    ),

    GoRoute(
          path: '/athlete-home',
          name: 'athlete_home',
          builder: (context, state) {
            return const AthleteHomePage();
          },
        ),

    GoRoute(
          path: '/athlete-check-in-scan',
          name: 'athlete-check-in-scan',
          builder: (context, state) {
            return const AthleteCheckInScanPage();
          },
        ),

        GoRoute(
          path: '/athlete-competition-registration',
          name: 'athlete_competition_registration',
          builder: (context, state) {
            return const AthleteCompetitionRegistrationPage();
          },
        ),

        GoRoute(
          path: '/athlete-checkin',
          name: 'athlete_checkin',
          builder: (context, state) {
            return const AthleteCheckinPage();
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
            final competitionId = state.pathParameters['id']!;

            // Gestisce sia CompetitionModel (navigazione normale dall'app)
            // sia Map<String,dynamic> (navigazione dalla ricerca globale)
            final extra = state.extra;
            String competitionName = '';
            if (extra is CompetitionModel) {
              competitionName = extra.descrizione;
            } else if (extra is Map) {
              competitionName = extra['competitionName'] as String? ?? '';
            }

            return BouldersPage(
              competitionId: competitionId,
              competitionName: competitionName,
            );
          },
        ),

        GoRoute(
          path: '/rankings',

          builder: (context, state) {
            return const RankingsCompetitionsPage();
          },
        ),

        GoRoute(
          path: '/rankings/:id/qualifications',
          builder: (context, state) {
            final competitionId = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>?;

            return RankingQualificationPage(
              competitionId: competitionId,
              competitionName: extra?['competitionName'] as String? ?? '',
              nrFinalisti: extra?['nrFinalisti'] as int? ?? 0,
            );
          },
        ),

        GoRoute(
          path: '/rankings/:id/final',
          builder: (context, state) {
            final competitionId = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>?;

            return RankingFinalPage(
              competitionId: competitionId,
              competitionName: extra?['competitionName'] as String? ?? '',
            );
          },
        ),

        GoRoute(
          path: '/rankings/:id/top-zone',
          builder: (context, state) {
            final competitionId = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>?;

            return RankingTopZonePage(
              competitionId: competitionId,
              competitionName: extra?['competitionName'] as String? ?? '',
              nrFinalisti: extra?['nrFinalisti'] as int? ?? 0,
            );
          },
        ),


        GoRoute(
          path: '/admin',

          builder: (context, state) {
            return const AdministrationPage();
          },
        ),

        // =====================================================
        // FORZO LOGIN DA MENU
        // =====================================================

        GoRoute(
          path: '/login',

          builder: (context, state) {
            return const LoginPage();
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
// CHECK-IN COMPETIZIONI
// ======================================================

        GoRoute(
          path: '/check-in',
          builder: (context, state) {
            return const CheckinCompetitionsPage();
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

            final extra = state.extra;

            String competitionName = '';
            DateTime? competitionDate;

            bool flIscrizioniChiuse = false;
            int nrMaxRegistrations = 0;

            bool isTurn = false;
            int nrMaxFirstTurn = 0;
            int nrMaxSecondTurn = 0;

            if (extra is CompetitionModel) {
              competitionName = extra.descrizione;
              competitionDate = extra.dtGara;

              flIscrizioniChiuse = extra.flIscrizioniChiuse;
              nrMaxRegistrations = extra.nrMaxRegistrations;

              isTurn = extra.isTurn;
              nrMaxFirstTurn = extra.nrMaxFirstTurn;
              nrMaxSecondTurn = extra.nrMaxSecondTurn;
            } else if (extra is Map) {
              competitionName =
                  extra['competitionName'] as String? ?? '';

              final rawDate = extra['competitionDate'];
              if (rawDate is DateTime) {
                competitionDate = rawDate;
              } else if (rawDate is String) {
                competitionDate = DateTime.tryParse(rawDate);
              }

              flIscrizioniChiuse =
                  extra['flIscrizioniChiuse'] as bool? ?? false;

              nrMaxRegistrations =
                  extra['nrMaxRegistrations'] as int? ?? 0;

              isTurn =
                  extra['isTurn'] as bool? ?? false;

              nrMaxFirstTurn =
                  extra['nrMaxFirstTurn'] as int? ?? 0;

              nrMaxSecondTurn =
                  extra['nrMaxSecondTurn'] as int? ?? 0;
            }

            if (competitionDate == null) {
              throw Exception(
                'Data della gara non disponibile per la competizione $competitionId',
              );
            }

            return RegistrationsPage(
              competitionId: competitionId,
              competitionName: competitionName,
              competitionDate: competitionDate,
              flIscrizioniChiuse: flIscrizioniChiuse,
              nrMaxRegistrations: nrMaxRegistrations,
              isTurn: isTurn,
              nrMaxFirstTurn: nrMaxFirstTurn,
              nrMaxSecondTurn: nrMaxSecondTurn,
            );
          },
        ),

        GoRoute(
          path: '/registrations/new',
          name: 'registration_create',
          builder: (context, state) {
            final data = state.extra as Map;

            return RegistrationFormPage(
              competitionId: data['competitionId'] as String,
              competitionDate: data['competitionDate'] as DateTime,
              isTurn: data['isTurn'] as bool? ?? false,
              nrMaxFirstTurn:
                  data['nrMaxFirstTurn'] as int? ?? 0,
              nrMaxSecondTurn:
                  data['nrMaxSecondTurn'] as int? ?? 0,
              firstTurnCount:
                  data['firstTurnCount'] as int? ?? 0,
              secondTurnCount:
                  data['secondTurnCount'] as int? ?? 0,
            );
          },
        ),

        GoRoute(
          path: '/registrations/edit',
          name: 'registration_edit',
          builder: (context, state) {
            final data = state.extra as Map;

            return RegistrationFormPage(
              competitionId: data['competitionId'] as String,
              competitionDate: data['competitionDate'] as DateTime,
              registration:
                  data['registration'] as RegistrationModel,
              isTurn: data['isTurn'] as bool? ?? false,
              nrMaxFirstTurn:
                  data['nrMaxFirstTurn'] as int? ?? 0,
              nrMaxSecondTurn:
                  data['nrMaxSecondTurn'] as int? ?? 0,
              firstTurnCount:
                  data['firstTurnCount'] as int? ?? 0,
              secondTurnCount:
                  data['secondTurnCount'] as int? ?? 0,
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
        // ======================================================
        // SECURITY
        // ======================================================

        GoRoute(
          path: '/security',
          builder: (context, state) {
            return const SecurityDashboardPage();
          },
        ),

        GoRoute(
          path: '/security/roles',
          builder: (context, state) {
            return const RolesListPage();
          },
        ),

        GoRoute(
          path: '/security/roles/new',
          builder: (context, state) {
            return const RoleFormPage();
          },
        ),

        GoRoute(
          path: '/security/roles/edit',
          builder: (context, state) {
            final role = state.extra as RoleModel;
            return RoleFormPage(role: role);
          },
        ),

        GoRoute(
          path: '/security/roles/manage',
          builder: (context, state) {
            final role = state.extra as RoleModel;
            return RoleManagePage(role: role);
          },
        ),

        GoRoute(
          path: '/security/permissions',
          builder: (context, state) {
            return const PermissionsListPage();
          },
        ),

        GoRoute(
          path: '/security/permissions/new',
          builder: (context, state) {
            return const PermissionFormPage();
          },
        ),

        GoRoute(
          path: '/security/permissions/edit',
          builder: (context, state) {
            final permission = state.extra as PermissionModel;
            return PermissionFormPage(permission: permission);
          },
        ),

        GoRoute(
          path: '/security/menus',
          builder: (context, state) {
            return const MenusListPage();
          },
        ),

        GoRoute(
          path: '/security/menus/new',
          builder: (context, state) {
            // extra può essere null (radice) o String (parentId)
            final parentId = state.extra as String?;
            return MenuFormPage(parentId: parentId);
          },
        ),

        GoRoute(
          path: '/security/menus/edit',
          builder: (context, state) {
            final menu = state.extra as MenuModel;
            return MenuFormPage(menu: menu);
          },
        ),
        GoRoute(
          path: '/security/menus/translations',
          builder: (context, state) {
            final menu = state.extra as MenuModel;
            return MenuTranslationsListPage(menu: menu);
          },
        ),
        GoRoute(
          path: '/security/menus/translations/new',
          builder: (context, state) {
            final menu = state.extra as MenuModel;
            return MenuTranslationFormPage(menu: menu);
          },
        ),
        GoRoute(
          path: '/security/menus/translations/edit',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return MenuTranslationFormPage(
              menu: extra['menu'] as MenuModel,
              translation: extra['translation'] as MenuTranslationModel,
            );
          },
        ),

        GoRoute(
          path: '/security/profiles',
          builder: (context, state) {
            return const ProfilesListPage();
          },
        ),

        GoRoute(
          path: '/security/profiles/new',
          builder: (_, _) => const ProfileFormPage(),
        ),

        GoRoute(
          path: '/security/profiles/delete',
          builder: (_, state) {
            final data = state.extra as Map<String, dynamic>;

            return ProfileFormPage(
              profileId: data['id'],
              nome: data['nome'],
              cognome: data['cognome'],
              email: data['email'],
            );
          },
        ),        

        GoRoute(
          path: '/security/profiles/roles',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return ProfileRolesPage(
              profile: data['profile'] as SecurityProfileModel,
              roles: data['roles'] as List<RoleModel>,
            );
          },
        ),

        GoRoute(
          path: '/security/email',
          builder: (context, state) {
            return const EmailTemplatesPage(); 
          },
        ),

        GoRoute(
          path: '/security/categorytemplates',
          builder: (context, state) {
            return const CategoryTemplatePage();

          },
        ),

        GoRoute(
          path: '/security/categorytemplates/:templateId/items',
          builder: (context, state) {
            final template = state.extra! as CategoryTemplateModel;
            return CategoryTemplateItemsPage(
              templateId: state.pathParameters['templateId']!,
              templateName: template.nome,
            );
          },
        ),

        GoRoute(
          path: '/security/categorytemplates/items/form',
          builder: (context, state) {
            final data = state.extra as Map;
            return CategoryTemplateItemsFormPage(
              templateId: data['templateId'] as String,
              item: data['item'] as CategoryTemplateItemModel?,
            );
          },
        ),

      ],
    ),
  ],
);