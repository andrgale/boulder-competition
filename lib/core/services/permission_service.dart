import 'package:supabase_flutter/supabase_flutter.dart';

class PermissionService {
  static final supabase =
      Supabase.instance.client;

  // =======================================================
  // CACHE
  // =======================================================

  static List<String>? _cachedPermissions;

  static List<String>? _cachedRoles;

  // =======================================================
  // LOAD USER PERMISSIONS
  // =======================================================

  static Future<List<String>> loadPermissions() async {
    try {
      if (_cachedPermissions != null) {
        return _cachedPermissions!;
      }

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        return [];
      }

      // ===================================================
      // PROFILE
      // ===================================================

      final profile =
          await supabase
              .from('profiles')
              .select('id')
              .eq(
                'auth_user_id',
                user.id,
              )
              .single();

      final profileId =
          profile['id'];

      // ===================================================
      // USER ROLES
      // ===================================================

      final roles =
          await supabase
              .from('user_roles')
              .select('role_id')
              .eq(
                'profile_id',
                profileId,
              );

      final roleIds =
          roles
              .map(
                (e) =>
                    e['role_id'],
              )
              .toList();

      if (roleIds.isEmpty) {
        return [];
      }

      // ===================================================
      // ROLE PERMISSIONS
      // ===================================================

      final rows =
          await supabase
              .from(
                'role_permissions',
              )
              .select(
                'permissions(permission_code)',
              )
              .inFilter(
                'role_id',
                roleIds,
              );

      final permissions =
          rows
              .map<String>((row) {
                return row['permissions']
                        ['permission_code']
                    as String;
              })
              .toSet()
              .toList();

      _cachedPermissions =
          permissions;

      return permissions;
    } catch (e) {
      return [];
    }
  }

  // =======================================================
  // LOAD USER ROLES
  // =======================================================

  static Future<List<String>> loadRoles() async {
    try {
      if (_cachedRoles != null) {
        return _cachedRoles!;
      }

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        return [];
      }

      // ===================================================
      // PROFILE
      // ===================================================

      final profile =
          await supabase
              .from('profiles')
              .select('id')
              .eq(
                'auth_user_id',
                user.id,
              )
              .single();

      final profileId =
          profile['id'];

      // ===================================================
      // ROLES
      // ===================================================

      final rows =
          await supabase
              .from('user_roles')
              .select(
                'roles(code)',
              )
              .eq(
                'profile_id',
                profileId,
              );

      final roles =
          rows
              .map<String>((row) {
                return row['roles']
                    ['code'] as String;
              })
              .toSet()
              .toList();

      _cachedRoles = roles;

      return roles;
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
  // HAS ROLE
  // =======================================================

  static Future<bool> hasRole(
    String roleCode,
  ) async {
    final roles =
        await loadRoles();

    return roles.contains(
      roleCode,
    );
  }

  // =======================================================
  // CLEAR CACHE
  // =======================================================

  static void clearCache() {
    _cachedPermissions = null;
    _cachedRoles = null;
  }
}