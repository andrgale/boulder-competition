import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AthleteCheckinPage extends StatefulWidget {
  const AthleteCheckinPage({super.key});

  @override
  State<AthleteCheckinPage> createState() =>
      _AthleteCheckinPageState();
}

class _AthleteCheckinPageState
    extends State<AthleteCheckinPage> {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final societaCtrl = TextEditingController();

  // ── dati gara ────────────────────────────────────────────────
  /// Id della gara aperta, determinato in _loadCompetition().
  String? competitionId;
  Map<String, dynamic>? competition;

  bool loading = true;
  bool saving = false;

  String? blockingMessage;

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
      blockingMessage = 'Errore nel caricamento dei dati: $e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openScanner(BuildContext context) async {
    await context.push('/athlete-check-in-scan');
  }

  // =====================================================
  // RICERCA GARA APERTA
  // L'app gestisce una sola gara alla volta: in competitions può
  // esistere al massimo una riga con fl_gara_chiusa = false.
  // =====================================================
  Future<void> _loadCompetition() async {
    final data = await supabase
        .from('competitions')
        .select()
        .eq('fl_gara_chiusa', false)
        .maybeSingle();

    if (data == null) {
      blockingMessage = 'Nessuna gara in corso al momento';
      return;
    }

    competition = data;
    competitionId = data['id'] as String;

  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(

        appBar: AppBar(
            title: const Text('Check-in Gara'), 
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Torna alla home',
                icon: const Icon(Icons.home_outlined),
                onPressed: () => context.go('/athlete-home'),
              ),
            ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = competition != null
        ? 'Check-in gara: ${competition!['descrizione'] ?? ''}\n'
          'Data: ${_formatDate(competition!['dt_gara'])}'
        : 'Iscrizione Gara';    

    if (blockingMessage != null) {
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
                  blockingMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Torna alla home'),
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
          tooltip: 'Check-in gara',
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () => openScanner(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Torna alla home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/athlete-home'),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Clicca sull\'icona in alto a sinistra per effettuare il check-in',
            textAlign: TextAlign.center,
            style: TextStyle(
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