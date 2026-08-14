import 'dart:async';

import 'package:boulder_competition/core/services/email_service.dart';
//import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AthleteRegistrationService {
    AthleteRegistrationService(this._supabase, this._emailService);

  final SupabaseClient _supabase;
  final EmailService _emailService;
  //final supabase = Supabase.instance.client;

  // =====================================================
  // CHECK EMAIL ESISTENTE
  // =====================================================
  //
  Future<bool> emailExists(String email) async {
    final response = await _supabase.rpc(
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
    final response = await _supabase.functions.invoke(
      'create-athlete-user',
      body: {
        'email': email,
        'nome': nome,
        'cognome': cognome,
        'issueRegistrationToken': true, // <-- auto-registrazione: serve il token
      },
    );

    final data = response.data as Map<String, dynamic>;
 //   debugPrint('create-athlete-user response: $data');

    final profileId = data['profile_id'] as String?;
    final registrationToken = data['registration_token'] as String?;
//    debugPrint('registrationToken estratto: $registrationToken');

    unawaited(_emailService.sendTemplateEmail(
      email: email,
      toName: '$nome $cognome'.trim(),
      templateCode: 'REG_ATLETA',
      variables: _emailService.buildEmailVariables({
        'NOME_ATLETA': nome,
        'COGNOME_ATLETA': cognome,
        'SENDERNAME': 'BoulderCompetition',
      }),
      registrationToken: registrationToken,
    ));

    return profileId;
  }


  // Future<void> sendTemplateEmail({
  //   required String email,
  //   required String toName,
  //   required String templateCode,
  //   required Map<String, dynamic> variables,
  //   String language = 'it',
  // }) async {
  //   try {
  //     await supabase.functions.invoke(
  //       'send-template-email',
  //       body: {
  //         'email': email,
  //         'toName': toName,
  //         'templateCode': templateCode,
  //         'language': language,
  //         'variables': variables,
  //       },
  //     );
  //   } catch (e) {
  //     // TODO: logging/retry lato server per l'invio mail.
  //     // Non rilanciare: la mail non deve bloccare il flusso chiamante.
  //   }
  // }

  // Map<String, String> buildEmailVariables(Map<String, String?> fields) {
  //   final result = <String, String>{};
  //   for (final entry in fields.entries) {
  //     final value = entry.value?.trim();
  //     if (value != null && value.isNotEmpty) {
  //       result[entry.key] = value;
  //     }
  //   }
  //   return result;
  // }


}