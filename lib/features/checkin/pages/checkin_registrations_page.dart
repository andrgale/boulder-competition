import 'package:flutter/material.dart';

import '../data/checkin_registration_service.dart';
import '../models/checkin_registration_model.dart';

class CheckinRegistrationsPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const CheckinRegistrationsPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  State<CheckinRegistrationsPage> createState() =>
      _CheckinRegistrationsPageState();
}

class _CheckinRegistrationsPageState
    extends State<CheckinRegistrationsPage> {
  final service = CheckinRegistrationService();
  final searchController = TextEditingController();

  List<CheckinRegistrationModel> registrations = [];
  bool loading = true;

  // ── statistiche calcolate in tempo reale ─────────────────
  int get totaleIscritti => registrations.length;
  int get totalePresenti =>
      registrations.where((r) => r.flPresente).length;
  int get totalePagati =>
      registrations.where((r) => r.flPagato).length;
  int get totaleOmaggi =>
      registrations.where((r) => r.flOmaggio).length;

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
    service
        .watchRegistrations(widget.competitionId)
        .listen((rows) {
      if (!mounted) return;
      setState(() {
        registrations = rows;
        loading = false;
      });
    });
  }

  // =========================================================
  // FILTER
  // =========================================================

  List<CheckinRegistrationModel> get filtered {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return registrations;

    return registrations.where((r) {
      return r.cognome.toLowerCase().contains(q) ||
          r.nome.toLowerCase().contains(q) ||
          (r.pettorale?.toString() ?? '').contains(q) ||
          (r.societa?.toLowerCase() ?? '').contains(q) ||
          r.email.toLowerCase().contains(q);
    }).toList();
  }

  // =========================================================
  // TOGGLE FLAG — ottimistico
  // =========================================================

  Future<void> _toggleFlag({
    required CheckinRegistrationModel reg,
    required String flag, // 'presente' | 'pagato' | 'omaggio'
  }) async {
    final idx = registrations.indexWhere((r) => r.id == reg.id);
    if (idx < 0) return;

    final updated = switch (flag) {
      'presente' =>
        reg.copyWith(flPresente: !reg.flPresente),
      'pagato' =>
        reg.copyWith(flPagato: !reg.flPagato),
      'omaggio' =>
        reg.copyWith(flOmaggio: !reg.flOmaggio),
      _ => reg,
    };

    // aggiorna subito la UI
    setState(() => registrations[idx] = updated);

    try {
      switch (flag) {
        case 'presente':
          await service.togglePresente(
            id: reg.id,
            currentValue: reg.flPresente,
          );
        case 'pagato':
          await service.togglePagato(
            id: reg.id,
            currentValue: reg.flPagato,
          );
        case 'omaggio':
          await service.toggleOmaggio(
            id: reg.id,
            currentValue: reg.flOmaggio,
          );
      }
    } catch (e) {
      // rollback in caso di errore
      setState(() => registrations[idx] = reg);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore aggiornamento: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in — ${widget.competitionName}'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── contatori ─────────────────────────────
                _StatsBar(
                  totale: totaleIscritti,
                  presenti: totalePresenti,
                  pagati: totalePagati,
                  omaggi: totaleOmaggi,
                ),

                // ── ricerca ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Cerca pettorale, cognome, nome...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                // ── legenda ───────────────────────────────
                const _CheckinLegend(),

                // ── lista ─────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('Nessuna iscrizione trovata'),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) =>
                              _RegistrationTile(
                            registration: filtered[i],
                            onToggle: _toggleFlag,
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STATS BAR
// ──────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final int totale;
  final int presenti;
  final int pagati;
  final int omaggi;

  const _StatsBar({
    required this.totale,
    required this.presenti,
    required this.pagati,
    required this.omaggi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Iscritti',
              value: totale,
              color: Colors.blue.shade700,
              icon: Icons.people,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              label: 'Presenti',
              value: presenti,
              color: Colors.green.shade700,
              icon: Icons.person_pin,
              suffix: totale > 0
                  ? '${(presenti / totale * 100).toStringAsFixed(0)}%'
                  : '0%',
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              label: 'Pagati',
              value: pagati,
              color: Colors.teal.shade700,
              icon: Icons.payments,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              label: 'Omaggi',
              value: omaggi,
              color: Colors.orange.shade700,
              icon: Icons.card_giftcard,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final String? suffix;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              Text(
                suffix!,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.blue.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// LEGENDA
// ──────────────────────────────────────────────────────────────

class _CheckinLegend extends StatelessWidget {
  const _CheckinLegend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          const Text(
            'Tocca le icone per aggiornare: ',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          _LegendDot(color: Colors.green.shade600, label: 'Presente'),
          const SizedBox(width: 8),
          _LegendDot(color: Colors.teal.shade600, label: 'Pagato'),
          const SizedBox(width: 8),
          _LegendDot(color: Colors.orange.shade600, label: 'Omaggio'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// REGISTRATION TILE
// ──────────────────────────────────────────────────────────────

class _RegistrationTile extends StatelessWidget {
  final CheckinRegistrationModel registration;
  final Future<void> Function({
    required CheckinRegistrationModel reg,
    required String flag,
  }) onToggle;

  const _RegistrationTile({
    required this.registration,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final r = registration;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // bordo verde se già presente, grigio altrimenti
          color: r.flPresente
              ? Colors.green.shade200
              : const Color(0xFFE5E7EB),
          width: r.flPresente ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            // ── pettorale ───────────────────────────────
            CircleAvatar(
              radius: 20,
              backgroundColor: r.flPresente
                  ? Colors.green.shade100
                  : Colors.grey.shade100,
              child: Text(
                r.pettorale?.toString() ?? '—',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: r.flPresente
                      ? Colors.green.shade800
                      : Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── dati atleta ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      r.email,
                      if (r.societa != null && r.societa!.isNotEmpty)
                        r.societa!,
                      if (r.sesso != null) r.sesso!,
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── toggle presenze ─────────────────────────
            _CheckinToggle(
              value: r.flPresente,
              activeIcon: Icons.person_pin,
              inactiveIcon: Icons.person_pin_outlined,
              activeColor: Colors.green,
              tooltip: r.flPresente ? 'Rimuovi presenza' : 'Segna presente',
              onTap: () => onToggle(reg: r, flag: 'presente'),
            ),

            const SizedBox(width: 4),

            // ── toggle pagamenti ────────────────────────
            _CheckinToggle(
              value: r.flPagato,
              activeIcon: Icons.payments,
              inactiveIcon: Icons.payments_outlined,
              activeColor: Colors.teal,
              tooltip: r.flPagato ? 'Annulla pagamento' : 'Segna pagato',
              onTap: () => onToggle(reg: r, flag: 'pagato'),
            ),

            const SizedBox(width: 4),

            // ── toggle omaggi ───────────────────────────
            _CheckinToggle(
              value: r.flOmaggio,
              activeIcon: Icons.card_giftcard,
              inactiveIcon: Icons.card_giftcard_outlined,
              activeColor: Colors.orange,
              tooltip: r.flOmaggio ? 'Annulla omaggio' : 'Segna omaggio',
              onTap: () => onToggle(reg: r, flag: 'omaggio'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// CHECKIN TOGGLE BUTTON
// ──────────────────────────────────────────────────────────────

class _CheckinToggle extends StatelessWidget {
  final bool value;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final String tooltip;
  final VoidCallback onTap;

  const _CheckinToggle({
    required this.value,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? activeColor.withOpacity(0.12)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value
                  ? activeColor.withOpacity(0.5)
                  : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            value ? activeIcon : inactiveIcon,
            size: 22,
            color: value ? activeColor : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
