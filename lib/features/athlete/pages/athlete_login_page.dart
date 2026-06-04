import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

//import '../pages/athlete_boulders_page.dart';
//import '../pages/athlete_change_password_page.dart';
import 'package:go_router/go_router.dart';

class AthleteLoginPage extends StatefulWidget {
  const AthleteLoginPage({super.key});

  @override
  State<AthleteLoginPage> createState() =>
      _AthleteLoginPageState();
}

class _AthleteLoginPageState
    extends State<AthleteLoginPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final authService = AuthService();

  bool loading = false;

  Future<void> login() async {
    try {
      setState(() {
        loading = true;
      });

      await authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) =>
      //         const AthleteBouldersPage(),
      //   ),
      // );

      context.go('/athlete-boulders');

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
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
      backgroundColor:
          const Color(0xFFF6F8FB),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 420,
              ),

              child: Card(
                elevation: 4,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

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
                        Icons.terrain,
                        size: 72,
                        color: Colors.blue,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      const Text(
                        'Boulder Competition',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      const Text(
                        'Accesso Atleti',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),

                      const SizedBox(
                        height: 32,
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
                            passwordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Password',
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
                                  : login,

                          child: loading
                              ? const SizedBox(
                                  width:
                                      22,
                                  height:
                                      22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      TextButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) =>
                          //         const AthleteChangePasswordPage(),
                          //   ),
                          // );
                          context.go('/athlete-change-password');
                        },
                        child: const Text(
                          'Cambia password',
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      const Text(
                        'Password iniziale fornita dall\'organizzazione',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Colors.grey,
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