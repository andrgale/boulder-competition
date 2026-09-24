import 'dart:async';

import 'package:boulder_competition/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/base_page.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/responsive_table.dart';

import '../data/competition_service.dart';
import '../models/competition_model.dart';

import 'package:boulder_competition/l10n/app_localizations.dart';

class CompetitionsPage extends StatefulWidget {
  const CompetitionsPage({super.key});

  @override
  State<CompetitionsPage> createState() => _CompetitionsPageState();
}

class _CompetitionsPageState extends State<CompetitionsPage> {
  final service = CompetitionService();
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  StreamSubscription<List<CompetitionModel>>? _realtimeSubscription;

  List<CompetitionModel> allCompetitions = [];
  List<CompetitionModel> competitions = [];

  bool loading = true;
  bool showOnlyOpen = false;
  bool sortAsc = true;
  String sortColumn = 'dt_gara';
  bool canWriteCategory = false;
  bool checkingPermissionCategory = true;
  bool canWriteDelete = false;
  bool checkingPermissionDelete = true;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // ── true se esiste almeno una gara aperta ──────────────────
  // Calcolato sui dati già in memoria (allCompetitions), che
  // sono sempre sincronizzati via realtime: non serve una
  // query separata, basta filtrare la lista che abbiamo già.
  bool get hasOpenCompetition =>
      allCompetitions.any((c) => c.flGaraChiusa == false);

  @override
  void initState() {
    super.initState();
    loadRealtime();
    checkPermissionCategory();
    checkPermissionDelete();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void loadRealtime() {
    _realtimeSubscription = service.watchCompetitions().listen((rows) {
      if (!mounted) return;
      allCompetitions = rows;
      applyFilters();
    });
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    var filtered = allCompetitions.where((c) {
      final matchSearch = c.descrizione.toLowerCase().contains(query);

      final matchOpen = !showOnlyOpen || c.flGaraChiusa == false;

      return matchSearch && matchOpen;
    }).toList();

    filtered.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      switch (sortColumn) {
        case 'descrizione':
          valueA = a.descrizione;
          valueB = b.descrizione;
          break;
        case 'dt_gara':
          valueA = a.dtGara;
          valueB = b.dtGara;
          break;
        default:
          valueA = a.createdAt;
          valueB = b.createdAt;
      }

      final result = Comparable.compare(valueA, valueB);
      return sortAsc ? result : -result;
    });

    setState(() {
      competitions = filtered;
      loading = false;
    });
  }

  Future<void> deleteCompetition(CompetitionModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.competitionMessageCustom26, // Elimina competizione
        ),
        content: Text(
          '${l10n.competitionMessageCustom27} "${c.descrizione}"?', // Eliminare
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l10n.commonCancel, // Annulla
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.commonDelete, // Elimina
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await service.deleteCompetition(c.id);
    await refreshData();
  }

  // =====================================================
  // CONTROLLO PERMESSI CATEGORIA
  // =====================================================
  Future<void> checkPermissionCategory() async {
    final allowed = await PermissionService.hasPermission('category.write');

    if (!mounted) return;

    setState(() {
      canWriteCategory = allowed;
      checkingPermissionCategory = false;
    });
  }

  // =====================================================
  // CONTROLLO PERMESSI CANCELLATION
  // =====================================================
  Future<void> checkPermissionDelete() async {
    final allowed = await PermissionService.hasPermission('competition.write');

    if (!mounted) return;

    setState(() {
      canWriteDelete = allowed;
      checkingPermissionDelete = false;
    });
  }

  Future<void> refreshData() async {
    final rows = await service.getCompetitions();
    if (!mounted) return;
    allCompetitions = rows;
    applyFilters();
  }

  void updateSort(String col) {
    setState(() {
      if (sortColumn == col) {
        sortAsc = !sortAsc;
      } else {
        sortColumn = col;
        sortAsc = true;
      }
      applyFilters();
    });
  }

  // ✅ AZIONI RIPRISTINATE

  Future<void> openCategories(CompetitionModel c) async {
    await context.push('/competitions/${c.id}/categories', extra: c);
  }

  Future<void> openBoulders(CompetitionModel c) async {
    await context.push('/competitions/${c.id}/boulders', extra: c);
  }

  Future<void> openStatistics(CompetitionModel c) async {
    await context.push('/competitions/${c.id}/statistics', extra: c);
  }

  Future<void> openRegistrations(CompetitionModel c) async {
    await context.push('/competitions/${c.id}/registrations', extra: c);
  }

  void _createNew() async {
    // ── guardia di sicurezza: non crea se esiste già una gara
    // aperta, anche se per qualche motivo il bottone fosse
    // stato chiamato comunque (es. tasto Invio, automazione test)
    if (hasOpenCompetition) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.competitionMessageCustom28, // Esiste già una gara aperta: chiudila prima di crearne una nuova.
          ),
        ),
      );
      return;
    }

    final result = await context.push('/competitions/new');
    if (result == true) await refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.responsive;

    return BasePage(
      title: l10n.competitionMessageCustom29, // Competizioni
      floatingActionButton: screen.isMobile
          ? FloatingActionButton.extended(
              onPressed: hasOpenCompetition ? null : _createNew,
              icon: const Icon(Icons.add),
              label: Text(
                l10n.competitionMessageCustom2, // Nuova
              ),
            )
          : null,
      actions: [
        Tooltip(
          message: hasOpenCompetition
              ? l10n
                    .competitionMessageCustom30 // Chiudi la gara aperta prima di crearne una nuova
              : l10n.competitionMessageCustom2, // Nuova Gara
          child: FilledButton.icon(
            onPressed: hasOpenCompetition ? null : _createNew,
            icon: const Icon(Icons.add),
            label: Text(
              l10n.competitionMessageCustom2, // Nuova Gara
            ),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(screen),
          const SizedBox(height: 24),
          Expanded(child: _buildContent(screen)),
        ],
      ),
    );
  }

  Widget _buildFilters(Responsive screen) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: screen.isMobile ? double.infinity : 420,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: l10n.competitionMessageCustom31, // Cerca competizione
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => applyFilters(),
          ),
        ),
        FilterChip(
          label: Text(
            l10n.competitionMessageCustom32, // Solo aperte
          ),
          selected: showOnlyOpen,
          onSelected: (v) {
            showOnlyOpen = v;
            applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildContent(Responsive screen) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (competitions.isEmpty) {
      return Center(
        child: Text(
          l10n.competitionMessageCustom33, // Nessuna competizione
        ),
      );
    }

    switch (screen.screenSize) {
      case ScreenSize.mobile:
        return _MobileListView(
          competitions: competitions,
          onDelete: deleteCompetition,
          refresh: refreshData,
          openRegistrations: openRegistrations,
          openCategories: openCategories,
          openBoulders: openBoulders,
          openStatistics: openStatistics,
          canWriteCategory: canWriteCategory,
          checkingPermissionCategory: checkingPermissionCategory,
          canWriteDelete: canWriteDelete,
          checkingPermissionDelete: checkingPermissionDelete,
        );

      case ScreenSize.tablet:
      case ScreenSize.desktop:
        return _TableView(
          competitions: competitions,
          scrollController: scrollController,
          onDelete: deleteCompetition,
          refresh: refreshData,
          updateSort: updateSort,
          sortAsc: sortAsc,
          sortColumn: sortColumn,
          openRegistrations: openRegistrations,
          openCategories: openCategories,
          openBoulders: openBoulders,
          openStatistics: openStatistics,
          canWriteCategory: canWriteCategory,
          checkingPermissionCategory: checkingPermissionCategory,
          canWriteDelete: canWriteDelete,
          checkingPermissionDelete: checkingPermissionDelete,
        );
    }
  }
}

// ✅ MOBILE

class _MobileListView extends StatelessWidget {
  final List<CompetitionModel> competitions;
  final Function refresh;
  final Function(CompetitionModel) onDelete;

  final Function(CompetitionModel) openRegistrations;
  final Function(CompetitionModel) openCategories;
  final Function(CompetitionModel) openBoulders;
  final Function(CompetitionModel) openStatistics;

  final bool canWriteCategory;
  final bool checkingPermissionCategory;
  final bool canWriteDelete;
  final bool checkingPermissionDelete;

  const _MobileListView({
    required this.competitions,
    required this.refresh,
    required this.onDelete,
    required this.openRegistrations,
    required this.openCategories,
    required this.openBoulders,
    required this.openStatistics,
    required this.canWriteCategory,
    required this.checkingPermissionCategory,
    required this.canWriteDelete,
    required this.checkingPermissionDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.separated(
      itemCount: competitions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final c = competitions[i];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.descrizione),
                const SizedBox(height: 8),
                Text(DateFormat('dd/MM/yyyy').format(c.dtGara)),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    c.flGaraChiusa
                        ? l10n
                              .competitionMessageCustom34 // Chiusa
                        : l10n.competitionMessageCustom35, // Aperta
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.how_to_reg),
                      onPressed: c.flGaraChiusa
                          ? null
                          : () => openRegistrations(c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.category),
                      onPressed:
                          (c.flGaraChiusa ||
                              !canWriteCategory ||
                              checkingPermissionCategory)
                          ? null
                          : () => openCategories(c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.terrain),
                      onPressed: c.flGaraChiusa ? null : () => openBoulders(c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.query_stats),
                      onPressed: () => openStatistics(c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: (!canWriteDelete || checkingPermissionDelete)
                          ? null
                          : () async {
                              final r = await context.push(
                                '/competitions/edit/${c.id}',
                              );
                              if (r == true) refresh();
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed:
                          (c.flGaraChiusa ||
                              !canWriteDelete ||
                              checkingPermissionDelete)
                          ? null
                          : () => onDelete(c),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ✅ TABLE

class _TableView extends StatelessWidget {
  final List<CompetitionModel> competitions;
  final ScrollController scrollController;
  final Function(CompetitionModel) onDelete;
  final Function refresh;
  final Function(String) updateSort;

  final bool sortAsc;
  final String sortColumn;

  final Function(CompetitionModel) openRegistrations;
  final Function(CompetitionModel) openCategories;
  final Function(CompetitionModel) openBoulders;
  final Function(CompetitionModel) openStatistics;
  final bool canWriteCategory;
  final bool checkingPermissionCategory;
  final bool canWriteDelete;
  final bool checkingPermissionDelete;

  const _TableView({
    required this.competitions,
    required this.scrollController,
    required this.onDelete,
    required this.refresh,
    required this.updateSort,
    required this.sortAsc,
    required this.sortColumn,
    required this.openRegistrations,
    required this.openCategories,
    required this.openBoulders,
    required this.openStatistics,
    required this.canWriteCategory,
    required this.checkingPermissionCategory,
    required this.canWriteDelete,
    required this.checkingPermissionDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveTable(
      controller: scrollController,
      columns: [
        DataColumn(
          label: Text(
            l10n.competitionDescription, // Descrizione
          ),
        ),
        DataColumn(
          label: Text(
            l10n.competitionDate, // Data
          ),
        ),
        DataColumn(
          label: Text(
            l10n.competitionMessageCustom36, // Stato
          ),
        ),
        DataColumn(
          label: Text(
            l10n.competitionMessageCustom37, // Azioni
          ),
        ),
      ],
      rows: competitions.map((c) {
        return DataRow(
          cells: [
            DataCell(
              SizedBox(
                width: 600,
                child: Text(c.descrizione, overflow: TextOverflow.ellipsis),
              ),
            ),
            DataCell(Text(DateFormat('dd/MM/yyyy').format(c.dtGara))),
            DataCell(
              Chip(
                label: Text(
                  c.flGaraChiusa
                      ? l10n
                            .competitionMessageCustom34 // Chiusa
                      : l10n.competitionMessageCustom35, // Aperta
                ),
              ),
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.how_to_reg),
                    onPressed: c.flGaraChiusa
                        ? null
                        : () => openRegistrations(c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.category),
                    onPressed:
                        (c.flGaraChiusa ||
                            !canWriteCategory ||
                            checkingPermissionCategory)
                        ? null
                        : () => openCategories(c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.terrain),
                    onPressed: c.flGaraChiusa ? null : () => openBoulders(c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.query_stats),
                    onPressed: () => openStatistics(c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: (!canWriteDelete || checkingPermissionDelete)
                        ? null
                        : () async {
                            final r = await context.push(
                              '/competitions/edit/${c.id}',
                            );
                            if (r == true) refresh();
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed:
                        (c.flGaraChiusa ||
                            !canWriteDelete ||
                            checkingPermissionDelete)
                        ? null
                        : () => onDelete(c),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}