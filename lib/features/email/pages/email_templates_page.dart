import 'package:boulder_competition/features/email/data/email_template_repository.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../models/email_template_model.dart';
import 'email_template_editor_page.dart';
import 'package:go_router/go_router.dart';

/// Pagina da aprire dalla tua amministrazione con Navigator.push(...).
class EmailTemplatesPage extends StatefulWidget {
  const EmailTemplatesPage({super.key});

  @override
  State<EmailTemplatesPage> createState() => _EmailTemplatesPageState();
}

class _EmailTemplatesPageState extends State<EmailTemplatesPage> {
  final _repository = EmailTemplateRepository();
  late Future<List<EmailTemplateModel>> _templates;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _templates = _repository.listTemplates();
  }

  Future<void> _reload() async {
    setState(() {
      _templates = _repository.listTemplates();
    });

    await _templates;
  }

  Future<void> _open(EmailTemplateModel template) async {
    try {
      final freshTemplate = await _repository.getTemplate(
        template.id,
      );

      if (!mounted) return;

      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => EmailTemplateEditorPage(
            template: freshTemplate,
          ),
        ),
      );

      if (!mounted) return;

      await _reload();
    } catch (error, stackTrace) {
      debugPrint('Errore apertura template: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.emailMessageCustom4(error.toString()), // 'Impossibile aprire il template: {error}'
          ),
        ),
      );
    }
  }

  Future<void> _create() async {
    final definition = await showDialog<_NewTemplateDefinition>(
      context: context,
      builder: (_) => const _NewTemplateDialog(),
    );
    if (definition == null) return;

    try {
      final template = await _repository.createDraft(
        templateCode: definition.code,
        language: definition.language,
        // Devono soddisfare i vincoli NOT NULL/check della tabella fin dalla
        // creazione; l'amministratore li sostituisce subito nell'editor.
        subject: 'Nuovo messaggio',
        htmlBody: '<p>Scrivi qui il contenuto della mail.</p>',
        description: definition.description,
      );
      if (!mounted) return;
      await _open(template);
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailMessageCustom5(error.toString()))), // 'Impossibile creare la bozza: {error}'
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (context.canPop()) {
              context.pop();            // aperta con push: torna indietro
            } else {
              context.go('/security');  // aperta con go: torna alla dashboard sicurezza
            }
          },
        ),
        title: Text(l10n.emailMessageCustom1), // 'Template email'
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.emailMessageCustom2, // 'Aggiorna'
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: Text(l10n.emailMessageCustom3), // 'Nuovo template'
      ),
      body: FutureBuilder<List<EmailTemplateModel>>(
        future: _templates,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(l10n.emailMessageCustom6(snapshot.error.toString())), // 'Errore nel caricamento: {error}'
            );
          }
          final templates = snapshot.data ?? [];
          if (templates.isEmpty) {
            return Center(
              child: Text(l10n.emailMessageCustom7), // 'Non hai ancora creato template email.'
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final template = templates[index];
                final subjectLabel = template.subject.isEmpty
                    ? l10n.emailMessageCustom16 // 'Senza oggetto'
                    : template.subject;
                final descriptionPart = template.description == null
                    ? ''
                    : '\n${template.description}';
                return Card(
                  child: ListTile(
                    onTap: () => _open(template),
                    leading:
                        CircleAvatar(child: Text('v${template.version}')),
                    title: Text(template.templateCode),
                    subtitle: Text(
                      '${template.language} · $subjectLabel$descriptionPart',
                    ),
                    isThreeLine: template.description != null,
                    trailing: Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusChip(status: template.status),
                        if (template.isDefault)
                          Chip(label: Text(l10n.emailMessageCustom17)), // 'Predefinito' / 'Default'                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

 String _localizedStatusLabel(String status, AppLocalizations l10n) {
  switch (status) {
    case 'active':
      return l10n.emailMessageCustom18; // 'Attivo' / 'Active'
    case 'draft':
      return l10n.emailMessageCustom19; // 'Bozza' / 'Draft'
    case 'archived':
      return l10n.emailMessageCustom64; // 'Archiviato' / 'Archived' (nuova chiave)
    default:
      return l10n.emailMessageCustom20; // 'Sconosciuto' / 'Unknown'
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'active':
      return Colors.green;
    case 'draft':
      return Colors.orange;
    case 'archived':
      return Colors.grey; // o un colore specifico se preferisci
    default:
      return Colors.grey;
  }
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _statusColor(status);
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.circle, color: color, size: 10),
      label: Text(_localizedStatusLabel(status, l10n)),
    );
  }
}

class _NewTemplateDefinition {
  const _NewTemplateDefinition({
    required this.code,
    required this.language,
    this.description,
  });
  final String code;
  final String language;
  final String? description;
}

class _NewTemplateDialog extends StatefulWidget {
  const _NewTemplateDialog();

  @override
  State<_NewTemplateDialog> createState() => _NewTemplateDialogState();
}

class _NewTemplateDialogState extends State<_NewTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _language = TextEditingController(text: 'it');
  final _description = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _language.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.emailMessageCustom3), // 'Nuovo template'
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.emailMessageCustom11, // 'Codice, es. WELCOME'
                ),
                validator: (value) => RegExp(r'^[A-Z][A-Z0-9_]*$')
                        .hasMatch((value ?? '').trim().toUpperCase())
                    ? null
                    : l10n.emailMessageCustom12, // 'Usa maiuscole, numeri e _.'
              ),
              TextFormField(
                controller: _language,
                decoration: InputDecoration(
                  labelText: l10n.emailMessageCustom13, // 'Lingua, es. it o en-US'
                ),
                validator: (value) => RegExp(r'^[a-z]{2,3}(-[A-Z]{2})?$')
                        .hasMatch((value ?? '').trim())
                    ? null
                    : l10n.emailMessageCustom14, // 'Formato lingua non valido.'
              ),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(
                  labelText: l10n.emailMessageCustom15, // 'Descrizione interna'
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.emailMessageCustom8), // 'Annulla'
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final description = _description.text.trim();
            Navigator.pop(
              context,
              _NewTemplateDefinition(
                code: _code.text.trim().toUpperCase(),
                language: _language.text.trim(),
                description: description.isEmpty ? null : description,
              ),
            );
          },
          child: Text(l10n.emailMessageCustom9), // 'Crea bozza'
        ),
      ],
    );
  }
}