import 'package:flutter/material.dart';

import '../models/athlete_boulder_model.dart';
import '../models/athlete_boulders_page_data.dart';
import '../data/athlete_boulder_service.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AthleteFilter {
  all,
  todo,
  done,
}

class AthleteBouldersPage extends StatefulWidget {
  const AthleteBouldersPage({
    super.key,
  });

  @override
  State<AthleteBouldersPage> createState() =>
      _AthleteBouldersPageState();
}

class _AthleteBouldersPageState
    extends State<AthleteBouldersPage> {
  final service = AthleteBoulderService();

  bool loading = true;
  Color _parseColor(
    String? colorName,
    ) {
        switch (
            colorName
                ?.toLowerCase()) {
          case 'rosso':
            return Colors.red;

          case 'blu':
            return Colors.blue;

          case 'verde':
            return Colors.green;

          case 'giallo':
            return Colors.yellow;

          case 'nero':
            return Colors.black;

          case 'bianco':
            return Colors.white;

          case 'arancione':
            return Colors.orange;

          case 'viola':
            return Colors.purple;

          case 'rosa':
            return Colors.pink;

          case 'grigio':
            return Colors.grey;

          default:
            return Colors.blueGrey;
        }
      }

  AthleteFilter filter =
      AthleteFilter.all;

  AthleteBouldersPageData?
      pageData;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data =
          await service.loadPage();

      if (!mounted) return;

      setState(() {
        pageData = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> markDone(
    AthleteBoulderModel item,
  ) async {
    try {
      await service.markAsDone(
        registrationId:
            pageData!.registrationId!,
        boulderId: item.boulderId,
      );

      await loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> removeAscent(
    AthleteBoulderModel item,
  ) async {
    try {
      await service.removeAscent(
        registrationId:
            pageData!.registrationId!,
        boulderId: item.boulderId,
      );

      await loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // =========================================================
  // SCAN QR — apre lo scanner e gestisce l'esito
  // =========================================================

  Future<void> openScanner() async {
    final competition = pageData?.competition;
    final registrationId = pageData?.registrationId;

   // debugPrint("OPEN SCANNER");

    if (competition == null || registrationId == null) return;

  //  debugPrint("PUSH SCANNER");
    final result = await context.push<bool>(
      '/athlete-boulder-scan',
      extra: {
        'competitionId': competition.id,
        'registrationId': registrationId,
      },
    );
 //   debugPrint("RETURNED FROM SCANNER");
    
    // Se la scansione ha avuto successo, ricarica la lista
    // così il boulder appena registrato appare come "Fatto".
    if (result == true) {
      await loadData();
    }
  }

  List<AthleteBoulderModel>
      filteredBoulders() {
    final items =
        pageData?.boulders ?? [];

    switch (filter) {
      case AthleteFilter.todo:
        return items
            .where(
              (e) => !e.top,
            )
            .toList();

      case AthleteFilter.done:
        return items
            .where(
              (e) => e.top,
            )
            .toList();

      case AthleteFilter.all:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final competition =
        pageData?.competition;

    if (competition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Boulder Competition',
          ),
        ),
        body: const Center(
          child: Padding(
            padding:
                EdgeInsets.all(24),
            child: Text(
              'Gara chiusa o atleta senza check-in',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final boulders =
        filteredBoulders();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // ── icona scanner QR in alto a sinistra ───────────────
        leading: IconButton(
          tooltip: 'Registra boulder (scansiona QR)',
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: openScanner,
        ),
        title: const Text(
          'I miei Boulder',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadData,
        child: Column(
          children: [
            // =====================================
            // GARA
            // =====================================

            Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.all(
                16,
              ),
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.blue.shade50,
                borderRadius:
                    BorderRadius
                        .circular(16),
              ),
              child: 
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Competizione',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.logout,
                          size: 18,
                        ),
                        label: const Text('Esci'),
                        onPressed: () async {
                          await Supabase
                              .instance
                              .client
                              .auth
                              .signOut();

                          if (!mounted) return;

                          context.go(
                            '/athlete-login',
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    competition.descrizione,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // =====================================
            // FILTRI
            // =====================================

            Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 16,
              ),
              child: SegmentedButton<
                  AthleteFilter>(
                segments: const [
                  ButtonSegment(
                    value:
                        AthleteFilter
                            .all,
                    label:
                        Text('Tutti'),
                  ),
                  ButtonSegment(
                    value:
                        AthleteFilter
                            .todo,
                    label:
                        Text(
                          'Da fare',
                        ),
                  ),
                  ButtonSegment(
                    value:
                        AthleteFilter
                            .done,
                    label:
                        Text(
                          'Fatti',
                        ),
                  ),
                ],
                selected: {
                  filter,
                },
                onSelectionChanged:
                    (value) {
                  setState(() {
                    filter =
                        value.first;
                  });
                },
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =====================================
            // ELENCO
            // =====================================

            Expanded(
              child: ListView.builder(
                itemCount:
                    boulders.length,
                itemBuilder:
                    (context, index) {
                  final item =
                      boulders[index];

                  return Card(
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal:
                          12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Text(
                              item.numero
                                  .toString(),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'Difficoltà ${item.difficolta}',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.terrain,
                                      size: 22,
                                      color: _parseColor(
                                        item.colore,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 8,
                                    ),

                                    Text(
                                      item.colore ?? '-',
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        10,
                                    vertical:
                                        4,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: item
                                            .top
                                        ? Colors
                                            .green
                                            .shade100
                                        : Colors
                                            .red
                                            .shade100,
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child:
                                      Text(
                                    item.top
                                        ? 'Fatto'
                                        : 'Da fare',
                                    style:
                                        TextStyle(
                                      color: item.top
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              IconButton(
                                tooltip:
                                    'Segna come fatto',
                                onPressed:
                                    item.top
                                        ? null
                                        : () =>
                                            markDone(
                                              item,
                                            ),
                                icon:
                                    const Icon(
                                  Icons.check_circle,
                                ),
                              ),
                              IconButton(
                                tooltip:
                                    'Annulla',
                                onPressed:
                                    item.top
                                        ? () =>
                                            removeAscent(
                                              item,
                                            )
                                        : null,
                                icon:
                                    const Icon(
                                  Icons.undo,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
