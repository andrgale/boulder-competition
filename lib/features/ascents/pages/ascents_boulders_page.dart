import 'package:flutter/material.dart';

import '../../athlete/models/athlete_boulder_model.dart';
import '../data/ascents_boulders_service.dart';

enum AthleteFilter {
  all,
  todo,
  done,
}

class AscentsBouldersPage extends StatefulWidget {
  final String registrationId;
  final String athleteName;

  const AscentsBouldersPage({
    super.key,
    required this.registrationId,
    required this.athleteName,
  });

  @override
  State<AscentsBouldersPage> createState() =>
      _AscentsBouldersPageState();
}

class _AscentsBouldersPageState
    extends State<AscentsBouldersPage> {
  final service = AscentsBouldersService();

  bool loading = true;

  AthleteFilter filter = AthleteFilter.all;

  List<AthleteBoulderModel> boulders = [];

  String competitionName = '';

  // ============================
  // STATS
  // ============================

  int get totalBoulders => boulders.length;

  int get completedBoulders =>
      boulders.where((e) => e.top).length;

  double get completionPercent {
    if (totalBoulders == 0) return 0;
    return completedBoulders / totalBoulders;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Color _parseColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
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

  // ============================
  // LOAD
  // ============================

  Future<void> loadData() async {
    try {
      setState(() {
        loading = true;
      });

      final data =
          await service.loadPageByRegistration(
        widget.registrationId,
      );

      if (!mounted) return;

      setState(() {
        competitionName =
            data.competition?.descrizione ?? '';

        boulders = data.boulders;

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

      setState(() {
        loading = false;
      });
    }
  }

  // ============================
  // ACTIONS
  // ============================

  Future<void> markDone(
      AthleteBoulderModel item) async {
    await service.markAsDone(
      registrationId: widget.registrationId,
      boulderId: item.boulderId,
    );

    await loadData();
  }

  Future<void> removeAscent(
      AthleteBoulderModel item) async {
    await service.removeAscent(
      registrationId: widget.registrationId,
      boulderId: item.boulderId,
    );

    await loadData();
  }

  // ============================
  // FILTER
  // ============================

  List<AthleteBoulderModel> filteredBoulders() {
    switch (filter) {
      case AthleteFilter.todo:
        return boulders.where((e) => !e.top).toList();
      case AthleteFilter.done:
        return boulders.where((e) => e.top).toList();
      case AthleteFilter.all:
        return boulders;
    }
  }

  // ============================
  // UI CARD
  // ============================

  Widget buildBoulderCard(AthleteBoulderModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(item.numero.toString()),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difficoltà ${item.difficolta}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.terrain,
                        size: 22,
                        color: _parseColor(item.colore),
                      ),
                      const SizedBox(width: 8),
                      Text(item.colore ?? '-'),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.top
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.top ? 'Fatto' : 'Da fare',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.top
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle),
                  onPressed: item.top ? null : () => markDone(item),
                ),
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed:
                      item.top ? () => removeAscent(item) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // STICKY HEADER
  // ============================

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.athleteName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            competitionName,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                'TOP: $completedBoulders / $totalBoulders',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: LinearProgressIndicator(
                  value: completionPercent,
                  minHeight: 8,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '${(completionPercent * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================
  // BUILD
  // ============================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filtered = filteredBoulders();

    return Scaffold(
      appBar: AppBar(
        title: Text('Boulder - ${widget.athleteName}'),
      ),

      body: Column(
        children: [
          buildHeader(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AthleteFilter>(
              segments: const [
                ButtonSegment(value: AthleteFilter.all, label: Text('Tutti')),
                ButtonSegment(value: AthleteFilter.todo, label: Text('Da fare')),
                ButtonSegment(value: AthleteFilter.done, label: Text('Fatti')),
              ],
              selected: {filter},
              onSelectionChanged: (value) {
                setState(() => filter = value.first);
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return buildBoulderCard(filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
 
 
 
 
  //   @override
  //   Widget build(BuildContext context) {
  //     if (loading) {
  //       return const Scaffold(
  //         body: Center(
  //           child: CircularProgressIndicator(),
  //         ),
  //       );
  //     }

  //     final filtered = filteredBoulders();

  //     return Scaffold(
  //       appBar: AppBar(
  //         title: Text('Boulder - ${widget.athleteName}'),
  //       ),

  //       body: Column(
  //         children: [
  //           // =====================================================
  //           // HEADER STICKY (come immagine)
  //           // =====================================================
  //           Container(
  //             width: double.infinity,
  //             margin: const EdgeInsets.all(16),
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.blue.shade50,
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   widget.athleteName,
  //                   style: const TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),

  //                 const SizedBox(height: 4),

  //                 Text(
  //                   competitionName,
  //                   style: const TextStyle(
  //                     color: Colors.grey,
  //                   ),
  //                 ),

  //                 const SizedBox(height: 12),

  //                 Row(
  //                   children: [
  //                     Text(
  //                       'TOP: $completedBoulders / $totalBoulders',
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),

  //                     const SizedBox(width: 12),

  //                     Expanded(
  //                       child: LinearProgressIndicator(
  //                         value: completionPercent,
  //                         minHeight: 8,
  //                         backgroundColor: Colors.grey.shade300,
  //                       ),
  //                     ),

  //                     const SizedBox(width: 12),

  //                     Text(
  //                       '${(completionPercent * 100).toStringAsFixed(0)}%',
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),

  //           // =====================================================
  //           // FILTRI (uguali a prima)
  //           // =====================================================
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             child: SegmentedButton<AthleteFilter>(
  //               segments: const [
  //                 ButtonSegment(
  //                   value: AthleteFilter.all,
  //                   label: Text('Tutti'),
  //                 ),
  //                 ButtonSegment(
  //                   value: AthleteFilter.todo,
  //                   label: Text('Da fare'),
  //                 ),
  //                 ButtonSegment(
  //                   value: AthleteFilter.done,
  //                   label: Text('Fatti'),
  //                 ),
  //               ],
  //               selected: {filter},
  //               onSelectionChanged: (value) {
  //                 setState(() {
  //                   filter = value.first;
  //                 });
  //               },
  //             ),
  //           ),

  //           const SizedBox(height: 12),

  //           // =====================================================
  //           // LISTA BOULDERS
  //           // =====================================================
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: filtered.length,
  //               itemBuilder: (context, index) {
  //                 final item = filtered[index];

  //                 return Card(
  //                   margin: const EdgeInsets.symmetric(
  //                     horizontal: 12,
  //                     vertical: 6,
  //                   ),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(12),
  //                     child: Row(
  //                       children: [
  //                         CircleAvatar(
  //                           child: Text(item.numero.toString()),
  //                         ),

  //                         const SizedBox(width: 12),

  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 'Difficoltà ${item.difficolta}',
  //                                 style: const TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),

  //                               const SizedBox(height: 4),

  //                               Row(
  //                                 children: [
  //                                   Icon(
  //                                     Icons.terrain,
  //                                     size: 22,
  //                                     color: _parseColor(item.colore),
  //                                   ),
  //                                   const SizedBox(width: 8),
  //                                   Text(item.colore ?? '-'),
  //                                 ],
  //                               ),

  //                               const SizedBox(height: 8),

  //                               Container(
  //                                 padding: const EdgeInsets.symmetric(
  //                                   horizontal: 10,
  //                                   vertical: 4,
  //                                 ),
  //                                 decoration: BoxDecoration(
  //                                   color: item.top
  //                                       ? Colors.green.shade100
  //                                       : Colors.red.shade100,
  //                                   borderRadius: BorderRadius.circular(20),
  //                                 ),
  //                                 child: Text(
  //                                   item.top ? 'Fatto' : 'Da fare',
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     color: item.top
  //                                         ? Colors.green.shade800
  //                                         : Colors.red.shade800,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),

  //                         Column(
  //                           children: [
  //                             IconButton(
  //                               icon: const Icon(Icons.check_circle),
  //                               onPressed: item.top ? null : () => markDone(item),
  //                             ),
  //                             IconButton(
  //                               icon: const Icon(Icons.undo),
  //                               onPressed: item.top ? () => removeAscent(item) : null,
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  // }
}