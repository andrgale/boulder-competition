import 'package:boulder_competition/features/registrations/data/registration_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pagina di iscrizione dell'atleta a una gara boulder.
///
/// Rispecchia i controlli presenti nella pagina di iscrizione lato
/// amministratore (RegistrationFormPage), con l'aggiunta dei controlli
/// specifici richiesti per l'iscrizione "self service" da smartphone:
///  - gara con iscrizioni aperte (fl_iscrizioni_chiuse = false)
///  - atleta non già iscritto (email già presente in registrations)
///  - numero massimo iscritti raggiunto (nr_max_registrations)
///  - gestione turni (is_turn, nr_max_first_turn, nr_max_second_turn)
///
/// L'applicazione gestisce una sola gara alla volta: in `competitions`
/// può esistere al massimo una riga con `fl_iscrizioni_chiuse = false`.
/// Per questo la pagina non riceve un `competitionId` dall'esterno: lo
/// determina da sé cercando l'eventuale gara con iscrizioni aperte.
class AthleteCompetitionRegistrationPage extends StatefulWidget {
  const AthleteCompetitionRegistrationPage({super.key});

  @override
  State<AthleteCompetitionRegistrationPage> createState() =>
      _AthleteCompetitionRegistrationPageState();
}

class _AthleteCompetitionRegistrationPageState
    extends State<AthleteCompetitionRegistrationPage> {
  final supabase = Supabase.instance.client;
  final service = RegistrationService();
  final formKey = GlobalKey<FormState>();

  final societaCtrl = TextEditingController();

  // ── dati gara ────────────────────────────────────────────────
  /// Id della gara con iscrizioni aperte, determinato in _loadCompetition().
  String? competitionId;
  Map<String, dynamic>? competition;
  bool isTurn = false;
  int nrMaxFirstTurn = 0;
  int nrMaxSecondTurn = 0;
  int nrMaxRegistrations = 0;

  int firstTurnCount = 0;
  int secondTurnCount = 0;
  int totalRegistrationsCount = 0;

  // ── dati atleta (da profiles, via auth_user_id) ────────────────
  String? profileId;
  String cognome = '';
  String nome = '';
  String email = '';
  String? sesso;

  bool isFirstTurn = false;
  bool isSecondTurn = false;

  int? pettorale;

  bool loading = true;
  bool saving = false;

  /// Se valorizzato, la pagina mostra solo questo messaggio + bottone home
  /// (gara chiusa, già iscritto, posti esauriti, ecc.)
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

      if (blockingMessage == null) {
        await _loadProfile();
      }

      if (blockingMessage == null) {
        await _checkAlreadyRegistered();
      }

      if (blockingMessage == null) {
        await _loadRegistrationCounts();
        await _computeNextPettorale();
      }
    } catch (e) {
      blockingMessage = 'Errore nel caricamento dei dati: $e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // =====================================================
  // RICERCA GARA CON ISCRIZIONI APERTE
  // L'app gestisce una sola gara alla volta: in competitions può
  // esistere al massimo una riga con fl_iscrizioni_chiuse = false.
  // =====================================================
  Future<void> _loadCompetition() async {
    final data = await supabase
        .from('competitions')
        .select()
        .eq('fl_iscrizioni_chiuse', false)
        .maybeSingle();

    if (data == null) {
      blockingMessage = 'Nessuna gara con iscrizioni aperte al momento';
      return;
    }

    competition = data;
    competitionId = data['id'] as String;

    isTurn = data['is_turn'] ?? false;
    nrMaxFirstTurn = data['nr_max_first_turn'] ?? 0;
    nrMaxSecondTurn = data['nr_max_second_turn'] ?? 0;
    nrMaxRegistrations = data['nr_max_registrations'] ?? 0;
  }

  // =====================================================
  // CARICAMENTO PROFILO ATLETA (auth_user_id -> profiles)
  // =====================================================
  Future<void> _loadProfile() async {
    final authUserId = supabase.auth.currentUser?.id;

    if (authUserId == null) {
      blockingMessage = 'Utente non autenticato';
      return;
    }

    final profile = await supabase
        .from('profiles')
        .select()
        .eq('auth_user_id', authUserId)
        .single();

    profileId = profile['id'] as String;
    cognome = profile['cognome'] ?? '';
    nome = profile['nome'] ?? '';
    email = profile['email'] ?? '';
    sesso = profile['sesso'];
  }

  // =====================================================
  // CONTROLLO ATLETA GIA' ISCRITTO (per email)
  // =====================================================
  Future<void> _checkAlreadyRegistered() async {
    final exists = await service.emailExists(
      competitionId: competitionId!,
      email: email,
    );

    if (exists) {
      blockingMessage =
          'Iscrizione già presente, cerca la mail nella tua cassetta di posta';
    }
  }

  // =====================================================
  // CONTEGGIO ISCRITTI (totale + per turno)
  // =====================================================
  Future<void> _loadRegistrationCounts() async {
    final registrations =
        await service.getRegistrations(competitionId!);

    totalRegistrationsCount = registrations.length;
    firstTurnCount = registrations.where((r) => r.isFirstTurn).length;
    secondTurnCount = registrations.where((r) => r.isSecondTurn).length;

    if (nrMaxRegistrations > 0 &&
        totalRegistrationsCount >= nrMaxRegistrations) {
      blockingMessage =
          'Numero massimo di iscritti raggiunto per questa gara';
    }
  }

  bool get firstTurnAvailable => isTurn && firstTurnCount < nrMaxFirstTurn;

  bool get secondTurnAvailable => isTurn && secondTurnCount < nrMaxSecondTurn;

   /// Testo del turno scelto da inserire nella mail di conferma.
  /// null se la gestione turni non è attiva o non è stato scelto un turno.
  String? get _turnoText {
    if (!isTurn) return null;
    if (isFirstTurn) return 'Primo turno';
    if (isSecondTurn) return 'Secondo turno';
    return null;
  }

  // =====================================================
  // CALCOLO PROSSIMO PETTORALE DISPONIBILE
  // =====================================================
  Future<void> _computeNextPettorale() async {
    pettorale = await service.getNextPettorale(competitionId!);
  }

  // =====================================================
  // SALVATAGGIO ISCRIZIONE
  // =====================================================
  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    if (isTurn && !isFirstTurn && !isSecondTurn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona un turno')),
      );
      return;
    }

    if (isFirstTurn && !firstTurnAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Primo turno al completo, seleziona un\'altra opzione')),
      );
      return;
    }

    if (isSecondTurn && !secondTurnAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Secondo turno al completo, seleziona un\'altra opzione')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      // ===============================================
      // CREATE SOLO SU registrations (via RegistrationService,
      // stessa logica usata dalla pagina admin)
      // ===============================================
      await service.createRegistration(
        competitionId: competitionId!,
        profileId: profileId,
        cognome: cognome,
        nome: nome,
        email: email,
        societa: societaCtrl.text.trim(),
        pettorale: pettorale,
        sesso: sesso,
        flPresente: false,
        flPagato: false,
        flOmaggio: false,
        isFirstTurn: isFirstTurn,
        isSecondTurn: isSecondTurn,
        ownerRegistration: 'athlete',
      );

      // ===============================================
      // INVIO MAIL DI CONFERMA ISCRIZIONE
      // Edge Function Supabase — non blocca l'iscrizione se fallisce,
      // la registrazione è comunque già stata salvata.
      // Passiamo direttamente i dati già in memoria (evitiamo un
      // ulteriore giro sul DB lato edge function).
      // ===============================================
      try {
        await supabase.functions.invoke(
          'send-mail-registration',
          body: {
            'email': email,
            'nome': nome,
            'cognome': cognome,
            'competitionName': competition?['descrizione'],
            'competitionDate': _formatDate(competition?['dt_gara']),
            'turno': _turnoText,
          },
        );
      } catch (_) {
        // TODO: valutare logging/retry lato server per l'invio mail.
      }

      if (mounted) _showSuccessAndGoHome();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showSuccessAndGoHome() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Iscrizione completata'),
        content: const Text(
            'La tua iscrizione è stata registrata. Riceverai una mail di conferma.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/athlete-home');
            },
            child: const Text('Torna alla home'),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Iscrizione Gara'),
          leading: IconButton(
            tooltip: 'Torna alla home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/athlete-home'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = competition != null
        ? 'Iscrizione alla gara: ${competition!['descrizione'] ?? ''}\n'
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
          leading: IconButton(
            tooltip: 'Torna alla home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/athlete-home'),
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
          style: const TextStyle(fontSize: 16, height: 1.2),
        ),
        leading: IconButton(
          tooltip: 'Torna alla home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/athlete-home'),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              _readOnlyField('Cognome', cognome),
              const SizedBox(height: 12),
              _readOnlyField('Nome', nome),
              const SizedBox(height: 12),
              _readOnlyField('Email', email),
              const SizedBox(height: 12),

              TextFormField(
                controller: societaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Società (facoltativo)',
                ),
              ),

              const SizedBox(height: 12),

              _readOnlyField('Pettorale', pettorale?.toString() ?? '-'),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text('Primo turno'),
                subtitle: !isTurn
                    ? const Text('Gestione turni non attiva per questa gara')
                    : (!firstTurnAvailable
                        ? const Text('Turno al completo')
                        : null),
                value: isFirstTurn,
                onChanged: firstTurnAvailable
                    ? (v) {
                        setState(() {
                          isFirstTurn = v;
                          if (v) isSecondTurn = false;
                        });
                      }
                    : null,
              ),

              SwitchListTile(
                title: const Text('Secondo turno'),
                subtitle: !isTurn
                    ? const Text('Gestione turni non attiva per questa gara')
                    : (!secondTurnAvailable
                        ? const Text('Turno al completo')
                        : null),
                value: isSecondTurn,
                onChanged: secondTurnAvailable
                    ? (v) {
                        setState(() {
                          isSecondTurn = v;
                          if (v) isFirstTurn = false;
                        });
                      }
                    : null,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crea iscrizione'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(labelText: label),
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