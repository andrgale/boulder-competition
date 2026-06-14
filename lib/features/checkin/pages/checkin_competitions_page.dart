import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/base_page.dart';
import '../../../shared/app_snackbar.dart';
import '../data/checkin_competition_service.dart';
import '../models/checkin_competition_model.dart';
import 'checkin_registrations_page.dart';


class CheckinCompetitionsPage extends StatefulWidget {
  const CheckinCompetitionsPage({super.key});

  @override
  State<CheckinCompetitionsPage> createState() =>
      _CheckinCompetitionsPageState();
}

class _CheckinCompetitionsPageState
    extends State<CheckinCompetitionsPage> {
  final service = CheckinCompetitionService();
  final searchController = TextEditingController();

  List<CheckinCompetitionModel> allCompetitions = [];
  List<CheckinCompetitionModel> competitions = [];

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

    List<CheckinCompetitionModel> filtered =
        allCompetitions.where((c) {
      final matchSearch =
          c.descrizione.toLowerCase().contains(query);
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
  // TOGGLE FLAGS — aggiorna ottimisticamente la lista locale
  // =========================================================

  Future<void> _toggleFlag({
    required CheckinCompetitionModel competition,
    required String flag, // 'presenze' | 'pagamenti' | 'omaggi'
  }) async {
    // aggiornamento ottimistico: cambia subito la UI
    final idx = competitions.indexOf(competition);
    if (idx < 0) return;

    final updated = switch (flag) {
      'presenze' => competition.copyWith(
          flGestionePresenze: !competition.flGestionePresenze),
      'pagamenti' => competition.copyWith(
          flGestionePagamenti: !competition.flGestionePagamenti),
      'omaggi' => competition.copyWith(
          flGestioneOmaggi: !competition.flGestioneOmaggi),
      _ => competition,
    };

    // aggiorna anche in allCompetitions
    final allIdx = allCompetitions
        .indexWhere((c) => c.id == competition.id);

    setState(() {
      competitions[idx] = updated;
      if (allIdx >= 0) allCompetitions[allIdx] = updated;
    });

    // persisti su DB
    try {
      switch (flag) {
        case 'presenze':
          await service.toggleGestionePresenze(
            id: competition.id,
            currentValue: competition.flGestionePresenze,
          );
        case 'pagamenti':
          await service.toggleGestionePagamenti(
            id: competition.id,
            currentValue: competition.flGestionePagamenti,
          );
        case 'omaggi':
          await service.toggleGestioneOmaggi(
            id: competition.id,
            currentValue: competition.flGestioneOmaggi,
          );
      }
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
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return BasePage(
      title: 'Check-in Competizioni',
      subtitle: 'Gestione presenze, pagamenti e omaggi',
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

          // ── legenda flag ─────────────────────────────────
          _FlagLegend(),

          const SizedBox(height: 16),

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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                _StatusChip(chiusa: c.flGaraChiusa),
                const SizedBox(height: 16),
                // ── flag toggles ────────────────────────────
                _FlagTogglesRow(
                  competition: c,
                  onToggle: _toggleFlag,
                ),
                const Divider(height: 24),
                // ── azioni ──────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Iscritti',
                      icon: const Icon(Icons.how_to_reg),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckinRegistrationsPage(
                              competitionId: c.id,
                              competitionName: c.descrizione,
                            ),
                          ),
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

  // =========================================================
  // DESKTOP
  // =========================================================

  Widget _buildDesktopTable() {
    final verticalController = ScrollController();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: verticalController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 360,
              ),
              child: DataTable(
                columnSpacing: 32,
                horizontalMargin: 32,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 72,
                headingRowHeight: 64,
                sortAscending: sortAsc,
                columns: [
                  DataColumn(
                    label: const Text('Descrizione'),
                    onSort: (_, __) => updateSort('descrizione'),
                  ),
                  DataColumn(
                    label: const Text('Data Gara'),
                    onSort: (_, __) => updateSort('dt_gara'),
                  ),
                  const DataColumn(label: Text('Stato')),
                  // i tre flag come colonne dedicate
                  const DataColumn(
                    label: _FlagColumnHeader(
                      icon: Icons.person_pin,
                      label: 'Presenze',
                      color: Colors.blue,
                    ),
                  ),
                  const DataColumn(
                    label: _FlagColumnHeader(
                      icon: Icons.payments_outlined,
                      label: 'Pagamenti',
                      color: Colors.green,
                    ),
                  ),
                  const DataColumn(
                    label: _FlagColumnHeader(
                      icon: Icons.card_giftcard,
                      label: 'Omaggi',
                      color: Colors.orange,
                    ),
                  ),
                  const DataColumn(label: Text('Azioni')),
                ],
                rows: competitions.map((c) => _buildRow(c)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(CheckinCompetitionModel c) {
    return DataRow(
      cells: [
        // descrizione
        DataCell(
          SizedBox(
            width: 340,
            child: Text(
              c.descrizione,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // data gara
        DataCell(Text(DateFormat('dd/MM/yyyy').format(c.dtGara))),

        // stato
        DataCell(_StatusChip(chiusa: c.flGaraChiusa)),

        // toggle presenze
        DataCell(
          _FlagToggleButton(
            value: c.flGestionePresenze,
            activeColor: Colors.blue,
            activeIcon: Icons.person_pin,
            inactiveIcon: Icons.person_pin_outlined,
            tooltip: c.flGestionePresenze
                ? 'Disabilita gestione presenze'
                : 'Abilita gestione presenze',
            onTap: () => _toggleFlag(
              competition: c,
              flag: 'presenze',
            ),
          ),
        ),

        // toggle pagamenti
        DataCell(
          _FlagToggleButton(
            value: c.flGestionePagamenti,
            activeColor: Colors.green,
            activeIcon: Icons.payments,
            inactiveIcon: Icons.payments_outlined,
            tooltip: c.flGestionePagamenti
                ? 'Disabilita gestione pagamenti'
                : 'Abilita gestione pagamenti',
            onTap: () => _toggleFlag(
              competition: c,
              flag: 'pagamenti',
            ),
          ),
        ),

        // toggle omaggi
        DataCell(
          _FlagToggleButton(
            value: c.flGestioneOmaggi,
            activeColor: Colors.orange,
            activeIcon: Icons.card_giftcard,
            inactiveIcon: Icons.card_giftcard_outlined,
            tooltip: c.flGestioneOmaggi
                ? 'Disabilita gestione omaggi'
                : 'Abilita gestione omaggi',
            onTap: () => _toggleFlag(
              competition: c,
              flag: 'omaggi',
            ),
          ),
        ),

        // azioni — solo iscritti
        DataCell(
          IconButton(
            tooltip: 'Iscritti',
            icon: const Icon(Icons.how_to_reg),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CheckinRegistrationsPage(
                  competitionId: c.id,
                  competitionName: c.descrizione,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// FLAG TOGGLE BUTTON
// Usato nelle celle della DataTable
// ──────────────────────────────────────────────────────────────

class _FlagToggleButton extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String tooltip;
  final VoidCallback onTap;

  const _FlagToggleButton({
    required this.value,
    required this.activeColor,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? activeColor.withOpacity(0.12)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value
                  ? activeColor.withOpacity(0.4)
                  : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            value ? activeIcon : inactiveIcon,
            color: value ? activeColor : Colors.grey.shade400,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// FLAG TOGGLES ROW  (usato nella card mobile)
// ──────────────────────────────────────────────────────────────

class _FlagTogglesRow extends StatelessWidget {
  final CheckinCompetitionModel competition;
  final Future<void> Function({
    required CheckinCompetitionModel competition,
    required String flag,
  }) onToggle;

  const _FlagTogglesRow({
    required this.competition,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final c = competition;
    return Row(
      children: [
        _FlagToggleButton(
          value: c.flGestionePresenze,
          activeColor: Colors.blue,
          activeIcon: Icons.person_pin,
          inactiveIcon: Icons.person_pin_outlined,
          tooltip: 'Presenze',
          onTap: () => onToggle(competition: c, flag: 'presenze'),
        ),
        const SizedBox(width: 8),
        _FlagToggleButton(
          value: c.flGestionePagamenti,
          activeColor: Colors.green,
          activeIcon: Icons.payments,
          inactiveIcon: Icons.payments_outlined,
          tooltip: 'Pagamenti',
          onTap: () => onToggle(competition: c, flag: 'pagamenti'),
        ),
        const SizedBox(width: 8),
        _FlagToggleButton(
          value: c.flGestioneOmaggi,
          activeColor: Colors.orange,
          activeIcon: Icons.card_giftcard,
          inactiveIcon: Icons.card_giftcard_outlined,
          tooltip: 'Omaggi',
          onTap: () => onToggle(competition: c, flag: 'omaggi'),
        ),
        const SizedBox(width: 16),
        // etichette compatte
        const Text('P', style: TextStyle(fontSize: 11, color: Colors.blue)),
        const SizedBox(width: 6),
        const Text('€', style: TextStyle(fontSize: 11, color: Colors.green)),
        const SizedBox(width: 6),
        const Text('O', style: TextStyle(fontSize: 11, color: Colors.orange)),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STATUS CHIP
// ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool chiusa;

  const _StatusChip({required this.chiusa});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chiusa
            ? Colors.grey.shade100
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chiusa
              ? Colors.grey.shade300
              : Colors.green.shade300,
        ),
      ),
      child: Text(
        chiusa ? 'Chiusa' : 'Aperta',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: chiusa ? Colors.grey.shade600 : Colors.green.shade700,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// FLAG COLUMN HEADER  (intestazione colonna DataTable)
// ──────────────────────────────────────────────────────────────

class _FlagColumnHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FlagColumnHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// LEGENDA FLAG  (sopra la tabella)
// ──────────────────────────────────────────────────────────────

class _FlagLegend extends StatelessWidget {
  const _FlagLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendItem(
          icon: Icons.person_pin,
          label: 'Gestione Presenze',
          color: Colors.blue,
        ),
        _LegendItem(
          icon: Icons.payments,
          label: 'Gestione Pagamenti',
          color: Colors.green,
        ),
        _LegendItem(
          icon: Icons.card_giftcard,
          label: 'Gestione Omaggi',
          color: Colors.orange,
        ),
        _LegendItem(
          icon: Icons.touch_app,
          label: 'Tocca le icone per attivare/disattivare',
          color: Colors.grey,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}
