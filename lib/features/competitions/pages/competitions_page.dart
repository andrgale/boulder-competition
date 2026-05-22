// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:go_router/go_router.dart';

// import '../../../shared/widgets/base_page.dart';
// //import '../../../shared/dialogs/app_confirm_dialog.dart';

// import '../data/competition_service.dart';
// import '../models/competition_model.dart';

// class CompetitionsPage extends StatefulWidget {
//   const CompetitionsPage({super.key});

//   @override
//   State<CompetitionsPage> createState() =>
//       _CompetitionsPageState();
// }

// class _CompetitionsPageState
//     extends State<CompetitionsPage> {
//   final service = CompetitionService();

//   final searchController =
//       TextEditingController();

//   List<CompetitionModel> allCompetitions =
//       [];

//   List<CompetitionModel> competitions =
//       [];

//   bool loading = true;

//   bool showOnlyOpen = false;

//   bool sortAsc = true;

//   String sortColumn = 'dt_gara';

//   @override
//   void initState() {
//     super.initState();

//     loadRealtime();
//   }

//   // =======================================================
//   // REALTIME
//   // =======================================================

//   void loadRealtime() {
//     service.watchCompetitions().listen(
//       (rows) {
//         if (!mounted) return;

//         allCompetitions = rows;

//         applyFilters();
//       },
//     );
//   }

//   // =======================================================
//   // FILTERS
//   // =======================================================

//   void applyFilters() {
//     final query =
//         searchController.text
//             .trim()
//             .toLowerCase();

//     List<CompetitionModel> filtered =
//         allCompetitions.where((c) {
//       final matchSearch =
//           c.descrizione
//               .toLowerCase()
//               .contains(query);

//       final matchOpen =
//           !showOnlyOpen ||
//           c.flGaraChiusa == false;

//       return matchSearch && matchOpen;
//     }).toList();

//     filtered.sort((a, b) {
//       dynamic valueA;
//       dynamic valueB;

//       switch (sortColumn) {
//         case 'descrizione':
//           valueA = a.descrizione;
//           valueB = b.descrizione;
//           break;

//         case 'dt_gara':
//           valueA = a.dtGara;
//           valueB = b.dtGara;
//           break;

//         default:
//           valueA = a.createdAt;
//           valueB = b.createdAt;
//       }

//       final result =
//           Comparable.compare(
//         valueA,
//         valueB,
//       );

//       return sortAsc ? result : -result;
//     });

//     setState(() {
//       competitions = filtered;

//       loading = false;
//     });
//   }

//   // =======================================================
//   // DELETE
//   // =======================================================
//   Future<void> deleteCompetition(
//     CompetitionModel competition,
//   ) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text(
//             'Elimina competizione',
//           ),
//           content: Text(
//             'Vuoi eliminare "${competition.descrizione}"?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop(false);
//               },
//               child: const Text('Annulla'),
//             ),
//             FilledButton.icon(
//               icon: const Icon(Icons.delete),
//               label: const Text('Elimina'),
//               style: FilledButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               onPressed: () {
//                 Navigator.of(dialogContext).pop(true);
//               },
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm != true) return;

//     try {
//       await service.deleteCompetition(
//         competition.id,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Competizione eliminata',
//           ),
//         ),
//       );

//       loadRealtime(); // ← refresh elenco
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Errore eliminazione: $e',
//           ),
//         ),
//       );
//     }
//   }
  
//   // =======================================================
//   // SORT
//   // =======================================================

//   void updateSort(String column) {
//     setState(() {
//       if (sortColumn == column) {
//         sortAsc = !sortAsc;
//       } else {
//         sortColumn = column;
//         sortAsc = true;
//       }

//       applyFilters();
//     });
//   }

//   // =======================================================
//   // REFRESH
//   // =======================================================

//   Future<void> refreshData() async {
//     final rows =
//         await service.getCompetitions();

//     if (!mounted) return;

//     allCompetitions = rows;

//     applyFilters();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile =
//         MediaQuery.of(context).size.width <
//             700;

//     return BasePage(
//       title: 'Competizioni',

//       floatingActionButton: isMobile
//           ? FloatingActionButton.extended(
//               onPressed: () async {
//                 final result =
//                     await context.push(
//                   '/competitions/new',
//                 );

//                 if (result == true) {
//                   await refreshData();
//                 }
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Nuova'),
//             )
//           : null,

//       actions: [
//         FilledButton.icon(
//           onPressed: () async {
//             final result =
//                 await context.push(
//               '/competitions/new',
//             );

//             if (result == true) {
//               await refreshData();
//             }
//           },
//           icon: const Icon(Icons.add),
//           label: const Text(
//             'Nuova Gara',
//           ),
//         ),
//       ],

//       // ===================================================
//       // FIXED LAYOUT
//       // ===================================================

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // =============================================
//           // FILTER BAR
//           // =============================================

//           Wrap(
//             spacing: 16,
//             runSpacing: 16,
//             crossAxisAlignment:
//                 WrapCrossAlignment.center,
//             children: [
//               SizedBox(
//                 width:
//                     isMobile ? 320 : 420,
//                 child: TextField(
//                   controller:
//                       searchController,
//                   decoration:
//                       const InputDecoration(
//                     hintText:
//                         'Cerca competizione',
//                     prefixIcon:
//                         Icon(Icons.search),
//                   ),
//                   onChanged: (_) {
//                     applyFilters();
//                   },
//                 ),
//               ),

//               FilterChip(
//                 label:
//                     const Text('Solo aperte'),
//                 selected: showOnlyOpen,
//                 onSelected: (value) {
//                   showOnlyOpen = value;

//                   applyFilters();
//                 },
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // =============================================
//           // TABLE
//           // =============================================

//           Expanded(
//             child: loading
//                 ? const Center(
//                     child:
//                         CircularProgressIndicator(),
//                   )
//                 : buildTable(),
//           ),
//         ],
//       ),
//     );
//   }

//   // =======================================================
//   // TABLE
//   // =======================================================

//   Widget buildTable() {
//     if (competitions.isEmpty) {
//       return const Center(
//         child: Text(
//           'Nessuna competizione trovata',
//         ),
//       );
//     }

//     final isMobile =
//         MediaQuery.of(context).size.width <
//             700;

//     // =====================================================
//     // MOBILE
//     // =====================================================

//     if (isMobile) {
//       return ListView.separated(
//         itemCount: competitions.length,
//         separatorBuilder:
//             (_, __) =>
//                 const SizedBox(height: 12),
//         itemBuilder: (context, index) {
//           final c = competitions[index];

//           return Card(
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(16),
//               side: const BorderSide(
//                 color: Color(0xFFE5E7EB),
//               ),
//             ),
//             child: Padding(
//               padding:
//                   const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     c.descrizione,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   Text(
//                     DateFormat(
//                       'dd/MM/yyyy',
//                     ).format(c.dtGara),
//                   ),

//                   const SizedBox(height: 12),

//                   Chip(
//                     label: Text(
//                       c.flGaraChiusa
//                           ? 'Chiusa'
//                           : 'Aperta',
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () async {
//                           final result =
//                               await context.push(
//                             '/competitions/edit/${c.id}',
//                           );

//                           if (result == true) {
//                             await refreshData();
//                           }
//                         },
//                         icon:
//                             const Icon(Icons.edit),
//                       ),

//                       IconButton(
//                         onPressed: () {
//                           deleteCompetition(c);
//                         },
//                         icon: const Icon(
//                           Icons.delete,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }

//     // =====================================================
//     // DESKTOP TABLE FULL WIDTH
//     // =====================================================

//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.circular(20),
//         side: const BorderSide(
//           color: Color(0xFFE5E7EB),
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             minWidth:
//                 MediaQuery.of(context)
//                         .size
//                         .width -
//                     360,
//           ),
//           child: DataTable(
//             columnSpacing: 48,
//             horizontalMargin: 32,
//             dataRowMinHeight: 72,
//             dataRowMaxHeight: 72,
//             headingRowHeight: 64,
//             sortAscending: sortAsc,

//             columns: [
//               DataColumn(
//                 label: const Text(
//                   'Descrizione',
//                 ),
//                 onSort: (_, __) {
//                   updateSort(
//                     'descrizione',
//                   );
//                 },
//               ),

//               DataColumn(
//                 label:
//                     const Text('Data Gara'),
//                 onSort: (_, __) {
//                   updateSort('dt_gara');
//                 },
//               ),

//               const DataColumn(
//                 label: Text('Stato'),
//               ),

//               const DataColumn(
//                 label: Text('Azioni'),
//               ),
//             ],

//             rows: competitions.map((c) {
//               return DataRow(
//                 cells: [
//                   DataCell(
//                     SizedBox(
//                       width: 500,
//                       child: Text(
//                         c.descrizione,
//                         overflow:
//                             TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),

//                   DataCell(
//                     Text(
//                       DateFormat(
//                         'dd/MM/yyyy',
//                       ).format(c.dtGara),
//                     ),
//                   ),

//                   DataCell(
//                     Chip(
//                       label: Text(
//                         c.flGaraChiusa
//                             ? 'Chiusa'
//                             : 'Aperta',
//                       ),
//                     ),
//                   ),

//                   DataCell(
//                     Row(
//                       mainAxisSize:
//                           MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           onPressed: () async {
//                             final result =
//                                 await context.push(
//                               '/competitions/edit/${c.id}',
//                             );

//                             if (result ==
//                                 true) {
//                               await refreshData();
//                             }
//                           },
//                           icon: const Icon(
//                             Icons.edit,
//                           ),
//                         ),

//                         IconButton(
//                           onPressed: () {
//                             deleteCompetition(
//                               c,
//                             );
//                           },
//                           icon: const Icon(
//                             Icons.delete,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/base_page.dart';

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
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Elimina competizione',
          ),
          content: Text(
            'Vuoi eliminare "${competition.descrizione}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annulla'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Elimina'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await service.deleteCompetition(
        competition.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Competizione eliminata',
          ),
        ),
      );

      loadRealtime();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Errore eliminazione: $e',
          ),
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

  // =======================================================
  // REFRESH
  // =======================================================

  Future<void> refreshData() async {
    final rows =
        await service.getCompetitions();

    if (!mounted) return;

    allCompetitions = rows;

    applyFilters();
  }

  // =======================================================
  // OPEN CATEGORIES
  // =======================================================

  // Future<void> openCategories(
  //   CompetitionModel competition,
  // ) async {
  //   await context.push(
  //     '/competitions/${competition.id}/categories',
  //     extra: competition,
  //   );
  // }

  Future<void> openCategories(CompetitionModel competition) async {
    await context.push(
      '/competitions/${competition.id}/categories',
      extra: competition,
    );
  }
  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width <
            700;

    return BasePage(
      title: 'Competizioni',

      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result =
                    await context.push(
                  '/competitions/new',
                );

                if (result == true) {
                  await refreshData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuova'),
            )
          : null,

      actions: [
        FilledButton.icon(
          onPressed: () async {
            final result =
                await context.push(
              '/competitions/new',
            );

            if (result == true) {
              await refreshData();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text(
            'Nuova Gara',
          ),
        ),
      ],

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =============================================
          // FILTER BAR
          // =============================================

          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment:
                WrapCrossAlignment.center,
            children: [
              SizedBox(
                width:
                    isMobile ? 320 : 420,
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

          // =============================================
          // TABLE
          // =============================================

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

    // =====================================================
    // MOBILE
    // =====================================================

    if (isMobile) {
      return ListView.separated(
        itemCount: competitions.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final c = competitions[index];

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
              side: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(20),
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
                        tooltip: 'Categorie',
                        onPressed: () {
                          openCategories(c);
                        },
                        icon: const Icon(
                          Icons.category,
                        ),
                      ),

                      IconButton(
                        onPressed: () async {
                          final result =
                              await context.push(
                            '/competitions/edit/${c.id}',
                          );

                          if (result == true) {
                            await refreshData();
                          }
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

    // =====================================================
    // DESKTOP TABLE
    // =====================================================

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth:
                MediaQuery.of(context)
                        .size
                        .width -
                    360,
          ),
          child: DataTable(
            columnSpacing: 48,
            horizontalMargin: 32,
            dataRowMinHeight: 72,
            dataRowMaxHeight: 72,
            headingRowHeight: 64,
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
                    SizedBox(
                      width: 500,
                      child: Text(
                        c.descrizione,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
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
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Categorie',
                          onPressed: () {
                            openCategories(c);
                          },
                          icon: const Icon(
                            Icons.category,
                          ),
                        ),

                        IconButton(
                          onPressed: () async {
                            final result =
                                await context.push(
                              '/competitions/edit/${c.id}',
                            );

                            if (result ==
                                true) {
                              await refreshData();
                            }
                          },
                          icon: const Icon(
                            Icons.edit,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            deleteCompetition(
                              c,
                            );
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
      ),
    );
  }
}