import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../../shared/widgets/base_page.dart';

import '../data/competition_service.dart';

import '../models/competition_model.dart';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
class CompetitionFormPage
    extends StatefulWidget {
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

  final descrizioneController =
      TextEditingController();

  final dtGaraController =
      TextEditingController();

  final nrBoulderController =
      TextEditingController();

  final quotaController =
      TextEditingController();

  final nrFinalistiController =
      TextEditingController();

  final noteController =
      TextEditingController();    

  DateTime? dtGara;

  bool flIscrizioniChiuse = false;

  bool flGaraChiusa = false;

  bool flGestionePresenze = false;

  bool flGestionePagamenti = false;

  bool flGestioneOmaggi = false;

  bool saving = false;

  final currencyFormatter =
      CurrencyTextInputFormatter.currency(
    locale: 'it',
    symbol: '€ ',
    decimalDigits: 2,
  );

  bool get isEdit =>
      widget.competition != null;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  // =======================================================
  // LOAD DATA
  // =======================================================

  void loadData() {
    final c = widget.competition;

    if (c == null) return;

    descrizioneController.text =
        c.descrizione;

    dtGara = c.dtGara;

    dtGaraController.text =
        formatDate(c.dtGara);

    nrBoulderController.text =
        c.nrBoulder.toString();

    quotaController.text =
        currencyFormatter.formatString(
      c.quotaIscrizione.toString(),
    );

    nrFinalistiController.text =
        c.nrFinalisti.toString();

    noteController.text =
        c.note ?? '';

    flIscrizioniChiuse =
        c.flIscrizioniChiuse;

    flGaraChiusa =
        c.flGaraChiusa;

    flGestionePresenze =
        c.flGestionePresenze;

    flGestionePagamenti =
        c.flGestionePagamenti;

    flGestioneOmaggi =
        c.flGestioneOmaggi;
  }

  // =======================================================
  // DATE FORMAT
  // =======================================================

  String formatDate(DateTime date) {
    return DateFormat(
      'dd/MM/yyyy',
    ).format(date);
  }

  // =======================================================
  // PICK DATE
  // =======================================================

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,

      initialDate:
          dtGara ?? DateTime.now(),

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      dtGara = picked;

      dtGaraController.text =
          formatDate(picked);
    });
  }

  // =======================================================
  // SAVE
  // =======================================================

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (dtGara == null) {
      showError(
        'Seleziona la data gara',
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      if (isEdit) {
        await service.updateCompetition(
          id: widget.competition!.id,

          descrizione:
              descrizioneController.text
                  .trim(),

          dtGara: dtGara!,

          nrBoulder:
              int.tryParse(
                    nrBoulderController.text,
                  ) ??
                  0,

          quotaIscrizione:
              currencyFormatter
                  .getUnformattedValue()
                  .toDouble(),

          nrFinalisti:
              int.tryParse(
                    nrFinalistiController.text,
                  ) ??
                  0,

          note:
              noteController.text.trim(),

          flIscrizioniChiuse:
              flIscrizioniChiuse,

          flGaraChiusa:
              flGaraChiusa,

          flGestionePresenze:
              flGestionePresenze,

          flGestionePagamenti:
              flGestionePagamenti,

          flGestioneOmaggi:
              flGestioneOmaggi,
        );
      } else {
        await service.createCompetition(
          descrizione:
              descrizioneController.text
                  .trim(),

          dtGara: dtGara!,

          nrBoulder:
              int.tryParse(
                    nrBoulderController.text,
                  ) ??
                  0,

          quotaIscrizione:
              currencyFormatter
                  .getUnformattedValue()
                  .toDouble(),

          nrFinalisti:
              int.tryParse(
                    nrFinalistiController.text,
                  ) ??
                  0,

          note:
              noteController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Competizione aggiornata'
                : 'Competizione creata',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showError(e.toString());
    } finally {
      if (!mounted) return;

      setState(() {
        saving = false;
      });
    }
  }

  // =======================================================
  // ERROR
  // =======================================================

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: isEdit
          ? 'Modifica Gara'
          : 'Nuova Gara',

      subtitle:
          'Gestione competizione',

      actions: [
        FilledButton.icon(
          onPressed:
              saving ? null : save,

          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save),

          label: Text(
            saving
                ? 'Salvataggio...'
                : 'Salva',
          ),
        ),
      ],

      // child: Center(
      //   child: ConstrainedBox(
      //     constraints:
      //         const BoxConstraints(
      //       maxWidth: 900,
      //     ),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(32),

              child: Form(
                key: formKey,

                child: ListView(
                  children: [
                    TextFormField(
                      controller:
                          descrizioneController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Descrizione',
                      ),

                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Campo obbligatorio';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller:
                          dtGaraController,

                      readOnly: true,

                      onTap: pickDate,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Data Gara',

                        suffixIcon: Icon(
                          Icons.calendar_today,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller:
                                nrBoulderController,

                            keyboardType:
                                TextInputType
                                    .number,

                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Nr Boulder',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Campo obbligatorio';
                              }
                                return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: TextFormField(
                            controller:
                                nrFinalistiController,

                            keyboardType:
                                TextInputType
                                    .number,

                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Nr Finalisti',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: quotaController,

                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      inputFormatters: [
                        currencyFormatter,
                      ],

                      decoration: const InputDecoration(
                        labelText: 'Quota Iscrizione',

                        prefixIcon: Icon(Icons.euro),
                      ),
                    ),


                    const SizedBox(height: 24),

                    TextFormField(
                      controller:
                          noteController,

                      maxLines: 4,

                      decoration:
                          const InputDecoration(
                        labelText: 'Note',
                      ),
                    ),

                    const SizedBox(height: 32),

                    SwitchListTile(
                      value:
                          flIscrizioniChiuse,

                      title: const Text(
                        'Iscrizioni chiuse',
                      ),

                      onChanged: (value) {
                        setState(() {
                          flIscrizioniChiuse =
                              value;
                        });
                      },
                    ),

                    SwitchListTile(
                      value: flGaraChiusa,

                      title: const Text(
                        'Gara chiusa',
                      ),

                      onChanged: (value) {
                        setState(() {
                          flGaraChiusa =
                              value;
                        });
                      },
                    ),

                    SwitchListTile(
                      value:
                          flGestionePresenze,

                      title: const Text(
                        'Gestione presenze',
                      ),

                      onChanged: (value) {
                        setState(() {
                          flGestionePresenze =
                              value;
                        });
                      },
                    ),

                    SwitchListTile(
                      value:
                          flGestionePagamenti,

                      title: const Text(
                        'Gestione pagamenti',
                      ),

                      onChanged: (value) {
                        setState(() {
                          flGestionePagamenti =
                              value;
                        });
                      },
                    ),

                    SwitchListTile(
                      value:
                          flGestioneOmaggi,

                      title: const Text(
                        'Gestione omaggi',
                      ),

                      onChanged: (value) {
                        setState(() {
                          flGestioneOmaggi =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
 //       ),
      ),
    );
  }
}