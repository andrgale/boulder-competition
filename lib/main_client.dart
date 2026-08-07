import 'package:boulder_competition/features/clienti/pages/clienti_list_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ATTENZIONE - uso esclusivamente locale/da sviluppatore.
// Questa entry point usa la SERVICE ROLE KEY del progetto Supabase che
// ospita la tabella "clienti" (non la anon key): serve per bypassare le RLS
// ed eseguire SELECT/INSERT/UPDATE/DELETE dirette sulla tabella.
// Non includere MAI questo file in una build distribuita agli utenti finali
// (nessun apk/ipa/web pubblico): va lanciato solo in locale, es.
//   flutter run -t lib/main_client.dart -d chrome
const String _adminSupabaseUrl = 'https://mgcxeqtadkxayeavzpko.supabase.co';
const String _adminServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nY3hlcXRhZGt4YXllYXZ6cGtvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDAyODc0OCwiZXhwIjoyMDk5NjA0NzQ4fQ.sKOh0l7_zEr12WDZqSMEzf0qcQGcQ5OeSrKdn8hVAPg';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _adminSupabaseUrl,
    anonKey: _adminServiceRoleKey,
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Clienti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const ClientiListPage(),
    );
  }
}
