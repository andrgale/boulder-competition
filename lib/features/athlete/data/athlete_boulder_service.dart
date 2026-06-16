import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/athlete_boulder_model.dart';
import '../models/athlete_boulders_page_data.dart';
import '../models/athlete_competition_model.dart';

class AthleteBoulderService {
  final supabase = Supabase.instance.client;

  // =====================================================
  // GARA APERTA
  // =====================================================

  Future<AthleteCompetitionModel?> getOpenCompetition() async {
    final response = await supabase
        .from('competitions')
        .select()
        .eq('fl_gara_chiusa', false)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return AthleteCompetitionModel.fromMap(
      response,
    );
  }

  // =====================================================
  // REGISTRATION ATLETA
  // =====================================================

  Future<Map<String, dynamic>?> getAthleteRegistration(
    String competitionId,
  ) async {
    final authUser = supabase.auth.currentUser;

    if (authUser == null) {
      return null;
    }

    final profile = await supabase
        .from('profiles')
        .select('id')
        .eq(
          'auth_user_id',
          authUser.id,
        )
        .maybeSingle();

    if (profile == null) {
      return null;
    }

    return await supabase
        .from('registrations')
        .select()
        .eq(
          'competition_id',
          competitionId,
        )
        .eq(
          'profile_id',
          profile['id'],
        )
        .eq(
          'fl_presente',
          true,
        )

        .maybeSingle();
  }

  // =====================================================
  // LOAD PAGINA
  // =====================================================

  Future<AthleteBouldersPageData> loadPage() async {
    final competition =
        await getOpenCompetition();

    if (competition == null) {
      return AthleteBouldersPageData(
        competition: null,
        registrationId: null,
        boulders: [],
        completedBoulders: 0,
      );
    }

    final registration =
        await getAthleteRegistration(
      competition.id,
    );

    if (registration == null) {
      throw Exception(
        'Atleta non iscritto alla gara o senza check-in',
      );
    }

    final registrationId =
        registration['id'] as String;

    // ===================================================
    // BOULDERS
    // ===================================================

    final boulders = await supabase
        .from('boulders')
        .select()
        .eq(
          'competition_id',
          competition.id,
        )
        .eq(
          'is_finale',
          false,
        )
        .order(
          'numero',
          ascending: true,
        );

    // ===================================================
    // ASCENTS
    // ===================================================

    final ascents = await supabase
        .from('ascents')
        .select(
          'boulder_id, top',
        )
        .eq(
          'registration_id',
          registrationId,
        );

    final Map<String, bool> ascentMap = {
      for (final ascent in ascents)
        ascent['boulder_id'] as String:
            ascent['top'] == true,
    };

    // ===================================================
    // BUILD MODEL
    // ===================================================

    final List<AthleteBoulderModel> items =
        boulders.map< AthleteBoulderModel >(
      (boulder) {
        return AthleteBoulderModel(
          boulderId:
              boulder['id'] as String,
          numero:
              boulder['numero'] ?? 0,
          difficolta:
              boulder['difficolta'] ?? 0,
          colore:
              boulder['colore'],
          top:
              ascentMap[
                    boulder['id']
                        as String
                  ] ??
                  false,
          zone: boulder['zone'] ?? false,
          tentativiTop: boulder['tentativi_top'] ?? 0,
          tentativiZone: boulder['tentativi_zone'] ?? 0,
        
        );
      },
    ).toList();
    
    final completedBoulders =
    items.where((b) => b.top).length;

    return AthleteBouldersPageData(
      competition: competition,
      registrationId: registrationId,
      boulders: items,
      completedBoulders: completedBoulders,
    );
  }

  // =====================================================
  // INSERIMENTO TOP
  // =====================================================

  Future<void> markAsDone({
    required String registrationId,
    required String boulderId,
  }) async {
    await supabase
        .from('ascents')
        .upsert({
      'registration_id':
          registrationId,
      'boulder_id': boulderId,
      'top': true,
      'zone': true,
      'tentativi_top': 1,
      'tentativi_zone': 1,
    });
  }

  // =====================================================
  // ELIMINAZIONE TOP
  // =====================================================

  Future<void> removeAscent({
    required String registrationId,
    required String boulderId,
  }) async {
    await supabase
        .from('ascents')
        .delete()
        .eq(
          'registration_id',
          registrationId,
        )
        .eq(
          'boulder_id',
          boulderId,
        );
  }
}