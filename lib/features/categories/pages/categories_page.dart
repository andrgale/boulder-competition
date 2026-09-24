import 'package:boulder_competition/shared/app_snackbar.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/category_service.dart';
import '../models/category_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class CategoriesPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const CategoriesPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final service = CategoryService();
  StreamSubscription<List<CategoryModel>>? _realtimeSubscription;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  List<CategoryModel> categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRealtime();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> refreshData() async {
    final rows = await service.getCategories(widget.competitionId);

    if (!mounted) return;

    setState(() {
      categories = rows;
      loading = false;
    });
  }

  // =====================================================
  // REALTIME
  // =====================================================
  void loadRealtime() {
    _realtimeSubscription = service
        .watchCategories(widget.competitionId)
        .listen((rows) {
          if (!mounted) return;

          setState(() {
            categories = rows;
            loading = false;
          });
        });
  }

  // =====================================================
  // DELETE
  // =====================================================
  Future<void> deleteCategory(String id) async {
    // =====================================================
    // CONTROLLO REGISTRAZIONI COLLEGATE
    // =====================================================
    try {
      final hasRegistrations = await service.hasRegistrationsCategory(id);

      if (hasRegistrations) {
        if (!mounted) return;

        AppSnackbar.error(
          context,
          l10n.categoryMessageCustom16, // 'Impossibile eliminare: sono presenti ascese registrate...
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.categoryMessageCustom2(e.toString()), // 'Errore: $e'
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.categoryMessageCustom17, // es. 'Elimina categoria'
        ),
        content: Text(
          l10n.categoryMessageCustom18, // es. 'Sei sicuro di voler eliminare questa categoria?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l10n.commonCancel, // 'Annulla'
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.commonDelete, // 'Elimina'
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await service.deleteCategory(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.categoryMessageCustom1, // 'Categoria eliminata'
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.categoryMessageCustom2(e.toString()), // 'Errore: $e'
          ),
        ),
      );
    }

    await refreshData();
  }

  // =====================================================
  // NAV CREATE
  // =====================================================
  Future<void> openCreate() async {
    final res = await context.push(
      '/categories/new',
      extra: widget.competitionId,
    );

    if (res == true) {
      refreshData();
    }
  }

  // =====================================================
  // NAV EDIT
  // =====================================================
  Future<void> openEdit(CategoryModel c) async {
    final res = await context.push(
      '/categories/edit',
      extra: {'competitionId': widget.competitionId, 'category': c},
    );

    if (res == true) {
      await refreshData();
    }
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.categoryMessageCustom3(
            widget.competitionName,
          ), // 'Categorie - ${widget.competitionName}'
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: openCreate),
        ],
      ),

      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: openCreate,
              child: const Icon(Icons.add),
            )
          : null,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? Center(
              child: Text(
                l10n.categoryMessageCustom4, // 'Nessuna categoria'
              ),
            )
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final c = categories[i];

                return ListTile(
                  title: Text(c.nome),
                  subtitle: Text(
                    '${c.sesso ?? "-"} | ${c.etaMin ?? "-"} - ${c.etaMax ?? "-"}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => openEdit(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteCategory(c.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}