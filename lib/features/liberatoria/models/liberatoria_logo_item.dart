import 'dart:typed_data';

/// Un logo nel form: già salvato (path valorizzato) oppure appena scelto (path null).
class LiberatoriaLogoItem {
  final String? path;
  final Uint8List bytes;
  final String extension; // 'png' | 'jpg'

  const LiberatoriaLogoItem({
    this.path,
    required this.bytes,
    required this.extension,
  });

  bool get isNew => path == null;

  String get contentType => extension == 'png' ? 'image/png' : 'image/jpeg';
}