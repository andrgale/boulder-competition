import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/registration_service.dart';
import '../models/registration_model.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class RegistrationsPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  // ── flag dalla competition: se true, iscrizioni chiuse ─────
  final bool flIscrizioniChiuse;

// ── numero massimo di atleti iscrivibili (0 = nessun limite) ─
  final int nrMaxRegistrations;

  final bool isTurn;
  final int nrMaxFirstTurn;
  final int nrMaxSecondTurn;

  const RegistrationsPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
    this.flIscrizioniChiuse = false,
    this.nrMaxRegistrations = 0,
    this.isTurn = false,
    this.nrMaxFirstTurn = 0,
    this.nrMaxSecondTurn = 0,
  });

  @override
  State<RegistrationsPage> createState() =>
      _RegistrationsPageState();
}

class _RegistrationsPageState
    extends State<RegistrationsPage> {
  final service = RegistrationService();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  List<RegistrationModel> registrations = [];

  bool loading = true;

  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    loadRealtime();
  }

  List<RegistrationModel> filteredRegistrations() {
    final query =
        searchController.text
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return registrations;
    }

    return registrations.where((r) {
      final nome =
          r.nome.toLowerCase();

      final cognome =
          r.cognome.toLowerCase();

      final pettorale =
          (r.pettorale ?? '')
              .toString()
              .toLowerCase();

      final societa =
          (r.societa ?? '')
              .toLowerCase();

      return nome.contains(query) ||
          cognome.contains(query) ||
          pettorale.contains(query) ||
          societa.contains(query);
    }).toList();
  }

// ── true se il numero di iscritti ha raggiunto il tetto massimo ────
// nrMaxRegistrations == 0 => nessun limite impostato
  bool get isFull =>
      widget.nrMaxRegistrations > 0 &&
      registrations.length >= widget.nrMaxRegistrations;

// ── conteggi iscritti per turno, calcolati sulla lista già in memoria ──
  int get firstTurnCount =>
      registrations.where((r) => r.isFirstTurn).length;

  int get secondTurnCount =>
      registrations.where((r) => r.isSecondTurn).length;      
// =====================================================
// IMPORT CSV
// =====================================================

  Future<void> importCsv() async {
    // ── guardia: non importa se le iscrizioni sono chiuse ────
    if (widget.flIscrizioniChiuse || isFull) return;

    try {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return;

      final path =
          result.files.single.path;

      if (path == null) return;

      final file = File(path);

      final csvContent =
          await file.readAsString();

      if (!mounted) return;

      setState(() {
        loading = true;
      });

      // debugPrint(
      //   'IMPORT CSV competitionId=${widget.competitionId}',
      // );

      final response =
          await Supabase.instance.client.functions
              .invoke(
        'import_competition_csv',
        body: {
          'competition_id':
              widget.competitionId,
          'csv_content': csvContent,
        },
      );

      if (!mounted) return;

      // debugPrint(response.data.toString());

      if (response.data != null) {
        final inserted =
            response.data['inserted'] ?? 0;

        final discarded =
            response.data['discarded'] ?? 0;


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.registrationMessageCustom1(
                inserted.toString(),
                discarded.toString(),
              ), // 'Import completato - Inseriti: $inserted Scartati: $discarded'
            ),
          ),
        );

        await refreshData();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error import CSV: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refreshData() async {
    final rows = await service.getRegistrations(
      widget.competitionId,
    );

    if (!mounted) return;

    setState(() {
      registrations = rows;
      loading = false;
    });
  }

  // =====================================================
  // REALTIME
  // =====================================================

  void loadRealtime() {
    service
        .watchRegistrations(
          widget.competitionId,
        )
        .listen((rows) {
      if (!mounted) return;

      setState(() {
        registrations = rows;
        loading = false;
      });
    });
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<void> deleteRegistration(
    String id,
  ) async {
    try {
      await service.deleteRegistration(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.registrationMessageCustom2, // 'Iscrizione eliminata'
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
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
    if (widget.flIscrizioniChiuse || isFull) return;

    final res = await context.push(
      '/registrations/new',
      extra: {
        'competitionId': widget.competitionId,
        'isTurn': widget.isTurn,
        'nrMaxFirstTurn': widget.nrMaxFirstTurn,
        'nrMaxSecondTurn': widget.nrMaxSecondTurn,
        'firstTurnCount': firstTurnCount,
        'secondTurnCount': secondTurnCount,
      },
    );

    if (res == true) {
      await refreshData();
    }
  }
  // =====================================================
  // NAV EDIT
  // =====================================================

  Future<void> openEdit(RegistrationModel r) async {
    final res = await context.push(
      '/registrations/edit',
      extra: {
        'competitionId': widget.competitionId,
        'registration': r,
        'isTurn': widget.isTurn,
        'nrMaxFirstTurn': widget.nrMaxFirstTurn,
        'nrMaxSecondTurn': widget.nrMaxSecondTurn,
        'firstTurnCount': firstTurnCount,
        'secondTurnCount': secondTurnCount,
      },
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
    final isMobile =
        MediaQuery.of(context).size.width < 700;

    final filtered = filteredRegistrations();

    final closed = widget.flIscrizioniChiuse;
    final full = isFull;
    final blocked = closed || full;

   String tooltipMessage(String actionLabel) {
    if (closed) return l10n.registrationMessageCustom3(actionLabel); // 'Iscrizioni chiuse: $actionLabel non disponibile'
    if (full) return l10n.registrationMessageCustom4(actionLabel); // 'Numero massimo iscritti raggiunto: $actionLabel non disponibile'
    return actionLabel;
  }

  return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.registrationMessageCustom7(widget.competitionName), // 'Iscrizioni - ${widget.competitionName}'
        ),

        actions: [
          Tooltip(
            message: tooltipMessage(l10n.registrationMessageCustom5), // 'Importa CSV'
            child: IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: blocked ? null : importCsv,
            ),
          ),

          Tooltip(
            message: tooltipMessage(l10n.registrationMessageCustom6), // 'Nuova iscrizione'
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: blocked ? null : openCreate,
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: blocked ? null : openCreate,
              backgroundColor:
                  blocked ? Colors.grey.shade300 : null,
              child: const Icon(Icons.add),
            )
          : null,

    body: loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [

              // ── banner informativo se iscrizioni chiuse o al completo ──
              if (closed || full)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 18, color: Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          closed
                              ? l10n.registrationMessageCustom8 // 'Le iscrizioni per questa gara sono chiuse. Non è possibile aggiungere nuovi atleti o importare CSV.'
                              : l10n.registrationMessageCustom9(
                                  registrations.length.toString(),
                                  widget.nrMaxRegistrations.toString(),
                                ), // 'Numero massimo di iscritti raggiunto (${registrations.length}/${widget.nrMaxRegistrations}). Non è possibile aggiungere nuovi atleti o importare CSV.'
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding:
                    const EdgeInsets.all(12),
                child: TextField(
                  controller:
                      searchController,
                  decoration:
                      InputDecoration(
                       hintText: l10n.registrationMessageCustom10, // 'Cerca pettorale, cognome o nome...'
                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                        searchController
                                .text
                                .isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  searchController
                                      .clear();

                                  setState(() {});
                                },
                              )
                            : null,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),

              Expanded(
                child: filtered.isEmpty

              ? Center(
                  child: Text(
                    l10n.registrationMessageCustom11, // 'Nessuna iscrizione'
                  ),
                )
              : ListView.builder(
                  itemCount:
                    filtered.length,
                  itemBuilder:
                      (context, index) {
                    final r =
                        filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          r.pettorale
                                  ?.toString() ??
                              '-',
                        ),
                      ),

                      title: Text(
                        '${r.cognome} ${r.nome}',
                      ),

                      subtitle: Text(
                        '${r.email}'
                        '${r.societa != null && r.societa!.isNotEmpty ? ' | ${r.societa}' : ''}',
                      ),

                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          if (r.flPagato)
                            const Padding(
                              padding:
                                  EdgeInsets.only(
                                right: 8,
                              ),
                              child: Icon(
                                Icons.euro,
                                color:
                                    Colors.green,
                              ),
                            ),

                          if (r.flPresente)
                            const Padding(
                              padding:
                                  EdgeInsets.only(
                                right: 8,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color:
                                    Colors.blue,
                              ),
                            ),

                            if (r.flOmaggio)
                              const Padding(
                                padding: EdgeInsets.only(
                                  right: 8,
                                ),
                                child: Icon(
                                  Icons.card_giftcard,
                                  color: Colors.orange,
                                ),
                              ),

                          IconButton(
                            icon: const Icon(
                              Icons.terrain,
                            ),
                            tooltip: r.flPresente
                                ? l10n.registrationMessageCustom12 // 'Boulder'
                                : l10n.registrationMessageCustom13, // 'Atleta non presente'
                            onPressed: r.flPresente
                                ? () {
                                    context.push(
                                      '/ascents-boulders',
                                      extra: {
                                        'registrationId': r.id,
                                        'athleteName':
                                            '${r.cognome} ${r.nome}',
                                      },
                                    );
                                  }
                                : null,
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                            ),
                            onPressed:
                                () => openEdit(
                                  r,
                                ),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed:
                                () =>
                                    deleteRegistration(
                                      r.id,
                                    ),
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
