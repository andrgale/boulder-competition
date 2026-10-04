import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:boulder_competition/core/services/permission_service.dart';
import '../../../shared/widgets/base_page.dart';
import '../../../shared/app_snackbar.dart';
import '../data/checkin_competition_service.dart';
import '../models/checkin_competition_model.dart';
import 'checkin_registrations_page.dart';
import 'dart:math';
import 'package:boulder_competition/l10n/app_localizations.dart';

class CheckinCompetitionsPage extends StatefulWidget {
  const CheckinCompetitionsPage({super.key});

  @override
  State<CheckinCompetitionsPage> createState() =>
      _CheckinCompetitionsPageState();
}

class _CheckinCompetitionsPageState extends State<CheckinCompetitionsPage> {
  final service = CheckinCompetitionService();
  final searchController = TextEditingController();
  StreamSubscription<List<CheckinCompetitionModel>>? _realtimeSubscription;

  List<CheckinCompetitionModel> allCompetitions = [];
  List<CheckinCompetitionModel> competitions = [];

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool loading = true;
  bool showOnlyOpen = false;
  bool sortAsc = true;
  String sortColumn = 'dt_gara';

  bool canWriteOpenClose = false;
  bool checkingPermissionOpenClose = true;

// true se esiste almeno una gara aperta (calcolato sui dati realtime già in memoria)
  bool get hasOpenCompetition =>
      allCompetitions.any((c) => c.flGaraChiusa == false);

  @override
  void initState() {
    super.initState();
    loadRealtime();
    checkPermissionWrite(); 
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> checkPermissionWrite() async {
    final allowed = await PermissionService.hasPermission('competition.write');
    if (!mounted) return;
    setState(() {
      canWriteOpenClose = allowed;
      checkingPermissionOpenClose = false;
    });
  }

  void _openRegistrations(CheckinCompetitionModel c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckinRegistrationsPage(
          competitionId: c.id,
          competitionName: c.descrizione,
          quotaIscrizione: c.quotaIscrizione,
          flGestionePresenze: c.flGestionePresenze,
          flGestionePagamenti: c.flGestionePagamenti,
          flGestioneOmaggi: c.flGestioneOmaggi,
          modalitaLiberatoria: c.modalitaLiberatoria,
          dtGara: c.dtGara,
        ),
      ),
    );
  }

  // =========================================================
  // REALTIME
  // =========================================================

  void loadRealtime() {
    _realtimeSubscription = service.watchCompetitions().listen((rows) {
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

    List<CheckinCompetitionModel> filtered = allCompetitions.where((c) {
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
  // TOGGLE FLAGS — aggiorna ottimisticamente la lista locale
  // =========================================================

  Future<void> _toggleFlag({
    required CheckinCompetitionModel competition,
    required String flag, // 'presenze' | 'pagamenti' | 'omaggi'
  }) async {
    if (competition.flGaraChiusa) return;
    // aggiornamento ottimistico: cambia subito la UI
    final idx = competitions.indexOf(competition);
    if (idx < 0) return;

    final updated = switch (flag) {
      'presenze' => competition.copyWith(
        flGestionePresenze: !competition.flGestionePresenze,
      ),
      'pagamenti' => competition.copyWith(
        flGestionePagamenti: !competition.flGestionePagamenti,
      ),
      'omaggi' => competition.copyWith(
        flGestioneOmaggi: !competition.flGestioneOmaggi,
      ),
      _ => competition,
    };

    // aggiorna anche in allCompetitions
    final allIdx = allCompetitions.indexWhere((c) => c.id == competition.id);

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
  // TOGGLE FL_GARA_CHIUSA — aggiornamento ottimistico
  // =========================================================

  Future<void> _toggleGaraChiusa(CheckinCompetitionModel competition) async {
    final idx = competitions.indexOf(competition);
    if (idx < 0) return;

    final isReopening = competition.flGaraChiusa;

    // guardia: non riapre se esiste già una gara aperta
    if (isReopening && hasOpenCompetition) {
      if (!mounted) return;
      AppSnackbar.error(context, l10n.competitionMessageCustom28);
      return;
    }

    final updated = competition.copyWith(flGaraChiusa: !competition.flGaraChiusa);
    final allIdx = allCompetitions.indexWhere((c) => c.id == competition.id);

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
      // rollback ottimistico
      setState(() {
        competitions[idx] = competition;
        if (allIdx >= 0) allCompetitions[allIdx] = competition;
      });
      if (!mounted) return;
      AppSnackbar.error(context, 'Errore aggiornamento: $e');
    }
  }

  // null = chip non cliccabile (permesso mancante o controllo ancora in corso)
  VoidCallback? _statusOnTap(CheckinCompetitionModel c) =>
      (canWriteOpenClose && !checkingPermissionOpenClose)
          ? () => _toggleGaraChiusa(c)
          : null;

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return BasePage(
      title: l10n.checkinMessageCustom19, // 'Check-in Competizioni'
      subtitle: l10n
          .checkinMessageCustom20, // 'Gestione presenze, pagamenti e omaggi'
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
                  decoration: InputDecoration(
                    hintText:
                        l10n.checkinMessageCustom21, // 'Cerca competizione'
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (_) => applyFilters(),
                ),
              ),
              FilterChip(
                label: Text(l10n.checkinMessageCustom22), // 'Solo aperte'
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
      return Center(
        child: Text(
          l10n.checkinMessageCustom23, // 'Nessuna competizione trovata'
        ),
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
                _StatusChip(chiusa: c.flGaraChiusa, onTap: _statusOnTap(c)),
                const SizedBox(height: 16),
                // ── flag toggles ────────────────────────────
                _FlagTogglesRow(competition: c, onToggle: _toggleFlag),
                const Divider(height: 24),
                // ── azioni ──────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      tooltip: l10n.checkinMessageCustom24, // 'Iscritti'
                      icon: const Icon(Icons.how_to_reg),
                      onPressed: c.flGaraChiusa ? null : () => _openRegistrations(c),
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

  Widget _buildDesktopTable() {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

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
          child: Scrollbar(
            controller: horizontalController,
            thumbVisibility: true,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.horizontal,
            child: SingleChildScrollView(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: max(1200, MediaQuery.of(context).size.width - 360),
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
                      label: Text(l10n.checkinMessageCustom25), // 'Descrizione'
                      onSort: (_, _) => updateSort('descrizione'),
                    ),
                    DataColumn(
                      label: Text(l10n.checkinMessageCustom26), // 'Data Gara'
                      onSort: (_, _) => updateSort('dt_gara'),
                    ),
                    DataColumn(
                      label: Text(l10n.checkinMessageCustom27),
                    ), // 'Stato'
                    DataColumn(
                      label: _FlagColumnHeader(
                        icon: Icons.person_pin,
                        label: l10n.checkinMessageCustom28, // 'Presenze'
                        color: Colors.blue,
                      ),
                    ),
                    DataColumn(
                      label: _FlagColumnHeader(
                        icon: Icons.payments_outlined,
                        label: l10n.checkinMessageCustom29, // 'Pagamenti'
                        color: Colors.green,
                      ),
                    ),
                    DataColumn(
                      label: _FlagColumnHeader(
                        icon: Icons.card_giftcard,
                        label: l10n.checkinMessageCustom30, // 'Omaggi'
                        color: Colors.orange,
                      ),
                    ),
                    DataColumn(
                      label: Text(l10n.checkinMessageCustom31),
                    ), // 'Azioni'
                  ],
                  rows: competitions.map((c) => _buildRow(c)).toList(),
                ),
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

        // stato — cliccabile: apre/chiude la gara (solo se autorizzato)
        DataCell(_StatusChip(chiusa: c.flGaraChiusa, onTap: _statusOnTap(c))),

        // toggle presenze
        DataCell(
          _FlagToggleButton(
            value: c.flGestionePresenze,
            enabled: !c.flGaraChiusa,
            activeColor: Colors.blue,
            activeIcon: Icons.person_pin,
            inactiveIcon: Icons.person_pin_outlined,
            tooltip: c.flGestionePresenze
                ? l10n
                      .checkinMessageCustom32 // 'Disabilita gestione presenze'
                : l10n.checkinMessageCustom33, // 'Abilita gestione presenze'
            onTap: () => _toggleFlag(competition: c, flag: 'presenze'),
          ),
        ),

        // toggle pagamenti
        DataCell(
          _FlagToggleButton(
            value: c.flGestionePagamenti,
            enabled: !c.flGaraChiusa,
            activeColor: Colors.green,
            activeIcon: Icons.payments,
            inactiveIcon: Icons.payments_outlined,
            tooltip: c.flGestionePagamenti
                ? l10n
                      .checkinMessageCustom34 // 'Disabilita gestione pagamenti'
                : l10n.checkinMessageCustom35, // 'Abilita gestione pagamenti'
            onTap: () => _toggleFlag(competition: c, flag: 'pagamenti'),
          ),
        ),

        // toggle omaggi
        DataCell(
          _FlagToggleButton(
            value: c.flGestioneOmaggi,
            enabled: !c.flGaraChiusa,
            activeColor: Colors.orange,
            activeIcon: Icons.card_giftcard,
            inactiveIcon: Icons.card_giftcard_outlined,
            tooltip: c.flGestioneOmaggi
                ? l10n
                      .checkinMessageCustom36 // 'Disabilita gestione omaggi'
                : l10n.checkinMessageCustom37, // 'Abilita gestione omaggi'
            onTap: () => _toggleFlag(competition: c, flag: 'omaggi'),
          ),
        ),

        // azioni — solo iscritti
        DataCell(
          IconButton(
            tooltip: l10n.checkinMessageCustom24, // 'Iscritti'
            icon: const Icon(Icons.how_to_reg),
            onPressed: c.flGaraChiusa ? null : () => _openRegistrations(c),
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
  final bool enabled; // 👈 nuovo

  const _FlagToggleButton({
    required this.value,
    required this.activeColor,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.tooltip,
    required this.onTap,
    this.enabled = true, 
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.4, // 👈 aspetto "disabilitato"
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null, // 👈 null = non cliccabile
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withValues(alpha: 0.12)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value
                    ? activeColor.withValues(alpha: 0.4)
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
  })
  onToggle;

  const _FlagTogglesRow({required this.competition, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = competition;
    return Row(
      children: [
        _FlagToggleButton(
          value: c.flGestionePresenze,
          enabled: !c.flGaraChiusa,
          activeColor: Colors.blue,
          activeIcon: Icons.person_pin,
          inactiveIcon: Icons.person_pin_outlined,
          tooltip: l10n.checkinMessageCustom28, // 'Presenze'
          onTap: () => onToggle(competition: c, flag: 'presenze'),
        ),
        const SizedBox(width: 8),
        _FlagToggleButton(
          value: c.flGestionePagamenti,
          enabled: !c.flGaraChiusa,
          activeColor: Colors.green,
          activeIcon: Icons.payments,
          inactiveIcon: Icons.payments_outlined,
          tooltip: l10n.checkinMessageCustom29, // 'Pagamenti'
          onTap: () => onToggle(competition: c, flag: 'pagamenti'),
        ),
        const SizedBox(width: 8),
        _FlagToggleButton(
          value: c.flGestioneOmaggi,
          enabled: !c.flGaraChiusa,
          activeColor: Colors.orange,
          activeIcon: Icons.card_giftcard,
          inactiveIcon: Icons.card_giftcard_outlined,
          tooltip: l10n.checkinMessageCustom30, // 'Omaggi'
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
  final VoidCallback? onTap;

  const _StatusChip({required this.chiusa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = onTap != null;

    return Tooltip(
      message: !enabled
          ? l10n.rankingMessageCustom61
          : (chiusa
                ? l10n.rankingMessageCustom27
                : l10n.rankingMessageCustom28),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
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
                  chiusa
                      ? l10n.checkinMessageCustom39 // 'Chiusa'
                      : l10n.checkinMessageCustom38, // 'Aperta'
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: chiusa
                        ? Colors.grey.shade600
                        : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
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
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(
          icon: Icons.person_pin,
          label: l10n.checkinMessageCustom40, // 'Gestione Presenze'
          color: Colors.blue,
        ),
        _LegendItem(
          icon: Icons.payments,
          label: l10n.checkinMessageCustom41, // 'Gestione Pagamenti'
          color: Colors.green,
        ),
        _LegendItem(
          icon: Icons.card_giftcard,
          label: l10n.checkinMessageCustom42, // 'Gestione Omaggi'
          color: Colors.orange,
        ),
        _LegendItem(
          icon: Icons.touch_app,
          label: l10n
              .checkinMessageCustom43, // 'Tocca le icone per attivare/disattivare'
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
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
