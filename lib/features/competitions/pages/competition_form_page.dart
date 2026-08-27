import 'package:boulder_competition/features/categories/data/category_service.dart';
import 'package:boulder_competition/features/categories/models/category_template_model.dart';
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

   AppLocalizations get l10n => AppLocalizations.of(context)!;

  final service = CompetitionService();
  final categoryService = CategoryService();

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
  bool createCategoriesFromTemplate = false;

  List<CategoryTemplateModel> categoryTemplates = [];

  String? selectedCategoryTemplateId;

  bool loadingCategoryTemplates = false;

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

    if (!isEdit) {
      loadCategoryTemplates();
    }

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

  Future<void> loadCategoryTemplates() async {
    setState(() => loadingCategoryTemplates = true);

    try {
      final templates = await categoryService.getCategoryTemplates();

      if (!mounted) return;

      setState(() {
        categoryTemplates = templates;
      });
    } catch (e) {
      if (!mounted) return;

      showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => loadingCategoryTemplates = false);
      }
    }
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
        l10n: l10n,
      );
    } catch (e) {
      showError('${l10n.competitionMessageCustom19} $e'); // Errore nella generazione del cartellino:
    } finally {
      if (mounted) setState(() => _exportingCartellino = false);
    }
  }
  // =======================================================
  // SAVE
  // =======================================================

  Future<void> save() async {
    final canWrite = await PermissionService.hasPermission(
      'competition.write',
    );

    if (!canWrite) {
      showError(
        l10n.competitionMessageCustom20, // Non hai i permessi per modificare le gare 
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;

    if (dtGara == null) {
      showError(l10n.competitionMessageCustom21); // Seleziona la data gara
      return;
    }

    if (!isEdit &&
        createCategoriesFromTemplate &&
        selectedCategoryTemplateId == null) {
      showError(
        l10n.competitionMessageCustom42, // Selezionare un template categorie
      );
      return;
    }

    final nrMaxRegistrations =
        int.tryParse(nrMaxRegistrationsController.text) ?? 0;
    final nrMaxFirstTurn =
        int.tryParse(nrMaxFirstTurnController.text) ?? 0;
    final nrMaxSecondTurn =
        int.tryParse(nrMaxSecondTurnController.text) ?? 0;

    if (isTurn) {
      if (nrMaxRegistrations <= 0) {
        showError(
          l10n.competitionMessageCustom22, // Inserisci un Nr. Massimo Iscritti maggiore di 0
        );
        return;
      }

      if ((nrMaxFirstTurn + nrMaxSecondTurn) >
          nrMaxRegistrations) {
        showError(
          l10n.competitionMessageCustom23, // La somma degli iscritti al primo e secondo turno non può superare il Nr. Massimo Iscritti
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
          final createdCompetition = await service.createCompetition(
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

          if (createCategoriesFromTemplate &&
              selectedCategoryTemplateId != null) {
            await categoryService.createCategoriesFromTemplate(
              competitionId: createdCompetition.id,
              templateId: selectedCategoryTemplateId!,
            );
          }
        }
 
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? l10n.competitionMessageCustom24  // Gara aggiornata
                : l10n.competitionMessageCustom25, // Gara creata
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
    //  final l10n = AppLocalizations.of(context)!;

          return BasePage(
            title: isEdit
                ? l10n.competitionMessageCustom1 // Modifica Gara
                : l10n.competitionMessageCustom2, // Nuova Gara
            subtitle: l10n.competitionMessageCustom3, // Gestione Gara
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
                      ? l10n.competitionMessageCustom4 // Salvataggio...
                      : l10n.commonSave, // Salva
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
                    tooltip: l10n.competitionMessageCustom5, // Stampa cartellino QR
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
                      labelText: l10n.competitionDescription, // Descrizione
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.competitionMessageCustom6; // Campo obbligatorio
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
                      labelText: l10n.competitionDate, // Data
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
                            labelText: l10n.boulderLabelNumber, // Nr Boulder
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.competitionMessageCustom6; // Campo obbligatorio
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
                              labelText: l10n.competitionMessageCustom7, // Nr Finalisti
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
                      labelText: l10n.competitionMessageCustom8, // Nr Massimo Iscritti
                    ),
                  ),

                  const SizedBox(height: 8),

                  SwitchListTile(
                    value: isTurn,
                    title: Text(l10n.competitionMessageCustom9), // Abilitazione Turni
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
                            labelText: l10n.competitionMessageCustom10, // Iscritti Primo Turno
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
                            labelText: l10n.competitionMessageCustom11, // Iscritti Secondo Turno
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
                      labelText: l10n.competitionMessageCustom12, // Quota Iscrizione
                      prefixIcon: const Icon(Icons.euro),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Visibile solo durante la creazione di una nuova gara.
                  if (!isEdit) ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: createCategoriesFromTemplate,
                            title: Text(
                              l10n.competitionMessageCustom40, // Vuoi creare le categorie da template
                            ),
                            onChanged: (value) {
                              setState(() {
                                createCategoriesFromTemplate = value;

                                // Se l'utente disabilita la creazione da template,
                                // azzeriamo anche il template eventualmente selezionato.
                                if (!value) {
                                  selectedCategoryTemplateId = null;
                                }
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 24),

                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: selectedCategoryTemplateId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.competitionMessageCustom41, // Template categorie
                            ),
                            items: categoryTemplates
                                .map(
                                  (template) => DropdownMenuItem<String>(
                                    value: template.id,
                                    child: Text(template.nome),
                                  ),
                                )
                                .toList(),
                            onChanged: createCategoriesFromTemplate &&
                                    !loadingCategoryTemplates
                                ? (value) {
                                    setState(() {
                                      selectedCategoryTemplateId = value;
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],

                  TextFormField(
                    controller: noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.competitionMessageCustom13, // Note
                    ),
                  ),

                  const SizedBox(height: 32),

                  SwitchListTile(
                    value: flIscrizioniChiuse,
                    title: Text(l10n.competitionMessageCustom14), // Iscrizioni chiuse
                    onChanged: (value) =>
                        setState(() => flIscrizioniChiuse = value),
                  ),

                  SwitchListTile(
                    value: flGaraChiusa,
                    title: Text(l10n.competitionMessageCustom15), // Gara chiusa
                    onChanged: (value) =>
                        setState(() => flGaraChiusa = value),
                  ),

                  SwitchListTile(
                    value: flGestionePresenze,
                    title: Text(l10n.competitionMessageCustom16), // Gestione presenze
                    onChanged: (value) =>
                        setState(() => flGestionePresenze = value),
                  ),

                  SwitchListTile(
                    value: flGestionePagamenti,
                    title: Text(l10n.competitionMessageCustom17), // Gestione pagamenti
                    onChanged: (value) =>
                        setState(() => flGestionePagamenti = value),
                  ),

                  SwitchListTile(
                    value: flGestioneOmaggi,
                    title: Text(l10n.competitionMessageCustom18), // Gestione omaggi
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