import 'dart:io';

import 'package:boulder_competition/core/services/locale_override_controller.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/base_page.dart';
import '../../../config/app_mode.dart';
import '../../../main.dart' show bootstrapAppKey;

class SecurityDashboardPage extends StatefulWidget {
  const SecurityDashboardPage({super.key});

  @override
  State<SecurityDashboardPage> createState() =>
      _SecurityDashboardPageState();
}

class _SecurityDashboardPageState extends State<SecurityDashboardPage> {
  final ScrollController _cardsScrollController = ScrollController();

  @override
  void dispose() {
    _cardsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    final l10n = AppLocalizations.of(context)!;

    final cards = [
      _SecurityCard(
        icon: Icons.manage_accounts,
        title: l10n.administrationMessaggeCustom1, // 'Ruoli'
        description: l10n.administrationMessaggeCustom2, // 'Definisci i ruoli applicativi e assegna menu e permessi.'
        route: '/security/roles',
        color: Colors.blue,
      ),
      _SecurityCard(
        icon: Icons.lock_outline,
        title: l10n.administrationMessaggeCustom3, // 'Permessi'
        description: l10n.administrationMessaggeCustom4, // 'Gestisci i codici permesso e le attività associate.'
        route: '/security/permissions',
        color: Colors.orange,
      ),
      _SecurityCard(
        icon: Icons.menu_book_outlined,
        title: l10n.administrationMessaggeCustom5, // 'Menu'
        description: l10n.administrationMessaggeCustom6, // 'Configura la struttura del menu e la visibilità per piattaforma.'
        route: '/security/menus',
        color: Colors.green,
      ),
      _SecurityCard(
        icon: Icons.people_outline,
        title: l10n.administrationMessaggeCustom7, // 'Utenti'
        description: l10n.administrationMessaggeCustom8, // 'Assegna ruoli agli utenti registrati.'
        route: '/security/profiles',
        color: Colors.purple,
      ),
      _SecurityCard(
        icon: Icons.email_outlined,
        title: l10n.administrationMessaggeCustom9, // 'Email'
        description: l10n.administrationMessaggeCustom10, // 'Gestisci configurazioni, template e impostazioni di invio email.'
        route: '/security/email',
        color: Colors.teal,
      ),
      _SecurityCard(
        icon: Icons.category_outlined,
        title: l10n.administrationMessageCustom170, // 'Categorie'
        description: l10n.administrationMessageCustom171, // 'Gestisci i template delle categorie'
        route: '/security/categorytemplates',
        color: Colors.indigo,
      ),
    ];

    return BasePage(
      title: l10n.administrationMessaggeCustom11, // 'Sicurezza'
      subtitle: l10n.administrationMessaggeCustom12, // 'Gestione ruoli, permessi, menu e utenti'
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Scrollbar(
              controller: _cardsScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                controller: _cardsScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < cards.length; index++) ...[
                      SizedBox(
                        width: 180,
                        child: cards[index],
                      ),
                      if (index < cards.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
            ),
            // =====================================================
            // STRUMENTI DI SVILUPPO — visibili solo con flag di test
            // =====================================================
            if (AppConfig.mostraCampo) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                l10n.administrationMessaggeCustom13, // 'Strumenti di sviluppo'
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.logout),
                label: Text(l10n.administrationMessaggeCustom14), // 'Reset configurazione cliente'
                onPressed: () => _confirmAndReset(context),
              ),
              // ───── forzatura lingua per test ─────
              const SizedBox(height: 24),
              const _LocaleOverrideSwitcher(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.administrationMessaggeCustom14), // 'Reset configurazione cliente'
        content: Text(
          l10n.administrationMessaggeCustom15, // 'Il dispositivo verrà scollegato dal cliente attuale. L\'applicazione si chiuderà automaticamente: al riavvio dovrai inserire nuovamente codice cliente e password.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.administrationMessaggeCustom16), // 'Annulla'
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.administrationMessaggeCustom17), // 'Conferma reset'
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
        title: Text(l10n.administrationMessaggeCustom18), // 'Reset completato'
        content: Text(
          l10n.administrationMessaggeCustom19, // 'L\'applicazione verrà chiusa. Riaprila per inserire il nuovo codice cliente e la password.'
        ),
        actions: [
          FilledButton(
            onPressed: () => _closeApp(),
            child: Text(l10n.administrationMessaggeCustom20), // 'Chiudi ora'
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

class _LocaleOverrideSwitcher extends StatelessWidget {
  const _LocaleOverrideSwitcher();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeOverrideNotifier,
      builder: (context, currentOverride, _) {
        final l10n = AppLocalizations.of(context)!;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.translate, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      l10n.administrationMessaggeCustom21, // 'Forza lingua (solo test)'
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currentOverride == null
                      ? l10n.administrationMessaggeCustom22 // 'Lingua attuale: automatica (sistema operativo)'
                      : l10n.administrationMessaggeCustom23(currentOverride.languageCode.toUpperCase()), // 'Lingua forzata: ${currentOverride.languageCode.toUpperCase()}'
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // opzione "automatica" per tornare al comportamento normale
                    ChoiceChip(
                      label: Text(l10n.administrationMessaggeCustom24), // 'Automatica'
                      selected: currentOverride == null,
                      onSelected: (_) => LocaleOverrideController.set(null),
                    ),
                    ...AppLocalizations.supportedLocales.map((locale) {
                      final selected = currentOverride?.languageCode ==
                          locale.languageCode;
                      return ChoiceChip(
                        label: Text(locale.languageCode.toUpperCase()),
                        selected: selected,
                        onSelected: (_) =>
                            LocaleOverrideController.set(locale),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}