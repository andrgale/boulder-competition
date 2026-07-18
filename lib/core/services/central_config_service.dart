import 'package:boulder_competition/core/models/client_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class CentralConfigService {
  static final SupabaseClient _central = SupabaseClient(
    'https://mgcxeqtadkxayeavzpko.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nY3hlcXRhZGt4YXllYXZ6cGtvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQwMjg3NDgsImV4cCI6MjA5OTYwNDc0OH0.cHEhmVStJk-2EQYRZniD0tdCx2pYh29FduooBcMHGYI',
  );

  static Future<ClientConfig> authenticate({
    required String clientId,
    required String password,
  }) async {
    final result = await _central.rpc('verify_client', params: {
      'p_codice': clientId,
      'p_password': password,
    });

    final rows = result as List;
    if (rows.isEmpty) {
      throw Exception('Codice cliente o password non validi');
    }

    final data = rows.first as Map<String, dynamic>;
    return ClientConfig(
      clientId: data['codice_cliente'] as String,
      description: data['descrizione_cliente'] as String? ?? '',
      supabaseUrl: data['supabase_url'] as String,
      supabaseAnonKey: data['supabase_anon_key'] as String,
    );
  }
}