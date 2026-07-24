import 'package:boulder_competition/features/competitions/pages/competition_card_export_pdf.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../../shared/widgets/base_page.dart';

import '../data/competition_service.dart';

import '../models/competition_model.dart';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

//import '../../errors/forbidden_page.dart';
import '../../../core/services/permission_service.dart';

import 'package:boulder_competition/l10n/app_localizations.dart';

class CompetitionFormPage extends StatefulWidget {
  final CompetitionModel? competition;

  const CompetitionFormPage({
    super.key,
    this.competition,
  });

  @override
  State<CompetitionFormPage> createState() =>
      _CompetitionFormPageState();
}

class _CompetitionFormPageState
    extends State<CompetitionFormPage> {
  final service = CompetitionService();

  final formKey = GlobalKey<FormState>();

  final descrizioneController = TextEditingController();

  final dtGaraController = TextEditingController();

  final nrBoulderController = TextEditingController();

  final quotaController = TextEditingController();

  final nrFinalistiController = TextEditingController();

  final noteController = TextEditingController();

  final nrMaxRegistrationsController = TextEditingController();
  final nrMaxFirstTurnController = TextEditingController();
  final nrMaxSecondTurnController = TextEditingController();

  bool isTurn = false;

  DateTime? dtGara;

  bool flIscrizioniChiuse = false;

  bool flGaraChiusa = false;

  bool flGestionePresenze = false;

  bool flGestionePagamenti = false;

  bool flGestioneOmaggi = false;

  bool saving = false;

  bool checkingPermission = true;
  bool canWrite = false;

  final currencyFormatter = CurrencyTextInputFormatter.currency(
    locale: 'it',
    symbol: '€ ',
    decimalDigits: 2,
  );

  bool get isEdit => widget.competition != null;
  bool _exportingCartellino = false; 

  @override
  void initState() {
    super.initState();
    loadData();

    checkPermission();
  }

  // =======================================================
  // LOAD DATA
  // =======================================================

  void loadData() {
    final c = widget.competition;

    if (c == null) return;

    descrizioneController.text = c.descrizione;

    dtGara = c.dtGara;
    dtGaraController.text = formatDate(c.dtGara);

    nrBoulderController.text = c.nrBoulder.toString();

    nrMaxRegistrationsController.text = c.nrMaxRegistrations.toString();
    isTurn = c.isTurn;
    nrMaxFirstTurnController.text = c.nrMaxFirstTurn.toString();
    nrMaxSecondTurnController.text = c.nrMaxSecondTurn.toString();

    // ✅ FIX: formatDouble accetta direttamente il double dal DB (es. 25.0)
    //    e lo converte correttamente in "€ 25,00".
    //    formatString("25.0") invece trattava i caratteri come cifre grezze
    //    producendo "€ 0,25" o "€ 2,50" a seconda del valore.
    quotaController.text = currencyFormatter.formatDouble(
      c.quotaIscrizione,
    );

    nrFinalistiController.text = c.nrFinalisti.toString();

    noteController.text = c.note ?? '';

    flIscrizioniChiuse = c.flIscrizioniChiuse;
    flGaraChiusa = c.flGaraChiusa;
    flGestionePresenze = c.flGestionePresenze;
    flGestionePagamenti = c.flGestionePagamenti;
    flGestioneOmaggi = c.flGestioneOmaggi;
  }

  Future<void> checkPermission() async {
    final allowed =
        await PermissionService.hasPermission(
      'competition.write',
    );

    if (!mounted) return;

    setState(() {
      canWrite = allowed;
      checkingPermission = false;
    });
  }

  // =======================================================
  // DATE FORMAT
  // =======================================================

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // =======================================================
  // PICK DATE
  // =======================================================

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dtGara ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      dtGara = picked;
      dtGaraController.text = formatDate(picked);
    });
  }

  Future<void> printCard() async {
    final c = widget.competition;
    if (c == null || _exportingCartellino) return;

     setState(() => _exportingCartellino = true);

    try {
      await CompetitionCardExportPdf.exportAndShare(
        competitionId: c.id,
        descrizione: descrizioneController.text.trim(),
        dtGara: dtGara ?? c.dtGara,
      );
    } catch (e) {
      showError('Errore nella generazione del cartellino: $e');
    } finally {
      if (mounted) setState(() => _exportingCartellino = false);
    }
  }
  // =======================================================
  // SAVE
  // =======================================================

  Future<void> save() async {

    final canWrite =
        await PermissionService.hasPermission(
      'competition.write',
    );

    if (!canWrite) {
      showError(
        'Non hai i permessi per modificare le gare',
      );
      return;
    }


    if (!formKey.currentState!.validate()) return;

    if (dtGara == null) {
      showError('Seleziona la data gara');
      return;
    }

    final nrMaxRegistrations = int.tryParse(nrMaxRegistrationsController.text) ?? 0;
    final nrMaxFirstTurn = int.tryParse(nrMaxFirstTurnController.text) ?? 0;
    final nrMaxSecondTurn = int.tryParse(nrMaxSecondTurnController.text) ?? 0;

    if (isTurn) {
      if (nrMaxRegistrations <= 0) {
        showError('Inserisci un Nr. Massimo Iscritti maggiore di 0');
        return;
      }
      if ((nrMaxFirstTurn + nrMaxSecondTurn) > nrMaxRegistrations) {
        showError(
          'La somma degli iscritti al primo e secondo turno non può superare il Nr. Massimo Iscritti',
        );
        return;
      }
    }

    setState(() => saving = true);

    try {
      if (isEdit) {
        await service.updateCompetition(
          id: widget.competition!.id,
          descrizione: descrizioneController.text.trim(),
          dtGara: dtGara!,
          nrBoulder: int.tryParse(nrBoulderController.text) ?? 0,
          quotaIscrizione:
              currencyFormatter.getUnformattedValue().toDouble(),
          nrFinalisti: int.tryParse(nrFinalistiController.text) ?? 0,
          note: noteController.text.trim(),
          flIscrizioniChiuse: flIscrizioniChiuse,
          flGaraChiusa: flGaraChiusa,
          flGestionePresenze: flGestionePresenze,
          flGestionePagamenti: flGestionePagamenti,
          flGestioneOmaggi: flGestioneOmaggi,
          nrMaxRegistrations: nrMaxRegistrations,
          isTurn: isTurn,
          nrMaxFirstTurn: nrMaxFirstTurn,
          nrMaxSecondTurn: nrMaxSecondTurn,
        );
      } else {
        await service.createCompetition(
          descrizione: descrizioneController.text.trim(),
          dtGara: dtGara!,
          nrBoulder: int.tryParse(nrBoulderController.text) ?? 0,
          quotaIscrizione:
              currencyFormatter.getUnformattedValue().toDouble(),
          nrFinalisti: int.tryParse(nrFinalistiController.text) ?? 0,
          note: noteController.text.trim(),
          nrMaxRegistrations: nrMaxRegistrations,
          isTurn: isTurn,
          nrMaxFirstTurn: nrMaxFirstTurn,
          nrMaxSecondTurn: nrMaxSecondTurn,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Competizione aggiornata' : 'Competizione creata',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showError(e.toString());
    } finally {
      if (!mounted) return;
      setState(() => saving = false);
    }
  }

  // =======================================================
  // ERROR
  // =======================================================

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;

          return BasePage(
            title: isEdit
                ? l10n.competitionMessageCustom1
                : l10n.competitionMessageCustom2,
            subtitle: l10n.competitionMessageCustom3,
            actions: [
              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  saving
                      ? l10n.competitionMessageCustom4
                      : l10n.commonSave,
                ),
              ),
          // ── bottone cartellino: solo in modifica ──────────
          if (isEdit)
            _exportingCartellino
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: l10n.competitionMessageCustom5,
                    icon: const Icon(Icons.qr_code),
                    onPressed: isEdit ? printCard : null,
                  ),

      ],
      child: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: descrizioneController,
                    decoration: InputDecoration(
                      labelText: l10n.competitionDescription,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.competitionMessageCustom6;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: dtGaraController,
                    readOnly: true,
                    onTap: pickDate,
                      decoration: InputDecoration(
                      labelText: l10n.competitionDate,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: 
                          TextFormField(
                          controller: nrBoulderController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.boulderLabelNumber,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.competitionMessageCustom6;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: 
                          TextFormField(
                            controller: nrFinalistiController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.competitionMessageCustom7,
                            ),
                          ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: nrMaxRegistrationsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.competitionMessageCustom8,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SwitchListTile(
                    value: isTurn,
                    title: Text(l10n.competitionMessageCustom9),
                    onChanged: (value) => setState(() => isTurn = value),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: nrMaxFirstTurnController,
                          enabled: isTurn,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.competitionMessageCustom10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: nrMaxSecondTurnController,
                          enabled: isTurn,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.competitionMessageCustom11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: quotaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [currencyFormatter],
                    decoration: InputDecoration(
                      labelText: l10n.competitionMessageCustom12,
                      prefixIcon: const Icon(Icons.euro),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.competitionMessageCustom13,
                    ),
                  ),

                  const SizedBox(height: 32),

                  SwitchListTile(
                    value: flIscrizioniChiuse,
                    title: Text(l10n.competitionMessageCustom14),
                    onChanged: (value) =>
                        setState(() => flIscrizioniChiuse = value),
                  ),

                  SwitchListTile(
                    value: flGaraChiusa,
                    title: Text(l10n.competitionMessageCustom15),
                    onChanged: (value) =>
                        setState(() => flGaraChiusa = value),
                  ),

                  SwitchListTile(
                    value: flGestionePresenze,
                    title: Text(l10n.competitionMessageCustom16),
                    onChanged: (value) =>
                        setState(() => flGestionePresenze = value),
                  ),

                  SwitchListTile(
                    value: flGestionePagamenti,
                    title: Text(l10n.competitionMessageCustom17),
                    onChanged: (value) =>
                        setState(() => flGestionePagamenti = value),
                  ),

                  SwitchListTile(
                    value: flGestioneOmaggi,
                    title: Text(l10n.competitionMessageCustom18),
                    onChanged: (value) =>
                        setState(() => flGestioneOmaggi = value),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}