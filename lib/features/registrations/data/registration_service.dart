import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/registration_model.dart';

class RegistrationService {
  final _db = Supabase.instance.client.from('registrations');

  Map<String, String> _categoryNames = {};
  // =====================================================
  // STREAM
  // =====================================================
  Stream<List<RegistrationModel>> watchRegistrations(
    String competitionId,
  ) {
    return Supabase.instance.client
        .from('registrations')
        .stream(primaryKey: ['id'])
        .handleError((error) {
          // Connessione Realtime persa temporaneamente,
          // verrà riconnessa automaticamente
          debugPrint(
            'Realtime stream error (ignorato): $error',
          );
        })
        .map((data) {
          final filtered = data
              .where(
                (e) =>
                    e['competition_id'] == competitionId,
              )
              .toList();

          filtered.sort(
            (a, b) => (a['pettorale'] ?? 0)
                .compareTo(b['pettorale'] ?? 0),
          );

          return filtered
              .map(
                (e) => _registrationFromJson(e),
              )
              .toList();
        });
  }

  Future<void> loadCategoryNames(
    String competitionId,
  ) async {
    final data = await Supabase.instance.client
        .from('categories')
        .select('id, nome')
        .eq('competition_id', competitionId);

    _categoryNames = {
      for (final row in data)
        row['id'].toString(): row['nome'].toString(),
    };
  }

  RegistrationModel _registrationFromJson(
    Map<String, dynamic> json,
  ) {
    final data = Map<String, dynamic>.from(json);

    final categoryId = data['category_id'];

    data['category_name'] = categoryId != null
        ? _categoryNames[categoryId.toString()]
        : null;

    return RegistrationModel.fromJson(data);
  }
  // =====================================================
  // GET (ordinato per pettorale ASC)
  // =====================================================
  Future<List<RegistrationModel>> getRegistrations(
    String competitionId,
  ) async {
    await loadCategoryNames(competitionId);

    final data = await _db
        .select()
        .eq('competition_id', competitionId)
        .order('pettorale', ascending: true);

    return (data as List)
        .map(
          (e) => _registrationFromJson(e),
        )
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
    String? profileId,
    String? categoryId,
    required String cognome,
    required String nome,
    required String email,
    String? societa,
    int? pettorale,
    String? sesso,
    DateTime? dataNascita,
    bool flPresente = false,
    bool flPagato = false,
    bool flOmaggio = false,
    bool isFirstTurn = false,
    bool isSecondTurn = false,
    String ownerRegistration = 'admin',
  }) async {
    final autoPettorale =
        pettorale ??
        await getNextPettorale(competitionId);

    await _db.insert({
      'competition_id': competitionId,
      'profile_id': profileId,
      'category_id': categoryId,
      'cognome': cognome,
      'nome': nome,
      'email': email,
      'societa': societa,
      'pettorale': autoPettorale,
      'sesso': sesso,
      'data_nascita': dataNascita
          ?.toIso8601String()
          .split('T')
          .first,
      'fl_presente': flPresente,
      'fl_pagato': flPagato,
      'fl_omaggio': flOmaggio,
      'is_first_turn': isFirstTurn,
      'is_second_turn': isSecondTurn,
      'owner_registration': ownerRegistration,
    });
  }
  // =====================================================
  // UPDATE
  // =====================================================
  Future<void> updateRegistration({
    required String id,
    String? categoryId,
    required String cognome,
    required String nome,
    required String email,
    String? societa,
    int? pettorale,
    String? sesso,
    DateTime? dataNascita,
    bool flPresente = false,
    bool flPagato = false,
    bool flOmaggio = false,
    bool isFirstTurn = false,
    bool isSecondTurn = false,
  }) async {
    await _db.update({
      'category_id': categoryId,
      'cognome': cognome,
      'nome': nome,
      'email': email,
      'societa': societa,
      'pettorale': pettorale,
      'sesso': sesso,
      'data_nascita': dataNascita
          ?.toIso8601String()
          .split('T')
          .first,
      'fl_presente': flPresente,
      'fl_pagato': flPagato,
      'fl_omaggio': flOmaggio,
      'is_first_turn': isFirstTurn,
      'is_second_turn': isSecondTurn,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
  // =====================================================
  // DELETE
  // =====================================================
  Future<void> deleteRegistration(String id) async {
    await _db.delete().eq('id', id);
  }

  // =====================================================
// CHECK EMAIL EXISTS
// =====================================================

  Future<bool> emailExists({
    required String competitionId,
    required String email,
    String? excludeId,
  }) async {
    var query = Supabase.instance.client
        .from('registrations')
        .select('id')
        .eq('competition_id', competitionId)
        .eq('email', email);

    // In edit escludo il record corrente
    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }

    final result = await query.limit(1);

    return result.isNotEmpty;
  }

// =====================================================
// CREATE ATHLETE USER
// =====================================================

  Future<String?> createAthleteUser({
    required String email,
    required String nome,
    required String cognome,
  }) async {
    final response =
        await Supabase.instance.client.functions.invoke(
      'create-athlete-user',
      body: {
        'email': email,
        'nome': nome,
        'cognome': cognome,
      },
    );

    if (response.status != 200) {
      throw Exception(
        response.data['error'],
      );
    }

    return response.data['profile_id'];
  }

}