import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../core/models/app_menu.dart';

import '../../core/services/menu_service.dart';

import '../../core/ui/responsive.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final menuService = MenuService();

  bool loading = true;

  List<AppMenu> menus = [];

  @override
  void initState() {
    super.initState();

    loadMenus();
  }

  Future<void> loadMenus() async {
    try {
      final loadedMenus =
          await menuService.getMenus();

      if (!mounted) return;

      setState(() {
        menus = loadedMenus;

        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDesktop =
        Responsive.isDesktop(context);

    final isTablet =
        Responsive.isTablet(context);

    final isMobile =
        Responsive.isMobile(context);

    return Scaffold(
      drawer: (isDesktop || isTablet)
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    const _DrawerHeader(),

                    Expanded(
                      child: ListView(
                        children:
                            buildMenuTiles(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

      body: Row(
        children: [
          // =================================================
          // DESKTOP / TABLET SIDEBAR
          // =================================================

          if (isDesktop || isTablet)
            Container(
              width: isDesktop ? 280 : 220,

              decoration: BoxDecoration(
                color:
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerLowest,

                border: Border(
                  right: BorderSide(
                    color:
                        Theme.of(context)
                            .dividerColor,
                  ),
                ),
              ),

              child: SafeArea(
                child: Column(
                  children: [
                    const _SidebarHeader(),

                    Expanded(
                      child: ListView(
                        children:
                            buildMenuTiles(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // =================================================
          // CONTENT
          // =================================================

          Expanded(
            child: Column(
              children: [
                // =============================================
                // TOP BAR
                // =============================================

                Container(
                  height: 64,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),

                  decoration: BoxDecoration(
                    color:
                        Theme.of(context)
                            .colorScheme
                            .surface,

                    border: Border(
                      bottom: BorderSide(
                        color:
                            Theme.of(context)
                                .dividerColor,
                      ),
                    ),
                  ),

                  child: Row(
                    children: [
                      if (isMobile)
                        Builder(
                          builder: (context) {
                            return IconButton(
                              onPressed: () {
                                Scaffold.of(
                                  context,
                                ).openDrawer();
                              },
                              icon: const Icon(
                                Icons.menu,
                              ),
                            );
                          },
                        ),

                      if (isMobile)
                        const SizedBox(width: 12),

                      Text(
                        currentPageTitle(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {},

                        icon: const Icon(
                          Icons.notifications,
                        ),
                      ),

                      const SizedBox(width: 12),

                      CircleAvatar(
                        radius: 18,

                        child: Text(
                          currentUserInitials(),
                        ),
                      ),
                    ],
                  ),
                ),

                // =============================================
                // PAGE CONTENT
                // =============================================

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            Responsive.contentWidth(
                          context,
                        ),
                      ),

                      child: Padding(
                        padding:
                            Responsive.pagePadding(
                          context,
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            AppBreadcrumb(
                              current:
                                  currentPageTitle(),
                            ),

                            Expanded(
                              child: widget.child,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // =============================================
                // MOBILE BOTTOM NAVIGATION
                // =============================================

                if (isMobile)
                  NavigationBar(
                    selectedIndex:
                        currentBottomIndex(),

                    onDestinationSelected:
                        (index) {
                      context.go(
                        mobileRoutes[index],
                      );
                    },

                    destinations: const [
                      NavigationDestination(
                        icon:
                            Icon(Icons.dashboard),
                        label: 'Dashboard',
                      ),

                      NavigationDestination(
                        icon:
                            Icon(Icons.groups),
                        label: 'Iscritti',
                      ),

                      NavigationDestination(
                        icon:
                            Icon(Icons.terrain),
                        label: 'Boulder',
                      ),

                      NavigationDestination(
                        icon:
                            Icon(Icons.leaderboard),
                        label: 'Ranking',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // MENU TILES
  // =======================================================

  List<Widget> buildMenuTiles(
    BuildContext context,
  ) {
    return menus.map((menu) {
      final selected =
          GoRouterState.of(context).uri.path ==
              menu.route;

      return ListTile(
        leading: buildMenuIcon(menu.icon),

        title: Text(menu.label),

        selected: selected,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        onTap: () {
          context.go(menu.route);
        },
      );
    }).toList();
  }

  // =======================================================
  // MENU ICONS
  // =======================================================

  Widget buildMenuIcon(String? iconName) {
    switch (iconName) {
      case 'dashboard':
        return const Icon(Icons.dashboard);

      case 'groups':
        return const Icon(Icons.groups);

      case 'terrain':
        return const Icon(Icons.terrain);

      case 'leaderboard':
        return const Icon(Icons.leaderboard);

      case 'sports_score':
        return const Icon(Icons.sports_score);

      case 'emoji_events':
        return const Icon(Icons.emoji_events);

      case 'admin_panel_settings':
        return const Icon(
          Icons.admin_panel_settings,
        );

      case 'category':
        return const Icon(Icons.category);

      case 'person':
        return const Icon(Icons.person);

      default:
        return const Icon(Icons.circle);
    }
  }

  // =======================================================
  // PAGE TITLE
  // =======================================================

  String currentPageTitle() {
    final route =
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path;

    final menu = menus.where(
      (m) => m.route == route,
    );

    if (menu.isEmpty) {
      return 'Boulder Competition';
    }

    return menu.first.label;
  }

  // =======================================================
  // USER INITIALS
  // =======================================================

  String currentUserInitials() {
    return 'GC';
  }

  // =======================================================
  // MOBILE NAVIGATION
  // =======================================================

  final mobileRoutes = [
    '/dashboard',
    '/registrations',
    '/boulders',
    '/rankings',
  ];

  int currentBottomIndex() {
    final current =
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path;

    final index =
        mobileRoutes.indexOf(current);

    if (index < 0) {
      return 0;
    }

    return index;
  }
}

// =========================================================
// SIDEBAR HEADER
// =========================================================

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,

      alignment: Alignment.centerLeft,

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      child: const Text(
        'Boulder Admin',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// =========================================================
// DRAWER HEADER
// =========================================================

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,

      alignment: Alignment.centerLeft,

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      child: const Text(
        'MENU',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// =========================================================
// BREADCRUMB
// =========================================================

class AppBreadcrumb extends StatelessWidget {
  final String current;

  const AppBreadcrumb({
    super.key,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 24),

      child: Row(
        children: [
          Text(
            'Home',

            style: TextStyle(
              color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
            ),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 8,
            ),

            child: Text('/'),
          ),

          Text(current),
        ],
      ),
    );
  }
}