import 'package:supabase_flutter/supabase_flutter.dart';

class PermissionGuard {
  static Future<bool> canAccess(
    String permissionCode,
  ) async {
    final supabase = Supabase.instance.client;

    final userId =
        supabase.auth.currentUser?.id;

    if (userId == null) {
      return false;
    }

    final result = await supabase
        .from('v_user_permissions')
        .select()
        .eq('auth_user_id', userId)
        .eq('permission_code', permissionCode);

    return result.isNotEmpty;
  }
}