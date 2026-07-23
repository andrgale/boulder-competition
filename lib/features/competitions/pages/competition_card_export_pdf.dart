import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart' as qf;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as flutter;

/// Genera il cartellino PDF della gara, con QR contenente il competition_id,
/// da appendere vicino all'ingresso della palestra per il check-in atleti.
class CompetitionCardExportPdf {
  static Future<void> exportAndShare({
    required String competitionId,
    required String descrizione,
    required DateTime dtGara,
  }) async {
    final qrImageBytes = await _generateQrImage(competitionId: competitionId);

    final bytes = await _buildPdf(
      descrizione: descrizione,
      dtGara: dtGara,
      qrImageBytes: qrImageBytes,
    );

    String buildSafeFileName(String value) {
      return value
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
    }

    final fileName =
        'cartellino_gara_${buildSafeFileName(descrizione)}_'
        '${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

    if (Platform.isMacOS) {
      final dir = await getTemporaryDirectory();
      await dir.create(recursive: true);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Process.run('open', [file.path]);
    } else {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    }
  }

  // =========================================================
  // GENERA IMMAGINE QR
  // =========================================================
  //
  // NB: stesso formato JSON usato per il cartellino boulder, pensato
  // per essere letto dallo scanner interno dell'app. Se il check-in deve
  // avvenire inquadrando il QR con la fotocamera NATIVA del telefono
  // (senza passare dall'app), il payload va sostituito con un URL
  // (deep link/universal link verso la pagina di check-in), perché la
  // fotocamera di sistema apre solo link, non JSON grezzo.

  static Future<Uint8List> _generateQrImage({
    required String competitionId,
  }) async {
    final payload = '{"competition_id":"$competitionId"}';

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

    const double size = 600;
    final picData = await painter.toImageData(size);

    return picData!.buffer.asUint8List();
  }

  // =========================================================
  // BUILD PDF — cartellino A5, leggibile da lontano
  // =========================================================

  static Future<Uint8List> _buildPdf({
    required String descrizione,
    required DateTime dtGara,
    required Uint8List qrImageBytes,
  }) async {
    final doc = pw.Document();
    final qrImage = pw.MemoryImage(qrImageBytes);

    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    final dataGaraFormattata = DateFormat('dd/MM/yyyy').format(dtGara);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          PdfPageFormat.a5.width,
          PdfPageFormat.a5.height,
        ),
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              descrizione,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: bold,
                fontSize: 22,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              dataGaraFormattata,
              style: pw.TextStyle(
                font: regular,
                fontSize: 14,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 20),
            pw.Image(qrImage, width: 220, height: 220),
            pw.SizedBox(height: 12),
            pw.Text(
              'Inquadra il QR con la fotocamera per il check-in',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: regular,
                fontSize: 11,
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