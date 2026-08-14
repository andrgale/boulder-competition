import 'package:boulder_competition/core/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:go_router/go_router.dart';

import '../../../../shared/app_snackbar.dart';
import '../../data/security_profile_service.dart';

class ProfileFormPage extends StatefulWidget {
  final String? profileId; // se presente -> cancella
  final String? nome;
  final String? cognome;
  final String? email;


  const ProfileFormPage({
    super.key,
    this.profileId,
    this.nome,
    this.cognome,
    this.email,
  });

  @override
  State<ProfileFormPage> createState() =>
      _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final service = SecurityProfileService(
    Supabase.instance.client,
    EmailService(Supabase.instance.client),
  );


  final formKey = GlobalKey<FormState>();

  final cognomeCtrl = TextEditingController();
  final nomeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  bool loading = false;

  bool get isDelete => widget.profileId != null;

  @override
  void dispose() {
    cognomeCtrl.dispose();
    nomeCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  // =======================================================
  // CREATE USER
  // =======================================================

  Future<void> createUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await service.registerAthlete(
        email: emailCtrl.text.trim(),
        nome: nomeCtrl.text.trim(),
        cognome: cognomeCtrl.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Errore creazione: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteUser() async {
  if (widget.profileId == null) return;

  setState(() => loading = true);

  try {
  //  debugPrint('DELETE START ${widget.profileId}');

      await service.deleteAthleteUser(
      profileId: widget.profileId!,
    );

 //   debugPrint('DELETE DONE');

    if (!mounted) return;

    Navigator.pop(context, true);
  } catch (e, stack) {
    debugPrint('DELETE ERROR: $e');
    debugPrintStack(stackTrace: stack);

    if (!mounted) return;

    AppSnackbar.error(context, 'Errore eliminazione: $e');
  } finally {
    if (mounted) setState(() => loading = false);
  }
}


  // =======================================================
  // UI
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isDelete
            ? 'Cancella Utente'
            : 'Nuovo Utente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isDelete
            ? _buildDeleteView()
            : _buildCreateView(),
      ),
    );
  }

  // =======================================================
  // CREATE VIEW
  // =======================================================

    Widget _buildCreateView() {
      return Form(
        key: formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: cognomeCtrl,
              decoration:
                  const InputDecoration(labelText: 'Cognome'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Obbligatorio' : null,
            ),

            TextFormField(
              controller: nomeCtrl,
              decoration:
                  const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Obbligatorio' : null,
            ),

            TextFormField(
              controller: emailCtrl,
              decoration:
                  const InputDecoration(labelText: 'Email'),
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

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading ? null : createUser,
              child: const Text('Crea utente'),
            ),
          ],
        ),
      );
    }

    // =======================================================
    // DELETE VIEW
    // =======================================================

  Widget _buildDeleteView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conferma eliminazione utente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.cognome ?? ''} ${widget.nome ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.email ?? ''),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),

            const SizedBox(width: 12),

            FilledButton.icon(
              onPressed: loading ? null : deleteUser,
              icon: const Icon(Icons.delete),
              label: const Text('Cancella'),
            ),
          ],
        ),
      ],
    );
  }

}