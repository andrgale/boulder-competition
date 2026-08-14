import 'package:boulder_competition/core/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/app_snackbar.dart';
import '../data/athlete_registration_service.dart';

class AthleteRegistrationPage extends StatefulWidget {
  const AthleteRegistrationPage({super.key});

  @override
  State<AthleteRegistrationPage> createState() =>
      _AthleteRegistrationPageState();
}

class _AthleteRegistrationPageState
    extends State<AthleteRegistrationPage> {

  final service = AthleteRegistrationService(
    Supabase.instance.client,
    EmailService(Supabase.instance.client),
  );

  final formKey = GlobalKey<FormState>();

  final cognomeCtrl = TextEditingController();
  final nomeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    cognomeCtrl.dispose();
    nomeCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  // =====================================================
  // REGISTER
  // =====================================================

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final email = emailCtrl.text.trim();

      final exists = await service.emailExists(email);

      if (exists) {
        if (!mounted) return;
        AppSnackbar.error(context, 'Utente già registrato');
        return;
      }

      await service.registerAthlete(
        email: email,
        nome: nomeCtrl.text.trim(),
        cognome: cognomeCtrl.text.trim(),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Registrazione completata'),
          content: const Text(
            'Il tuo account è stato creato con successo. '
            'Controlla la tua email per la password iniziale.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.go('/athlete-login');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Errore registrazione: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_add,
                          size: 72,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Registrazione Atleta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Crea il tuo account per partecipare',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: cognomeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Cognome',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Obbligatorio'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nomeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Obbligatorio'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
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
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : register,
                            child: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('REGISTRATI'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => context.go('/athlete-login'),
                          child: const Text(
                            'Hai già un account? Accedi',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}