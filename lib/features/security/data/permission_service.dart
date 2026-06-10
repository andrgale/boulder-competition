import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/permission_model.dart';

class PermissionService {
  final supabase = Supabase.instance.client;

  Future<List<PermissionModel>> getPermissions() async {
    final response = await supabase
        .from('permissions')
        .select()
        .order('activity');

    return response
        .map<PermissionModel>((row) => PermissionModel.fromMap(row))
        .toList();
  }

  Future<void> createPermission({
    required String permissionCode,
    required String activity,
  }) async {
    await supabase.from('permissions').insert({
      'permission_code': permissionCode.trim().toLowerCase(),
      'activity': activity.trim(),
    });
  }

  Future<void> updatePermission({
    required String id,
    required String permissionCode,
    required String activity,
  }) async {
    await supabase.from('permissions').update({
      'permission_code': permissionCode.trim().toLowerCase(),
      'activity': activity.trim(),
    }).eq('id', id);
  }

  Future<void> deletePermission(String id) async {
    await supabase.from('permissions').delete().eq('id', id);
  }
}
