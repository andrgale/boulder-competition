import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/security_profile_model.dart';
//import 'package:flutter/material.dart';
//import '../models/role_model.dart';

class SecurityProfileService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // PROFILES
  // =========================================================

  Future<List<SecurityProfileModel>> getProfiles() async {
    final response = await supabase
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
    await supabase
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
      final res = await supabase.functions.invoke(
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

  // =====================================================
  // CREATE ATHLETE USER
  // =====================================================

  Future<String?> createAthleteUser({
    required String email,
    required String nome,
    required String cognome,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'create-athlete-user',
        body: {
          'email': email,
          'nome': nome,
          'cognome': cognome,
        },
      );

      return response.data['profile_id'];
    } on FunctionException catch (e) {
      final message = (e.details is Map)
          ? (e.details['error'] ?? e.toString())
          : e.toString();
      throw Exception(message);
    }
  }

  // =========================================================
  // USER ROLES
  // =========================================================

  Future<List<String>> getProfileRoleIds(String profileId) async {
    final rows = await supabase
        .from('user_roles')
        .select('role_id')
        .eq('profile_id', profileId);

    return rows.map<String>((r) => r['role_id'] as String).toList();
  }

  Future<void> setProfileRoles({
    required String profileId,
    required List<String> roleIds,
  }) async {
    await supabase
        .from('user_roles')
        .delete()
        .eq('profile_id', profileId);

    if (roleIds.isEmpty) return;

    await supabase.from('user_roles').insert(
      roleIds
          .map((rid) => {'profile_id': profileId, 'role_id': rid})
          .toList(),
    );
  }
}
