import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/base_page.dart';
import '../../../config/app_mode.dart';
import '../../../main.dart' show bootstrapAppKey;

class SecurityDashboardPage extends StatelessWidget {
  const SecurityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SecurityCard(
        icon: Icons.manage_accounts,
        title: 'Ruoli',
        description: 'Definisci i ruoli applicativi e assegna menu e permessi.',
        route: '/security/roles',
        color: Colors.blue,
      ),
      _SecurityCard(
        icon: Icons.lock_outline,
        title: 'Permessi',
        description: 'Gestisci i codici permesso e le attività associate.',
        route: '/security/permissions',
        color: Colors.orange,
      ),
      _SecurityCard(
        icon: Icons.menu_book_outlined,
        title: 'Menu',
        description: 'Configura la struttura del menu e la visibilità per piattaforma.',
        route: '/security/menus',
        color: Colors.green,
      ),
      _SecurityCard(
        icon: Icons.people_outline,
        title: 'Utenti',
        description: 'Assegna ruoli agli utenti registrati.',
        route: '/security/profiles',
        color: Colors.purple,
      ),
    ];

    return BasePage(
      title: 'Sicurezza',
      subtitle: 'Gestione ruoli, permessi, menu e utenti',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: cards,
          ),

          // =====================================================
          // STRUMENTI DI SVILUPPO — visibili solo con flag di test
          // =====================================================
          if (AppConfig.mostraCampo) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Strumenti di sviluppo',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.logout),
              label: const Text('Reset configurazione cliente'),
              onPressed: () => _confirmAndReset(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAndReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset configurazione cliente'),
        content: const Text(
          'Il dispositivo verrà scollegato dal cliente attuale. '
          "L'applicazione si chiuderà automaticamente: al riavvio dovrai "
          'inserire nuovamente codice cliente e password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Conferma reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // Pulisce SharedPreferences + fa signOut da Supabase
    await bootstrapAppKey.currentState?.resetToActivation();

    if (!context.mounted) return;

    // Messaggio finale prima della chiusura forzata
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset completato'),
        content: const Text(
          "L'applicazione verrà chiusa. Riaprila per inserire il nuovo "
          'codice cliente e la password.',
        ),
        actions: [
          FilledButton(
            onPressed: () => _closeApp(),
            child: const Text('Chiudi ora'),
          ),
        ],
      ),
    );

    // Chiusura automatica anche senza interazione, dopo una breve pausa
    // (fallback nel caso l'utente non prema il bottone)
    Future.delayed(const Duration(seconds: 2), _closeApp);
  }

  void _closeApp() {
    // exit(0) è l'approccio affidabile su desktop (macOS/Windows/Linux)
    // per forzare la terminazione del processo; SystemNavigator.pop()
    // su desktop non garantisce la chiusura effettiva.
    exit(0);
  }
}

class _SecurityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final Color color;

  const _SecurityCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}