import 'package:boulder_competition/features/notifications/data/notification_service.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NotificationFormPage extends StatefulWidget {
  const NotificationFormPage({super.key});

  @override
  State<NotificationFormPage> createState() => _NotificationFormPageState();
}

class _NotificationFormPageState extends State<NotificationFormPage> {
  final _notificationService = NotificationService();
  final _notifications = <_NotificationDraft>[];

  bool _isLoading = true;
  String? _loadError;
  int _registeredRecipients = 0;
  int _firstTurnRecipients = 0;
  int _secondTurnRecipients = 0;
  int _finalistRecipients = 0;
  bool _isTurn = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_notifications.isEmpty) {
      _notifications.addAll([
        _NotificationDraft(
          type: 'competition_open',
          title: l10n.notificationMessageCustom7, // Gara aperta
          body: l10n
              .notificationMessageCustom8, // La gara è stata aperta. Puoi registrare i boulder.
        ),
        _NotificationDraft(
          type: 'competition_closed',
          title: l10n.notificationMessageCustom9, // Gara chiusa
          body: l10n
              .notificationMessageCustom10, // La gara è terminata. Non è più possibile registrare boulder.
        ),
        _NotificationDraft(
          type: 'competition_qualificated',
          title: l10n.notificationMessageCustom11, // Atleta qualificato
          body: l10n
              .notificationMessageCustom12, // Ti sei qualificato per la finale.
        ),
      ]);
    }
  }

  @override
  void dispose() {
    for (final notification in _notifications) {
      notification.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final overview = await _notificationService.getOverview();

      if (!mounted) return;
      setState(() {
        _registeredRecipients = overview.registeredRecipients;
        _firstTurnRecipients = overview.firstTurnRecipients;
        _secondTurnRecipients = overview.secondTurnRecipients;
        _finalistRecipients = overview.finalistRecipients;
        _isTurn = overview.isTurn;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _send(_NotificationDraft notification) async {
    final recipients = notification.type == 'competition_qualificated'
        ? _finalistRecipients
        : !_isTurn
        ? _registeredRecipients
        : notification.turn == 'first'
        ? _firstTurnRecipients
        : notification.turn == 'second'
        ? _secondTurnRecipients
        : 0;
    if (_isTurn &&
        notification.type != 'competition_qualificated' &&
        notification.turn == null) {
      _showError(l10n.notificationMessageCustom31); // Seleziona un turno.
      return;
    }
    if (recipients == 0) {
      _showError(
        l10n.notificationMessageCustom14,
      ); // Non ci sono destinatari per questa notifica.
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationMessageCustom15), // Conferma invio
        content: Text(
          l10n.notificationMessageCustom16(
            recipients,
          ), // Inviare la notifica a {count} atleti?
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel), // Annulla
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.notificationMessageCustom17), // Invia
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => notification.isSending = true);
    try {
      final result = await _notificationService.send(
        type: notification.type,
        title: notification.title.text.trim(),
        body: notification.body.text.trim(),
        turn: notification.turn,
      );
      if (!mounted) return;
      setState(
        () =>
            notification.result = l10n.notificationMessageCustom18(result.sent),
      ); // Inviate: {count}.
    } catch (error) {
      if (mounted) {
        _showError(
          l10n.notificationMessageCustom19(error.toString()),
        ); // Errore durante l'invio: {error}
      }
    } finally {
      if (mounted) setState(() => notification.isSending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationMessageCustom20),
      ), // Notifiche agli atleti
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(child: Text(_loadError!))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InfoCard(
                    icon: Icons.people_outline,
                    label: l10n.notificationMessageCustom21, // Iscritti
                    count: _registeredRecipients,
                  ),
                  if (_isTurn) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.looks_one_outlined,
                      label: l10n.notificationMessageCustom32, // Primo turno
                      count: _firstTurnRecipients,
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.looks_two_outlined,
                      label: l10n.notificationMessageCustom33, // Secondo turno
                      count: _secondTurnRecipients,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: Icons.emoji_events_outlined,
                    label: l10n.notificationMessageCustom22, // Finalisti
                    count: _finalistRecipients,
                  ),
                  const SizedBox(height: 24),
                  for (final notification in _notifications) ...[
                    _NotificationCard(
                      notification: notification,
                      recipients:
                          notification.type == 'competition_qualificated'
                          ? _finalistRecipients
                          : !_isTurn
                          ? _registeredRecipients
                          : notification.turn == 'first'
                          ? _firstTurnRecipients
                          : notification.turn == 'second'
                          ? _secondTurnRecipients
                          : 0,
                      onSend: () => _send(notification),
                      isTurn: _isTurn,
                      onTurnChanged: (turn) =>
                          setState(() => notification.turn = turn),
                      l10n: l10n,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }
}

class _NotificationDraft {
  _NotificationDraft({
    required this.type,
    required String title,
    required String body,
  }) : title = TextEditingController(text: title),
       body = TextEditingController(text: body);

  final String type;
  final TextEditingController title;
  final TextEditingController body;
  String? turn;
  bool isSending = false;
  String? result;

  void dispose() {
    title.dispose();
    body.dispose();
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        '$count',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    ),
  );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.recipients,
    required this.onSend,
    required this.l10n,
    required this.isTurn,
    required this.onTurnChanged,
  });

  final _NotificationDraft notification;
  final int recipients;
  final VoidCallback onSend;
  final AppLocalizations l10n;
  final bool isTurn;
  final ValueChanged<String> onTurnChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            notification.type == 'competition_open'
                ? l10n
                      .notificationMessageCustom23 // Gara aperta
                : notification.type == 'competition_closed'
                ? l10n
                      .notificationMessageCustom24 // Gara chiusa
                : l10n.notificationMessageCustom25, // Atleti finalisti
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: notification.title,
            decoration: InputDecoration(
              labelText: l10n.notificationMessageCustom26, // Titolo
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (isTurn && notification.type != 'competition_qualificated')
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'first',
                  label: Text(l10n.notificationMessageCustom32), // Primo turno
                ),
                ButtonSegment(
                  value: 'second',
                  label: Text(
                    l10n.notificationMessageCustom33,
                  ), // Secondo turno
                ),
              ],
              selected: {if (notification.turn != null) notification.turn!},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  onTurnChanged(selection.first);
                }
              },
            ),
          if (isTurn && notification.type != 'competition_qualificated')
            const SizedBox(height: 12),
          TextFormField(
            controller: notification.body,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.notificationMessageCustom27, // Messaggio
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.notificationMessageCustom28(recipients),
          ), // Destinatari: {count}
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: notification.isSending ? null : onSend,
              icon: notification.isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(l10n.notificationMessageCustom17), // Invia
            ),
          ),
          if (notification.result != null)
            Text(
              notification.result!,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
        ],
      ),
    ),
  );
}
