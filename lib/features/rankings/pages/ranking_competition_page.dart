import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/base_page.dart';
import '../../../shared/app_snackbar.dart';
import '../data/ranking_competition_service.dart';
import '../models/ranking_competition_model.dart';

class RankingsCompetitionsPage extends StatefulWidget {
  const RankingsCompetitionsPage({super.key});

  @override
  State<RankingsCompetitionsPage> createState() =>
      _RankingsCompetitionsPageState();
}

class _RankingsCompetitionsPageState
    extends State<RankingsCompetitionsPage> {
  final service = RankingsCompetitionService();
  final searchController = TextEditingController();
  final _verticalController = ScrollController();   // ← nuovo
  final _horizontalController = ScrollController();  // ← nuovo


  List<RankingCompetitionModel> allCompetitions = [];
  List<RankingCompetitionModel> competitions = [];

  bool loading = true;
  bool showOnlyOpen = false;
  bool sortAsc = true;
  String sortColumn = 'dt_gara';

  @override
  void initState() {
    super.initState();
    loadRealtime();
  }

  @override
  void dispose() {
    searchController.dispose();
    _verticalController.dispose();   // ← nuovo
    _horizontalController.dispose(); // ← nuovo
    super.dispose();
  }

  // =========================================================
  // REALTIME
  // =========================================================

  void loadRealtime() {
    service.watchCompetitions().listen((rows) {
      if (!mounted) return;
      allCompetitions = rows;
      applyFilters();
    });
  }

  // =========================================================
  // FILTERS
  // =========================================================

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    List<RankingCompetitionModel> filtered = allCompetitions.where((c) {
      final matchSearch = c.descrizione.toLowerCase().contains(query);
      final matchOpen = !showOnlyOpen || !c.flGaraChiusa;
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
        default:
          valueA = a.dtGara;
          valueB = b.dtGara;
      }

      final result = Comparable.compare(valueA, valueB);
      return sortAsc ? result : -result;
    });

    setState(() {
      competitions = filtered;
      loading = false;
    });
  }

  // =========================================================
  // SORT
  // =========================================================

  void updateSort(String column) {
    setState(() {
      sortColumn == column ? sortAsc = !sortAsc : sortAsc = true;
      sortColumn = column;
      applyFilters();
    });
  }

  // =========================================================
  // TOGGLE FL_GARA_CHIUSA — aggiornamento ottimistico
  // =========================================================

  Future<void> _toggleGaraChiusa(RankingCompetitionModel competition) async {
    final idx = competitions.indexOf(competition);
    if (idx < 0) return;

    final updated = competition.copyWith(
      flGaraChiusa: !competition.flGaraChiusa,
    );

    final allIdx =
        allCompetitions.indexWhere((c) => c.id == competition.id);

    setState(() {
      competitions[idx] = updated;
      if (allIdx >= 0) allCompetitions[allIdx] = updated;
    });

    try {
      await service.toggleGaraChiusa(
        id: competition.id,
        currentValue: competition.flGaraChiusa,
      );
    } catch (e) {
      // rollback ottimistico in caso di errore
      setState(() {
        competitions[idx] = competition;
        if (allIdx >= 0) allCompetitions[allIdx] = competition;
      });
      if (!mounted) return;
      AppSnackbar.error(context, 'Errore aggiornamento: $e');
    }
  }

  // =========================================================
  // NAVIGAZIONE ALLE CLASSIFICHE
  // =========================================================

  void _goToQualifications(RankingCompetitionModel c) {
    context.push('/rankings/${c.id}/qualifications', extra: {
      'competitionId': c.id,
      'competitionName': c.descrizione,
      'nrFinalisti': c.nrFinalisti,
    });
  }

  void _goToFinal(RankingCompetitionModel c) {
    context.push('/rankings/${c.id}/final', extra: {
      'competitionId': c.id,
      'competitionName': c.descrizione,
    });
  }

  void _goToTopZone(RankingCompetitionModel c) {
    context.push('/rankings/${c.id}/top-zone', extra: {
      'competitionId': c.id,
      'competitionName': c.descrizione,
      'nrFinalisti': c.nrFinalisti,
    });
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return BasePage(
      title: 'Classifiche',
      subtitle: 'Gestione classifiche',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── filtri ──────────────────────────────────────
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: isMobile ? 320 : 420,
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
                onSelected: (value) {
                  setState(() => showOnlyOpen = value);
                  applyFilters();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── tabella ──────────────────────────────────────
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _buildTable(),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TABLE ROUTER
  // =========================================================

  Widget _buildTable() {
    if (competitions.isEmpty) {
      return const Center(
        child: Text('Nessuna competizione trovata'),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 700;
    return isMobile ? _buildMobileList() : _buildDesktopTable();
  }

  // =========================================================
  // MOBILE
  // =========================================================

  Widget _buildMobileList() {
    return ListView.separated(
      itemCount: competitions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = competitions[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.descrizione,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(DateFormat('dd/MM/yyyy').format(c.dtGara)),
                const SizedBox(height: 8),
                // ── stato cliccabile per apri/chiudi gara ──────
                _StatusChip(
                  chiusa: c.flGaraChiusa,
                  onTap: () => _toggleGaraChiusa(c),
                ),
                const Divider(height: 24),
                // ── bottoni classifiche ─────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RankingButton(
                      label: 'Classifica qualificazioni',
                      icon: Icons.format_list_numbered,
                      color: Colors.indigo,
                      onTap: () => _goToQualifications(c),
                    ),
                    _RankingButton(
                      label: 'Classifica finale',
                      icon: Icons.emoji_events,
                      color: Colors.amber.shade800,
                      onTap: () => _goToFinal(c),
                    ),
                    _RankingButton(
                      label: 'Classifica Top e Zone',
                      icon: Icons.terrain,
                      color: Colors.teal,
                      onTap: () => _goToTopZone(c),
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

  // =========================================================
  // DESKTOP
  // =========================================================

  Widget _buildDesktopTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const minContentWidth = 900.0;
          final contentWidth = constraints.maxWidth > minContentWidth
              ? constraints.maxWidth
              : minContentWidth;

          return Scrollbar(
            controller: _verticalController,
            thumbVisibility: true,
            notificationPredicate: (notif) =>
                notif.metrics.axis == Axis.vertical,
            child: SingleChildScrollView(
              controller: _verticalController,
              scrollDirection: Axis.vertical,
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                notificationPredicate: (notif) =>
                    notif.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: contentWidth),
                    child: DataTable(
                      columnSpacing: 24,
                      horizontalMargin: 32,
                      dataRowMinHeight: 72,
                      dataRowMaxHeight: 72,
                      headingRowHeight: 56,
                      sortAscending: sortAsc,
                      columns: [
                        DataColumn(
                          label: const Text('Descrizione'),
                          onSort: (_, _) => updateSort('descrizione'),
                        ),
                        DataColumn(
                          label: const Text('Data Gara'),
                          onSort: (_, _) => updateSort('dt_gara'),
                        ),
                        const DataColumn(label: Text('Stato')),
                        const DataColumn(label: Text('Qualificazioni')),
                        const DataColumn(label: Text('Finale')),
                        const DataColumn(label: Text('Top e Zone')),
                      ],
                      rows: competitions.map((c) => _buildRow(c)).toList(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildRow(RankingCompetitionModel c) {
    return DataRow(
      cells: [
        // descrizione
        DataCell(
          SizedBox(
            width: 320,
            child: Text(
              c.descrizione,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // data gara
        DataCell(Text(DateFormat('dd/MM/yyyy').format(c.dtGara))),

        // stato — cliccabile: apre/chiude la gara
        DataCell(
          _StatusChip(
            chiusa: c.flGaraChiusa,
            onTap: () => _toggleGaraChiusa(c),
          ),
        ),

        // classifica qualificazioni
        DataCell(
          _RankingButton(
            label: 'Qualificazioni',
            icon: Icons.format_list_numbered,
            color: Colors.indigo,
            onTap: () => _goToQualifications(c),
          ),
        ),

        // classifica finale
        DataCell(
          _RankingButton(
            label: 'Finale',
            icon: Icons.emoji_events,
            color: Colors.amber.shade800,
            onTap: () => _goToFinal(c),
          ),
        ),

        // classifica top e zone
        DataCell(
          _RankingButton(
            label: 'Top e Zone',
            icon: Icons.terrain,
            color: Colors.teal,
            onTap: () => _goToTopZone(c),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// RANKING BUTTON — bottone per apertura pagine classifica
// ──────────────────────────────────────────────────────────────

class _RankingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RankingButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        backgroundColor: color.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STATUS CHIP — cliccabile per apri/chiudi gara
// ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool chiusa;
  final VoidCallback onTap;

  const _StatusChip({required this.chiusa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: chiusa ? 'Tocca per riaprire la gara' : 'Tocca per chiudere la gara',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: chiusa ? Colors.grey.shade100 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: chiusa ? Colors.grey.shade300 : Colors.green.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                chiusa ? Icons.lock_outline : Icons.lock_open,
                size: 14,
                color: chiusa ? Colors.grey.shade600 : Colors.green.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                chiusa ? 'Chiusa' : 'Aperta',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: chiusa ? Colors.grey.shade600 : Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
