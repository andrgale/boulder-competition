import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

class ProfileService {
  final SupabaseClient client = Supabase.instance.client;

  Future<AppUser?> getCurrentProfile() async {
    final authUser = client.auth.currentUser;

    if (authUser == null) {
      return null;
    }

    final response = await client
        .from('profiles')
        .select()
        .eq('auth_user_id', authUser.id)
        .single();

    return AppUser.fromMap(response);
  }
}
