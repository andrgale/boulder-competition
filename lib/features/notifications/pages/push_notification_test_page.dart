import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationTestPage extends StatefulWidget {
  const PushNotificationTestPage({super.key});

  @override
  State<PushNotificationTestPage> createState() =>
      _PushNotificationTestPageState();
}

class _PushNotificationTestPageState extends State<PushNotificationTestPage> {
  final _formKey = GlobalKey<FormState>();

  final _profileIdController = TextEditingController();
  final _titleController = TextEditingController(
    text: 'Test notifica',
  );
  final _bodyController = TextEditingController(
    text: 'Questa è una notifica di prova.',
  );
  final _competitionIdController = TextEditingController();

  bool _isLoading = false;
  bool? _requestSucceeded;
  String? _resultText;

  @override
  void dispose() {
    _profileIdController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _competitionIdController.dispose();
    super.dispose();
  }

  Future<void> _sendPushNotification() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileId = _profileIdController.text.trim();
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final competitionId = _competitionIdController.text.trim();

    // final data = <String, String>{
    //   'type': competitionId.isEmpty ? 'test' : 'competition_event',
    // };
    final data = <String, String>{
      'type': 'competition_open',
    };
    if (competitionId.isNotEmpty) {
      data['competitionId'] = competitionId;
    }


    setState(() {
      _isLoading = true;
      _requestSucceeded = null;
      _resultText = null;
    });

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'send-push-notification',
        body: {
          'profileIds': [profileId],
          'title': title,
          'body': body,
          'data': data,
          // 'data': {
          //   'type': 'competition_closed',
          //   'competitionId': competitionId,
          // },
        },
      );

      if (!mounted) return;

      setState(() {
        _requestSucceeded = true;
        _resultText = _formatResponse(response.data);
      });
    } on FunctionException catch (error) {
      if (!mounted) return;

      setState(() {
        _requestSucceeded = false;
        _resultText = _formatResponse(error.details ?? error.toString());
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _requestSucceeded = false;
        _resultText = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatResponse(dynamic responseData) {
    if (responseData == null) {
      return 'La Edge Function ha risposto senza contenuto.';
    }

    if (responseData is String) {
      return responseData;
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(responseData);
    } catch (_) {
      return responseData.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test notifiche push'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Invia una notifica tramite la Edge Function '
                'send-push-notification.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _profileIdController,
                decoration: const InputDecoration(
                  labelText: 'Profile ID destinatario',
                  hintText: 'UUID del record nella tabella profiles',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci il Profile ID del destinatario.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo notifica',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci un titolo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Messaggio',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci il messaggio della notifica.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _competitionIdController,
                decoration: const InputDecoration(
                  labelText: 'Competition ID (facoltativo)',
                  hintText: 'Aggiunto al payload data',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isLoading) {
                    _sendPushNotification();
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isLoading ? null : _sendPushNotification,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isLoading ? 'Invio in corso...' : 'Invia notifica',
                ),
              ),
              if (_resultText != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (_requestSucceeded ?? false)
                        ? colorScheme.primaryContainer
                        : colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _requestSucceeded == true
                            ? 'Risposta della Edge Function'
                            : 'Errore durante l’invio',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _resultText!,
                        style: TextStyle(
                          color: _requestSucceeded == true
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onErrorContainer,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}