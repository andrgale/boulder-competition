import 'package:boulder_competition/features/competitions/models/competition_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';


class AthleteCheckInScanService {
  final supabase = Supabase.instance.client;


  Map<String, String>? parseQrPayload(String qr) {
    try {
      final json = jsonDecode(qr);

      if (json is! Map<String, dynamic>) {
        return null;
      }

      final competitionId = json['competition_id'];

      if (competitionId is! String || competitionId.isEmpty) {
        return null;
      }

      return {
        'competition_id': competitionId,
      };
    } catch (_) {
      return null;
    }
  }

  Future<CheckInResult> performCheckIn({
    required String competitionId,
  }) async {
    try {
      //--------------------------------------------------
      // Competition
      //--------------------------------------------------

      final competitionMap = await supabase
          .from('competitions')
          .select()
          .eq('id', competitionId)
          .single();

      final competition =
          CompetitionModel.fromMap(competitionMap);

      if (competition.flGaraChiusa) {
        return CheckInResult.error(
          'Gara terminata, impossibile fare il check-in.',
        );
      }

      //--------------------------------------------------
      // Utente autenticato
      //--------------------------------------------------

      final user = supabase.auth.currentUser;

      if (user == null) {
        return CheckInResult.error(
          'Utente non autenticato.',
        );
      }

      //--------------------------------------------------
      // Ricerca profilo
      //--------------------------------------------------

      Map<String, dynamic>? profile =
          await supabase
              .from('profiles')
              .select()
              .eq('auth_user_id', user.id)
              .maybeSingle();

      profile ??= await supabase
          .from('profiles')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      if (profile == null) {
        return CheckInResult.error(
          'Profilo atleta non trovato.',
        );
      }

      final profileId = profile['id'] as String;

      //--------------------------------------------------
      // Registrazione
      //--------------------------------------------------

      final registration = await supabase
          .from('registrations')
          .select()
          .eq('competition_id', competitionId)
          .eq('profile_id', profileId)
          .maybeSingle();

      if (registration == null) {
        return CheckInResult.error(
          'Non sei iscritto alla gara, impossibile fare il check-in.',
        );
      }

      if ((registration['fl_presente'] as bool?) ?? false) {
        return CheckInResult.error(
          'Check-in già effettuato.',
        );
      }

      //--------------------------------------------------
      // Update
      //--------------------------------------------------

      await supabase
          .from('registrations')
          .update({
            'fl_presente': true,
          })
          .eq('id', registration['id']);

      return CheckInResult.success(
        'Check-in effettuato con successo.',
      );
    } catch (e) {
      return CheckInResult.error(
        'Errore durante il check-in.\n$e',
      );
    }
  }
}

class CheckInResult {
  final bool success;
  final String message;

  const CheckInResult({
    required this.success,
    required this.message,
  });

  factory CheckInResult.success(String message) {
    return CheckInResult(
      success: true,
      message: message,
    );
  }

  factory CheckInResult.error(String message) {
    return CheckInResult(
      success: false,
      message: message,
    );
  }
}