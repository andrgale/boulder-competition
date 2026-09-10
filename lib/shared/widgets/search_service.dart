import 'package:supabase_flutter/supabase_flutter.dart';

import 'search_result.dart';

class SearchService {
  SearchService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

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
  // competitions → /competitions (lista, nessun extra necessario)
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
        // Rotta esistente nel router — nessun extra necessario
        route: '/competitions',
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // registrations → /competitions/:id/registrations
  // Recuperiamo anche competition_id per costruire la rotta corretta.
  // Deduplicati per email.
  // ---------------------------------------------------------------------------
  Future<List<SearchResult>> _searchAthletes(String q, int limit) async {
    final safe = q.replaceAll('"', '');

    // Recuperiamo anche competition_id per costruire la rotta corretta.
    // Il nome gara e i flag/limiti di controllo iscrizioni e turni vengono
    // caricati con una seconda query, per applicarli correttamente nella
    // pagina di destinazione (RegistrationsPage).
    final rows = await _client
        .from('registrations')
        .select('id, competition_id, cognome, nome, email, societa')
        .or(
          'cognome.ilike."%$safe%",'
          'nome.ilike."%$safe%",'
          'email.ilike."%$safe%",'
          'societa.ilike."%$safe%"',
        )
        .limit(limit * 3);

    if ((rows as List).isEmpty) return [];

    // Recupera i dati delle competizioni coinvolte in un'unica query
    final competitionIds = rows
        .map((r) => r['competition_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final compRows = competitionIds.isNotEmpty
        ? await _client
            .from('competitions')
            // ← aggiunte le colonne necessarie ai controlli iscrizioni/turni
            .select(
                'id, descrizione, dt_gara, fl_iscrizioni_chiuse, nr_max_registrations, '
                'is_turn, nr_max_first_turn, nr_max_second_turn')
            .inFilter('id', competitionIds)
        : <Map<String, dynamic>>[];

    // ← mappiamo l'intera riga della competizione, non solo la descrizione
    final compMap = {
      for (final c in compRows as List) c['id'] as String: c,
    };

    final seen = <String>{};
    final results = <SearchResult>[];

    for (final r in rows) {
      final email = (r['email'] as String?) ?? r['id'] as String;
      if (seen.contains(email)) continue;
      seen.add(email);

      final nome = '${r['cognome'] ?? ''} ${r['nome'] ?? ''}'.trim();
      final competitionId = r['competition_id'] as String? ?? '';
      final comp = compMap[competitionId];
      final competitionName = comp?['descrizione'] as String? ?? '';
      final competitionDate = comp?['dt_gara'] as String? ?? '';
      final flIscrizioniChiuse =
          comp?['fl_iscrizioni_chiuse'] as bool? ?? false;
      final nrMaxRegistrations =
          comp?['nr_max_registrations'] as int? ?? 0;
      final isTurn = comp?['is_turn'] as bool? ?? false; // ← aggiunto
      final nrMaxFirstTurn =
          comp?['nr_max_first_turn'] as int? ?? 0; // ← aggiunto
      final nrMaxSecondTurn =
          comp?['nr_max_second_turn'] as int? ?? 0; // ← aggiunto

      results.add(SearchResult(
        id: r['id'] as String,
        type: SearchResultType.athlete,
        title: nome.isNotEmpty ? nome : email,
        subtitle: (r['societa'] as String?) ?? email,
        route: '/competitions/$competitionId/registrations',
        extra: {
          'competitionId': competitionId,
          'competitionName': competitionName,
          'competitionDate': competitionDate,
          'flIscrizioniChiuse': flIscrizioniChiuse,
          'nrMaxRegistrations': nrMaxRegistrations,
          'isTurn': isTurn, // ← aggiunto
          'nrMaxFirstTurn': nrMaxFirstTurn, // ← aggiunto
          'nrMaxSecondTurn': nrMaxSecondTurn, // ← aggiunto
        },
      ));

      if (results.length >= limit) break;
    }

    return results;
  } 
  // ---------------------------------------------------------------------------
  // boulders → /competitions (non esiste /boulders standalone)
  // Recuperiamo competition_id per navigare alla gara giusta.
  // ---------------------------------------------------------------------------
  Future<List<SearchResult>> _searchBoulders(String q, int limit) async {
    final safe = q.replaceAll('"', '');

    final rows = await _client
        .from('boulders')
        .select('id, competition_id, numero, difficolta, colore')
        .or('colore.ilike."%$safe%"')
        .limit(limit);

    final qLower = q.toLowerCase();
    final filtered = (rows as List).where((r) {
      final numero = r['numero']?.toString() ?? '';
      final diff = r['difficolta']?.toString() ?? '';
      final colore = (r['colore'] as String? ?? '').toLowerCase();
      return numero.contains(qLower) ||
          diff.contains(qLower) ||
          colore.contains(qLower);
    }).toList();

    if (filtered.isEmpty) return [];

    // Recupera i nomi delle competizioni in un'unica query
    final competitionIds = filtered
        .map((r) => r['competition_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final compRows = competitionIds.isNotEmpty
        ? await _client
            .from('competitions')
            .select('id, descrizione')
            .inFilter('id', competitionIds)
        : <Map<String, dynamic>>[];

    final compMap = {
      for (final c in compRows as List)
        c['id'] as String: c['descrizione'] as String? ?? '',
    };

    return filtered.take(limit).map((r) {
      final competitionId = r['competition_id'] as String? ?? '';
      final competitionName = compMap[competitionId] ?? '';
      return SearchResult(
        id: r['id'] as String,
        type: SearchResultType.boulder,
        title: 'Boulder ${r['numero']}',
        subtitle: '${r['colore']} · difficoltà ${r['difficolta']}',
        route: '/competitions/$competitionId/boulders',
        extra: {
          'competitionId': competitionId,
          'competitionName': competitionName,
        },
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // ascents → /ascents-boulders (richiede registrationId e athleteName)
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
        .select(
            'registration_id, boulder_id, top, zone, tentativi_top, tentativi_zone')
        .inFilter('registration_id', athleteIds)
        .limit(limit);

    return (ascentRows as List).map((r) {
      final athlete = athleteRows.firstWhere(
        (a) => a['id'] == r['registration_id'],
        orElse: () => {'cognome': '?', 'nome': '', 'id': ''},
      );
      final nome =
          '${athlete['cognome'] ?? ''} ${athlete['nome'] ?? ''}'.trim();
      final registrationId = r['registration_id'] as String;
      final top = (r['top'] as bool?) == true ? 'Top ✓' : 'Top ✗';
      final zone = (r['zone'] as bool?) == true ? 'Zone ✓' : 'Zone ✗';

      return SearchResult(
        id: registrationId,
        type: SearchResultType.ascent,
        title: 'Ascent – $nome',
        subtitle: '$top · $zone · ${r['tentativi_top']} tent.',
        // Rotta esistente nel router con extra Map richiesto
        route: '/ascents-boulders',
        extra: {
          'registrationId': registrationId,
          'athleteName': nome,
        },
      );
    }).toList();
  }
}
