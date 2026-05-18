import 'package:flutter/material.dart';

import '../../core/models/app_menu.dart';
import '../../core/models/app_user.dart';

import '../../core/services/menu_service.dart';
import '../../core/services/profile_service.dart';

import '../../shared/widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final profileService = ProfileService();

  final menuService = MenuService();

  AppUser? user;

  List<AppMenu> menus = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    try {
      user = await profileService.getCurrentProfile();

      menus = await menuService.getMenus();
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boulder Competition'),
      ),

      drawer: AppDrawer(
        menus: menus,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Benvenuto ${user?.nome ?? ''} ${user?.cognome ?? ''}',

              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Menu disponibili:',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,

              children: menus
                  .map(
                    (e) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(e.label),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}