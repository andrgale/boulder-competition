import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:boulder_competition/l10n/app_localizations.dart';

import '../../checkin/models/checkin_registration_model.dart';
import '../data/liberatoria_service.dart';
import '../models/liberatoria_atleta_model.dart';
import '../models/liberatoria_mode.dart';
import '../models/liberatoria_template_model.dart';
import '../pages/liberatoria_sign_dialog.dart';
import 'liberatoria_pdf_builder.dart';
import 'liberatoria_placeholders.dart';
import 'pdf_opener.dart';

class LiberatoriaCheckinActions {
  static final _fmt = DateFormat('dd/MM/yyyy');

  static bool isMinor(DateTime? birth, DateTime ref) {
    if (birth == null) return false;
    var age = ref.year - birth.year;
    if (ref.month < birth.month ||
        (ref.month == birth.month && ref.day < birth.day)) {
      age--;
    }
    return age < 18;
  }

  static Map<String, String> values({
    required CheckinRegistrationModel reg,
    required String competitionName,
    required DateTime dtGara,
    String tutore = '',
  }) {
    return {
      'cognome': reg.cognome,
      'nome': reg.nome,
      'data_nascita':
          reg.dataNascita != null ? _fmt.format(reg.dataNascita!) : '',
      'societa': reg.societa ?? '',
      'nome_gara': competitionName,
      'data_gara': _fmt.format(dtGara),
      'data': _fmt.format(DateTime.now()),
      'tutore': tutore,
    };
  }

  static Future<void> handle({
    required BuildContext context,
    required LiberatoriaService service,
    required CheckinRegistrationModel reg,
    required LiberatoriaMode mode,
    required String competitionId,
    required String competitionName,
    required DateTime dtGara,
    required LiberatoriaTemplateModel template,
    required List<Uint8List> logos,
    LiberatoriaAtletaModel? existing,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Firma digitale senza data di nascita: non si può sapere se è minorenne
    if (mode == LiberatoriaMode.digitale &&
        existing?.pdfPath == null &&
        reg.dataNascita == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.liberatoriaBirthDateMissing)),
      );
      return;
    }

    try {
      if (mode == LiberatoriaMode.cartacea) {
        await _paper(context, l10n, service, reg, competitionId,
            competitionName, dtGara, template, logos, existing);
      } else if (mode == LiberatoriaMode.digitale) {
        if (existing?.pdfPath != null) {
          // Già firmata: apre il PDF archiviato
          final bytes = await service.downloadSigned(existing!.pdfPath!);
          await PdfOpener.open(
            bytes,
            'liberatoria_${reg.cognome}_${reg.nome}',
          );
        } else {
          await _sign(context, l10n, service, reg, competitionId,
              competitionName, dtGara, template, logos);
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.liberatoriaError}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // ── CARTACEA ───────────────────────────────────────────
  static Future<void> _paper(
    BuildContext context,
    AppLocalizations l10n,
    LiberatoriaService service,
    CheckinRegistrationModel reg,
    String competitionId,
    String competitionName,
    DateTime dtGara,
    LiberatoriaTemplateModel template,
    List<Uint8List> logos,
    LiberatoriaAtletaModel? existing,
  ) async {
    var current = existing;
    final minor = isMinor(reg.dataNascita, dtGara);

    while (context.mounted) {
      final delivered = current?.isDone ?? false;

      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(reg.fullName),
          content: Text(
            delivered
                ? l10n.liberatoriaPaperDelivered
                : l10n.liberatoriaPaperHint,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonClose),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx, 'print'),
              icon: const Icon(Icons.print),
              label: Text(l10n.liberatoriaPrint),
            ),
            if (delivered)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'undo'),
                child: Text(l10n.liberatoriaUndoDelivered),
              )
            else
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'delivered'),
                child: Text(l10n.liberatoriaMarkDelivered),
              ),
          ],
        ),
      );

      if (action == null) return;

      if (action == 'print') {
        final bytes = await LiberatoriaPdfBuilder.build(
          testo: template.testo,
          logos: logos,
          values: values(
            reg: reg,
            competitionName: competitionName,
            dtGara: dtGara,
            // Per i minorenni cartacei il tutore si scrive a mano
            tutore: minor ? '____________________' : '',
          ),
          signerLabel: minor
              ? l10n.liberatoriaSignerTutore
              : l10n.liberatoriaSignerAthlete,
        );

        await PdfOpener.open(
          bytes,
          'liberatoria_${reg.cognome}_${reg.nome}',
        );

        if (current == null) {
          final newId = await service.setPaperState(
            competitionId: competitionId,
            registrationId: reg.id,
            templateId: template.id,
            stato: 'stampata',
          );
          current = LiberatoriaAtletaModel(
            id: newId,
            registrationId: reg.id,
            templateId: template.id,
            modalita: 'cartacea',
            stato: 'stampata',
          );
        }
      } else {
        // 'delivered' / 'undo'
        await service.setPaperState(
          competitionId: competitionId,
          registrationId: reg.id,
          templateId: template.id,
          stato: action == 'delivered' ? 'consegnata' : 'stampata',
          existingId: current?.id,
        );
        return;
      }
    }
  }

  // ── DIGITALE ───────────────────────────────────────────
  static Future<void> _sign(
    BuildContext context,
    AppLocalizations l10n,
    LiberatoriaService service,
    CheckinRegistrationModel reg,
    String competitionId,
    String competitionName,
    DateTime dtGara,
    LiberatoriaTemplateModel template,
    List<Uint8List> logos,
  ) async {
    final minor = isMinor(reg.dataNascita, dtGara);

    final result = await showDialog<LiberatoriaSignResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LiberatoriaSignDialog(
        athleteName: reg.fullName,
        needsTutore: minor,
        logos: logos,
        renderText: (tutore) => LiberatoriaPlaceholders.render(
          template.testo,
          values(
            reg: reg,
            competitionName: competitionName,
            dtGara: dtGara,
            tutore: tutore,
          ),
        ),
      ),
    );

    if (result == null || !context.mounted) return;

    final bytes = await LiberatoriaPdfBuilder.build(
      testo: template.testo,
      logos: logos,
      values: values(
        reg: reg,
        competitionName: competitionName,
        dtGara: dtGara,
        tutore: result.tutore ?? '',
      ),
      signerLabel: minor
          ? '${l10n.liberatoriaSignerTutore}: ${result.tutore}'
          : reg.fullName,
      signaturePng: result.png,
    );

    final hash = sha256.convert(bytes).toString();

    await service.saveSigned(
      competitionId: competitionId,
      registrationId: reg.id,
      templateId: template.id,
      pdfBytes: bytes,
      hash: hash,
      tutoreNome: result.tutore,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.liberatoriaSigned)),
    );
  }
}