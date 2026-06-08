import 'package:supabase_flutter/supabase_flutter.dart';

import '../../athlete/models/athlete_boulder_model.dart';
import '../../athlete/models/athlete_boulders_page_data.dart';
import '../../athlete/models/athlete_competition_model.dart';

class AscentsBouldersService {
  final supabase = Supabase.instance.client;

  // =====================================================
  // LOAD PAGINA PER REGISTRATION
  // =====================================================

  Future<AthleteBouldersPageData>
      loadPageByRegistration(
    String registrationId,
  ) async {
    // ===============================
    // REGISTRAZIONE
    // ===============================

    final registration =
        await supabase
            .from('registrations')
            .select()
            .eq(
              'id',
              registrationId,
            )
            .single();

    final competitionId =
        registration['competition_id']
            as String;

    // ===============================
    // COMPETIZIONE
    // ===============================

    final competitionRow =
        await supabase
            .from('competitions')
            .select()
            .eq(
              'id',
              competitionId,
            )
            .single();

    final competition =
        AthleteCompetitionModel.fromMap(
      competitionRow,
    );

    // ===============================
    // BOULDERS
    // ===============================

    final boulders = await supabase
        .from('boulders')
        .select()
        .eq(
          'competition_id',
          competitionId,
        )
        .order(
          'numero',
          ascending: true,
        );

    // ===============================
    // ASCENTS
    // ===============================

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

    // ===============================
    // MODEL
    // ===============================

    final List<AthleteBoulderModel>
        items =
        boulders.map<
            AthleteBoulderModel>(
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
        );
      },
    ).toList();

    final completedBoulders =
        items
            .where((b) => b.top)
            .length;

    return AthleteBouldersPageData(
      competition: competition,
      registrationId: registrationId,
      boulders: items,
      completedBoulders:
          completedBoulders,
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