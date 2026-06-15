import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/checkin_registration_model.dart';

import 'package:flutter/services.dart';

//import 'package:flutter/material.dart';

/// Genera e condivide/stampa il PDF di check-in.
///
/// Dipendenze da aggiungere in pubspec.yaml:
///   pdf: ^3.11.0
///   printing: ^5.13.0
class CheckinPdfExport {
  /// Formatta un double come valuta italiana: € 1.250,00
  static String _formatEuro(double value) {
    final intPart = value.truncate();
    final decPart = ((value - intPart) * 100).round().abs();
    final intStr = intPart.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '\u20AC $intStr,${decPart.toString().padLeft(2, '0')}';
  }


  /// Apre il dialog di stampa/condivisione nativo.
  static Future<void> exportAndShare({
    required String competitionName,
    required DateTime dtGara,
    required List<CheckinRegistrationModel> registrations,
    required double quotaIscrizione,
    required bool showPresente,
    required bool showPagato,
    required bool showOmaggio,
  }) async {
    final bytes = await _buildPdf(
      competitionName: competitionName,
      dtGara: dtGara,
      registrations: registrations,
      quotaIscrizione: quotaIscrizione,
      showPresente: showPresente,
      showPagato: showPagato,
      showOmaggio: showOmaggio,
    );

      String buildSafeFileName(String value) {
        return value
            .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
            .replaceAll(RegExp(r'_+'), '_');
      }

    if (Platform.isMacOS) {
      // // Su macOS salva in una cartella temporanea e apre con Anteprima.
      // await Process.run('open', ['-a', 'Preview', file.path]);
      final dir = await getTemporaryDirectory();
      await dir.create(recursive: true);
      final safeName =
          buildSafeFileName(competitionName);
      final fileName =
          'checkin_${safeName}_${DateFormat('yyyyMMdd').format(dtGara)}.pdf';
      //debugPrint(fileName);
      final file = File('${dir.path}/$fileName');
      //debugPrint(file.path);         
      await file.writeAsBytes(bytes);
      await Process.run(
        'open',
        [file.path],
      );
    } else {
      // iOS e altri: share sheet nativa.
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'checkin_${competitionName.replaceAll(' ', '_')}_'
            '${DateFormat('yyyyMMdd').format(dtGara)}.pdf',
      );
    }
  }

  // =========================================================
  // BUILD PDF
  // =========================================================

  static Future<Uint8List> _buildPdf({
    required String competitionName,
    required DateTime dtGara,
    required List<CheckinRegistrationModel> registrations,
    required double quotaIscrizione,
    required bool showPresente,
    required bool showPagato,
    required bool showOmaggio,
  }) async {
    final doc = pw.Document();

    // ── statistiche ──────────────────────────────────────────
    final totale = registrations.length;
    final presenti = registrations.where((r) => r.flPresente).length;
    final pagati = registrations.where((r) => r.flPagato).length;
    final omaggi = registrations.where((r) => r.flOmaggio).length;
    final importoIncassato = pagati * quotaIscrizione;

    // ── colori ───────────────────────────────────────────────
    const headerBg = PdfColor.fromInt(0xFF1E40AF);   // blue-800
    const rowAlt   = PdfColor.fromInt(0xFFF8FAFC);   // slate-50
    const green    = PdfColor.fromInt(0xFF16A34A);
  //  const red      = PdfColor.fromInt(0xFFDC2626);
    const grey     = PdfColor.fromInt(0xFF6B7280);
    const teal     = PdfColor.fromInt(0xFF0F766E);
    const orange   = PdfColor.fromInt(0xFFEA580C);

    // ── font (Helvetica built-in, nessun download) ───────────
//    final bold    = pw.Font.helveticaBold();
//    final regular = pw.Font.helvetica();

    final regular = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      ),
    );

    final bold = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/NotoSans-Bold.ttf',
      ),
    );



    // ── intestazioni colonne dinamiche ───────────────────────
    final colHeaders = <String>['#', 'Pett.', 'Cognome e Nome', 'Società'];
    if (showPresente) colHeaders.add('Presente');
    if (showPagato)   colHeaders.add('Pagato');
    if (showOmaggio)  colHeaders.add('Omaggio');

    // ── larghezze colonne (in punti) ─────────────────────────
    // A4 landscape usable width ≈ 770pt
    // Fisse: #(25), pett(45), nome(flexible), società(flexible)
    // Flag: 55 ciascuna
    final int flagCount =
        (showPresente ? 1 : 0) + (showPagato ? 1 : 0) + (showOmaggio ? 1 : 0);
    final double flagWidth = 55;
    final double fixedWidth = 25 + 45 + flagCount * flagWidth + 20; // 20=margins
    final double remaining = 770 - fixedWidth;
    final double nomeWidth    = remaining * 0.55;
    final double societaWidth = remaining * 0.45;

    final colWidths = <double>[25, 45, nomeWidth, societaWidth];
    for (var i = 0; i < flagCount; i++) {
      colWidths.add(flagWidth);
    }

    // ── helper: cella flag ───────────────────────────────────
    pw.Widget flagCell(bool value, PdfColor activeColor) {
      return pw.Center(
        child: pw.Container(
          width: 16,
          height: 16,
          decoration: pw.BoxDecoration(
            color: value ? activeColor : PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: value
              ? pw.Center(
                  child: pw.Text(
                //    '✓',
                    'v',
               //     '\U2713',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                )
              : pw.SizedBox(),
        ),
      );
    }

    // ── costruzione righe ────────────────────────────────────
    final dataRows = registrations.asMap().entries.map((entry) {
      final i = entry.key;
      final r = entry.value;

      final cells = <pw.Widget>[
        pw.Text('${i + 1}',
            style: pw.TextStyle(font: regular, fontSize: 8, color: grey)),
        pw.Text(r.pettorale?.toString() ?? '—',
            style: pw.TextStyle(font: bold, fontSize: 9),
            textAlign: pw.TextAlign.center),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(r.fullName,
                style: pw.TextStyle(font: bold, fontSize: 9)),
            pw.Text(r.email,
                style: pw.TextStyle(
                    font: regular, fontSize: 7, color: grey)),
          ],
        ),
        pw.Text(r.societa ?? '',
            style: pw.TextStyle(font: regular, fontSize: 8)),
      ];

      if (showPresente) cells.add(flagCell(r.flPresente, green));
      if (showPagato)   cells.add(flagCell(r.flPagato, teal));
      if (showOmaggio)  cells.add(flagCell(r.flOmaggio, orange));

      return MapEntry(i, cells);
    }).toList();

    // ── pagina ───────────────────────────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => _buildHeader(
          competitionName: competitionName,
          dtGara: dtGara,
          bold: bold,
          regular: regular,
          headerBg: headerBg,
        ),
        footer: (ctx) => _buildFooter(ctx, regular, grey),
        build: (ctx) => [
          // ── box statistiche ────────────────────────────────
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFEFF6FF), // blue-50
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(
                color: const PdfColor.fromInt(0xFFBFDBFE), // blue-200
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _statBox('Iscritti', '$totale',
                    const PdfColor.fromInt(0xFF1D4ED8), bold, regular),
                if (showPresente)
                  _statBox(
                    'Presenti',
                    '$presenti / $totale'
                    '${totale > 0 ? ' (${(presenti / totale * 100).toStringAsFixed(0)}%)' : ''}',
                    green, bold, regular,
                  ),
                if (showPagato)
                  _statBox(
                    'Pagati',
                    '$pagati - ${_formatEuro(importoIncassato)}',
                    teal, bold, regular,
                  ),
                if (showOmaggio)
                  _statBox('Omaggi', '$omaggi', orange, bold, regular),
              ],
            ),
          ),

          // ── tabella ────────────────────────────────────────
          pw.Table(
            columnWidths: {
              for (var i = 0; i < colWidths.length; i++)
                i: pw.FixedColumnWidth(colWidths[i]),
            },
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: const PdfColor.fromInt(0xFFE5E7EB),
                width: 0.5,
              ),
            ),
            children: [
              // intestazione
              pw.TableRow(
                decoration: pw.BoxDecoration(color: headerBg),
                children: colHeaders
                    .map(
                      (h) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                        child: pw.Text(
                          h,
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 9,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              ),

              // righe dati
              ...dataRows.map((entry) {
                final i = entry.key;
                final cells = entry.value;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven ? PdfColors.white : rowAlt,
                  ),
                  children: cells
                      .map(
                        (cell) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                          child: cell,
                        ),
                      )
                      .toList(),
                );
              }),

              // riga totali
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE0F2FE), // sky-100
                ),
                children: [
                  // #
                  pw.SizedBox(),
                  // pettorale
                  pw.SizedBox(),
                  // nome — etichetta TOTALI
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6, vertical: 8),
                    child: pw.Text(
                      'TOTALI',
                      style: pw.TextStyle(
                        font: bold, fontSize: 9,
                        color: const PdfColor.fromInt(0xFF1E40AF),
                      ),
                    ),
                  ),
                  // società
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6, vertical: 8),
                    child: pw.Text(
                      '$totale iscritti',
                      style: pw.TextStyle(font: bold, fontSize: 9),
                    ),
                  ),
                  // flag totali
                  if (showPresente)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 8),
                      child: pw.Text(
                        '$presenti',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: bold, fontSize: 9, color: green),
                      ),
                    ),
                  if (showPagato)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 8),
                      child: pw.Text(
                        '$pagati',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: bold, fontSize: 9, color: teal),
                      ),
                    ),
                  if (showOmaggio)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 8),
                      child: pw.Text(
                        '$omaggi',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: bold, fontSize: 9, color: orange),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── nota importo incassato ─────────────────────────
          if (showPagato && importoIncassato > 0)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                'Importo totale incassato: ${_formatEuro(importoIncassato)}',
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 10,
                  color: teal,
                ),
              ),
            ),
        ],
      ),
    );

    return doc.save();
  }

  // ── header pagina ──────────────────────────────────────────

  static pw.Widget _buildHeader({
    required String competitionName,
    required DateTime dtGara,
    required pw.Font bold,
    required pw.Font regular,
    required PdfColor headerBg,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  competitionName,
                  style: pw.TextStyle(
                    font: bold,
                    fontSize: 16,
                    color: headerBg,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Check-in atleti — ${DateFormat('dd/MM/yyyy').format(dtGara)}',
                  style: pw.TextStyle(
                    font: regular,
                    fontSize: 10,
                    color: const PdfColor.fromInt(0xFF6B7280),
                  ),
                ),
              ],
            ),
            pw.Text(
              'Generato il ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(
                font: regular,
                fontSize: 8,
                color: const PdfColor.fromInt(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: const PdfColor.fromInt(0xFFE5E7EB)),
        pw.SizedBox(height: 4),
      ],
    );
  }

  // ── footer pagina ──────────────────────────────────────────

  static pw.Widget _buildFooter(
    pw.Context ctx,
    pw.Font regular,
    PdfColor grey,
  ) {
    return pw.Column(
      children: [
        pw.Divider(color: const PdfColor.fromInt(0xFFE5E7EB)),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Boulder Competition Management',
              style: pw.TextStyle(font: regular, fontSize: 8, color: grey),
            ),
            pw.Text(
              'Pagina ${ctx.pageNumber} di ${ctx.pagesCount}',
              style: pw.TextStyle(font: regular, fontSize: 8, color: grey),
            ),
          ],
        ),
      ],
    );
  }

  // ── box statistica ─────────────────────────────────────────

  static pw.Widget _statBox(
    String label,
    String value,
    PdfColor color,
    pw.Font bold,
    pw.Font regular,
  ) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(font: bold, fontSize: 14, color: color),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: pw.TextStyle(font: regular, fontSize: 8, color: color),
        ),
      ],
    );
  }
}