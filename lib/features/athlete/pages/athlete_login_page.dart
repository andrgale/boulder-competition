import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:boulder_competition/l10n/app_localizations.dart';
import '../../../core/services/auth_service.dart';

class AthleteLoginPage extends StatefulWidget {
  /// Email pre-valorizzata (es. dopo registrazione o cambio password)
  final String? initialEmail;

  const AthleteLoginPage({super.key, this.initialEmail});

  @override
  State<AthleteLoginPage> createState() => _AthleteLoginPageState();
}

class _AthleteLoginPageState extends State<AthleteLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
    AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool loading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      emailController.text = widget.initialEmail!;
    }
  }

  Future<void> login() async {
    try {
      setState(() {
        loading = true;
      });

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await authService.signIn(
        email: email,
        password: password,
      );

      final user = Supabase.instance.client.auth.currentUser!;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('password_changed')
          .eq('auth_user_id', user.id)
          .single();

      if (!mounted) return;

      if (profile['password_changed'] == false) {
        context.go(
          '/athlete-change-password',
          extra: {
            'email': email,
            'password': password,
          },
        );
      } else {
        context.go('/athlete-home');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.athleteMessageCustom34(e.toString())),
        ),
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
    passwordController.dispose();
    super.dispose();
  }

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.terrain,
                        size: 72,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.athleteMessageCustom27, // 'Boulder Competition'
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.athleteMessageCustom28, // 'Accesso Atleti'
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.athleteMessageCustom29, // 'Email'
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.athleteMessageCustom30, // 'Password'
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.athleteMessageCustom31), // 'LOGIN'
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          context.go(
                            '/athlete-change-password',
                            extra: {
                              'email': emailController.text.trim(),
                              'password': passwordController.text,
                            },
                          );
                        },
                        child: Text(l10n.athleteMessageCustom32), // 'Cambia password'
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          context.go('/athlete-registration');
                        },
                        child: Text(l10n.athleteMessageCustom33), // 'Non hai un account? Registrati'
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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