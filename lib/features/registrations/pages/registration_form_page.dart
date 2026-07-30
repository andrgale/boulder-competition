import 'package:flutter/material.dart';
import '../models/registration_model.dart';
import '../data/registration_service.dart';

class RegistrationFormPage extends StatefulWidget {
  final String competitionId;
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

  final formKey = GlobalKey<FormState>();

  late TextEditingController cognomeCtrl;
  late TextEditingController nomeCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController societaCtrl;
  late TextEditingController pettoraleCtrl;

  String? sesso;

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
    super.dispose();
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
        const SnackBar(
          content: Text(
            'Email non valida',
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

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Email già presente in questa competizione',
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
          const SnackBar(
            content: Text('Primo turno al completo, seleziona un\'altra opzione'),
          ),
        );
        setState(() => loading = false);
        return;
      }

      if (isSecondTurn && !secondTurnAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Secondo turno al completo, seleziona un\'altra opzione'),
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

      // ===============================================
      // UPDATE
      // ===============================================

      if (isEdit) {
        await service.updateRegistration(
          id: widget.registration!.id,
          cognome:
              cognomeCtrl.text.trim(),
          nome: nomeCtrl.text.trim(),
          email: email,
          societa:
              societaCtrl.text.trim(),
          pettorale: pettorale,
          sesso: sesso,
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
            'Errore: $e',
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


  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final isNew = !isEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? 'Modifica iscrizione'
            : 'Nuova iscrizione'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: cognomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cognome',
                ),
                validator: (v) =>
                    v == null || v.isEmpty
                        ? 'Obbligatorio'
                        : null,
              ),

              TextFormField(
                controller: nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
                validator: (v) =>
                    v == null || v.isEmpty
                        ? 'Obbligatorio'
                        : null,
              ),

              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Email obbligatoria';
                  }

                  final emailRegex = RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  );

                  if (!emailRegex.hasMatch(email)) {
                    return 'Formato email non valido';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: societaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Società',
                ),
              ),

              // =================================================
              // PETTORALE (AUTO IN NEW)
              // =================================================
              TextFormField(
                controller: pettoraleCtrl,
                enabled: !isNew, // 🔥 blocco edit in NEW
                decoration: const InputDecoration(
                  labelText: 'Pettorale',
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: sesso,
                items: const [
                  DropdownMenuItem(
                      value: 'M', child: Text('M')),
                  DropdownMenuItem(
                      value: 'F', child: Text('F')),
                ],
                onChanged: (v) =>
                    setState(() => sesso = v),
                decoration: const InputDecoration(
                  labelText: 'Sesso',
                ),
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Primo turno'),
                subtitle: !widget.isTurn
                    ? const Text('Gestione turni non attiva per questa gara')
                    : (!firstTurnAvailable
                        ? const Text('Turno al completo')
                        : null),
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
                title: const Text('Secondo turno'),
                subtitle: !widget.isTurn
                    ? const Text('Gestione turni non attiva per questa gara')
                    : (!secondTurnAvailable
                        ? const Text('Turno al completo')
                        : null),
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
                title: const Text('Presente'),
                value: flPresente,
                onChanged: (v) =>
                    setState(() => flPresente = v),
              ),

              SwitchListTile(
                title: const Text('Pagato'),
                value: flPagato,
                onChanged: (v) =>
                    setState(() => flPagato = v),
              ),

              SwitchListTile(
                title: const Text('Omaggio'),
                value: flOmaggio,
                onChanged: (v) =>
                    setState(() => flOmaggio = v),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : save,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Text(
                      isEdit ? 'Aggiorna' : 'Crea',
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