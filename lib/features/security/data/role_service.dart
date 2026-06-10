import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/role_model.dart';
//import '../models/permission_model.dart';
//import '../models/menu_model.dart';

class RoleService {
  final supabase = Supabase.instance.client;

  // =========================================================
  // ROLES — CRUD
  // =========================================================

  Future<List<RoleModel>> getRoles() async {
    final response = await supabase
        .from('roles')
        .select()
        .order('name');

    return response
        .map<RoleModel>((row) => RoleModel.fromMap(row))
        .toList();
  }

  Future<void> createRole({
    required String code,
    required String name,
  }) async {
    await supabase.from('roles').insert({
      'code': code.trim().toLowerCase(),
      'name': name.trim(),
    });
  }

  Future<void> updateRole({
    required String id,
    required String code,
    required String name,
  }) async {
    await supabase.from('roles').update({
      'code': code.trim().toLowerCase(),
      'name': name.trim(),
    }).eq('id', id);
  }

  Future<void> deleteRole(String id) async {
    await supabase.from('roles').delete().eq('id', id);
  }

  // =========================================================
  // ROLE ↔ PERMISSIONS
  // =========================================================

  Future<List<String>> getRolePermissionIds(String roleId) async {
    final rows = await supabase
        .from('role_permissions')
        .select('permission_id')
        .eq('role_id', roleId);

    return rows.map<String>((r) => r['permission_id'] as String).toList();
  }

  Future<void> setRolePermissions({
    required String roleId,
    required List<String> permissionIds,
  }) async {
    // delete existing
    await supabase
        .from('role_permissions')
        .delete()
        .eq('role_id', roleId);

    if (permissionIds.isEmpty) return;

    await supabase.from('role_permissions').insert(
      permissionIds
          .map((pid) => {'role_id': roleId, 'permission_id': pid})
          .toList(),
    );
  }

  // =========================================================
  // ROLE ↔ MENUS
  // =========================================================

  Future<List<String>> getRoleMenuIds(String roleId) async {
    final rows = await supabase
        .from('role_menus')
        .select('menu_id')
        .eq('role_id', roleId);

    return rows.map<String>((r) => r['menu_id'] as String).toList();
  }

  Future<void> setRoleMenus({
    required String roleId,
    required List<String> menuIds,
  }) async {
    await supabase
        .from('role_menus')
        .delete()
        .eq('role_id', roleId);

    if (menuIds.isEmpty) return;

    await supabase.from('role_menus').insert(
      menuIds
          .map((mid) => {'role_id': roleId, 'menu_id': mid})
          .toList(),
    );
  }
}
