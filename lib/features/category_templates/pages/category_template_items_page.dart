import 'package:boulder_competition/features/categories/models/category_template_item_model.dart';
import 'package:boulder_competition/features/category_templates/data/category_template_items_service.dart';

import 'package:boulder_competition/features/category_templates/models/category_template_item_sex_l10n.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';


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
  final _horizontalController = ScrollController();
  StreamSubscription<List<CategoryTemplateItemModel>>? _itemsSubscription;

  List<CategoryTemplateItemModel> _items = [];
  bool _loading = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _listenToItems();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    _horizontalController.dispose();
    super.dispose();
  }

  String _fingerprint(CategoryTemplateItemModel e) {
    // fallback se id non esiste
    return '${e.nome}|${e.sesso ?? ''}|${e.etaMin ?? ''}|${e.etaMax ?? ''}';
  }

  List<CategoryTemplateItemModel> _uniqueItems(List<CategoryTemplateItemModel> items) {
    // LinkedHashMap preserva l'ordine d'inserimento
    final map = <String, CategoryTemplateItemModel>{};
    for (final item in items) {
      final key = (item.id.isNotEmpty) ? 'id:${item.id}' : _fingerprint(item);
      // scrivendo map[key] = item sovrascriviamo eventuali occorrenze precedenti:
      // questo tiene l'ultima occorrenza (utile quando la lista aggiornata contiene la versione "corretta")
      map[key] = item;
    }
    return map.values.toList();
  }

  void _listenToItems() {
    // se esiste già una subscription, non crearne una nuova
    if (_itemsSubscription != null) return;

    _itemsSubscription = _service.watchForTemplate(widget.templateId).listen(
      (items) {
  //      debugPrint('[stream] received ${items.length} items -> ids: ${items.map((e) => e.id).toList()}');
        if (!mounted) return;
        setState(() {
          _items = _uniqueItems(items);
          _loading = false;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
  //      debugPrint('Errore realtime categorie template: $error');
  //      debugPrintStack(stackTrace: stackTrace);
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categoryTemplateMessageCustom28(error.toString())),
          ),
        );
      },
    );
  }

  Future<void> _reload() async {
    // cancelliamo da subito la sottoscrizione per evitare emissioni concorrenti
    await _itemsSubscription?.cancel();
    _itemsSubscription = null;

    try {
      final items = await _service.listForTemplate(widget.templateId);
      //      debugPrint('[reload] fetched ${items.length} items -> ids: ${items.map((e) => e.id).toList()}');
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
          content: Text(l10n.categoryTemplateMessageCustom28(error.toString())),
        ),
      );
    } finally {
      // riaprire la sottoscrizione dopo il fetch
      _listenToItems();
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
        title: Text(l10n.categoryTemplateMessageCustom34), // 'Elimina categoria' / 'Delete category'
        content: Text(l10n.categoryTemplateMessageCustom35(item.nome)), // 'Vuoi eliminare la categoria "{nome}"?' / 'Do you want to delete the "{nome}" category?'
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.categoryTemplateMessageCustom32), // 'Annulla' / 'Cancel'
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.categoryTemplateMessageCustom36), // 'Elimina' / 'Delete'
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
          content: Text(l10n.categoryTemplateMessageCustom37), // 'Categoria eliminata.' / 'Category deleted.'
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryTemplateMessageCustom38(error.toString())), // 'Impossibile eliminare la categoria: {error}' / 'Unable to delete the category: {error}'
        ),
      );
    }
  }

  String _valueOrDash(Object? value) => value?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoryTemplateMessageCustom25(widget.templateName)), // 'Categorie - {nomeTemplate}' / 'Categories - {templateName}'
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: Text(l10n.categoryTemplateMessageCustom27), // 'Nuova categoria' / 'New category'
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(l10n.categoryTemplateMessageCustom29), // 'Nessuna categoria nel template.' / 'There are no categories in this template.'
                )
              : Scrollbar(
                  controller: _horizontalController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: 840,
                      child: RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),

                          itemBuilder: (context, index) {
                            final item = _items[index];

                            // Key stabile: preferisci id se presente, altrimenti fallback su fingerprint
                            final rowKey = (item.id.isNotEmpty)
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
                                      tooltip: l10n.categoryTemplateMessageCustom33, // 'Modifica categoria' / 'Edit category'
                                    ),
                                    IconButton(
                                      onPressed: () => _delete(item),
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: l10n.categoryTemplateMessageCustom34, // 'Elimina categoria' / 'Delete category'
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