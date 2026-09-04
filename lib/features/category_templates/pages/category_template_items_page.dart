import 'dart:collection';

import 'package:boulder_competition/features/categories/models/category_template_item_model.dart';
import 'package:boulder_competition/features/category_templates/data/category_template_items_service.dart';
import 'package:boulder_competition/features/category_templates/models/category_template_item_sex_l10n.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryTemplateItemsPage extends StatefulWidget {
  const CategoryTemplateItemsPage({
    super.key,
    required this.templateId,
    required this.templateName,
  });

  final String templateId;
  final String templateName;

  @override
  State<CategoryTemplateItemsPage> createState() =>
      _CategoryTemplateItemsPageState();
}

class _CategoryTemplateItemsPageState extends State<CategoryTemplateItemsPage> {
  final _service = CategoryTemplateItemsService();
  final _verticalController = ScrollController();

  List<CategoryTemplateItemModel> _items = [];
  bool _loading = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  // fingerprint / dedup: safety net se il server restituisce voci "simili"
  String _fingerprint(CategoryTemplateItemModel e) {
    return '${e.nome}|${e.sesso ?? ''}|${e.etaMin ?? ''}|${e.etaMax ?? ''}';
  }

  List<CategoryTemplateItemModel> _uniqueItems(List<CategoryTemplateItemModel> items) {
    final map = LinkedHashMap<String, CategoryTemplateItemModel>();
    String keyFor(CategoryTemplateItemModel item) {
      final id = item.id;
      if (id.isNotEmpty == true) return 'id:$id';
      return _fingerprint(item);
    }

    for (final item in items) {
      map[keyFor(item)] = item; // sovrascrive precedenti -> mantiene l'ultima occorrenza
    }
    return map.values.toList();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final items = await _service.listForTemplate(widget.templateId);
      if (!mounted) return;
      setState(() {
        _items = _uniqueItems(items);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom28(error.toString())), // 'Errore nel caricamento: {error}'
        ),
      );
    }
  }

  Future<void> _openCreate() async {
    final result = await context.push(
      '/security/categorytemplates/items/form',
      extra: {'templateId': widget.templateId},
    );
    if (result == true && mounted) await _reload();
  }

  Future<void> _openEdit(CategoryTemplateItemModel item) async {
    final result = await context.push(
      '/security/categorytemplates/items/form',
      extra: {'templateId': widget.templateId, 'item': item},
    );
    if (result == true && mounted) await _reload();
  }

  Future<void> _delete(CategoryTemplateItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.categoryTemplateMessageCustom34), // 'Elimina categoria'
        content: Text(l10n.categoryTemplateMessageCustom35(item.nome)), // 'Vuoi eliminare la categoria "{nome}"?'
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.categoryTemplateMessageCustom32), // 'Annulla'
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.categoryTemplateMessageCustom36), // 'Elimina'
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.delete(item.id);
      if (!mounted) return;
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom37), // 'Categoria eliminata.'
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom38(error.toString())), // 'Impossibile eliminare la categoria: {error}'
        ),
      );
    }
  }

  String _valueOrDash(Object? value) => value?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    const double maxContentWidth = 840;

    return Scaffold(
      appBar: AppBar(
        // titleSpacing 0 ci permette di posizionare con flexibleSpace esattamente il titolo
        titleSpacing: 0,
        toolbarHeight: kToolbarHeight,
        flexibleSpace: SafeArea(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Center(
                child: Text(
                  l10n.categoryTemplateMessageCustom25(widget.templateName), // 'Categorie - {nomeTemplate}'
                  style: Theme.of(context).appBarTheme.titleTextStyle ??
                      Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: Text(l10n.categoryTemplateMessageCustom27), // 'Nuova categoria'
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(l10n.categoryTemplateMessageCustom29), // 'Nessuna categoria nel template.'
                )
              : SingleChildScrollView(
                  // horizontal scroll enabled for safety on narrow/odd monitors
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      // manteniamo la larghezza ideale (maxContentWidth).
                      // se lo schermo è più stretto apparirà la scrollbar orizzontale
                      constraints: const BoxConstraints.tightFor(width: maxContentWidth),
                      child: RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView.separated(
                          controller: _verticalController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _items[index];

                            final rowKey = (item.id.isNotEmpty == true)
                                ? item.id
                                : _fingerprint(item);

                            return Card(
                              key: ValueKey(rowKey),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.category_outlined),
                                ),
                                title: Text(item.nome),
                                subtitle: Text(
                                  // 'Sesso' / 'Sex'; 'Età' / 'Age'
                                  '${l10n.categoryTemplateMessageCustom30}: ${item.localizedSessoLabel(context)}   •   ${l10n.categoryTemplateMessageCustom31}: ${_valueOrDash(item.etaMin)} - ${_valueOrDash(item.etaMax)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _openEdit(item),
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: l10n.categoryTemplateMessageCustom33, // 'Modifica categoria'
                                    ),
                                    IconButton(
                                      onPressed: () => _delete(item),
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: l10n.categoryTemplateMessageCustom34, // 'Elimina categoria'
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}