import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

import '../../../shared/widgets/base_page.dart';

import '../../../shared/dialogs/app_confirm_dialog.dart';

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

  final searchController =
      TextEditingController();

  List<CompetitionModel> allCompetitions =
      [];

  List<CompetitionModel> competitions =
      [];

  bool loading = true;

  bool showOnlyOpen = false;

  bool sortAsc = true;

  String sortColumn = 'dt_gara';

  @override
  void initState() {
    super.initState();

    loadRealtime();
  }

  // =======================================================
  // REALTIME
  // =======================================================

  void loadRealtime() {
    service.watchCompetitions().listen(
      (rows) {
        if (!mounted) return;

        allCompetitions = rows;

        applyFilters();
      },
    );
  }

  // =======================================================
  // FILTERS
  // =======================================================

  void applyFilters() {
    final query =
        searchController.text
            .trim()
            .toLowerCase();

    List<CompetitionModel> filtered =
        allCompetitions.where((c) {
      final matchSearch =
          c.descrizione
              .toLowerCase()
              .contains(query);

      final matchOpen =
          !showOnlyOpen ||
          c.flGaraChiusa == false;

      return matchSearch && matchOpen;
    }).toList();

    // =====================================================
    // SORTING
    // =====================================================

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

      final result =
          Comparable.compare(
        valueA,
        valueB,
      );

      return sortAsc ? result : -result;
    });

    setState(() {
      competitions = filtered;

      loading = false;
    });
  }

  // =======================================================
  // DELETE
  // =======================================================

  Future<void> deleteCompetition(
    CompetitionModel competition,
  ) async {
    final confirm =
        await AppConfirmDialog.showDelete(
      context: context,

      title: 'Elimina competizione',

      message:
          'Vuoi eliminare "${competition.descrizione}"?',
    );

    if (!confirm) return;

    try {
      await service.deleteCompetition(
        competition.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Competizione eliminata'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =======================================================
  // SORT
  // =======================================================

  void updateSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAsc = !sortAsc;
      } else {
        sortColumn = column;

        sortAsc = true;
      }

      applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Competizioni',

      floatingActionButton:
          MediaQuery.of(context)
                      .size
                      .width <
                  900
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    await context.push(
                      '/competitions/new',
                    );
                  },

                  icon: const Icon(Icons.add),

                  label:
                      const Text('Nuova'),
                )
              : null,

      actions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push(
              '/competitions/new',
            );
          },

          icon: const Icon(Icons.add),

          label: const Text(
            'Nuova Gara',
          ),
        ),
      ],

      child: Column(
        children: [
          // =================================================
          // FILTER BAR
          // =================================================

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      searchController,

                  decoration:
                      const InputDecoration(
                    hintText:
                        'Cerca competizione',
                    prefixIcon:
                        Icon(Icons.search),
                  ),

                  onChanged: (_) {
                    applyFilters();
                  },
                ),
              ),

              const SizedBox(width: 16),

              FilterChip(
                label:
                    const Text('Solo aperte'),

                selected: showOnlyOpen,

                onSelected: (value) {
                  showOnlyOpen = value;

                  applyFilters();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =================================================
          // TABLE
          // =================================================

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : buildTable(),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // TABLE
  // =======================================================

  Widget buildTable() {
    if (competitions.isEmpty) {
      return const Center(
        child: Text(
          'Nessuna competizione trovata',
        ),
      );
    }

    final isMobile =
        MediaQuery.of(context).size.width <
            700;

    if (isMobile) {
      return ListView.separated(
        itemCount: competitions.length,

        separatorBuilder:
            (_, __) =>
                const SizedBox(height: 12),

        itemBuilder: (context, index) {
          final c = competitions[index];

          return Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    c.descrizione,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(c.dtGara),
                  ),

                  const SizedBox(height: 12),

                  Chip(
                    label: Text(
                      c.flGaraChiusa
                          ? 'Chiusa'
                          : 'Aperta',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await context.push(
                            '/competitions/edit/${c.id}',
                          );
                        },

                        icon:
                            const Icon(Icons.edit),
                      ),

                      IconButton(
                        onPressed: () {
                          deleteCompetition(c);
                        },

                        icon: const Icon(
                          Icons.delete,
                        ),
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

    return Card(
      clipBehavior: Clip.antiAlias,

      child: SingleChildScrollView(
        child: DataTable(
          sortAscending: sortAsc,

          columns: [
            DataColumn(
              label: const Text(
                'Descrizione',
              ),

              onSort: (_, __) {
                updateSort(
                  'descrizione',
                );
              },
            ),

            DataColumn(
              label:
                  const Text('Data Gara'),

              onSort: (_, __) {
                updateSort('dt_gara');
              },
            ),

            const DataColumn(
              label: Text('Stato'),
            ),

            const DataColumn(
              label: Text('Azioni'),
            ),
          ],

          rows: competitions.map((c) {
            return DataRow(
              cells: [
                DataCell(
                  Text(c.descrizione),
                ),

                DataCell(
                  Text(
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(c.dtGara),
                  ),
                ),

                DataCell(
                  Chip(
                    label: Text(
                      c.flGaraChiusa
                          ? 'Chiusa'
                          : 'Aperta',
                    ),
                  ),
                ),

                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await context.push(
                            '/competitions/edit/${c.id}',
                          );
                        },

                        icon: const Icon(
                          Icons.edit,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          deleteCompetition(c);
                        },

                        icon: const Icon(
                          Icons.delete,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}