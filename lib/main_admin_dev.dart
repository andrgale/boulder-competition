import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

//import 'core/config/prod_env.dart';
import 'core/config/env.dart';

import 'core/config/dev_env.dart';

import 'config/app_mode.dart';

import 'core/routing/app_router.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // LOAD DEV ENV
//   ProdEnv.load();

//   // INIT SUPABASE
//   await Supabase.initialize(
//     url: Env.supabaseUrl,
//     anonKey: Env.supabaseAnonKey,
//   );

//   runApp(const MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 // ProdEnv.load();
    DevEnv.load();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  AppConfig.mode = AppMode.admin;


  runApp(const AdminApp());
}
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'Boulder Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Boulder Competition Prod',

      debugShowCheckedModeBanner: false,

      routerConfig: appRouter,

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
    );
  }
}