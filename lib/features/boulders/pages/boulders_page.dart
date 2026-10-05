import 'package:boulder_competition/core/services/permission_service.dart';
import 'dart:async';

import 'package:boulder_competition/shared/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/boulder_service.dart';
import '../models/boulder_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class BouldersPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;
  final int nrBoulder;

  const BouldersPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
    this.nrBoulder = 0,
  });

  @override
  State<BouldersPage> createState() => _BouldersPageState();
}

class _BouldersPageState extends State<BouldersPage> {
  final service = BoulderService();
  StreamSubscription<List<BoulderModel>>? _realtimeSubscription;

  List<BoulderModel> boulders = [];

  bool showOnlyFinals = false;
  bool canWriteDelete = false;
  bool checkingPermissionDelete = true;

  bool loading = true;
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  // nrBoulder <= 0 = limite non configurato → nessun vincolo
  // bool get canCreateBoulder {
  //   if (widget.nrBoulder <= 0) return true;

  //   final nonFinali = boulders.where((b) => !b.isFinale).length;
  //   return nonFinali < widget.nrBoulder;
  // }
  bool get canCreateBoulder => true;

  @override
  void initState() {
    super.initState();

    loadRealtime();
    checkPermissionDelete();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  // =====================================================
  // CONTROLLO PERMESSI CANCELLATION
  // =====================================================
  Future<void> checkPermissionDelete() async {
    final allowed = await PermissionService.hasPermission('boulder.write');

    if (!mounted) return;

    setState(() {
      canWriteDelete = allowed;
      checkingPermissionDelete = false;
    });
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refreshData() async {
    final rows = await service.getBoulders(widget.competitionId);

    if (!mounted) return;

    setState(() {
      boulders = rows;
      loading = false;
    });
  }

  // =====================================================
  // REALTIME
  // =====================================================

  void loadRealtime() {
    _realtimeSubscription = service.watchBoulders(widget.competitionId).listen((
      rows,
    ) {
      if (!mounted) return;

      setState(() {
        boulders = rows;
        loading = false;
      });
    });
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<void> deleteBoulder(BoulderModel boulder) async {
    // =====================================================
    // CONTROLLO ASCESE COLLEGATE
    // =====================================================
    try {
      final hasAscents = await service.hasAscents(boulder.id);

      if (hasAscents) {
        if (!mounted) return;

        AppSnackbar.error(
          context,
          l10n.boulderMessageCustom39, // 'Impossibile eliminare: sono presenti ascese registrate...
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.boulderMessageCustom2(e.toString()), // 'Errore: $e'
          ),
        ),
      );
      return;
    }

    // =====================================================
    // CONFERMA UTENTE
    // =====================================================
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.boulderMessageCustom37, // 'Elimina boulder'
        ),
        content: Text(
          l10n.boulderMessageCustom38(
            boulder.numero.toString(),
          ), // 'Sei sicuro di voler eliminare il boulder ${boulder.numero}?'
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

    // =====================================================
    // CANCELLAZIONE EFFETTIVA
    // =====================================================
    try {
      await service.deleteBoulder(boulder.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.boulderMessageCustom1, // 'Boulder eliminato'
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.boulderMessageCustom2(e.toString()), // 'Errore: $e'
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
    if (!canCreateBoulder) return; // guardia di sicurezza

    final res = await context.push(
      '/boulders/new',
      extra: {
        'competitionId': widget.competitionId,
        'nrBoulder': widget.nrBoulder,
      },
    );

    if (res == true) {
      await refreshData();
    }
  }
  // =====================================================
  // NAV EDIT
  // =====================================================

  Future<void> openEdit(BoulderModel boulder) async {
    final res = await context.push(
      '/boulders/edit',
      extra: {'competitionId': widget.competitionId, 'boulder': boulder},
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
    final filteredBoulders = showOnlyFinals
        ? boulders.where((b) => b.isFinale).toList()
        : boulders;

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.boulderMessageCustom3(
            widget.competitionName,
          ), // 'Boulders - ${widget.competitionName}'
        ),
        actions: [
          IconButton(
            tooltip: canCreateBoulder
                ? null
                : l10n.boulderMessageCustom40(widget.nrBoulder.toString()),
            icon: const Icon(Icons.add),
            onPressed: canCreateBoulder ? openCreate : null,
          ),
        ],
      ),

      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: canCreateBoulder ? openCreate : null,
              backgroundColor: canCreateBoulder
                  ? null
                  : Theme.of(context).disabledColor,
              child: const Icon(Icons.add),
            )
          : null,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(
                          l10n.boulderMessageCustom4, // 'Solo finale'
                        ),
                        selected: showOnlyFinals,
                        onSelected: (value) {
                          setState(() {
                            showOnlyFinals = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: filteredBoulders.isEmpty
                      ? Center(
                          child: Text(
                            l10n.boulderMessageCustom5, // 'Nessun boulder'
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredBoulders.length,
                          itemBuilder: (context, index) {
                            final b = filteredBoulders[index];

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(b.numero.toString()),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    l10n.boulderMessageCustom6(
                                      b.numero.toString(),
                                    ), // 'Boulder ${b.numero}'
                                  ),
                                  if (b.isFinale)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        l10n.boulderMessageCustom7, // 'FINALE'
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                l10n.boulderMessageCustom8(
                                  b.difficolta.toString(), // difficulty
                                  b.colore ?? '-', // color
                                  b.valoreTeorico.toStringAsFixed(
                                    2,
                                  ), // value (formatted)
                                ), // 'Diff: ${b.difficolta} | Colore: ${b.colore ?? "-"} | Valore: ${b.valoreTeorico.toStringAsFixed(2)}'
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => openEdit(b),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed:
                                        (!canWriteDelete ||
                                            checkingPermissionDelete)
                                        ? null
                                        : () => deleteBoulder(b),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}