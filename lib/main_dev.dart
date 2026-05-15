import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/config/dev_env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carica configurazione DEV
  DevEnv.load();

  // Inizializza Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // ================================
  // TEST CONNESSIONE DATABASE
  // ================================

  // final response =
  //     await Supabase.instance.client
  //         .from('roles')
  //         .select();

  // print(response);
  final response = await Supabase.instance.client.auth.signInWithPassword(
    email: 'andrea.galeazzo@virgilio.it',
    password: 'A3103g.bks',
  );

  print(response.user);

  final roles =
      await Supabase.instance.client
          .from('roles')
          .select();

  print(roles);

  // ================================

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