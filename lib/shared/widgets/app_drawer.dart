import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../core/models/app_menu.dart';

class AppDrawer extends StatelessWidget {
  final List<AppMenu> menus;

  const AppDrawer({
    super.key,
    required this.menus,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text('MENU'),
          ),

          ...menus.map(
            (menu) => ListTile(
              title: Text(menu.label),

              onTap: () {

                // CLOSE DRAWER
                Navigator.pop(context);

                // NAVIGATION
                context.go(menu.route);
              },
            ),
          ),
        ],
      ),
    );
  }
}