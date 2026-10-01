import 'package:boulder_competition/core/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/app_snackbar.dart';
import '../data/athlete_registration_service.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class AthleteRegistrationPage extends StatefulWidget {
  const AthleteRegistrationPage({super.key});

  @override
  State<AthleteRegistrationPage> createState() =>
      _AthleteRegistrationPageState();
}

class _AthleteRegistrationPageState extends State<AthleteRegistrationPage> {
  final service = AthleteRegistrationService(
    Supabase.instance.client,
    EmailService(Supabase.instance.client),
  );

  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
        AppSnackbar.error(context, l10n.athleteMessageCustom20); // 'Utente già registrato'
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
          title: Text(l10n.athleteMessageCustom21), // 'Registrazione completata'
          content: Text(
            l10n.athleteMessageCustom22, // 'Il tuo account è stato creato ...'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.athleteMessageCustom23), // 'OK'
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.go(
        '/athlete-login',
        extra: {'email': email},
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, l10n.athleteMessageCustom26(e.toString())); // 'Errore registrazione: {error}'
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
                        Text(
                          l10n.athleteMessageCustom12, // 'Registrazione Atleta'
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.athleteMessageCustom13, // 'Crea il tuo account per partecipare'
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: cognomeCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.athleteMessageCustom14, // 'Cognome'
                            prefixIcon: const Icon(Icons.badge),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? l10n.athleteMessageCustom17 // 'Obbligatorio'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nomeCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.athleteMessageCustom15, // 'Nome'
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? l10n.athleteMessageCustom17 // 'Obbligatorio'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l10n.athleteMessageCustom16, // 'Email'
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return l10n.athleteMessageCustom18; // 'Email obbligatoria'
                            }

                            final emailRegex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );

                            if (!emailRegex.hasMatch(email)) {
                              return l10n.athleteMessageCustom19; // 'Formato email non valido'
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
                                : Text(l10n.athleteMessageCustom24), // 'REGISTRATI'
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => context.go('/athlete-login'),
                          child: Text(l10n.athleteMessageCustom25), // 'Hai già un account? Accedi'
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