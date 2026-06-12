import 'package:supabase_flutter/supabase_flutter.dart';

class ShellUser {
  final String nomeCompleto;
  final String iniziali;
  final String ruolo;

  const ShellUser({
    required this.nomeCompleto,
    required this.iniziali,
    required this.ruolo,
  });

  factory ShellUser.fallback() => const ShellUser(
        nomeCompleto: 'Utente',
        iniziali: '?',
        ruolo: '',
      );
}

class ShellUserService {
  ShellUserService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<ShellUser> fetchCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return ShellUser.fallback();

    // 1. Recupera profilo tramite auth_user_id
    final profileRow = await _client
        .from('profiles')
        .select('id, nome, cognome')
        .eq('auth_user_id', authUser.id)
        .maybeSingle();

    if (profileRow == null) return ShellUser.fallback();

    final nome = (profileRow['nome'] as String? ?? '').trim();
    final cognome = (profileRow['cognome'] as String? ?? '').trim();
    final nomeCompleto = '$cognome $nome'.trim();
    final iniziali = _initials(nome, cognome);
    final profileId = profileRow['id'] as String;

    // 2. Recupera il primo ruolo associato al profilo (join lato client)
    final userRoleRow = await _client
        .from('user_roles')
        .select('role_id')
        .eq('profile_id', profileId)
        .limit(1)
        .maybeSingle();

    String ruolo = '';

    if (userRoleRow != null) {
      final roleId = userRoleRow['role_id'] as String;

      final roleRow = await _client
          .from('roles')
          .select('name')
          .eq('id', roleId)
          .maybeSingle();

      ruolo = (roleRow?['name'] as String? ?? '');
    }

    return ShellUser(
      nomeCompleto: nomeCompleto.isNotEmpty ? nomeCompleto : authUser.email ?? '',
      iniziali: iniziali,
      ruolo: ruolo,
    );
  }

  String _initials(String nome, String cognome) {
    final n = nome.isNotEmpty ? nome[0].toUpperCase() : '';
    final c = cognome.isNotEmpty ? cognome[0].toUpperCase() : '';
    return '$c$n'.trim().isNotEmpty ? '$c$n' : '?';
  }
}
