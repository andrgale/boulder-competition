import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

import 'athlete_login_page.dart';

class AthleteChangePasswordPage extends StatefulWidget {
  /// Email e password attuale pre-valorizzate (passate dalla pagina di login)
  final String? initialEmail;
  final String? initialPassword;

  const AthleteChangePasswordPage({
    super.key,
    this.initialEmail,
    this.initialPassword,
  });

  @override
  State<AthleteChangePasswordPage> createState() =>
      _AthleteChangePasswordPageState();
}

class _AthleteChangePasswordPageState extends State<AthleteChangePasswordPage> {
  final emailController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool loading = false;

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.initialEmail ?? '';
    currentPasswordController.text = widget.initialPassword ?? '';
  }

  Widget _visibilityButton(bool obscured, VoidCallback onToggle) {
    return IconButton(
      icon: Icon(obscured ? Icons.visibility : Icons.visibility_off),
      onPressed: onToggle,
    );
  }

  Future<void> changePassword() async {
    try {
      final email = emailController.text.trim();
      final currentPassword = currentPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      // Validation with localized messages
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.athleteMessageCustom41)), // 'Inserire l'email'
        );
        return;
      }

      if (currentPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.athleteMessageCustom42)), // 'Inserire la password attuale'
        );
        return;
      }

      if (newPassword.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.athleteMessageCustom43)), // 'La nuova password deve contenere almeno 8 caratteri'
        );
        return;
      }

      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.athleteMessageCustom44)), // 'Le password non coincidono'
        );
        return;
      }

      setState(() {
        loading = true;
      });

      // verifica credenziali correnti
      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      // cambio password
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!mounted) return;

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.athleteMessageCustom47)), // 'Utente non autenticato'
        );
        return;
      }

      await supabase.from('profiles').update({'password_changed': true}).eq('auth_user_id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.athleteMessageCustom46)), // 'Password modificata correttamente'
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => AthleteLoginPage(initialEmail: email),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.athleteMessageCustom48(e.toString()))), // 'Errore cambio password: {error}'
      );
    } finally {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(l10n.athleteMessageCustom35), // 'Cambio Password'
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.athleteMessageCustom36, // 'Imposta una nuova password'
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.athleteMessageCustom16, // reuse 'Email'
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: l10n.athleteMessageCustom37, // 'Password attuale'
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: _visibilityButton(
                            obscureCurrent,
                            () => setState(() => obscureCurrent = !obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: l10n.athleteMessageCustom38, // 'Nuova password'
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: _visibilityButton(
                            obscureNew,
                            () => setState(() => obscureNew = !obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: l10n.athleteMessageCustom39, // 'Conferma password'
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: _visibilityButton(
                            obscureConfirm,
                            () => setState(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : changePassword,
                          child: loading
                              ? const CircularProgressIndicator()
                              : Text(l10n.athleteMessageCustom40), // 'SALVA PASSWORD'
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
    );
  }
}