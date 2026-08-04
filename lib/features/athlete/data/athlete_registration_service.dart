import 'package:supabase_flutter/supabase_flutter.dart';

class AthleteRegistrationService {
  final supabase = Supabase.instance.client;

  // =====================================================
  // CHECK EMAIL ESISTENTE
  // =====================================================
  //
  Future<bool> emailExists(String email) async {
    final response = await supabase.rpc(
      'check_email_exists',
      params: {'p_email': email},
    );

    return response as bool;
  }
  // =====================================================
  // REGISTRAZIONE ATLETA
  // =====================================================
  //
  // Riusa la stessa Edge Function 'create-athlete-user' già
  // usata lato amministrazione, perché la creazione utente
  // richiede i privilegi elevati (service role) presenti solo
  // nella function.

  Future<String?> registerAthlete({
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
}