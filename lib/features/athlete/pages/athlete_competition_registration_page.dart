import 'package:boulder_competition/features/registrations/data/registration_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

/// Pagina di iscrizione dell'atleta a una gara boulder.
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
  final dataNascitaCtrl = TextEditingController();
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // ── dati gara ────────────────────────────────────────────────
  String? competitionId;
  Map<String, dynamic>? competition;
  bool isTurn = false;
  int nrMaxFirstTurn = 0;
  int nrMaxSecondTurn = 0;
  int nrMaxRegistrations = 0;

  int firstTurnCount = 0;
  int secondTurnCount = 0;
  int totalRegistrationsCount = 0;

    // ── categorie gara ───────────────────────────────────────────
  List<Map<String, dynamic>> categories = [];
  bool hasCategories = false;
  String? categoryId;

  // ── dati atleta (da profiles, via auth_user_id) ────────────────
  String? profileId;
  String cognome = '';
  String nome = '';
  String email = '';
  String? sesso;
  DateTime? dataNascita;

  bool isFirstTurn = false;
  bool isSecondTurn = false;

  int? pettorale;

  bool loading = true;
  bool saving = false;

  // Instead of storing a localized string at init time (no context),
  // store a key and optional argument and convert to localized text in build().
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
    dataNascitaCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await _loadCompetition();

      if (blockingKey == null) {
        await _loadCategories();
      }

      if (blockingKey == null) {
        await _loadProfile();
      }

      if (blockingKey == null) {
        await _checkAlreadyRegistered();
      }

      if (blockingKey == null) {
        await _loadRegistrationCounts();
        await _computeNextPettorale();
      }
    } catch (e) {
      blockingKey = 'loading_error';
      blockingArg = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // =====================================================
  // RICERCA GARA CON ISCRIZIONI APERTE
  // =====================================================
  Future<void> _loadCompetition() async {
    final data = await supabase
        .from('competitions')
        .select()
        .eq('fl_iscrizioni_chiuse', false)
        .maybeSingle();

    if (data == null) {
      blockingKey = 'no_open_competition';
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
  // CARICAMENTO CATEGORIE DELLA GARA
  // =====================================================
  Future<void> _loadCategories() async {
    if (competitionId == null) return;

    final data = await supabase
        .from('categories')
        .select('id, eta_min, eta_max, sesso')
        .eq('competition_id', competitionId!);

    categories = List<Map<String, dynamic>>.from(data);
    hasCategories = categories.isNotEmpty;

    // Se non ci sono categorie, category_id rimane null.
    if (!hasCategories) {
      categoryId = null;
    }
  }
  // =====================================================
  // CARICAMENTO PROFILO ATLETA (auth_user_id -> profiles)
  // =====================================================
  Future<void> _loadProfile() async {
    final authUserId = supabase.auth.currentUser?.id;

    if (authUserId == null) {
      blockingKey = 'user_not_authenticated';
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
      blockingKey = 'already_registered';
    }
  }

  // =====================================================
  // CALCOLO ETA' ALLA DATA DELLA GARA
  // =====================================================
  int? _calculateAgeOnCompetitionDate() {
    if (dataNascita == null || competition == null) {
      return null;
    }

    final rawCompetitionDate = competition!['dt_gara'];

    if (rawCompetitionDate == null) {
      return null;
    }

    final competitionDate = DateTime.tryParse(
      rawCompetitionDate.toString(),
    );

    if (competitionDate == null) {
      return null;
    }

    int age = competitionDate.year - dataNascita!.year;

    final birthdayAlreadyOccurred =
        competitionDate.month > dataNascita!.month ||
        (competitionDate.month == dataNascita!.month &&
            competitionDate.day >= dataNascita!.day);

    if (!birthdayAlreadyOccurred) {
      age--;
    }

    return age;
  }

  // =====================================================
  // RICERCA CATEGORIA IN BASE A ETA' E SESSO
  // =====================================================
  String? _findCategoryId() {
    // Se la gara non ha categorie, non assegniamo category_id.
    if (!hasCategories) {
      return null;
    }

    final age = _calculateAgeOnCompetitionDate();

    if (age == null || sesso == null || sesso!.trim().isEmpty) {
      return null;
    }

    final normalizedSex = sesso!.trim().toUpperCase();

    for (final category in categories) {
      final categorySex =
          category['sesso']?.toString().trim().toUpperCase();

      final etaMin = _toInt(category['eta_min']);
      final etaMax = _toInt(category['eta_max']);

      if (categorySex != normalizedSex) {
        continue;
      }

      if (etaMin == null || etaMax == null) {
        continue;
      }

      if (age >= etaMin && age <= etaMax) {
        return category['id']?.toString();
      }
    }

    return null;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  // =====================================================
  // CONTEGGIO ISCRITTI (totale + per turno)
  // =====================================================
  Future<void> _loadRegistrationCounts() async {
    final registrations = await service.getRegistrations(competitionId!);

    totalRegistrationsCount = registrations.length;
    firstTurnCount = registrations.where((r) => r.isFirstTurn).length;
    secondTurnCount = registrations.where((r) => r.isSecondTurn).length;

    if (nrMaxRegistrations > 0 &&
        totalRegistrationsCount >= nrMaxRegistrations) {
      blockingKey = 'max_registrations';
    }
  }

  bool get firstTurnAvailable => isTurn && firstTurnCount < nrMaxFirstTurn;
  bool get secondTurnAvailable => isTurn && secondTurnCount < nrMaxSecondTurn;

  /// Testo del turno scelto da inserire nella mail di conferma.
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

    // =====================================================
   // CALCOLO / VERIFICA CATEGORIA
   // =====================================================
    if (hasCategories) {
      categoryId = _findCategoryId();

      if (categoryId == null) {
        final age = _calculateAgeOnCompetitionDate();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              age == null
                  ? l10n.athleteMessageCustom109 //'Impossibile calcolare la categoria dell’atleta.'
                  : l10n.athleteMessageCustom110 //'Nessuna categoria disponibile per età e sesso dell’atleta.',
            ),
          ),
        );

        return;
      }
    } else {
      categoryId = null;
    }

    if (isTurn && !isFirstTurn && !isSecondTurn) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.athleteMessageCustom53))); // Seleziona un turno
      return;
    }

    if (isFirstTurn && !firstTurnAvailable) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.athleteMessageCustom54))); // Primo turno al completo, seleziona un'altra opzione
      return;
    }

    if (isSecondTurn && !secondTurnAvailable) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.athleteMessageCustom55))); // Secondo turno al completo, seleziona un'altra opzione
      return;
    }

    setState(() => saving = true);

    try {
      await service.createRegistration(
        competitionId: competitionId!,
        profileId: profileId,
        cognome: cognome,
        nome: nome,
        email: email,
        societa: societaCtrl.text.trim(),
        pettorale: pettorale,
        sesso: sesso,
        dataNascita: dataNascita,
        categoryId: categoryId,
        flPresente: false,
        flPagato: false,
        flOmaggio: false,
        isFirstTurn: isFirstTurn,
        isSecondTurn: isSecondTurn,
        ownerRegistration: 'athlete',
      );

      // invio mail di conferma (edge function)
      try {
        final turno = _turnoText?.trim();

        final riepilogoParts = <String>[
          if ((competition?['descrizione'] as String?)?.trim().isNotEmpty ?? false)
            '${AppLocalizations.of(context)!.athleteMessageCustom76}: ${(competition!['descrizione'] as String).trim()}', // Gara
          if (_formatDate(competition?['dt_gara']).trim().isNotEmpty)
            '${AppLocalizations.of(context)!.athleteMessageCustom77}: ${_formatDate(competition?['dt_gara']).trim()}', // Data
          if (turno?.isNotEmpty ?? false)
            '${AppLocalizations.of(context)!.athleteMessageCustom78}: $turno', // Turno
        ];

        await supabase.functions.invoke(
          'send-template-email',
          body: {
            'email': email,
            'toName': '$nome $cognome'.trim(),
            'templateCode': 'REG_GARA',
            'language': 'it',
            'variables': buildEmailVariables({
              'NOME_ATLETA': '$nome $cognome',
              'DESC_GARA': competition?['descrizione'] as String?,
              'DT_GARA': _formatDate(competition?['dt_gara']),
              'TURNO': _turnoText,
              'RIEPILOGO_GARA': riepilogoParts.isNotEmpty ? riepilogoParts.join(' — ') : null,
            }),
          },
        );
      } catch (_) {
        // non bloccare l'iscrizione se l'invio mail fallisce
      }

      if (mounted) _showSuccessAndGoHome();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.athleteMessageCustom56(e.toString())))); // Errore: {error}
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Map<String, String> buildEmailVariables(Map<String, String?> fields) {
    final result = <String, String>{};
    for (final entry in fields.entries) {
      final value = entry.value?.trim();
      if (value != null && value.isNotEmpty) {
        result[entry.key] = value;
      }
    }
    return result;
  }

  void _showSuccessAndGoHome() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(l10n.athleteMessageCustom57), // Iscrizione completata
        content: Text(l10n.athleteMessageCustom58), // La tua iscrizione è stata registrata. Riceverai una mail di conferma.
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/athlete-home');
            },
            child: Text(l10n.athleteMessageCustom59), // Torna alla home
          ),
        ],
      ),
    );
  }

  String _localizedBlockingMessage(AppLocalizations l10n) {
    switch (blockingKey) {
      case 'loading_error':
        return l10n.athleteMessageCustom49(blockingArg ?? ''); // Errore nel caricamento dei dati: {error}
      case 'no_open_competition':
        return l10n.athleteMessageCustom50; // Nessuna gara con iscrizioni aperte al momento
      case 'user_not_authenticated':
        return l10n.athleteMessageCustom47; //  Utente non autenticato
      case 'already_registered':
        return l10n.athleteMessageCustom51; // Iscrizione già presente, cerca la mail nella tua casella di posta
      case 'max_registrations':
        return l10n.athleteMessageCustom52; // Numero massimo di iscritti raggiunto per questa gara
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
          title: Text(l10n.athleteMessageCustom61), // Iscrizione Gara
          leading: IconButton(
            tooltip: l10n.athleteMessageCustom59, // Torna alla home
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/athlete-home'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = competition != null
        ? l10n.athleteMessageCustom60( // 
            (competition!['descrizione'] as String?) ?? '', _formatDate(competition!['dt_gara'])) // {competition} · Data: {date}
        : l10n.athleteMessageCustom61; // Iscrizione Gara

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
          leading: IconButton(
            tooltip: l10n.athleteMessageCustom59, // Torna alla home
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
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home_outlined),
                  label: Text(l10n.athleteMessageCustom59), // Torna alla home
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
          tooltip: l10n.athleteMessageCustom59, // Torna alla home
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
              _readOnlyField(l10n.athleteMessageCustom63, cognome), // cognome
              const SizedBox(height: 12),
              _readOnlyField(l10n.athleteMessageCustom64, nome), // nome
              const SizedBox(height: 12),
              _readOnlyField(l10n.athleteMessageCustom65, email), // email
              const SizedBox(height: 12),
              TextFormField(
                controller: dataNascitaCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.athleteMessageCustom66, // data di nascita
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: _selectDataNascita,
                validator: (_) {
                  if (dataNascita == null) {
                    return l10n.athleteMessageCustom17; // 'Obbligatorio'
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: sesso,
                decoration: InputDecoration(
                  labelText: l10n.athleteMessageCustom67, // sesso
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'M',
                    child: Text('M'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'F',
                    child: Text('F'),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    sesso = v;
                    categoryId = _findCategoryId();
                  });
                },
                  validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.athleteMessageCustom17; // 'Obbligatorio'
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: societaCtrl,
                decoration: InputDecoration(
                  labelText: l10n.athleteMessageCustom68, // società
                ),
              ),
              const SizedBox(height: 12),
              _readOnlyField(l10n.athleteMessageCustom69, pettorale?.toString() ?? '-'), // pettorale
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(l10n.athleteMessageCustom71), // Primo turno
                subtitle: !isTurn
                    ? Text(l10n.athleteMessageCustom73) // Gestione turni non attiva per questa gara
                    : (!firstTurnAvailable
                        ? Text(l10n.athleteMessageCustom74) // Turno al completo
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
                title: Text(l10n.athleteMessageCustom72), // Secondo turno
                subtitle: !isTurn
                    ? Text(l10n.athleteMessageCustom73) // Gestione turni non attiva per questa gara
                    : (!secondTurnAvailable
                        ? Text(l10n.athleteMessageCustom74) // Turno al completo
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
                        : Text(l10n.athleteMessageCustom75), // Crea iscrizione
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

  Future<void> _selectDataNascita() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dataNascita = picked;
        dataNascitaCtrl.text = _formatDate(picked);

        // Ricalcola la categoria in base all'età
        // dell'atleta alla data della gara.
        categoryId = _findCategoryId();
      });
    }
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