import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_menu.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final List<AppMenu> menus;

  const MainLayout({
    super.key,
    required this.child,
    required this.menus,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              extended: true,
              selectedIndex: -1,
              destinations: menus
                  .map(
                    (m) => NavigationRailDestination(
                      icon: const Icon(Icons.circle),
                      label: Text(m.label),
                    ),
                  )
                  .toList(),
              onDestinationSelected: (index) {
                context.go(menus[index].route);
              },
            ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Boulder Competition',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.person),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),

      drawer: isDesktop
          ? null
          : Drawer(
              child: ListView(
                children: menus
                    .map(
                      (m) => ListTile(
                        title: Text(m.label),
                        onTap: () {
                          context.go(m.route);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}