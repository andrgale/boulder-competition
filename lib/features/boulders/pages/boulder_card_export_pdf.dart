import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart' as qf;

import 'package:flutter/services.dart';
//import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;

/// Genera il cartellino PDF di un boulder, con QR code contenente
/// competition_id e boulder_id, da appendere sotto al boulder in palestra.
///
/// Dipendenze da aggiungere in pubspec.yaml:
///   pdf: ^3.11.0
///   printing: ^5.13.0
///   qr_flutter: ^4.1.0
class BoulderCardExportPdf {
  /// Apre il dialog di stampa/condivisione nativo per il cartellino.
  static Future<void> exportAndShare({
    required String competitionId,
    required String boulderId,
    required int numero,
    required int difficolta,
    required String? colore,
  }) async {
    final qrImageBytes = await _generateQrImage(
      competitionId: competitionId,
      boulderId: boulderId,
    );

    final bytes = await _buildPdf(
      numero: numero,
      difficolta: difficolta,
      colore: colore,
      qrImageBytes: qrImageBytes,
    );

    String buildSafeFileName(String value) {
      return value
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
    }

    final fileName =
        'cartellino_boulder_${buildSafeFileName(numero.toString())}_'
        '${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

    if (Platform.isMacOS) {
      // Su macOS salva in una cartella temporanea e apre con Anteprima.
      final dir = await getTemporaryDirectory();
      await dir.create(recursive: true);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Process.run('open', [file.path]);
    } else {
      // iOS e altri: share sheet nativa.
      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName,
      );
    }
  }

  // =========================================================
  // GENERA IMMAGINE QR — renderizzata off-screen come PNG bytes
  // =========================================================
  //
  // Il payload del QR è un JSON minimale con i due id richiesti
  // dalla Edge Function register-boulder-ascent.

  static Future<Uint8List> _generateQrImage({
    required String competitionId,
    required String boulderId,
  }) async {
    final payload =
        '{"competition_id":"$competitionId","boulder_id":"$boulderId"}';

    final qrValidationResult = qf.QrValidator.validate(
      data: payload,
      version: qf.QrVersions.auto,
      errorCorrectionLevel: qf.QrErrorCorrectLevel.M,
    );

    if (qrValidationResult.status != qf.QrValidationStatus.valid) {
      throw Exception('Payload QR non valido');
    }

    final qrCode = qrValidationResult.qrCode!;

    final painter = qf.QrPainter.withQr(
      qr: qrCode,
      color: const flutter.Color(0xFF000000),
      emptyColor: const flutter.Color(0xFFFFFFFF),
      gapless: true,
    );

    const double size = 600; // px, alta risoluzione per stampa nitida
    final picData = await painter.toImageData(size);

    return picData!.buffer.asUint8List();
  }

  // =========================================================
  // BUILD PDF — cartellino A6, leggibile da lontano
  // =========================================================

  static Future<Uint8List> _buildPdf({
    required int numero,
    required int difficolta,
    required String? colore,
    required Uint8List qrImageBytes,
  }) async {
    final doc = pw.Document();

    final qrImage = pw.MemoryImage(qrImageBytes);

    // ── colori boulder → riferimento visivo sul cartellino ────
    final colorMap = <String, PdfColor>{
      'bianco': PdfColors.grey300,
      'giallo': PdfColors.yellow700,
      'verde': PdfColors.green700,
      'blu': PdfColors.blue700,
      'rosso': PdfColors.red700,
      'nero': PdfColors.black,
    };
    final boulderColor =
        colorMap[colore?.toLowerCase()] ?? PdfColors.grey600;

    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    doc.addPage(
      pw.Page(
        // A6 verticale: dimensione tipica di un cartellino da appendere
        pageFormat: PdfPageFormat(
          PdfPageFormat.a6.width,
          PdfPageFormat.a6.height,
        ),
        margin: const pw.EdgeInsets.all(20),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // ── numero boulder, grande e centrale ──────────────
            pw.Text(
              'BOULDER',
              style: pw.TextStyle(
                font: bold,
                fontSize: 14,
                color: PdfColors.grey600,
                letterSpacing: 2,
              ),
            ),
            pw.Text(
              '$numero',
              style: pw.TextStyle(
                font: bold,
                fontSize: 72,
                color: boulderColor,
              ),
            ),

            pw.SizedBox(height: 8),

            // ── difficoltà + colore ─────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  width: 16,
                  height: 16,
                  decoration: pw.BoxDecoration(
                    color: boulderColor,
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(
                      color: PdfColors.grey400,
                      width: 0.5,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  colore ?? 'Nessun colore',
                  style: pw.TextStyle(font: regular, fontSize: 14),
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              'Difficoltà: $difficolta / 10',
              style: pw.TextStyle(
                font: bold,
                fontSize: 14,
                color: PdfColors.grey800,
              ),
            ),

            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // ── QR code, grande e centrato ──────────────────────
            pw.Image(qrImage, width: 160, height: 160),

            pw.SizedBox(height: 8),

            pw.Text(
              'Scansiona per registrare il top',
              style: pw.TextStyle(
                font: regular,
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }
}
