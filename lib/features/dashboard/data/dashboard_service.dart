import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_model.dart';

class DashboardService {
  DashboardService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Recupera i contatori per la dashboard.
  ///
  /// Il conteggio degli atleti deduplica per email, in modo che
  /// più iscrizioni dello stesso atleta a gare diverse contino una sola volta.
  Future<DashboardStats> fetchStats() async {
    // Le quattro query vengono lanciate in parallelo per ridurre la latenza.
    final results = await Future.wait([
      _countAll('competitions'),
      _countDistinctAthletes(),
      _countAll('boulders'),
      _countAll('ascents'),
    ]);

    return DashboardStats(
      competitions: results[0],
      athletes: results[1],
      boulders: results[2],
      ascents: results[3],
    );
  }

  // ---------------------------------------------------------------------------
  // Metodi privati
  // ---------------------------------------------------------------------------

  /// Conta tutte le righe di una tabella.
  Future<int> _countAll(String table) async {
    final response = await _client
        .from(table)
        .select()
        .count(CountOption.exact);

    return response.count;
  }

  /// Conta gli atleti unici nella tabella registrations (distinct per email).
  Future<int> _countDistinctAthletes() async {
    // Supabase non espone COUNT(DISTINCT email) via client Dart; usiamo
    // una RPC o, in alternativa, recuperiamo le sole email e deduplicamo
    // lato client (accettabile poiché il volume è limitato).
    //
    // Se preferisci una RPC, crea in Supabase la funzione:
    //   CREATE OR REPLACE FUNCTION count_distinct_athletes()
    //   RETURNS bigint LANGUAGE sql AS
    //   $$ SELECT COUNT(DISTINCT email) FROM registrations; $$;
    // e sostituisci il blocco qui sotto con:
    //   final res = await _client.rpc('count_distinct_athletes');
    //   return (res as int?) ?? 0;

    final response = await _client
        .from('registrations')
        .select('email');

    final rows = response as List<dynamic>;
    final distinct = {for (final r in rows) (r as Map)['email'] as String?}
      ..remove(null);
    return distinct.length;
  }
}
