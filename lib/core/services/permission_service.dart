import 'package:supabase_flutter/supabase_flutter.dart';

class PermissionService {
  static final supabase =
      Supabase.instance.client;

  // =======================================================
  // CACHE
  // =======================================================

  static List<String>? _cachedPermissions;

  // =======================================================
  // LOAD USER PERMISSIONS
  // =======================================================

  static Future<List<String>>
      loadPermissions() async {
    try {
      // ===============================================
      // CACHE
      // ===============================================

      if (_cachedPermissions != null) {
        return _cachedPermissions!;
      }

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        return [];
      }

      // ===============================================
      // PROFILE
      // ===============================================

      final profile =
          await supabase
              .from('profiles')
              .select('role_id')
              .eq(
                'auth_user_id',
                user.id,
              )
              .single();

      final roleId = profile['role_id'];

      // ===============================================
      // ROLE PERMISSIONS
      // ===============================================

      final rows = await supabase
          .from('role_permissions')
          .select('permissions(permission_code)')
          .eq('role_id', roleId);

      final permissions =
          rows.map<String>((row) {
        return row['permissions']
            ['permission_code'] as String;
      }).toList();

      // ===============================================
      // CACHE
      // ===============================================

      _cachedPermissions = permissions;

      return permissions;
    } catch (e) {
      return [];
    }
  }

  // =======================================================
  // HAS PERMISSION
  // =======================================================

  static Future<bool> hasPermission(
    String permission,
  ) async {
    final permissions =
        await loadPermissions();

    return permissions.contains(
      permission,
    );
  }

  // =======================================================
  // CLEAR CACHE
  // =======================================================

  static void clearCache() {
    _cachedPermissions = null;
  }
}