import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
//import '../home/home_page.dart';

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


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

  Future<void> login() async {
    try {
      setState(() {
        loading = true;
      });

      await authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user =
          Supabase.instance.client.auth.currentUser!;

      final profile =
          await Supabase.instance.client
              .from('profiles')
              .select('password_changed')
              .eq('auth_user_id', user.id)
              .single();


      if (!mounted) return;

      if (profile['password_changed'] == false) {
        context.go('/change-password');
      } else {
        context.go('/dashboard');
      }


      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //    builder: (_) => const HomePage(),
      //   ),
      // );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Boulder Competition',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('LOGIN'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
