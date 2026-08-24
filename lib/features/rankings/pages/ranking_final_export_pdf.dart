import 'dart:io';
import 'package:boulder_competition/features/rankings/models/ranking_sex_model_l10n.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/ranking_final_model.dart';

import 'package:flutter/services.dart';

/// Genera e condivide/stampa il PDF della classifica finale.
/// Ora tutte le stringhe sono localizzabili tramite AppLocalizations.
class RankingFinalExportPdf {
  /// Apre il dialog di stampa/condivisione nativo.
  static Future<void> exportAndShare({
    required String competitionName,
    required DateTime dtGara,
    required List<RankingFinalModel> rankings,
    required AppLocalizations l10n,
  }) async {
    final bytes = await _buildPdf(
      competitionName: competitionName,
      dtGara: dtGara,
      rankings: rankings,
      l10n: l10n,
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
          'classifica_finale_${safeName}_'
          '${DateFormat('yyyyMMdd').format(dtGara)}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Process.run('open', [file.path]);
    } else {
      // iOS e altri: share sheet nativa.
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'classifica_finale_${competitionName.replaceAll(' ', '_')}_'
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
    required List<RankingFinalModel> rankings,
    required AppLocalizations l10n,
  }) async {
    final doc = pw.Document();

    // ── colori (stessa palette di CheckinPdfExport) ───────────
    const headerBg = PdfColor.fromInt(0xFF1E40AF); // blue-800
    const rowAlt = PdfColor.fromInt(0xFFF8FAFC); // slate-50
    const grey = PdfColor.fromInt(0xFF6B7280);
    const blue = PdfColor.fromInt(0xFF1D4ED8);
    const pink = PdfColor.fromInt(0xFFDB2777);
    const indigo = PdfColor.fromInt(0xFF4F46E5);

    // ── colori podio: oro, argento, bronzo ─────────────────────
    const gold = PdfColor.fromInt(0xFFD4AF37);
    const silver = PdfColor.fromInt(0xFFA8A9AD);
    const bronze = PdfColor.fromInt(0xFFB08D57);

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
    final generale = rankings; // già ordinata dal service

    _addRankingPage(
      doc: doc,
      title: l10n.rankingMessageCustom35, // 'Classifica Maschile'
      subtitleColor: blue,
      competitionName: competitionName,
      dtGara: dtGara,
      rankings: maschile,
      bold: bold,
      regular: regular,
      headerBg: headerBg,
      rowAlt: rowAlt,
      grey: grey,
      gold: gold,
      silver: silver,
      bronze: bronze,
      l10n: l10n,
    );

    _addRankingPage(
      doc: doc,
      title: l10n.rankingMessageCustom36, // 'Classifica Femminile'
      subtitleColor: pink,
      competitionName: competitionName,
      dtGara: dtGara,
      rankings: femminile,
      bold: bold,
      regular: regular,
      headerBg: headerBg,
      rowAlt: rowAlt,
      grey: grey,
      gold: gold,
      silver: silver,
      bronze: bronze,
      l10n: l10n,
    );

    _addRankingPage(
      doc: doc,
      title: l10n.rankingMessageCustom37, // 'Classifica Generale'
      subtitleColor: indigo,
      competitionName: competitionName,
      dtGara: dtGara,
      rankings: generale,
      bold: bold,
      regular: regular,
      headerBg: headerBg,
      rowAlt: rowAlt,
      grey: grey,
      gold: gold,
      silver: silver,
      bronze: bronze,
      l10n: l10n,
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
    required List<RankingFinalModel> rankings,
    required pw.Font bold,
    required pw.Font regular,
    required PdfColor headerBg,
    required PdfColor rowAlt,
    required PdfColor grey,
    required PdfColor gold,
    required PdfColor silver,
    required PdfColor bronze,
    required AppLocalizations l10n,
  }) {
    // ── intestazioni colonne (localizzate)
    final colHeaders = <String>[
      l10n.rankingMessageCustom45, // '#'
      l10n.rankingMessageCustom46, // 'Pett.' / 'Bib'
      l10n.rankingMessageCustom47, // 'Cognome e Nome'
      l10n.rankingMessageCustom48, // 'Sesso'
      l10n.rankingMessageCustom49, // 'Società'
      l10n.rankingMessageCustom32, // 'Top'
      l10n.rankingMessageCustom51, // 'Tent. Top'
      l10n.rankingMessageCustom52, // 'Zone'
      l10n.rankingMessageCustom53, // 'Tent. Zone'
    ];

    // ── larghezze colonne (A4 landscape usable width ≈ 770pt) ─
    final colWidths = <double>[25, 40, 190, 50, 190, 45, 60, 45, 60];

    // ── helper: colore podio per posizione ────────────────────
    PdfColor? podiumColor(int position) {
      switch (position) {
        case 1:
          return gold;
        case 2:
          return silver;
        case 3:
          return bronze;
        default:
          return null;
      }
    }

    // ── helper: cella pettorale (oro/argento/bronzo per podio) ─
    pw.Widget pettoraleCell(int? pettorale, PdfColor? color) {
      return pw.Center(
        child: pw.Container(
          width: 26,
          height: 26,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            color: color ?? PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(13),
          ),
          child: pw.Text(
            pettorale?.toString() ?? '—',
            style: pw.TextStyle(
              font: bold,
              fontSize: 9,
              color: color != null ? PdfColors.white : PdfColors.grey700,
            ),
          ),
        ),
      );
    }

    // ── costruzione righe ──────────────────────────────────────
    final dataRows = rankings.asMap().entries.map((entry) {
      final i = entry.key;
      final r = entry.value;
      final position = i + 1;
      final color = podiumColor(position);

      final cells = <pw.Widget>[
        pw.Center(
          child: pw.Text(
            '$position°',
            style: pw.TextStyle(font: bold, fontSize: 9, color: grey),
          ),
        ),
        pettoraleCell(r.pettorale, color),
        pw.Text(r.fullName, style: pw.TextStyle(font: bold, fontSize: 9)),
        pw.Center(
          child: pw.Text(r.localizedSessoLabelFromL10n(l10n), style: pw.TextStyle(font: regular, fontSize: 8)),
        ),
        pw.Text(r.societa ?? '', style: pw.TextStyle(font: regular, fontSize: 8)),
        pw.Center(child: pw.Text('${r.nrTop}', style: pw.TextStyle(font: bold, fontSize: 9))),
        pw.Center(child: pw.Text('${r.tentativiTop}', style: pw.TextStyle(font: regular, fontSize: 8, color: grey))),
        pw.Center(child: pw.Text('${r.nrZone}', style: pw.TextStyle(font: bold, fontSize: 9))),
        pw.Center(child: pw.Text('${r.tentativiZone}', style: pw.TextStyle(font: regular, fontSize: 8, color: grey))),
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
          l10n: l10n,
        ),
        footer: (ctx) => _buildFooter(ctx, regular, grey, l10n),
        build: (ctx) => [
          // ── box statistiche ─────────────────────────────────
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFEFF6FF),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: const PdfColor.fromInt(0xFFBFDBFE)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _statBox(l10n.rankingMessageCustom38, '${rankings.length}', subtitleColor, bold, regular), // 'Atleti'
              ],
            ),
          ),

          // ── tabella ──────────────────────────────────────────
          rankings.isEmpty
              ? pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 24),
                  child: pw.Center(
                    child: pw.Text(
                      l10n.rankingMessageCustom40, // 'Nessun atleta in questa categoria'
                      style: pw.TextStyle(font: regular, fontSize: 11, color: grey),
                    ),
                  ),
                )
              : pw.Table(
                  columnWidths: {
                    for (var i = 0; i < colWidths.length; i++) i: pw.FixedColumnWidth(colWidths[i]),
                  },
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: const PdfColor.fromInt(0xFFE5E7EB), width: 0.5),
                  ),
                  children: [
                    // intestazione
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: headerBg),
                      children: colHeaders
                          .map((h) => pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                child: pw.Text(h, style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white), textAlign: pw.TextAlign.center),
                              ))
                          .toList(),
                    ),

                    // righe dati
                    ...dataRows.map((entry) {
                      final i = entry.key;
                      final cells = entry.value;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(color: i.isEven ? PdfColors.white : rowAlt),
                        children: cells.map((cell) => pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: cell)).toList(),
                      );
                    }),
                  ],
                ),

          // ── legenda podio ───────────────────────────────────
          if (rankings.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Row(
                children: [
                  _podiumLegendDot(gold, l10n.rankingMessageCustom54), // '1° posto'
                  pw.SizedBox(width: 12),
                  _podiumLegendDot(silver, l10n.rankingMessageCustom55), // '2° posto'
                  pw.SizedBox(width: 12),
                  _podiumLegendDot(bronze, l10n.rankingMessageCustom56), // '3° posto'
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _podiumLegendDot(PdfColor color, String label) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(width: 12, height: 12, decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(6))),
        pw.SizedBox(width: 6),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      ],
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
    required AppLocalizations l10n,
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
                pw.Text(competitionName, style: pw.TextStyle(font: bold, fontSize: 16, color: headerBg)),
                pw.SizedBox(height: 2),
                pw.Text(
                  '$sectionTitle — ${l10n.rankingMessageCustom37} · ${DateFormat('dd/MM/yyyy').format(dtGara)}',
                  style: pw.TextStyle(font: bold, fontSize: 11, color: subtitleColor),
                ),
              ],
            ),
            pw.Text(l10n.rankingMessageCustom43(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())), style: pw.TextStyle(font: regular, fontSize: 8, color: const PdfColor.fromInt(0xFF9CA3AF))),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: const PdfColor.fromInt(0xFFE5E7EB)),
        pw.SizedBox(height: 4),
      ],
    );
  }

  // ── footer pagina ──────────────────────────────────────────

  static pw.Widget _buildFooter(pw.Context ctx, pw.Font regular, PdfColor grey, AppLocalizations l10n) {
    return pw.Column(
      children: [
        pw.Divider(color: const PdfColor.fromInt(0xFFE5E7EB)),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(l10n.rankingMessageCustom42, style: pw.TextStyle(font: regular, fontSize: 8, color: grey)), // branding
            pw.Text(l10n.rankingMessageCustom44(ctx.pageNumber.toString(), ctx.pagesCount.toString()), style: pw.TextStyle(font: regular, fontSize: 8, color: grey)), // 'Pagina {page} di {count}'
          ],
        ),
      ],
    );
  }

  // ── box statistica ─────────────────────────────────────────

  static pw.Widget _statBox(String label, String value, PdfColor color, pw.Font bold, pw.Font regular) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 14, color: color)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: pw.TextStyle(font: regular, fontSize: 8, color: color)),
      ],
    );
  }
}