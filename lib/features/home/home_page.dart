import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_menu.dart';
import '../../core/models/app_user.dart';

import '../../core/services/menu_service.dart';
import '../../core/services/profile_service.dart';

//import '../../shared/widgets/app_drawer.dart';

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

    // La HomePage è deprecata: reindirizza subito alla dashboard.
    // addPostFrameCallback garantisce che il context sia pronto per go_router.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/dashboard');
    });
  }

  // loadData() non viene più chiamato ma lo manteniamo
  // nel caso serva riabilitare la pagina in futuro.
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
    // Mostra uno spinner mentre go_router processa il redirect.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}