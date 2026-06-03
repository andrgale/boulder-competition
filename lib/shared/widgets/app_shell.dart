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
      var loadedMenus =
          await menuService.getMenus();

      loadedMenus = loadedMenus.where((m) {
        if (!m.visible) {
          return false;
        }

        if (Responsive.isMobile(context)) {
          return m.mobile;
        }

        return m.desktop;
      }).toList();

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

    final isMobile =
        Responsive.isMobile(context);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),

      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    const _DrawerHeader(),

                    Expanded(
                      child: ListView(
                        padding:
                            const EdgeInsets.all(12),
                        children:
                            buildMenuTiles(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,

      body: Row(
        children: [
          // =================================================
          // SIDEBAR
          // =================================================

          if (!isMobile)
            Container(
              width: isDesktop ? 280 : 230,

              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),

              child: SafeArea(
                child: Column(
                  children: [
                    const _SidebarHeader(),

                    Expanded(
                      child: ListView(
                        padding:
                            const EdgeInsets.all(12),
                        children:
                            buildMenuTiles(context),
                      ),
                    ),

                    const Divider(height: 1),

                    Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                Colors.blue.shade100,
                            child: Text(
                              currentUserInitials(),
                              style: TextStyle(
                                color:
                                    Colors.blue.shade900,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Text(
                                  'Andrea Galeazzo',
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Administrator',
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // =================================================
          // MAIN CONTENT
          // =================================================

          Expanded(
            child: Column(
              children: [
                // =============================================
                // TOP BAR
                // =============================================

                Container(
                  height: 72,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),

                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E7EB),
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

                      Expanded(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              currentPageTitle(),
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              'Boulder Competition Management',
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!isMobile) ...[
                        const SizedBox(width: 24),

                        SizedBox(
                          width: 300,
                          height: 42,

                          child: TextField(
                            decoration:
                                InputDecoration(
                              hintText:
                                  'Search...',
                              filled: true,
                              fillColor:
                                  const Color(
                                0xFFF3F4F6,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                                borderSide:
                                    BorderSide.none,
                              ),
                              prefixIcon:
                                  const Icon(
                                Icons.search,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(width: 12),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none,
                        ),
                      ),
                    ],
                  ),
                ),

                // =============================================
                // CONTENT
                // =============================================

                Expanded(
                  child: Container(
                    width: double.infinity,

                    padding:
                        EdgeInsets.symmetric(
                      horizontal:
                          isDesktop ? 40 : 20,
                      vertical: 32,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        AppBreadcrumb(
                          current:
                              currentPageTitle(),
                        ),

                        const SizedBox(height: 24),

                        // IMPORTANTISSIMO:
                        // niente Expanded qui

                        Flexible(
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ),

                // =============================================
                // MOBILE NAVIGATION
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

  List<Widget> buildMenuTiles(
    BuildContext context,
  ) {
    return menus.map((menu) {
      final selected =
          GoRouterState.of(context).uri.path ==
              menu.route;

      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        child: Material(
          color: selected
              ? Colors.blue.shade50
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            leading: buildMenuIcon(menu.icon),
            title: Text(menu.label),
            selected: selected,
            selectedColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onTap: () {
              context.go(menu.route);
            },
          ),
        ),
      );
    }).toList();
  }

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

  String currentUserInitials() {
    return 'AG';
  }

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

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.centerLeft,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Boulder Admin',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Competition Platform',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      alignment: Alignment.centerLeft,
      padding:
          const EdgeInsets.symmetric(
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

class AppBreadcrumb extends StatelessWidget {
  final String current;

  const AppBreadcrumb({
    super.key,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Home',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Padding(
          padding:
              EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Icon(
            Icons.chevron_right,
            size: 18,
            color: Colors.grey,
          ),
        ),
        Flexible(
          child: Text(
            current,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}