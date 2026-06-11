import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';

import '../../athlete/models/athlete_boulder_model.dart';
import '../data/ascents_boulders_service.dart';
import 'ascents_boulders_form_page.dart';

enum AthleteFilter { all, todo, done }

class AscentsBouldersPage extends StatefulWidget {
  final String registrationId;
  final String athleteName;

  const AscentsBouldersPage({
    super.key,
    required this.registrationId,
    required this.athleteName,
  });

  @override
  State<AscentsBouldersPage> createState() => _AscentsBouldersPageState();
}

class _AscentsBouldersPageState extends State<AscentsBouldersPage> {
  final service = AscentsBouldersService();

  bool loading = true;
  AthleteFilter filter = AthleteFilter.all;
  List<AthleteBoulderModel> boulders = [];
  String competitionName = '';

  // ── stats ────────────────────────────────────────────────
  int get totalBoulders => boulders.length;
  int get completedBoulders => boulders.where((e) => e.top).length;
  double get completionPercent =>
      totalBoulders == 0 ? 0 : completedBoulders / totalBoulders;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ── colore ───────────────────────────────────────────────
  Color _parseColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'rosso':
        return Colors.red;
      case 'blu':
        return Colors.blue;
      case 'verde':
        return Colors.green;
      case 'giallo':
        return Colors.yellow.shade700;
      case 'nero':
        return Colors.black;
      case 'bianco':
        return Colors.grey.shade300;
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

  // ── load ─────────────────────────────────────────────────
  Future<void> loadData() async {
    try {
      setState(() => loading = true);

      final data = await service.loadPageByRegistration(
        widget.registrationId,
      );

      if (!mounted) return;

      setState(() {
        competitionName = data.competition?['descrizione'] ?? '';
        boulders = data.boulders;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => loading = false);
    }
  }

  // ── actions ──────────────────────────────────────────────
  Future<void> markDone(AthleteBoulderModel item) async {
    await service.markAsDone(
      registrationId: widget.registrationId,
      boulderId: item.boulderId,
    );
    await loadData();
  }

  Future<void> removeAscent(AthleteBoulderModel item) async {
    await service.removeAscent(
      registrationId: widget.registrationId,
      boulderId: item.boulderId,
    );
    await loadData();
  }

  // ── NUOVO: apri form dettaglio ───────────────────────────
  Future<void> openForm(AthleteBoulderModel item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AscentsBouldersFormPage(
          registrationId: widget.registrationId,
          athleteName: widget.athleteName,
          boulder: item,
        ),
      ),
    );

    if (result == true) await loadData();
  }

  // ── filter ───────────────────────────────────────────────
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

  // ── card mobile ──────────────────────────────────────────
  Widget buildBoulderCard(AthleteBoulderModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(child: Text(item.numero.toString())),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difficoltà ${item.difficolta}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.terrain,
                          size: 22, color: _parseColor(item.colore)),
                      const SizedBox(width: 8),
                      Text(item.colore ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // badge stato
                  Wrap(
                    spacing: 6,
                    children: [
                      _StatusChip(label: 'TOP', active: item.top),
                      _StatusChip(label: 'ZONE', active: item.zone),
                    ],
                  ),
                ],
              ),
            ),
            // ── azioni ──────────────────────────────────────
            Column(
              children: [
                // NUOVO: matita
                IconButton(
                  tooltip: 'Modifica',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => openForm(item),
                ),
                IconButton(
                  tooltip: 'Segna TOP',
                  icon: const Icon(Icons.check_circle),
                  onPressed: item.top ? null : () => markDone(item),
                ),
                IconButton(
                  tooltip: 'Rimuovi ascent',
                  icon: const Icon(Icons.undo),
                  onPressed: item.top ? () => removeAscent(item) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── header ───────────────────────────────────────────────
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(competitionName,
              style: const TextStyle(color: Colors.grey)),
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

  // ── build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = filteredBoulders();

    return Scaffold(
      appBar: AppBar(
        title: Text('Boulder — ${widget.athleteName}'),
      ),
      body: Column(
        children: [
          buildHeader(),

          // filtri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AthleteFilter>(
              segments: const [
                ButtonSegment(
                    value: AthleteFilter.all, label: Text('Tutti')),
                ButtonSegment(
                    value: AthleteFilter.todo, label: Text('Da fare')),
                ButtonSegment(
                    value: AthleteFilter.done, label: Text('Fatti')),
              ],
              selected: {filter},
              onSelectionChanged: (val) =>
                  setState(() => filter = val.first),
            ),
          ),

          const SizedBox(height: 12),

          // lista
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      filter == AthleteFilter.done
                          ? 'Nessun boulder completato'
                          : filter == AthleteFilter.todo
                              ? 'Tutti i boulder completati!'
                              : 'Nessun boulder',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => buildBoulderCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STATUS CHIP
// ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final bool active;

  const _StatusChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? Colors.green.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: active ? Colors.green.shade800 : Colors.grey.shade500,
        ),
      ),
    );
  }
}
