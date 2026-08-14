import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  EmailService(this._supabase);

  final SupabaseClient _supabase;
Future<void> sendTemplateEmail({
  required String email,
  required String toName,
  required String templateCode,
  required Map<String, dynamic> variables,
  String language = 'it',
  String? registrationToken,
}) async {
//  debugPrint('sendTemplateEmail - registrationToken ricevuto: $registrationToken'); // TEMP DEBUG
  try {
    final response = await _supabase.functions.invoke(
      'send-template-email',
      headers: registrationToken != null
          ? {'x-registration-token': registrationToken}
          : null,
      body: {
        'email': email,
        'toName': toName,
        'templateCode': templateCode,
        'language': language,
        'variables': variables,
      },
    );
    debugPrint('sendTemplateEmail status: ${response.status}'); // TEMP DEBUG
  } catch (e) {
    // TODO: logging/retry lato server per l'invio mail.
    debugPrint('sendTemplateEmail ERROR: $e');
  }
}

  Map<String, dynamic> buildEmailVariables(Map<String, dynamic> raw) {
    // rimuove i null, o qualsiasi normalizzazione tu faccia oggi
    return {
      for (final entry in raw.entries)
        if (entry.value != null) entry.key: entry.value,
    };
  }
}