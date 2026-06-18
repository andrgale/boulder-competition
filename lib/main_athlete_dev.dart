import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/dev_env.dart';
import 'core/config/env.dart';

import 'core/routing/app_router.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_mode.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // LOAD DEV ENV
//   DevEnv.load();

//   // INIT SUPABASE
//   await Supabase.initialize(
//     url: Env.supabaseUrl,
//     anonKey: Env.supabaseAnonKey,
//   );

//   runApp(const MyApp());
// }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DevEnv.load();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  AppConfig.mode = AppMode.athlete;

  runApp(const AthleteApp());
}

class AthleteApp extends StatelessWidget {
  const AthleteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'Athlete Boulder',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('it'),
        Locale('en'),
      ],
      title: 'Boulder Competition DEV',

      debugShowCheckedModeBanner: false,

      routerConfig: appRouter,

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
    );
  }
}
