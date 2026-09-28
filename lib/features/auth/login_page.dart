import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
//import '../home/home_page.dart';

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import '../../../core/services/permission_service.dart';

// Adatta il percorso al tuo progetto (o usa flutter_gen se lo preferisci).
import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authService = AuthService();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// [forceChangePassword] = true: dopo l'autenticazione porta sempre
  /// alla pagina di cambio password (cambio volontario).
  Future<void> login({bool forceChangePassword = false}) async {
    try {
      setState(() {
        loading = true;
      });

      await authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

//      PermissionService.clearCache();

      final user = Supabase.instance.client.auth.currentUser!;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('password_changed')
          .eq('auth_user_id', user.id)
          .single();

      if (!mounted) return;

      if (forceChangePassword || profile['password_changed'] == false) {
        context.go('/change-password');
      } else {
        context.go('/dashboard');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.loginMessageCustom1, // Boulder Competition
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: l10n.loginMessageCustom2, // Email
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    onSubmitted: (_) => loading ? null : login(),
                    decoration: InputDecoration(
                      labelText: l10n.loginMessageCustom3, // Password
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : () => login(),
                      child: loading
                          ? const CircularProgressIndicator()
                          : Text(l10n.loginMessageCustom4), // LOGIN
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () => login(forceChangePassword: true),
                    child: Text(l10n.loginMessageCustom5), // Cambia password
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