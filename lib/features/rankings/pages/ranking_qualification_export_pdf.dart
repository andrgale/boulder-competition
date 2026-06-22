import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/ranking_qualification_model.dart';

import 'package:flutter/services.dart';

/// Genera e condivide/stampa il PDF della classifica qualificazioni.
///
/// Produce tre sezioni — Maschile, Femminile, Generale — ciascuna
/// su una nuova pagina, con lo stesso stile grafico di CheckinPdfExport.
///
/// Dipendenze da aggiungere in pubspec.yaml:
///   pdf: ^3.11.0
///   printing: ^5.13.0
class RankingQualificazioneExportPdf {
  /// Apre il dialog di stampa/condivisione nativo.
  static Future<void> exportAndShare({
    required String competitionName,
    required DateTime dtGara,
    required List<RankingQualificationModel> rankings,
    required int nrFinalisti,
  }) async {
    final bytes = await _buildPdf(
      competitionName: competitionName,
      dtGara: dtGara,
      rankings: rankings,
      nrFinalisti: nrFinalisti,
    );

    String buildSafeFileName(String value) {
      return value
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
    }

    if (Platform.isMacOS) {
      // Su macOS salva in una cartella temporanea e apre con Anteprima.
      final dir = await getTemporaryDirectory();
      await dir.create(recursive: true);
      final safeName = buildSafeFileName(competitionName);
      final fileName =
          'classifica_qualificazioni_${safeName}_'
          '${DateFormat('yyyyMMdd').format(dtGara)}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Process.run('open', [file.path]);
    } else {
      // iOS e altri: share sheet nativa.
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'classifica_qualificazioni_${competitionName.replaceAll(' ', '_')}_'
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
    required List<RankingQualificationModel> rankings,
    required int nrFinalisti,
  }) async {
    final doc = pw.Document();

    // ── colori (stessa palette di CheckinPdfExport) ───────────
    const headerBg = PdfColor.fromInt(0xFF1E40AF); // blue-800
    const rowAlt   = PdfColor.fromInt(0xFFF8FAFC); // slate-50
    const green    = PdfColor.fromInt(0xFF16A34A);
    const grey     = PdfColor.fromInt(0xFF6B7280);
    const blue     = PdfColor.fromInt(0xFF1D4ED8);
    const pink     = PdfColor.fromInt(0xFFDB2777);
    const indigo   = PdfColor.fromInt(0xFF4F46E5);

    // ── font (NotoSans, coerente col resto dell'app) ──────────
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    // ── tre sezioni: Maschile, Femminile, Generale ────────────
    final maschile = rankings.where((r) => r.sesso == 'M').toList();
    final femminile = rankings.where((r) => r.sesso == 'F').toList();
    final generale = rankings; // già ordinata per punteggio dal service

    _addRankingPage(
      doc: doc,
      title: 'Classifica Maschile',
      subtitleColor: blue,
      competitionName: competitionName,
      dtGara: dtGara,
      rankings: maschile,
      nrFinalisti: nrFinalisti,
      bold: bold,
      regular: regular,
      headerBg: headerBg,
      rowAlt: rowAlt,
      green: green,
      grey: grey,
    );

    _addRankingPage(
      doc: doc,
      title: 'Classifica Femminile',
      subtitleColor: pink,
      competitionName: competitionName,
      dtGara: dtGara,
      rankings: femminile,
      nrFinalisti: nrFinalisti,
      bold: bold,
      regular: regular,
      headerBg: headerBg,
      rowAlt: rowAlt,
      green: green,
      grey: grey,
    );

    _addRankingPage(
      doc: doc,
      title: 'Classifica Generale',
      subtitleColor: indigo,
      competitionName: competitionName,
      dtGara: dtGara,
      rankings: generale,
      nrFinalisti: nrFinalisti,
      bold: bold,
      regular: regular,
      headerBg: headerBg,
      rowAlt: rowAlt,
      green: green,
      grey: grey,
    );

    return doc.save();
  }

  // =========================================================
  // PAGINA SINGOLA SEZIONE (Maschile / Femminile / Generale)
  // =========================================================

  static void _addRankingPage({
    required pw.Document doc,
    required String title,
    required PdfColor subtitleColor,
    required String competitionName,
    required DateTime dtGara,
    required List<RankingQualificationModel> rankings,
    required int nrFinalisti,
    required pw.Font bold,
    required pw.Font regular,
    required PdfColor headerBg,
    required PdfColor rowAlt,
    required PdfColor green,
    required PdfColor grey,
  }) {
    // ── intestazioni colonne ─────────────────────────────────
    final colHeaders = <String>[
      '#', 'Pett.', 'Cognome e Nome', 'Sesso', 'Società', 'Top', 'Punti',
    ];

    // ── larghezze colonne (A4 landscape usable width ≈ 770pt) ─
    final colWidths = <double>[25, 40, 220, 55, 220, 50, 80];

    // ── helper: cella pettorale (verde se finalista) ──────────
    pw.Widget pettoraleCell(int? pettorale, bool isFinalist) {
      return pw.Center(
        child: pw.Container(
          width: 26,
          height: 26,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            color: isFinalist ? green : PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(13),
          ),
          child: pw.Text(
            pettorale?.toString() ?? '—',
            style: pw.TextStyle(
              font: bold,
              fontSize: 9,
              color: isFinalist ? PdfColors.white : PdfColors.grey700,
            ),
          ),
        ),
      );
    }

    // ── costruzione righe ──────────────────────────────────────
    final dataRows = rankings.asMap().entries.map((entry) {
      final i = entry.key;
      final r = entry.value;
      final isFinalist = nrFinalisti > 0 && i < nrFinalisti;

      final cells = <pw.Widget>[
        pw.Center(
          child: pw.Text(
            '${i + 1}°',
            style: pw.TextStyle(font: bold, fontSize: 9, color: grey),
          ),
        ),
        pettoraleCell(r.pettorale, isFinalist),
        pw.Text(r.fullName,
            style: pw.TextStyle(font: bold, fontSize: 9)),
        pw.Center(
          child: pw.Text(
            r.sessoLabel,
            style: pw.TextStyle(font: regular, fontSize: 8),
          ),
        ),
        pw.Text(r.societa ?? '',
            style: pw.TextStyle(font: regular, fontSize: 8)),
        pw.Center(
          child: pw.Text(
            '${r.nrTop}',
            style: pw.TextStyle(font: bold, fontSize: 9),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            r.punteggioTotale.toStringAsFixed(2),
            style: pw.TextStyle(font: bold, fontSize: 9),
          ),
        ),
      ];

      return MapEntry(i, cells);
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => _buildHeader(
          competitionName: competitionName,
          dtGara: dtGara,
          sectionTitle: title,
          subtitleColor: subtitleColor,
          bold: bold,
          regular: regular,
          headerBg: headerBg,
        ),
        footer: (ctx) => _buildFooter(ctx, regular, grey),
        build: (ctx) => [
          // ── box statistiche ─────────────────────────────────
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
                _statBox('Atleti', '${rankings.length}',
                    subtitleColor, bold, regular),
                _statBox('Finalisti', '$nrFinalisti',
                    green, bold, regular),
              ],
            ),
          ),

          // ── tabella ──────────────────────────────────────────
          rankings.isEmpty
              ? pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 24),
                  child: pw.Center(
                    child: pw.Text(
                      'Nessun atleta in questa categoria',
                      style: pw.TextStyle(
                          font: regular, fontSize: 11, color: grey),
                    ),
                  ),
                )
              : pw.Table(
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
                  ],
                ),

          // ── legenda finalisti ──────────────────────────────
          if (nrFinalisti > 0 && rankings.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      color: green,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    'Pettorale verde = atleta qualificato alla finale '
                    '(primi $nrFinalisti)',
                    style: pw.TextStyle(
                        font: regular, fontSize: 8, color: grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── header pagina ──────────────────────────────────────────

  static pw.Widget _buildHeader({
    required String competitionName,
    required DateTime dtGara,
    required String sectionTitle,
    required PdfColor subtitleColor,
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
                  '$sectionTitle — Classifica Qualificazioni · '
                  '${DateFormat('dd/MM/yyyy').format(dtGara)}',
                  style: pw.TextStyle(
                    font: bold,
                    fontSize: 11,
                    color: subtitleColor,
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