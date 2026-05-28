import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/registration_model.dart';

class RegistrationService {
  final _db = Supabase.instance.client.from('registrations');

  // =====================================================
  // STREAM
  // =====================================================
  Stream<List<RegistrationModel>> watchRegistrations(
    String competitionId,
  ) {
    return Supabase.instance.client
        .from('registrations')
        .stream(primaryKey: ['id'])
        .map((data) {
      final filtered = data
          .where((e) =>
              e['competition_id'] == competitionId)
          .toList();

      filtered.sort((a, b) =>
          (a['pettorale'] ?? 0)
              .compareTo(b['pettorale'] ?? 0));

      return filtered
          .map((e) => RegistrationModel.fromJson(e))
          .toList();
    });
  }

  // =====================================================
  // GET (ordinato per pettorale ASC)
  // =====================================================
  Future<List<RegistrationModel>> getRegistrations(
    String competitionId,
  ) async {
    final data = await _db
        .select()
        .eq('competition_id', competitionId)
        .order('pettorale', ascending: true);

    return (data as List)
        .map((e) => RegistrationModel.fromJson(e))
        .toList();
  }

  // =====================================================
  // NEXT PETTORALE (MAX + 1)
  // =====================================================
  Future<int> getNextPettorale(
    String competitionId,
  ) async {
    final res = await Supabase.instance.client
        .from('registrations')
        .select('pettorale')
        .eq('competition_id', competitionId)
        .order('pettorale', ascending: false)
        .limit(1)
        .maybeSingle();

    final max = res?['pettorale'] as int?;

    return (max ?? 0) + 1;
  }

  // =====================================================
  // CREATE
  // =====================================================
  Future<void> createRegistration({
    required String competitionId,
    required String cognome,
    required String nome,
    required String email,
    String? societa,
    int? pettorale,
    String? sesso,
    bool flPresente = false,
    bool flPagato = false,
    bool flOmaggio = false,
  }) async {
    final autoPettorale =
        pettorale ??
        await getNextPettorale(competitionId);

    await _db.insert({
      'competition_id': competitionId,
      'cognome': cognome,
      'nome': nome,
      'email': email,
      'societa': societa,
      'pettorale': autoPettorale,
      'sesso': sesso,
      'fl_presente': flPresente,
      'fl_pagato': flPagato,
      'fl_omaggio': flOmaggio,
    });
  }

  // =====================================================
  // UPDATE
  // =====================================================
  Future<void> updateRegistration({
    required String id,
    required String cognome,
    required String nome,
    required String email,
    String? societa,
    int? pettorale,
    String? sesso,
    bool flPresente = false,
    bool flPagato = false,
    bool flOmaggio = false,
  }) async {
    await _db.update({
      'cognome': cognome,
      'nome': nome,
      'email': email,
      'societa': societa,
      'pettorale': pettorale,
      'sesso': sesso,
      'fl_presente': flPresente,
      'fl_pagato': flPagato,
      'fl_omaggio': flOmaggio,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // =====================================================
  // DELETE
  // =====================================================
  Future<void> deleteRegistration(String id) async {
    await _db.delete().eq('id', id);
  }
}