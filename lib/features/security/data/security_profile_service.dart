import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/security_profile_model.dart';
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
