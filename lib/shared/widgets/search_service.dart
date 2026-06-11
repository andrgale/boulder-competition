import 'package:supabase_flutter/supabase_flutter.dart';

import 'search_result.dart';

class SearchService {
  SearchService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Cerca in tutte le tabelle in parallelo.
  /// Restituisce al massimo [limitPerTable] risultati per tabella.
  Future<List<SearchResult>> search(
    String query, {
    int limitPerTable = 5,
  }) async {
    if (query.trim().isEmpty) return [];

    final q = query.trim();

    final results = await Future.wait([
      _searchCompetitions(q, limitPerTable),
      _searchAthletes(q, limitPerTable),
      _searchBoulders(q, limitPerTable),
      _searchAscents(q, limitPerTable),
    ]);

    return results.expand((list) => list).toList();
  }

  // ---------------------------------------------------------------------------
  // competitions → descrizione, note
  // ---------------------------------------------------------------------------
  Future<List<SearchResult>> _searchCompetitions(String q, int limit) async {
    final safe = q.replaceAll('"', '');

    final rows = await _client
        .from('competitions')
        .select('id, descrizione, note')
        .or('descrizione.ilike."%$safe%",note.ilike."%$safe%"')
        .limit(limit);

    return (rows as List).map((r) {
      final note = (r['note'] as String?) ?? '';
      return SearchResult(
        id: r['id'] as String,
        type: SearchResultType.competition,
        title: r['descrizione'] as String? ?? '—',
        subtitle: note.isNotEmpty ? note : 'Competizione',
        route: '/competitions',
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // registrations → cognome, nome, email, societa
  // Deduplicati per email (stesso atleta iscritto a più gare conta una volta).
  //
  // NOTA: il client Dart di Supabase richiede che dentro .or() i valori
  // per ilike siano racchiusi tra virgolette doppie quando contengono
  // caratteri speciali (es. %). La sintassi corretta è:
  //   or('col.ilike."%valore%",col2.ilike."%valore%"')
  // ---------------------------------------------------------------------------
  Future<List<SearchResult>> _searchAthletes(String q, int limit) async {
    // Escape apici nel query per evitare injection nella stringa PostgREST.
    final safe = q.replaceAll('"', '');

    final rows = await _client
        .from('registrations')
        .select('id, cognome, nome, email, societa')
        .or(
          'cognome.ilike."%$safe%",'
          'nome.ilike."%$safe%",'
          'email.ilike."%$safe%",'
          'societa.ilike."%$safe%"',
        )
        .limit(limit * 3); // margine per la dedup

    final seen = <String>{};
    final results = <SearchResult>[];

    for (final r in rows as List) {
      final email = (r['email'] as String?) ?? r['id'] as String;
      if (seen.contains(email)) continue;
      seen.add(email);

      final nome = '${r['cognome'] ?? ''} ${r['nome'] ?? ''}'.trim();
      results.add(SearchResult(
        id: r['id'] as String,
        type: SearchResultType.athlete,
        title: nome.isNotEmpty ? nome : email,
        subtitle: (r['societa'] as String?) ?? email,
        route: '/registrations',
      ));

      if (results.length >= limit) break;
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // boulders → colore, difficolta (cast a text), numero (cast a text)
  // ---------------------------------------------------------------------------
  Future<List<SearchResult>> _searchBoulders(String q, int limit) async {
    final safe = q.replaceAll('"', '');

    final rows = await _client
        .from('boulders')
        .select('id, numero, difficolta, colore')
        .or('colore.ilike."%$safe%"')
        .limit(limit);

    // Filtro lato client per numero/difficolta (campi numerici):
    final qLower = q.toLowerCase();
    final filtered = (rows as List).where((r) {
      final numero = r['numero']?.toString() ?? '';
      final diff = r['difficolta']?.toString() ?? '';
      final colore = (r['colore'] as String? ?? '').toLowerCase();
      return numero.contains(qLower) ||
          diff.contains(qLower) ||
          colore.contains(qLower);
    }).take(limit);

    return filtered.map((r) => SearchResult(
          id: r['id'] as String,
          type: SearchResultType.boulder,
          title: 'Boulder ${r['numero']}',
          subtitle: '${r['colore']} · difficoltà ${r['difficolta']}',
          route: '/boulders',
        )).toList();
  }

  // ---------------------------------------------------------------------------
  // ascents → ricerca per nome atleta, poi ascent correlati
  // ---------------------------------------------------------------------------
  Future<List<SearchResult>> _searchAscents(String q, int limit) async {
    final safe = q.replaceAll('"', '');

    final athleteRows = await _client
        .from('registrations')
        .select('id, cognome, nome')
        .or('cognome.ilike."%$safe%",nome.ilike."%$safe%"')
        .limit(limit);

    if ((athleteRows as List).isEmpty) return [];

    final athleteIds =
        athleteRows.map((r) => r['id'] as String).toList();

    final ascentRows = await _client
        .from('ascents')
        .select('registration_id, boulder_id, top, zone, tentativi_top, tentativi_zone')
        .inFilter('registration_id', athleteIds)
        .limit(limit);

    return (ascentRows as List).map((r) {
      final athlete = athleteRows.firstWhere(
        (a) => a['id'] == r['registration_id'],
        orElse: () => {'cognome': '?', 'nome': ''},
      );
      final nome =
          '${athlete['cognome'] ?? ''} ${athlete['nome'] ?? ''}'.trim();
      final top = (r['top'] as bool?) == true ? 'Top ✓' : 'Top ✗';
      final zone = (r['zone'] as bool?) == true ? 'Zone ✓' : 'Zone ✗';
      return SearchResult(
        id: r['registration_id'] as String,
        type: SearchResultType.ascent,
        title: 'Ascent – $nome',
        subtitle: '$top · $zone · ${r['tentativi_top']} tent.',
        route: '/ascents',
      );
    }).toList();
  }
}