import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'core/config/prod_env.dart';
import 'core/config/env.dart';


import 'features/splash/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LOAD PROD ENV
  ProdEnv.load();

  // INIT SUPABASE
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boulder Competition PROD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const SplashPage(),
    );
  }
}