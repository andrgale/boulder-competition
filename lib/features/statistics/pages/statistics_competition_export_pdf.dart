import 'dart:io';

import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

import '../models/statistic_competition_boulder_detail_model.dart';
import '../models/statistic_competition_boulder_model.dart';
import '../models/statistic_competition_category_model.dart';
import '../models/statistic_competition_registration_model.dart';
import '../models/statistic_competition_registration_owner_model.dart';

class StatisticsCompetitionExportPdf {
  static Future<void> exportAndShare({
    required String competitionName,
    required StatisticCompetitionRegistrationModel stats,
    required List<StatisticCompetitionRegistrationOwnerModel> ownerStats,
    required StatisticCompetitionBoulderModel boulderStats,
    required List<StatisticCompetitionBoulderDetailModel> boulderDetails,
    required List<StatisticCompetitionCategoryModel> categoryStats,
    required AppLocalizations l10n,
  }) async {
    final bytes = await _buildPdf(
      competitionName: competitionName,
      stats: stats,
      ownerStats: ownerStats,
      boulderStats: boulderStats,
      boulderDetails: boulderDetails,
      categoryStats: categoryStats,
      l10n: l10n,
    );
    final safeName = competitionName
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final fileName =
        'statistiche_${safeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

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

  static Future<Uint8List> _buildPdf({
    required String competitionName,
    required StatisticCompetitionRegistrationModel stats,
    required List<StatisticCompetitionRegistrationOwnerModel> ownerStats,
    required StatisticCompetitionBoulderModel boulderStats,
    required List<StatisticCompetitionBoulderDetailModel> boulderDetails,
    required List<StatisticCompetitionCategoryModel> categoryStats,
    required AppLocalizations l10n,
  }) async {
    final doc = pw.Document();
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );
    const blue = PdfColor.fromInt(0xFF1E40AF);
    const grey = PdfColor.fromInt(0xFF6B7280);
    const rowAlt = PdfColor.fromInt(0xFFF8FAFC);

    _addAthletesPage(
      doc: doc,
      competitionName: competitionName,
      stats: stats,
      ownerStats: ownerStats,
      regular: regular,
      bold: bold,
      blue: blue,
      grey: grey,
      rowAlt: rowAlt,
      l10n: l10n,
    );
    _addBoulderPage(
      doc: doc,
      competitionName: competitionName,
      stats: boulderStats,
      details: boulderDetails,
      regular: regular,
      bold: bold,
      blue: blue,
      grey: grey,
      rowAlt: rowAlt,
      l10n: l10n,
    );
    _addCategoriesPage(
      doc: doc,
      competitionName: competitionName,
      categories: categoryStats,
      regular: regular,
      bold: bold,
      blue: blue,
      grey: grey,
      rowAlt: rowAlt,
      l10n: l10n,
    );
    return doc.save();
  }

  static void _addAthletesPage({
    required pw.Document doc,
    required String competitionName,
    required StatisticCompetitionRegistrationModel stats,
    required List<StatisticCompetitionRegistrationOwnerModel> ownerStats,
    required pw.Font regular,
    required pw.Font bold,
    required PdfColor blue,
    required PdfColor grey,
    required PdfColor rowAlt,
    required AppLocalizations l10n,
  }) {
    doc.addPage(
      _multiPage(
        title: l10n.statisticsMessageCustom2,
        competitionName: competitionName,
        regular: regular,
        bold: bold,
        grey: grey,
        l10n: l10n,
        build: (context) => [
          _statsRow([
            _statBox(
              l10n.statisticsMessageCustom8,
              stats.nrAtletiIscritti,
              blue,
              regular,
              bold,
            ),
            _statBox(
              l10n.statisticsMessageCustom9,
              stats.nrAtletiPartecipanti,
              const PdfColor.fromInt(0xFF0F766E),
              regular,
              bold,
            ),
          ]),
          _heading(l10n.statisticsMessageCustom10, bold),
          _table(
            headers: [
              l10n.statisticsMessageCustom7,
              l10n.statisticsMessageCustom8,
              l10n.statisticsMessageCustom9,
            ],
            rows: [
              [
                l10n.statisticsMessageCustom10,
                '${stats.nrAtletiMaschiIscritti}',
                '${stats.nrAtletiMaschiPartecipanti}',
              ],
              [
                l10n.statisticsMessageCustom11,
                '${stats.nrAtleteFemmineIscritte}',
                '${stats.nrAtleteFemminePartecipanti}',
              ],
            ],
            regular: regular,
            bold: bold,
            rowAlt: rowAlt,
          ),
          _heading(l10n.statisticsMessageCustom14, bold),
          if (ownerStats.isEmpty)
            _empty(l10n.statisticsMessageCustom27, regular, grey)
          else
            _table(
              headers: [
                l10n.statisticsMessageCustom14,
                l10n.statisticsMessageCustom8,
              ],
              rows: ownerStats
                  .map(
                    (owner) => [
                      _ownerLabel(owner.ownerRegistration, l10n),
                      '${owner.nrAtletiIscritti}',
                    ],
                  )
                  .toList(),
              regular: regular,
              bold: bold,
              rowAlt: rowAlt,
            ),
          _heading(l10n.statisticsMessageCustom18, bold),
          _table(
            headers: [
              l10n.statisticsMessageCustom18,
              l10n.statisticsMessageCustom23,
              l10n.statisticsMessageCustom24,
              l10n.statisticsMessageCustom25,
            ],
            rows: [
              _athleteRow(
                l10n.statisticsMessageCustom19,
                stats.atletaMaschioPartecipantePiuGiovane,
                l10n,
              ),
              _athleteRow(
                l10n.statisticsMessageCustom20,
                stats.atletaFemminaPartecipantePiuGiovane,
                l10n,
              ),
              _athleteRow(
                l10n.statisticsMessageCustom21,
                stats.atletaMaschioPartecipantePiuVecchio,
                l10n,
              ),
              _athleteRow(
                l10n.statisticsMessageCustom22,
                stats.atletaFemminaPartecipantePiuVecchia,
                l10n,
              ),
            ],
            regular: regular,
            bold: bold,
            rowAlt: rowAlt,
          ),
        ],
      ),
    );
  }

  static void _addBoulderPage({
    required pw.Document doc,
    required String competitionName,
    required StatisticCompetitionBoulderModel stats,
    required List<StatisticCompetitionBoulderDetailModel> details,
    required pw.Font regular,
    required pw.Font bold,
    required PdfColor blue,
    required PdfColor grey,
    required PdfColor rowAlt,
    required AppLocalizations l10n,
  }) {
    doc.addPage(
      _multiPage(
        title: l10n.statisticsMessageCustom3,
        competitionName: competitionName,
        regular: regular,
        bold: bold,
        grey: grey,
        l10n: l10n,
        build: (context) => [
          _statsRow([
            _statBox(
              l10n.statisticsMessageCustom29,
              stats.nrBoulder,
              blue,
              regular,
              bold,
            ),
            _statBox(
              l10n.statisticsMessageCustom30,
              stats.nrBoulderFinale,
              const PdfColor.fromInt(0xFF7E22CE),
              regular,
              bold,
            ),
          ]),
          _heading(l10n.statisticsMessageCustom31, bold),
          if (details.isEmpty)
            _empty(l10n.statisticsMessageCustom27, regular, grey)
          else
            _table(
              headers: [
                l10n.statisticsMessageCustom32(0),
                l10n.statisticsMessageCustom33,
                l10n.statisticsMessageCustom35,
                l10n.statisticsMessageCustom36,
                l10n.statisticsMessageCustom37,
                l10n.statisticsMessageCustom38,
                l10n.statisticsMessageCustom39,
                l10n.statisticsMessageCustom40,
                l10n.statisticsMessageCustom41,
              ],
              rows: details
                  .map(
                    (boulder) => [
                      '${boulder.numero}',
                      boulder.isFinale
                          ? l10n.statisticsMessageCustom33
                          : l10n.statisticsMessageCustom34,
                      '${boulder.difficolta ?? '—'}',
                      boulder.colore ?? '—',
                      '${boulder.nrSalite}',
                      '${boulder.nrSaliteMaschili}',
                      '${boulder.nrSaliteFemminili}',
                      boulder.valoreTeorico.toStringAsFixed(2),
                      boulder.valoreAttuale.toStringAsFixed(2),
                    ],
                  )
                  .toList(),
              regular: regular,
              bold: bold,
              rowAlt: rowAlt,
            ),
        ],
      ),
    );
  }

  static void _addCategoriesPage({
    required pw.Document doc,
    required String competitionName,
    required List<StatisticCompetitionCategoryModel> categories,
    required pw.Font regular,
    required pw.Font bold,
    required PdfColor blue,
    required PdfColor grey,
    required PdfColor rowAlt,
    required AppLocalizations l10n,
  }) {
    doc.addPage(
      _multiPage(
        title: l10n.statisticsMessageCustom4,
        competitionName: competitionName,
        regular: regular,
        bold: bold,
        grey: grey,
        l10n: l10n,
        build: (context) => [
          _statsRow([
            _statBox(
              l10n.statisticsMessageCustom44,
              categories.length,
              blue,
              regular,
              bold,
            ),
            _statBox(
              l10n.statisticsMessageCustom45,
              categories.fold(0, (sum, c) => sum + c.nrAtletiIscritti),
              blue,
              regular,
              bold,
            ),
            _statBox(
              l10n.statisticsMessageCustom46,
              categories.fold(0, (sum, c) => sum + c.nrAtletiPartecipanti),
              const PdfColor.fromInt(0xFF0F766E),
              regular,
              bold,
            ),
          ]),
          _heading(l10n.statisticsMessageCustom47, bold),
          if (categories.isEmpty)
            _empty(l10n.statisticsMessageCustom27, regular, grey)
          else
            _table(
              headers: [
                l10n.statisticsMessageCustom47,
                l10n.statisticsMessageCustom48,
                l10n.statisticsMessageCustom49,
              ],
              rows: categories
                  .map(
                    (category) => [
                      category.nome,
                      '${category.nrAtletiIscritti}',
                      '${category.nrAtletiPartecipanti}',
                    ],
                  )
                  .toList(),
              regular: regular,
              bold: bold,
              rowAlt: rowAlt,
            ),
        ],
      ),
    );
  }

  static pw.MultiPage _multiPage({
    required String title,
    required String competitionName,
    required pw.Font regular,
    required pw.Font bold,
    required PdfColor grey,
    required AppLocalizations l10n,
    required List<pw.Widget> Function(pw.Context) build,
  }) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            competitionName,
            style: pw.TextStyle(
              font: bold,
              fontSize: 16,
              color: const PdfColor.fromInt(0xFF1E40AF),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 12)),
          pw.Divider(color: const PdfColor.fromInt(0xFFE5E7EB)),
        ],
      ),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            l10n.statisticsMessageCustom1(competitionName),
            style: pw.TextStyle(font: regular, fontSize: 8, color: grey),
          ),
          pw.Text(
            '${context.pageNumber}',
            style: pw.TextStyle(font: regular, fontSize: 8, color: grey),
          ),
        ],
      ),
      build: build,
    );
  }

  static pw.Widget _heading(String text, pw.Font bold) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
    child: pw.Text(text, style: pw.TextStyle(font: bold, fontSize: 11)),
  );

  static pw.Widget _statsRow(List<pw.Widget> children) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
    children: children,
  );

  static pw.Widget _statBox(
    String label,
    int value,
    PdfColor color,
    pw.Font regular,
    pw.Font bold,
  ) => pw.Column(
    children: [
      pw.Text(
        '$value',
        style: pw.TextStyle(font: bold, fontSize: 18, color: color),
      ),
      pw.Text(
        label,
        style: pw.TextStyle(font: regular, fontSize: 9, color: color),
      ),
    ],
  );

  static pw.Widget _empty(String text, pw.Font regular, PdfColor grey) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 16),
        child: pw.Text(
          text,
          style: pw.TextStyle(font: regular, fontSize: 10, color: grey),
        ),
      );

  static pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required pw.Font regular,
    required pw.Font bold,
    required PdfColor rowAlt,
  }) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(
          color: const PdfColor.fromInt(0xFFE5E7EB),
          width: 0.5,
        ),
      ),
      columnWidths: {
        for (var i = 0; i < headers.length; i++) i: const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF1E40AF),
          ),
          children: headers
              .map(
                (header) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    header,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 8,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...rows.asMap().entries.map(
          (entry) => pw.TableRow(
            decoration: pw.BoxDecoration(
              color: entry.key.isEven ? PdfColors.white : rowAlt,
            ),
            children: entry.value
                .map(
                  (cell) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      cell,
                      style: pw.TextStyle(font: regular, fontSize: 8),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static List<String> _athleteRow(
    String label,
    AthleteStatisticModel athlete,
    AppLocalizations l10n,
  ) {
    final birthDate = athlete.dataNascita == null
        ? '—'
        : DateFormat('dd/MM/yyyy').format(athlete.dataNascita!);
    return [
      label,
      athlete.fullName.isEmpty
          ? l10n.statisticsMessageCustom26
          : athlete.fullName,
      athlete.societa ?? '—',
      birthDate,
    ];
  }

  static String _ownerLabel(String owner, AppLocalizations l10n) {
    switch (owner) {
      case 'admin':
        return l10n.statisticsMessageCustom15;
      case 'athlete':
        return l10n.statisticsMessageCustom16;
      case 'import':
        return l10n.statisticsMessageCustom17;
      default:
        return owner;
    }
  }
}
