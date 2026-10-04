import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'liberatoria_placeholders.dart';

class LiberatoriaPdfBuilder {
  /// [signaturePng] null = versione cartacea (riga vuota per la firma).
  static Future<Uint8List> build({
    required String testo,
    required List<Uint8List> logos,
    required Map<String, String> values,
    required String signerLabel,
    Uint8List? signaturePng,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    final body = LiberatoriaPlaceholders.render(testo, values);
    final dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          if (logos.isNotEmpty) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: logos
                  .map((b) => pw.Image(pw.MemoryImage(b), height: 50))
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],
          ...body.split('\n').map(
                (p) => p.trim().isEmpty
                    ? pw.SizedBox(height: 8)
                    : pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text(
                          p,
                          style: const pw.TextStyle(fontSize: 10.5),
                          textAlign: pw.TextAlign.justify,
                        ),
                      ),
              ),
          pw.SizedBox(height: 32),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Data: $dateStr'),
              pw.Container(
                width: 220,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (signaturePng != null)
                      pw.Image(pw.MemoryImage(signaturePng), height: 60)
                    else
                      pw.SizedBox(height: 60),
                    pw.Divider(thickness: 0.8),
                    pw.Text(signerLabel,
                        style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }
}