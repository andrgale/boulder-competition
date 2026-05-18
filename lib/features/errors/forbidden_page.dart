import 'package:flutter/material.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 72,
            ),

            const SizedBox(height: 24),

            const Text(
              'Accesso negato',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Non hai i permessi necessari',
            ),

            const SizedBox(height: 32),

            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Indietro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}