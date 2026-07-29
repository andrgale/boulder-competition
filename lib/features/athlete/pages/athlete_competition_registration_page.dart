import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AthleteCompetitionRegistrationPage extends StatelessWidget {
  const AthleteCompetitionRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iscrizione Gara'),
        leading: IconButton(
          tooltip: 'Torna alla home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/athlete-home'),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Funzionalità in arrivo: qui l\'atleta potrà iscriversi alla gara.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}