import 'package:boulder_competition/features/categories/data/category_rules.dart';
import 'package:boulder_competition/features/categories/data/category_service.dart';
import 'package:boulder_competition/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/registration_model.dart';
import '../data/registration_service.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class RegistrationFormPage extends StatefulWidget {
  final String competitionId;
  final DateTime competitionDate;
  final RegistrationModel? registration;

  // ── nuovi campi per controllo turni ─────────────────────────
  final bool isTurn;
  final int nrMaxFirstTurn;
  final int nrMaxSecondTurn;
  final int firstTurnCount;
  final int secondTurnCount;

  const RegistrationFormPage({
    super.key,
    required this.competitionId,
    required this.competitionDate,
    this.registration,
    this.isTurn = false,
    this.nrMaxFirstTurn = 0,
    this.nrMaxSecondTurn = 0,
    this.firstTurnCount = 0,
    this.secondTurnCount = 0,
  });

  @override
  State<RegistrationFormPage> createState() => _RegistrationFormPageState();
}
class _RegistrationFormPageState
    extends State<RegistrationFormPage> {
  final service = RegistrationService();
  final categoryService = CategoryService();

  AppLocalizations get l10n => AppLocalizations.of(context)!;
  
  final formKey = GlobalKey<FormState>();

  late TextEditingController cognomeCtrl;
  late TextEditingController nomeCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController societaCtrl;
  late TextEditingController pettoraleCtrl;
  late TextEditingController dataNascitaController;

  String? sesso;

  DateTime? dataNascita;

  bool flPresente = false;
  bool flPagato = false;
  bool flOmaggio = false;

  bool isFirstTurn = false;
  bool isSecondTurn = false;

  bool loading = false;

  bool get isEdit => widget.registration != null;

  // ── conteggio iscritti al turno, escludendo il record che si sta
  // modificando (altrimenti un atleta già iscritto al turno non
  // potrebbe mai salvare/mantenere la propria iscrizione) ───────────
  int get _effectiveFirstTurnCount =>
      widget.firstTurnCount -
      (isEdit && (widget.registration?.isFirstTurn ?? false) ? 1 : 0);

  int get _effectiveSecondTurnCount =>
      widget.secondTurnCount -
      (isEdit && (widget.registration?.isSecondTurn ?? false) ? 1 : 0);

  // ── vero se il campo va abilitato: is_turn deve essere true, e il
  // turno deve avere posti liberi oppure essere già quello selezionato
  // (così l'utente può comunque disattivarlo senza restare bloccato) ──
  bool get firstTurnAvailable =>
      widget.isTurn &&
      (isFirstTurn || _effectiveFirstTurnCount < widget.nrMaxFirstTurn);

  bool get secondTurnAvailable =>
      widget.isTurn &&
      (isSecondTurn || _effectiveSecondTurnCount < widget.nrMaxSecondTurn);

  @override
  void initState() {
    super.initState();

    final r = widget.registration;

    cognomeCtrl =
        TextEditingController(text: r?.cognome ?? '');
    nomeCtrl =
        TextEditingController(text: r?.nome ?? '');
    emailCtrl =
        TextEditingController(text: r?.email ?? '');
    societaCtrl =
        TextEditingController(text: r?.societa ?? '');

    sesso = r?.sesso;

    dataNascita = r?.dataNascita;

    dataNascitaController = TextEditingController(
      text: formatDate(dataNascita),
    );

    flPresente = r?.flPresente ?? false;
    flPagato = r?.flPagato ?? false;
    flOmaggio = r?.flOmaggio ?? false;

    isFirstTurn = r?.isFirstTurn ?? false;
    isSecondTurn = r?.isSecondTurn ?? false;

    pettoraleCtrl = TextEditingController();

    _initPettorale();
  }

  Future<void> _initPettorale() async {
    if (isEdit) {
      pettoraleCtrl.text =
          widget.registration!.pettorale?.toString() ??
              '';
      return;
    }

    final next = await service.getNextPettorale(
      widget.competitionId,
    );

    if (!mounted) return;

    setState(() {
      pettoraleCtrl.text = next.toString();
    });
  }

  @override
  void dispose() {
    cognomeCtrl.dispose();
    nomeCtrl.dispose();
    emailCtrl.dispose();
    societaCtrl.dispose();
    pettoraleCtrl.dispose();
    dataNascitaController.dispose();
    super.dispose();
  }

  Future<void> _selectDataNascita() async {
    final picked = await showDatePicker( 
    context: context, 
    initialDate: DateTime(2005), 
    firstDate: DateTime(1965), 
    lastDate: DateTime.now(), ); 

    if (picked == null) return;

    setState(() {
      dataNascita = picked;
      dataNascitaController.text = formatDate(picked);
    });

  }

  // =======================================================
  // DATE FORMAT
  // =======================================================
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

// =====================================================
// SAVE
// =====================================================

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = emailCtrl.text.trim();

    // ===================================================
    // CHECK EMAIL FORMAT
    // ===================================================

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.registrationMessageCustom14, // 'Email non valida'
          ),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // =================================================
      // CHECK EMAIL DUPLICATA
      // =================================================

      final exists =
          await service.emailExists(
        competitionId: widget.competitionId,
        email: email,
        excludeId:
            isEdit
                ? widget.registration!.id
                : null,
      );

      if (exists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.registrationMessageCustom15, // 'Email già presente in questa competizione'
            ),
          ),
        );

        setState(() {
          loading = false;
        });

        return;
      }

      if (isFirstTurn && !firstTurnAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.registrationMessageCustom16, // 'Primo turno al completo, seleziona un\'altra opzione'
            ),
          ),
        );
        setState(() => loading = false);
        return;
      }

      if (isSecondTurn && !secondTurnAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.registrationMessageCustom17, // 'Secondo turno al completo, seleziona un\'altra opzione'
            ),
          ),
        );
        setState(() => loading = false);
        return;
      }

      final pettorale =
          pettoraleCtrl.text.isEmpty
              ? null
              : int.parse(
                  pettoraleCtrl.text,
                );


      String? categoryId;

      // La categoria può essere calcolata solamente
      // se abbiamo la data di nascita.
      if (dataNascita != null) {
        final category = await _findAthleteCategory(
          dataNascita: dataNascita!,
          sesso: sesso,
        );

        categoryId = category?.id;
      }

      // Debug opzionale.
      debugPrint(
        'Categoria assegnata: $categoryId',
      );
      // ===============================================
      // UPDATE
      // ===============================================

      if (isEdit) {
        await service.updateRegistration(
          id: widget.registration!.id,
          cognome: cognomeCtrl.text.trim(),
          nome: nomeCtrl.text.trim(),
          email: email,
          societa: societaCtrl.text.trim(),
          categoryId: categoryId,
          pettorale: pettorale,
          sesso: sesso,
          dataNascita: dataNascita,
          flPresente: flPresente,
          flPagato: flPagato,
          flOmaggio: flOmaggio,
          isFirstTurn: isFirstTurn,
          isSecondTurn: isSecondTurn,
        );
      }

      // ===============================================
      // CREATE
      // ===============================================

      else {
        // ============================================
        // CREATE AUTH USER + PROFILE
        // ============================================

        final profileId =
            await service.createAthleteUser(
          email: emailCtrl.text.trim(),
          nome: nomeCtrl.text.trim(),
          cognome: cognomeCtrl.text.trim(),
        );

        // ============================================
        // CREATE REGISTRATION
        // ============================================

        await service.createRegistration(
          competitionId: widget.competitionId,
          profileId: profileId,
          cognome: cognomeCtrl.text.trim(),
          nome: nomeCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          societa: societaCtrl.text.trim(),
          pettorale: pettorale,
          sesso: sesso,
          dataNascita: dataNascita,
          categoryId: categoryId,
          flPresente: flPresente,
          flPagato: flPagato,
          flOmaggio: flOmaggio,
          isFirstTurn: isFirstTurn,
          isSecondTurn: isSecondTurn,
          ownerRegistration: 'admin',
        );
      }

      if (mounted) {
        Navigator.pop(
          context,
          true,
        );
      }
    } 
    catch (e) {
     if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<CategoryModel?> _findAthleteCategory({
    required DateTime dataNascita,
    required String? sesso,
  }) async {
    // 1. Recupera SOLO le categorie della gara corrente.
    final categories = await categoryService.getCategories(
      widget.competitionId,
    );

    // 2. Cerca la categoria usando:
    //    - data di nascita atleta
    //    - sesso atleta
    //    - data della gara
    return CategoryRules.findMatchingCategory(
      categories: categories,
      birthDate: dataNascita,
      competitionDate: widget.competitionDate,
      sesso: sesso,
    );
  }
  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = !isEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? l10n.registrationMessageCustom18 : l10n.registrationMessageCustom19, // 'Modifica iscrizione' / 'Nuova iscrizione'
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: cognomeCtrl,
                decoration: InputDecoration(
                  labelText: l10n.registrationMessageCustom20, // 'Cognome'
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.registrationMessageCustom22 : null, // 'Obbligatorio'
              ),

              TextFormField(
                controller: nomeCtrl,
                decoration: InputDecoration(
                  labelText: l10n.registrationMessageCustom21, // 'Nome'
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.registrationMessageCustom22 : null, // 'Obbligatorio'
              ),

              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: l10n.registrationMessageCustom23, // 'Email'
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return l10n.registrationMessageCustom24; // 'Email obbligatoria'
                  }

                  final emailRegex = RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  );

                  if (!emailRegex.hasMatch(email)) {
                    return l10n.registrationMessageCustom25; // 'Formato email non valido'
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: societaCtrl,
                decoration: InputDecoration(
                  labelText: l10n.registrationMessageCustom26, // 'Società'
                ),
              ),

              // =================================================
              // PETTORALE (AUTO IN NEW)
              // =================================================
              TextFormField(
                controller: pettoraleCtrl,
                enabled: !isNew, // 🔥 blocco edit in NEW
                decoration: InputDecoration(
                  labelText: l10n.registrationMessageCustom27, // 'Pettorale'
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: sesso,
                items: [
                  DropdownMenuItem(value: 'M', child: Text(l10n.registrationMessageCustom29)), // 'M'
                  DropdownMenuItem(value: 'F', child: Text(l10n.registrationMessageCustom30)), // 'F'
                ],
                onChanged: (v) => setState(() => sesso = v),
                decoration: InputDecoration(
                  labelText: l10n.registrationMessageCustom28, // 'Sesso'
                ),
              ),

              TextFormField(
                controller: dataNascitaController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.registrationMessageCustom31, // 'Data di nascita'
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: _selectDataNascita,
                validator: (_) {
                  if (dataNascita == null) {
                    return l10n.registrationMessageCustom32; // 'Campo obbligatorio'
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: Text(l10n.registrationMessageCustom33), // 'Primo turno'
                subtitle: !widget.isTurn
                    ? Text(l10n.registrationMessageCustom34) // 'Gestione turni non attiva per questa gara'
                    : (!firstTurnAvailable ? Text(l10n.registrationMessageCustom35) : null), // 'Turno al completo'
                value: isFirstTurn,
                onChanged: firstTurnAvailable
                    ? (v) {
                        setState(() {
                          isFirstTurn = v;
                          if (v) isSecondTurn = false;
                        });
                      }
                    : null,
              ),

              SwitchListTile(
                title: Text(l10n.registrationMessageCustom36), // 'Secondo turno'
                subtitle: !widget.isTurn
                    ? Text(l10n.registrationMessageCustom34) // 'Gestione turni non attiva per questa gara'
                    : (!secondTurnAvailable ? Text(l10n.registrationMessageCustom35) : null), // 'Turno al completo'
                value: isSecondTurn,
                onChanged: secondTurnAvailable
                    ? (v) {
                        setState(() {
                          isSecondTurn = v;
                          if (v) isFirstTurn = false;
                        });
                      }
                    : null,
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: Text(l10n.registrationMessageCustom37), // 'Presente'
                value: flPresente,
                onChanged: (v) => setState(() => flPresente = v),
              ),

              SwitchListTile(
                title: Text(l10n.registrationMessageCustom38), // 'Pagato'
                value: flPagato,
                onChanged: (v) => setState(() => flPagato = v),
              ),

              SwitchListTile(
                title: Text(l10n.registrationMessageCustom39), // 'Omaggio'
                value: flOmaggio,
                onChanged: (v) => setState(() => flOmaggio = v),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Text(
                      isEdit ? l10n.registrationMessageCustom40 : l10n.registrationMessageCustom41, // 'Aggiorna' / 'Crea'
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}