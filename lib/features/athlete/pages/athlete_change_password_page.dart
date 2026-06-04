import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'athlete_login_page.dart';

class AthleteChangePasswordPage
    extends StatefulWidget {
  const AthleteChangePasswordPage({
    super.key,
  });

  @override
  State<AthleteChangePasswordPage>
      createState() =>
          _AthleteChangePasswordPageState();
}

class _AthleteChangePasswordPageState
    extends State<AthleteChangePasswordPage> {
  final emailController =
      TextEditingController();

  final currentPasswordController =
      TextEditingController();

  final newPasswordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool loading = false;

  final supabase =
      Supabase.instance.client;

  Future<void> changePassword() async {
    try {
      final email =
          emailController.text.trim();

      final currentPassword =
          currentPasswordController.text
              .trim();

      final newPassword =
          newPasswordController.text.trim();

      final confirmPassword =
          confirmPasswordController.text
              .trim();

      if (email.isEmpty) {
        throw Exception(
          'Inserire l\'email',
        );
      }

      if (currentPassword.isEmpty) {
        throw Exception(
          'Inserire la password attuale',
        );
      }

      if (newPassword.length < 8) {
        throw Exception(
          'La nuova password deve contenere almeno 8 caratteri',
        );
      }

      if (newPassword != confirmPassword) {
        throw Exception(
          'Le password non coincidono',
        );
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
        UserAttributes(
          password: newPassword,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password modificata correttamente',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AthleteLoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
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

    currentPasswordController.dispose();

    newPasswordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text(
          'Cambio Password',
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 450,
              ),

              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      const Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: Colors.blue,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      const Text(
                        'Imposta una nuova password',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      TextField(
                        controller:
                            emailController,
                        keyboardType:
                            TextInputType
                                .emailAddress,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Email',
                          prefixIcon:
                              Icon(
                            Icons.email,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            currentPasswordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Password attuale',
                          prefixIcon:
                              Icon(
                            Icons.lock_outline,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            newPasswordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Nuova password',
                          prefixIcon:
                              Icon(
                            Icons.lock,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            confirmPasswordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Conferma password',
                          prefixIcon:
                              Icon(
                            Icons.lock,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 50,
                        child:
                            ElevatedButton(
                          onPressed:
                              loading
                                  ? null
                                  : changePassword,
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'SALVA PASSWORD',
                                ),
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