import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/app_menu.dart';
import '../../../core/services/menu_service.dart';
import '../../../shared/widgets/shell_user_service.dart';

class AthleteHomePage extends StatefulWidget {
  const AthleteHomePage({super.key});

  @override
  State<AthleteHomePage> createState() => _AthleteHomePageState();
}

class _AthleteHomePageState extends State<AthleteHomePage> {
  final _menuService = MenuService();
  final _shellUserService = ShellUserService();

  bool _loading = true;
  List<AppMenu> _menus = [];
  ShellUser _user = ShellUser.fallback();

  String? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_lastLocale != locale) {
      _lastLocale = locale;
      _load(locale);
    }
  }

  Future<void> _load(String locale) async {
    try {
      final results = await Future.wait([
        _menuService.getMenus(locale: locale),
        _shellUserService.fetchCurrentUser(),
      ]);

      final loadedMenus = (results[0] as List<AppMenu>)
          .where((m) => m.visible && m.mobile)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      if (!mounted) return;
      setState(() {
        _menus = loadedMenus;
        _user = results[1] as ShellUser;
        _loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/athlete-login');
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buongiorno';
    if (h < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: RefreshIndicator(
        onRefresh: () => _load(_lastLocale ?? 'it'),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 160,
              backgroundColor: Colors.green.shade600,
              actions: [
                IconButton(
                  tooltip: 'Esci',
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade700, Colors.green.shade400],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Text(
                          _user.iniziali,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _greeting,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _user.nomeCompleto,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _menus.isEmpty
                  ? SliverToBoxAdapter(child: _fallbackGrid(context))
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.05,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _MenuCard(
                          icon: _iconFor(_menus[index].icon),
                          label: _menus[index].label,
                          onTap: () => context.go(_menus[index].route),
                        ),
                        childCount: _menus.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrata solo se le voci menu per il ruolo 'athlete' non sono ancora
  /// configurate a DB: permette comunque di raggiungere le funzioni note.
  Widget _fallbackGrid(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.orange.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nessuna voce di menu configurata per il tuo profilo. '
                    'Contatta l\'organizzazione della gara.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.05,
          children: [
            _MenuCard(
              icon: Icons.terrain,
              label: 'Registrazione Boulder',
              onTap: () => context.go('/athlete-boulders'),
            ),
            _MenuCard(
              icon: Icons.app_registration,
              label: 'Iscrizione Gara',
              enabled: false,
              onTap: () {},
            ),
            _MenuCard(
              icon: Icons.qr_code_scanner,
              label: 'Check-in Gara',
              enabled: false,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  IconData _iconFor(String? name) {
    switch (name) {
      case 'dashboard':
        return Icons.dashboard;
      case 'terrain':
        return Icons.terrain;
      case 'leaderboard':
        return Icons.leaderboard;
      case 'sports_score':
        return Icons.sports_score;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'app_registration':
        return Icons.app_registration;
      case 'qr_code_scanner':
        return Icons.qr_code_scanner;
      case 'how_to_reg':
        return Icons.how_to_reg;
      case 'event_available':
        return Icons.event_available;
      case 'checklist':
        return Icons.checklist;
      case 'person':
        return Icons.person;
      default:
        return Icons.circle;
    }
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.green.shade700, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (!enabled) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Presto disponibile',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}