import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PdfOpener {
  static String _safe(String v) => v
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
      .replaceAll(RegExp(r'_+'), '_');

  /// Apre il PDF nel lettore predefinito (Anteprima/Acrobat), come le altre stampe.
  static Future<void> open(Uint8List bytes, String baseName) async {
    final fileName = '${_safe(baseName)}.pdf';

    if (Platform.isMacOS || Platform.isWindows) {
      final dir = await getTemporaryDirectory();
      await dir.create(recursive: true);
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(bytes, flush: true);

      if (Platform.isMacOS) {
        await Process.run('open', [file.path]);
      } else {
        await Process.run('cmd', ['/c', 'start', '', file.path]);
      }
    } else {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    }
  }
}