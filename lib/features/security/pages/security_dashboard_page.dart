import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/base_page.dart';

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
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: cards,
      ),
    );
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
                  backgroundColor: color.withOpacity(0.12),
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
