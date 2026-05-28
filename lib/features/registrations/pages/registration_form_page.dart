import 'package:flutter/material.dart';
import '../models/registration_model.dart';
import '../data/registration_service.dart';

class RegistrationFormPage extends StatefulWidget {
  final String competitionId;
  final RegistrationModel? registration;

  const RegistrationFormPage({
    super.key,
    required this.competitionId,
    this.registration,
  });

  @override
  State<RegistrationFormPage> createState() =>
      _RegistrationFormPageState();
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

  bool loading = false;

  bool get isEdit => widget.registration != null;

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
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final pettorale = pettoraleCtrl.text.isEmpty
          ? null
          : int.parse(pettoraleCtrl.text);

      if (isEdit) {
        await service.updateRegistration(
          id: widget.registration!.id,
          cognome: cognomeCtrl.text.trim(),
          nome: nomeCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          societa: societaCtrl.text.trim(),
          pettorale: pettorale,
          sesso: sesso,
          flPresente: flPresente,
          flPagato: flPagato,
          flOmaggio: flOmaggio,
        );
      } else {
        await service.createRegistration(
          competitionId: widget.competitionId,
          cognome: cognomeCtrl.text.trim(),
          nome: nomeCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          societa: societaCtrl.text.trim(),
          pettorale: pettorale,
          sesso: sesso,
          flPresente: flPresente,
          flPagato: flPagato,
          flOmaggio: flOmaggio,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
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
                value: sesso,
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