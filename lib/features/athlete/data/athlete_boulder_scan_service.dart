import 'package:supabase_flutter/supabase_flutter.dart';

class AthleteBoulderScanResult {
  final bool success;
  final String message;

  AthleteBoulderScanResult({required this.success, required this.message});
}

class AthleteBoulderScanService {
  final supabase = Supabase.instance.client;

  /// Decodifica il payload JSON del QR e ne estrae competition_id e boulder_id.
  /// Ritorna null se il formato non è quello atteso.
  Map<String, String>? parseQrPayload(String raw) {
    try {
      // Il payload è generato come stringa JSON semplice in
      // boulder_card_export_pdf.dart: {"competition_id":"...","boulder_id":"..."}
      final competitionMatch =
          RegExp(r'"competition_id"\s*:\s*"([^"]+)"').firstMatch(raw);
      final boulderMatch =
          RegExp(r'"boulder_id"\s*:\s*"([^"]+)"').firstMatch(raw);

      if (competitionMatch == null || boulderMatch == null) return null;

      return {
        'competition_id': competitionMatch.group(1)!,
        'boulder_id': boulderMatch.group(1)!,
      };
    } catch (_) {
      return null;
    }
  }

  /// Chiama la Edge Function register-boulder-ascent.
  Future<AthleteBoulderScanResult> registerAscent({
    required String competitionId,
    required String boulderId,
    required String registrationId,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'register-boulder-ascent',
        body: {
          'competitionId': competitionId,
          'boulderId': boulderId,
          'registrationId': registrationId,
        },
      );

      final data = response.data;

      if (data is Map) {
        return AthleteBoulderScanResult(
          success: data['success'] == true,
          message: data['message'] as String? ??
              (data['success'] == true
                  ? 'Boulder registrato'
                  : 'Operazione non riuscita'),
        );
      }

      return AthleteBoulderScanResult(
        success: false,
        message: 'Risposta inattesa dal server',
      );
    } on FunctionException catch (e) {
      final message = (e.details is Map)
          ? (e.details['message'] ?? e.toString())
          : e.toString();
      return AthleteBoulderScanResult(success: false, message: message.toString());
    } catch (e) {
      return AthleteBoulderScanResult(success: false, message: e.toString());
    }
  }
}
