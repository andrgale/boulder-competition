import 'dart:async';

import 'package:boulder_competition/core/services/email_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/security_profile_model.dart';
//import 'package:flutter/material.dart';
//import '../models/role_model.dart';

class SecurityProfileService {
      SecurityProfileService(this._supabase, this._emailService);

  final SupabaseClient _supabase;
  final EmailService _emailService;

 // final supabase = Supabase.instance.client;

  // =========================================================
  // PROFILES
  // =========================================================

  Future<List<SecurityProfileModel>> getProfiles() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .order('cognome')
        .order('nome');

    return response
        .map<SecurityProfileModel>((row) => SecurityProfileModel.fromMap(row))
        .toList();
  }

  // =========================================================
  // UPDATE PASSWORD CHANGED
  // =========================================================

  Future<void> updatePasswordChanged({
    required String profileId,
    required bool passwordChanged,
  }) async {
    await _supabase
        .from('profiles')
        .update({
          'password_changed': passwordChanged,
        })
        .eq('id', profileId);
  }

  // =====================================================
  // DELETE ATHLETE USER
  // =====================================================
  //
  // NOTA: functions.invoke() del client Supabase Dart lancia
  // automaticamente una FunctionException se la Edge Function
  // risponde con status != 2xx. Il controllo "res.status != 200"
  // non scatta mai in quel caso perché il throw avviene prima,
  // dentro invoke() stesso — quindi qui catturiamo direttamente
  // FunctionException per leggere il messaggio di errore corretto.

  Future<void> deleteAthleteUser({
    required String profileId,
  }) async {
    try {
      final res = await _supabase.functions.invoke(
        'delete-athlete-user',
        body: {'profileId': profileId},
      );

 //     debugPrint('DELETE RESPONSE: ${res.data}');

      final data = res.data;
      if (data is Map && data['success'] != true) {
        throw Exception(data['error'] ?? 'Eliminazione non riuscita');
      }
    } on FunctionException catch (e) {
      // e.details contiene il body JSON ritornato dalla function,
      // dove c'è il campo "error" che abbiamo impostato lato Deno.
      final message = (e.details is Map)
          ? (e.details['error'] ?? e.toString())
          : e.toString();
      throw Exception(message);
    }
  }

  Future<bool> isLastAdmin(String profileId) async {
    final adminRole = await _supabase
        .from('roles')
        .select('id')
        .eq('code', 'admin')
        .single();

    final adminRoleId = adminRole['id'];

    final myRoles = await _supabase
        .from('user_roles')
        .select('role_id')
        .eq('profile_id', profileId);

    final isAdmin = myRoles.any((r) => r['role_id'] == adminRoleId);
    if (!isAdmin) return false;

    final allAdmins = await _supabase
        .from('user_roles')
        .select('profile_id')
        .eq('role_id', adminRoleId);

    return allAdmins.length <= 1;
  }

  // =====================================================
  // CREATE ATHLETE USER
  // =====================================================

  Future<String?> registerAthlete({
    required String email,
    required String nome,
    required String cognome,
  }) async {
    final response = await _supabase.functions.invoke(
      'create-athlete-user',
      body: {
        'email': email,
        'nome': nome,
        'cognome': cognome,
        'issueRegistrationToken': false, // esplicito, per chiarezza
      },
    );

    final data = response.data as Map<String, dynamic>;
    final profileId = data['profile_id'] as String?;

    // l'admin è già loggato: send-template-email userà il controllo di ruolo,
    // nessun registrationToken necessario
    unawaited(_emailService.sendTemplateEmail(
      email: email,
      toName: '$nome $cognome'.trim(),
      templateCode: 'REG_ATLETA',
      variables: _emailService.buildEmailVariables({
        'NOME_ATLETA': nome,
        'COGNOME_ATLETA': cognome,
        'SENDERNAME': 'BoulderCompetition',
      }),
    ));

    return profileId;
  }



  // =========================================================
  // USER ROLES
  // =========================================================

  Future<List<String>> getProfileRoleIds(String profileId) async {
    final rows = await _supabase
        .from('user_roles')
        .select('role_id')
        .eq('profile_id', profileId);

    return rows.map<String>((r) => r['role_id'] as String).toList();
  }

  Future<void> setProfileRoles({
    required String profileId,
    required List<String> roleIds,
  }) async {
    try {
      await _supabase.rpc('set_profile_roles', params: {
        'p_profile_id': profileId,
        'p_role_ids': roleIds,
      });
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }
}
