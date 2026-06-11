import 'package:supabase_flutter/supabase_flutter.dart';

import '../../athlete/models/athlete_boulder_model.dart';

// modello già esistente che usi nella pagina lista
class AscentsPageData {
  final dynamic competition;
  final List<AthleteBoulderModel> boulders;

  AscentsPageData({required this.competition, required this.boulders});
}

class AscentsBouldersService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // LOAD PAGE BY REGISTRATION
  // =========================================================

  Future<AscentsPageData> loadPageByRegistration(
    String registrationId,
  ) async {
    // registrazione + competizione
    final reg = await supabase
        .from('registrations')
        .select('competition_id, competitions(id, descrizione)')
        .eq('id', registrationId)
        .single();

    final competitionId = reg['competition_id'] as String;
    final competition = reg['competitions'];

    // boulder della competizione
    final bouldersRaw = await supabase
        .from('boulders')
        .select()
        .eq('competition_id', competitionId)
        .order('numero', ascending: true);

    // ascents dell'atleta
    final ascentsRaw = await supabase
        .from('ascents')
        .select()
        .eq('registration_id', registrationId);

    final ascentMap = <String, Map<String, dynamic>>{};
    for (final a in ascentsRaw) {
      ascentMap[a['boulder_id'] as String] = a;
    }

    final boulders = bouldersRaw.map<AthleteBoulderModel>((b) {
      final a = ascentMap[b['id']];
      return AthleteBoulderModel(
        boulderId: b['id'],
        numero: b['numero'] ?? 0,
        difficolta: b['difficolta'] ?? 0,
        colore: b['colore'],
        top: a?['top'] ?? false,
        zone: a?['zone'] ?? false,
        tentativiTop: a?['tentativi_top'] ?? 0,
        tentativiZone: a?['tentativi_zone'] ?? 0,
      );
    }).toList();

    return AscentsPageData(competition: competition, boulders: boulders);
  }

  // =========================================================
  // GET SINGLE ASCENT (per pre-popolare il form)
  // =========================================================

  Future<Map<String, dynamic>?> getAscent({
    required String registrationId,
    required String boulderId,
  }) async {
    final result = await supabase
        .from('ascents')
        .select()
        .eq('registration_id', registrationId)
        .eq('boulder_id', boulderId)
        .maybeSingle();

    return result;
  }

  // =========================================================
  // UPSERT ASCENT (insert o update)
  // =========================================================

  Future<void> upsertAscent({
    required String registrationId,
    required String boulderId,
    required bool top,
    required bool zone,
    required int tentativiTop,
    required int tentativiZone,
  }) async {
    await supabase.from('ascents').upsert(
      {
        'registration_id': registrationId,
        'boulder_id': boulderId,
        'top': top,
        'zone': zone,
        'tentativi_top': tentativiTop,
        'tentativi_zone': tentativiZone,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'registration_id,boulder_id',
    );
  }

  // =========================================================
  // MARK AS DONE (metodo semplice esistente)
  // =========================================================

  Future<void> markAsDone({
    required String registrationId,
    required String boulderId,
  }) async {
    await upsertAscent(
      registrationId: registrationId,
      boulderId: boulderId,
      top: true,
      zone: true,
      tentativiTop: 1,
      tentativiZone: 1,
    );
  }

  // =========================================================
  // REMOVE ASCENT
  // =========================================================

  Future<void> removeAscent({
    required String registrationId,
    required String boulderId,
  }) async {
    await supabase
        .from('ascents')
        .delete()
        .eq('registration_id', registrationId)
        .eq('boulder_id', boulderId);
  }
}
