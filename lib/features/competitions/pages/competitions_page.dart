import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/base_page.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/responsive_table.dart';

import '../data/competition_service.dart';
import '../models/competition_model.dart';

class CompetitionsPage extends StatefulWidget {
  const CompetitionsPage({super.key});

  @override
  State<CompetitionsPage> createState() =>
      _CompetitionsPageState();
}

class _CompetitionsPageState
    extends State<CompetitionsPage> {
  final service = CompetitionService();
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  List<CompetitionModel> allCompetitions = [];
  List<CompetitionModel> competitions = [];

  bool loading = true;
  bool showOnlyOpen = false;
  bool sortAsc = true;
  String sortColumn = 'dt_gara';

  @override
  void initState() {
    super.initState();
    loadRealtime();
  }

  void loadRealtime() {
    service.watchCompetitions().listen((rows) {
      if (!mounted) return;
      allCompetitions = rows;
      applyFilters();
    });
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    var filtered = allCompetitions.where((c) {
      final matchSearch =
          c.descrizione.toLowerCase().contains(query);

      final matchOpen =
          !showOnlyOpen || c.flGaraChiusa == false;

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

  Future<void> deleteCompetition(
      CompetitionModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina competizione'),
        content: Text('Eliminare "${c.descrizione}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await service.deleteCompetition(c.id);
    await refreshData();
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
    await context.push(
      '/competitions/${c.id}/categories',
      extra: c,
    );
  }

  Future<void> openBoulders(CompetitionModel c) async {
    await context.push(
      '/competitions/${c.id}/boulders',
      extra: c,
    );
  }

  Future<void> openRegistrations(CompetitionModel c) async {
    await context.push(
      '/competitions/${c.id}/registrations',
      extra: c,
    );
  }

  void _createNew() async {
    final result =
        await context.push('/competitions/new');
    if (result == true) await refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.responsive;

    return BasePage(
      title: 'Competizioni',
      floatingActionButton: screen.isMobile
          ? FloatingActionButton.extended(
              onPressed: _createNew,
              icon: const Icon(Icons.add),
              label: const Text('Nuova'),
            )
          : null,
      actions: [
        FilledButton.icon(
          onPressed: _createNew,
          icon: const Icon(Icons.add),
          label: const Text('Nuova Gara'),
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
            decoration: const InputDecoration(
              hintText: 'Cerca competizione',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => applyFilters(),
          ),
        ),
        FilterChip(
          label: const Text('Solo aperte'),
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
      return const Center(
          child: CircularProgressIndicator());
    }

    if (competitions.isEmpty) {
      return const Center(
          child: Text('Nessuna competizione'));
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

  const _MobileListView({
    required this.competitions,
    required this.refresh,
    required this.onDelete,
    required this.openRegistrations,
    required this.openCategories,
    required this.openBoulders,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: competitions.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final c = competitions[i];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(c.descrizione),
                const SizedBox(height: 8),
                Text(DateFormat('dd/MM/yyyy')
                    .format(c.dtGara)),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                      c.flGaraChiusa ? 'Chiusa' : 'Aperta'),
                ),
                Row(
                  children: [
                    IconButton(
                        icon:
                            const Icon(Icons.how_to_reg),
                        onPressed: () =>
                            openRegistrations(c)),
                    IconButton(
                        icon:
                            const Icon(Icons.category),
                        onPressed: () =>
                            openCategories(c)),
                    IconButton(
                        icon:
                            const Icon(Icons.terrain),
                        onPressed: () =>
                            openBoulders(c)),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final r =
                            await context.push(
                                '/competitions/edit/${c.id}');
                        if (r == true) refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          onDelete(c),
                    ),
                  ],
                )
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
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveTable(
      controller: scrollController,
      columns: const [
        DataColumn(label: Text('Descrizione')),
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Stato')),
        DataColumn(label: Text('Azioni')),
      ],
      rows: competitions.map((c) {
        return DataRow(cells: [
          DataCell(SizedBox(
            width: 400,
            child: Text(
              c.descrizione,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(Text(
              DateFormat('dd/MM/yyyy')
                  .format(c.dtGara))),
          DataCell(Chip(
              label: Text(c.flGaraChiusa
                  ? 'Chiusa'
                  : 'Aperta'))),
          DataCell(Row(
            children: [
              IconButton(
                  icon:
                      const Icon(Icons.how_to_reg),
                  onPressed: () =>
                      openRegistrations(c)),
              IconButton(
                  icon:
                      const Icon(Icons.category),
                  onPressed: () =>
                      openCategories(c)),
              IconButton(
                  icon:
                      const Icon(Icons.terrain),
                  onPressed: () =>
                      openBoulders(c)),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final r =
                      await context.push(
                          '/competitions/edit/${c.id}');
                  if (r == true) refresh();
                },
              ),
              IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      onDelete(c)),
            ],
          )),
        ]);
      }).toList(),
    );
  }
}