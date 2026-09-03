import 'package:boulder_competition/features/categories/models/category_template_model.dart';
import 'package:boulder_competition/features/category_templates/data/category_template_service.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryTemplatePage extends StatefulWidget {
  const CategoryTemplatePage({super.key});

  @override
  State<CategoryTemplatePage> createState() => _CategoryTemplatePageState();
}

class _CategoryTemplatePageState extends State<CategoryTemplatePage> {
  final _service = CategoryTemplateService();
  late Future<List<CategoryTemplateModel>> _templates;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _templates = _service.listTemplates();
  }

  Future<void> _reload() async {
    final future = _service.listTemplates();

    if (!mounted) return;

    setState(() {
      _templates = future;
    });

    await future;
  }

  Future<void> _create() async {
    final nome = await _showNameDialog();
    if (nome == null) return;

    try {
      await _service.create(nome: nome);
      if (!mounted) return;
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom12), // 'Template creato.' / 'Template created.'
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom13(error.toString())), // 'Impossibile creare il template: {error}' / 'Unable to create the template: {error}'
        ),
      );
    }
  }

  Future<void> _edit(CategoryTemplateModel template) async {
    final nome = await _showNameDialog(template: template);
    if (nome == null || nome == template.nome) return;

    try {
      await _service.update(id: template.id, nome: nome);
      if (!mounted) return;
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom14), // 'Template aggiornato.' / 'Template updated.'
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom15(error.toString())), // 'Impossibile aggiornare il template: {error}' / 'Unable to update the template: {error}'
        ),
      );
    }
  }

  Future<void> _delete(CategoryTemplateModel template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.categoryTemplateMessageCustom16), // 'Elimina template' / 'Delete template'
        content: Text(l10n.categoryTemplateMessageCustom17(template.nome)), // 'Vuoi eliminare il template "{nome}"?' / 'Do you want to delete the "{nome}" template?'
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.categoryTemplateMessageCustom8), // 'Annulla' / 'Cancel'
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.categoryTemplateMessageCustom18), // 'Elimina' / 'Delete'
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.delete(template.id);
      if (!mounted) return;
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom19), // 'Template eliminato.' / 'Template deleted.'
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom20(error.toString())), // 'Impossibile eliminare il template: {error}' / 'Unable to delete the template: {error}'
        ),
      );
    }
  }

  Future<void> _openItems(CategoryTemplateModel template) async {
    await context.push(
      '/security/categorytemplates/${template.id}/items',
      extra: template,
    );
    if (mounted) await _reload();
  }

  Future<String?> _showNameDialog({CategoryTemplateModel? template}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _CategoryTemplateNameDialog(template: template),
    );
  }

  // Dialog per duplicare: precompilato con il nome del template sorgente.
  Future<String?> _showDuplicateDialog(CategoryTemplateModel template) {
    // Riusa lo stesso dialog widget, passando un titolo custom per "Duplica template"
    return showDialog<String>(
      context: context,
      builder: (_) => _CategoryTemplateNameDialog(
        template: template,
        title: AppLocalizations.of(context)!.categoryTemplateMessageCustom41, // 'Duplica template'
      ),
    );
  }

  Future<void> _duplicate(CategoryTemplateModel template) async {
    final nuovoNome = await _showDuplicateDialog(template);
    if (nuovoNome == null) return;

    try {
      await _service.duplicate(id: template.id, nuovoNome: nuovoNome);
      if (!mounted) return;
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom42), // 'Template duplicato.' / 'Template duplicated.'
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom43(error.toString())), // 'Impossibile duplicare il template: {error}' / 'Unable to duplicate the template: {error}'
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoryTemplateMessageCustom1), // 'Template categorie' / 'Category templates'
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.categoryTemplateMessageCustom2, // 'Aggiorna' / 'Refresh'
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: Text(l10n.categoryTemplateMessageCustom3), // 'Nuovo template' / 'New template'
      ),
      body: FutureBuilder<List<CategoryTemplateModel>>(
        future: _templates,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(l10n.categoryTemplateMessageCustom4(snapshot.error.toString())), // 'Errore nel caricamento: {error}' / 'Loading error: {error}'
            );
          }

          final templates = snapshot.data ?? [];
          if (templates.isEmpty) {
            return Center(
              child: Text(l10n.categoryTemplateMessageCustom5), // 'Non hai ancora creato template di categoria.' / 'You have not created any category templates yet.'
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final template = templates[index];
                final updatedAt = MaterialLocalizations.of(context)
                    .formatCompactDate(template.updatedAt.toLocal());
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.category_outlined),
                    ),
                    title: Text(template.nome),
                    subtitle: Text(
                      l10n.categoryTemplateMessageCustom21(updatedAt), // 'Aggiornato il {data}' / 'Updated on {data}'
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          onPressed: () => _openItems(template),
                          icon: const Icon(Icons.category_outlined),
                          tooltip: l10n.categoryTemplateMessageCustom24, // 'Gestisci categorie' / 'Manage categories'
                        ),
                        IconButton(
                          onPressed: () => _edit(template),
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: l10n.categoryTemplateMessageCustom22, // 'Modifica template' / 'Edit template'
                        ),

                        // ICONA DUPLICA: aggiunta prima della delete
                        IconButton(
                          onPressed: () => _duplicate(template),
                          icon: const Icon(Icons.copy), // icona per duplicare
                          tooltip: l10n.categoryTemplateMessageCustom41, // 'Duplica template' / 'Duplicate template'
                        ),

                        IconButton(
                          onPressed: () => _delete(template),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: l10n.categoryTemplateMessageCustom23, // 'Elimina template' / 'Delete template'
                        ),
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

class _CategoryTemplateNameDialog extends StatefulWidget {
  const _CategoryTemplateNameDialog({this.template, this.title});

  final CategoryTemplateModel? template;
  final String? title;

  @override
  State<_CategoryTemplateNameDialog> createState() =>
      _CategoryTemplateNameDialogState();
}

class _CategoryTemplateNameDialogState extends State<_CategoryTemplateNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.template?.nome ?? '');
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.template != null;
    return AlertDialog(
      title: Text(
        widget.title ?? (isEdit
            ? l10n.categoryTemplateMessageCustom10 // 'Modifica template' / 'Edit template'
            : l10n.categoryTemplateMessageCustom3), // 'Nuovo template' / 'New template'
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nome,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.categoryTemplateMessageCustom6, // 'Nome categoria' / 'Category name'
            ),
            validator: (value) => (value ?? '').trim().isEmpty
                ? l10n.categoryTemplateMessageCustom7 // 'Il nome è obbligatorio.' / 'The name is required.'
                : null,
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.categoryTemplateMessageCustom8), // 'Annulla' / 'Cancel'
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            isEdit
                ? l10n.categoryTemplateMessageCustom11 // 'Salva' / 'Save'
                : l10n.categoryTemplateMessageCustom9, // 'Crea' / 'Create'
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _nome.text.trim());
  }
}