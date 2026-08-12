import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/email_template_asset_model.dart';

class EmailTemplateAssetService {
  EmailTemplateAssetService([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _mimeTypes = <String, String>{
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
  };

  /// Usa withData: true: e' indispensabile su Flutter Web e consente di usare
  /// lo stesso uploadBinary su tutte le piattaforme supportate.
  Future<UploadedTemplateImage?> pickUploadAndGetPublicUrl(
    String templateId,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _mimeTypes.keys.toList(),
      allowMultiple: false,
      withData: true,
    );
    if (result == null) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Impossibile leggere il file selezionato.');
    }

    final extension = (file.extension ?? '').toLowerCase();
    final mimeType = _mimeTypes[extension];
    if (mimeType == null) throw StateError('Formato immagine non supportato.');

    // La RPC deve creare il record pending e restituire un percorso server-side.
    final created = await _client.rpc(
      'create_email_template_asset',
      params: {
        'p_template_id': templateId,
        'p_filename': file.name,
        'p_mime_type': mimeType,
        'p_alt_text': null,
      },
    );
    final asset = EmailTemplateAssetModel.fromMap(
      created as Map<String, dynamic>,
    );

    try {
      await _client.storage
          .from(asset.bucketId)
          .uploadBinary(
            asset.storagePath,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      // La RPC verifica anche che l'oggetto Storage esista prima di renderlo
      // referenziabile dall'HTML. Evita di dover allargare le policy RLS del
      // record pending al client.
      final ready = await _client.rpc(
        'mark_email_template_asset_ready',
        params: {'p_asset_id': asset.id, 'p_size_bytes': bytes.length},
      );
      final readyAsset = EmailTemplateAssetModel.fromMap(ready);
      final publicUrl = _client.storage
          .from(readyAsset.bucketId)
          .getPublicUrl(readyAsset.storagePath);
      return UploadedTemplateImage(asset: readyAsset, publicUrl: publicUrl);
    } catch (_) {
      // Il record pending evita che un URL non caricato finisca nel template.
      await _client
          .from('email_template_assets')
          .update({'status': 'deleted'})
          .eq('id', asset.id);
      rethrow;
    }
  }
}

class UploadedTemplateImage {
  const UploadedTemplateImage({required this.asset, required this.publicUrl});

  final EmailTemplateAssetModel asset;
  final String publicUrl;
}
