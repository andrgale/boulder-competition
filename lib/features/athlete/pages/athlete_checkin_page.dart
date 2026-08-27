import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class AthleteCheckinPage extends StatefulWidget {
  const AthleteCheckinPage({super.key});

  @override
  State<AthleteCheckinPage> createState() => _AthleteCheckinPageState();
}

class _AthleteCheckinPageState extends State<AthleteCheckinPage> {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  final societaCtrl = TextEditingController();

  // ── dati gara ────────────────────────────────────────────────
  /// Id della gara aperta, determinato in _loadCompetition().
  String? competitionId;
  Map<String, dynamic>? competition;

  bool loading = true;
  bool saving = false;

  // Per localizzazione: memorizziamo una chiave di blocco (senza testo
  // localizzato) finché non abbiamo un BuildContext per tradurre.
  String? blockingKey;
  String? blockingArg;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    societaCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await _loadCompetition();
    } catch (e) {
      blockingKey = 'loading_error';
      blockingArg = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openScanner(BuildContext context) async {
    await context.push('/athlete-check-in-scan');
  }

  // =====================================================
  // RICERCA GARA APERTA
  // =====================================================
  Future<void> _loadCompetition() async {
    final data = await supabase
        .from('competitions')
        .select()
        .eq('fl_gara_chiusa', false)
        .maybeSingle();

    if (data == null) {
      blockingKey = 'no_competition';
      return;
    }

    competition = data;
    competitionId = data['id'] as String;
  }

  String _localizedBlockingMessage(AppLocalizations l10n) {
    switch (blockingKey) {
      case 'loading_error':
        return l10n.athleteMessageCustom49(blockingArg ?? '');
      case 'no_competition':
        return l10n.athleteMessageCustom81;
      default:
        return '';
    }
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.athleteMessageCustom79), // 'Check-in Gara'
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: l10n.athleteMessageCustom59, // 'Torna alla home'
              icon: const Icon(Icons.home_outlined),
              onPressed: () => context.go('/athlete-home'),
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = competition != null
        ? '${l10n.athleteMessageCustom79}: ${(competition!['descrizione'] as String?) ?? ''}\n${l10n.athleteMessageCustom77}: ${_formatDate(competition!['dt_gara'])}'
        : l10n.athleteMessageCustom79;

    if (blockingKey != null) {
      final message = _localizedBlockingMessage(l10n);
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 76,
          title: Text(
            title,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, height: 1.2),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home_outlined),
                  label: Text(l10n.athleteMessageCustom59),
                  onPressed: () => context.go('/athlete-home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Text(
          title,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            height: 1.2,
          ),
        ),
        leading: IconButton(
          tooltip: l10n.athleteMessageCustom79, // use same label as page title
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () => openScanner(context),
        ),
        actions: [
          IconButton(
            tooltip: l10n.athleteMessageCustom59,
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/athlete-home'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            l10n.athleteMessageCustom80,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final date = DateTime.parse(raw.toString());
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return raw.toString();
    }
  }
}