import 'package:boulder_competition/features/email/data/email_template_repository.dart';
import 'package:flutter/material.dart';

import '../models/email_template_model.dart';
import 'email_template_editor_page.dart';

/// Pagina da aprire dalla tua amministrazione con Navigator.push(...).
class EmailTemplatesPage extends StatefulWidget {
  const EmailTemplatesPage({super.key});

  @override
  State<EmailTemplatesPage> createState() => _EmailTemplatesPageState();
}

class _EmailTemplatesPageState extends State<EmailTemplatesPage> {
  final _repository = EmailTemplateRepository();
  late Future<List<EmailTemplateModel>> _templates;

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
      // debugPrint('======================================');
      // debugPrint('APERTURA TEMPLATE DALLA LISTA');
      // debugPrint('ID: ${template.id}');
      // debugPrint('MODELLO LISTA HTML:');
      // debugPrint(template.htmlBody);

      final freshTemplate = await _repository.getTemplate(
        template.id,
      );

      // debugPrint('--------------------------------------');
      // debugPrint('MODELLO FRESCO DAL DB HTML:');
      // debugPrint(freshTemplate.htmlBody);
      // debugPrint('======================================');

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
            'Impossibile aprire il template: $error',
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
        SnackBar(content: Text('Impossibile creare la bozza: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Template email'),
      actions: [
        IconButton(
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
          tooltip: 'Aggiorna',
        ),
        const SizedBox(width: 8),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _create,
      icon: const Icon(Icons.add),
      label: const Text('Nuovo template'),
    ),
    body: FutureBuilder<List<EmailTemplateModel>>(
      future: _templates,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Errore nel caricamento: ${snapshot.error}'),
          );
        }
        final templates = snapshot.data ?? [];
        if (templates.isEmpty) {
          return const Center(
            child: Text('Non hai ancora creato template email.'),
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
              return Card(
                child: ListTile(
                  onTap: () => _open(template),
                  leading: CircleAvatar(child: Text('v${template.version}')),
                  title: Text(template.templateCode),
                  subtitle: Text(
                    '${template.language} · ${template.subject.isEmpty ? 'Senza oggetto' : template.subject}'
                    '${template.description == null ? '' : '\n${template.description}'}',
                  ),
                  isThreeLine: template.description != null,
                  trailing: Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _StatusChip(status: template.status),
                      if (template.isDefault)
                        const Chip(label: Text('Predefinito')),
                      const Icon(Icons.chevron_right),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => Colors.green,
      'draft' => Colors.orange,
      _ => Colors.grey,
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.circle, color: color, size: 10),
      label: Text(status),
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
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nuovo template'),
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
              decoration: const InputDecoration(
                labelText: 'Codice, es. WELCOME',
              ),
              validator: (value) =>
                  RegExp(
                    r'^[A-Z][A-Z0-9_]*$',
                  ).hasMatch((value ?? '').trim().toUpperCase())
                  ? null
                  : 'Usa maiuscole, numeri e _.',
            ),
            TextFormField(
              controller: _language,
              decoration: const InputDecoration(
                labelText: 'Lingua, es. it o en-US',
              ),
              validator: (value) =>
                  RegExp(
                    r'^[a-z]{2,3}(-[A-Z]{2})?$',
                  ).hasMatch((value ?? '').trim())
                  ? null
                  : 'Formato lingua non valido.',
            ),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Descrizione interna',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annulla'),
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
        child: const Text('Crea bozza'),
      ),
    ],
  );
}
