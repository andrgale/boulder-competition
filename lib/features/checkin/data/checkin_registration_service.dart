import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/checkin_registration_model.dart';

class CheckinRegistrationService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // REALTIME STREAM
  // =========================================================

  Stream<List<CheckinRegistrationModel>> watchRegistrations(
    String competitionId,
  ) {
    return supabase
        .from('registrations')
        .stream(primaryKey: ['id'])
        .handleError((error) {
          debugPrint(
            'Checkin registrations stream error (ignorato): $error',
          );
        })
        .map((data) {
          final filtered = data
              .where((e) => e['competition_id'] == competitionId)
              .toList();

          filtered.sort(
            (a, b) =>
                (a['pettorale'] ?? 0).compareTo(b['pettorale'] ?? 0),
          );

          return filtered
              .map((e) => CheckinRegistrationModel.fromJson(e))
              .toList();
        });
  }

  // =========================================================
  // GET ALL
  // =========================================================

  Future<List<CheckinRegistrationModel>> getRegistrations(
    String competitionId,
  ) async {
    final data = await supabase
        .from('registrations')
        .select()
        .eq('competition_id', competitionId)
        .order('pettorale', ascending: true);

    return data
        .map<CheckinRegistrationModel>(
          (e) => CheckinRegistrationModel.fromJson(e),
        )
        .toList();
  }

  // =========================================================
  // TOGGLE FL_PRESENTE
  // =========================================================

  Future<void> togglePresente({
    required String id,
    required bool currentValue,
  }) async {
    await supabase.from('registrations').update({
      'fl_presente': !currentValue,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // =========================================================
  // TOGGLE FL_PAGATO
  // =========================================================

  Future<void> togglePagato({
    required String id,
    required bool currentValue,
  }) async {
    await supabase.from('registrations').update({
      'fl_pagato': !currentValue,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // =========================================================
  // TOGGLE FL_OMAGGIO
  // =========================================================

  Future<void> toggleOmaggio({
    required String id,
    required bool currentValue,
  }) async {
    await supabase.from('registrations').update({
      'fl_omaggio': !currentValue,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}
