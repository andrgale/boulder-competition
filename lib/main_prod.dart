import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/config/prod_env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ProdEnv.load();

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
      title: 'Boulder Competition DEV',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DEV Environment'),
        ),
        body: const Center(
          child: Text('Supabase DEV connected'),
        ),
      ),
    );
  }
}