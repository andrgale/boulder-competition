import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Adatta il percorso al tuo progetto (o usa flutter_gen se lo preferisci).
import '../../l10n/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    final l10n = AppLocalizations.of(context)!;

    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      _showError(l10n.loginMessageCustom6); // Inserire la password attuale
      return;
    }
    if (newPassword.length < 8) {
      _showError(l10n.loginMessageCustom7); // La nuova password deve contenere almeno 8 caratteri
      return;
    }
    if (newPassword != confirmPassword) {
      _showError(l10n.loginMessageCustom8); // Le password non coincidono
      return;
    }

    setState(() => loading = true);

    try {
      // Verifica credenziali correnti ri-autenticando con email dell'utente loggato.
      final email = supabase.auth.currentUser?.email ?? '';

      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      // Aggiorna la password.
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      final user = supabase.auth.currentUser;
      if (user == null) throw Exception(l10n.loginMessageCustom9); // Utente non autenticato

      // Segna password_changed = true nel profilo.
      await supabase
          .from('profiles')
          .update({'password_changed': true})
          .eq('auth_user_id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginMessageCustom10)), // Password modificata correttamente
      );

      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo — stesso stile della LoginPage
                  Center(
                    child: Text(
                      l10n.loginMessageCustom1, // Boulder Competition
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      l10n.loginMessageCustom11, // Imposta una nuova password
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Password attuale
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: l10n.loginMessageCustom12, // Password attuale
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => obscureCurrent = !obscureCurrent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nuova password
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: l10n.loginMessageCustom13, // Nuova password
                      helperText: l10n.loginMessageCustom14, // Minimo 8 caratteri
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => obscureNew = !obscureNew,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Conferma password
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    onSubmitted: (_) => loading ? null : changePassword(),
                    decoration: InputDecoration(
                      labelText: l10n.loginMessageCustom15, // Conferma password
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => obscureConfirm = !obscureConfirm,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bottone salva
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : changePassword,
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.loginMessageCustom16), // SALVA PASSWORD
                    ),
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