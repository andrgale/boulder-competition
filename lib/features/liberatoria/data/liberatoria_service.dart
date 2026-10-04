import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/liberatoria_logo_item.dart';
import '../models/liberatoria_template_model.dart';
import 'package:flutter/foundation.dart';
import '../models/liberatoria_atleta_model.dart';

class LiberatoriaService {
  final supabase = Supabase.instance.client;

  static const String logosBucket = 'liberatoria-logos';
  static const String signedBucket = 'liberatorie-firmate';

  Future<LiberatoriaTemplateModel?> getLatestTemplate(
    String competitionId,
  ) async {
    final row = await supabase
        .from('liberatoria_template')
        .select()
        .eq('competition_id', competitionId)
        .order('versione', ascending: false)
        .limit(1)
        .maybeSingle();

    return row == null ? null : LiberatoriaTemplateModel.fromMap(row);
  }

  Future<Uint8List> downloadLogo(String path) {
    return supabase.storage.from(logosBucket).download(path);
  }

  /// Carica un nuovo logo. Il nome è sempre univoco: nessuna sovrascrittura.
  Future<String> _uploadLogo(
    String competitionId,
    LiberatoriaLogoItem logo,
  ) async {
    final path =
        '$competitionId/${DateTime.now().microsecondsSinceEpoch}.${logo.extension}';

    await supabase.storage.from(logosBucket).uploadBinary(
          path,
          logo.bytes,
          fileOptions: FileOptions(
            contentType: logo.contentType,
            upsert: false,
          ),
        );

    return path;
  }

  bool _samePaths(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Stream<List<LiberatoriaAtletaModel>> watchByCompetition(String competitionId) {
    return supabase
        .from('liberatorie_atleti')
        .stream(primaryKey: ['id'])
        .eq('competition_id', competitionId)
        .handleError((e) => debugPrint('Liberatorie stream error (ignorato): $e'))
        .map((rows) => rows.map(LiberatoriaAtletaModel.fromMap).toList());
  }

  Future<String?> _currentProfileId() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final p = await supabase
        .from('profiles')
        .select('id')
        .eq('auth_user_id', user.id)
        .maybeSingle();
    return p?['id'] as String?;
  }

  /// Cartacea: crea il record (stampata) o aggiorna lo stato (stampata/consegnata).
  /// Cartacea: crea il record (stampata) o aggiorna lo stato.
  /// Restituisce l'id del record.
  Future<String> setPaperState({
    required String competitionId,
    required String registrationId,
    required String templateId,
    required String stato,
    String? existingId,
  }) async {
    final operatore = await _currentProfileId();
    final firmatoIl =
        stato == 'consegnata' ? DateTime.now().toUtc().toIso8601String() : null;

    if (existingId == null || existingId.isEmpty) {
      final row = await supabase
          .from('liberatorie_atleti')
          .insert({
            'competition_id': competitionId,
            'registration_id': registrationId,
            'template_id': templateId,
            'modalita': 'cartacea',
            'stato': stato,
            'firmato_il': firmatoIl,
            'operatore_id': operatore,
          })
          .select('id')
          .single();
      return row['id'] as String;
    }

    await supabase.from('liberatorie_atleti').update({
      'stato': stato,
      'firmato_il': firmatoIl,
      'operatore_id': operatore,
    }).eq('id', existingId);
    return existingId;
  }
  
  /// Digitale: upload PDF (nome univoco, mai sovrascritto) + record.
  Future<void> saveSigned({
    required String competitionId,
    required String registrationId,
    required String templateId,
    required Uint8List pdfBytes,
    required String hash,
    String? tutoreNome,
  }) async {
    final path =
        '$competitionId/$registrationId-${DateTime.now().millisecondsSinceEpoch}.pdf';

    await supabase.storage.from(signedBucket).uploadBinary(
          path,
          pdfBytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: false,
          ),
        );

    await supabase.from('liberatorie_atleti').insert({
      'competition_id': competitionId,
      'registration_id': registrationId,
      'template_id': templateId,
      'modalita': 'digitale',
      'stato': 'firmata',
      'pdf_path': path,
      'hash_sha256': hash,
      'tutore_nome': tutoreNome,
      'firmato_il': DateTime.now().toUtc().toIso8601String(),
      'operatore_id': await _currentProfileId(),
    });
  }

  Future<Uint8List> downloadSigned(String path) {
    return supabase.storage.from(signedBucket).download(path);
  }

  /// Crea una nuova versione SOLO se cambiano testo o loghi.
  /// Restituisce true se è stata creata una nuova versione.
  Future<bool> saveTemplateIfChanged({
    required String competitionId,
    required String testo,
    required List<LiberatoriaLogoItem> logos,
  }) async {
    final latest = await getLatestTemplate(competitionId);
    final testoTrim = testo.trim();

    final hasNewLogos = logos.any((l) => l.isNew);

    // Se non ci sono loghi nuovi posso confrontare prima di caricare qualsiasi cosa
    if (!hasNewLogos && latest != null) {
      final currentPaths = logos.map((l) => l.path!).toList();
      if (latest.testo.trim() == testoTrim &&
          _samePaths(latest.logoPaths, currentPaths)) {
        return false;
      }
    }

    // Upload dei soli loghi nuovi, mantenendo l'ordine scelto
    final paths = <String>[];
    for (final logo in logos) {
      paths.add(logo.isNew ? await _uploadLogo(competitionId, logo) : logo.path!);
    }

    final user = supabase.auth.currentUser;
    String? profileId;
    if (user != null) {
      final profile = await supabase
          .from('profiles')
          .select('id')
          .eq('auth_user_id', user.id)
          .maybeSingle();
      profileId = profile?['id'] as String?;
    }

    await supabase.from('liberatoria_template').insert({
      'competition_id': competitionId,
      'versione': (latest?.versione ?? 0) + 1,
      'testo': testoTrim,
      'logo_paths': paths,
      'created_by': profileId,
    });

    return true;
  }
}