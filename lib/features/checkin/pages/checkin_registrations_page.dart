import 'dart:async';

import 'package:flutter/material.dart';

import '../data/checkin_registration_service.dart';
import '../models/checkin_registration_model.dart';
import 'checkin_pdf_export.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class CheckinRegistrationsPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  // ── nuovi parametri dalla competition ─────────────────────
  final double quotaIscrizione;
  final bool flGestionePresenze;
  final bool flGestionePagamenti;
  final bool flGestioneOmaggi;

  const CheckinRegistrationsPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
    this.quotaIscrizione = 0,
    this.flGestionePresenze = false,
    this.flGestionePagamenti = false,
    this.flGestioneOmaggi = false,
  });

  @override
  State<CheckinRegistrationsPage> createState() =>
      _CheckinRegistrationsPageState();
}

class _CheckinRegistrationsPageState extends State<CheckinRegistrationsPage> {
  final service = CheckinRegistrationService();
  final searchController = TextEditingController();
  final _horizontalController = ScrollController();
  StreamSubscription<List<CheckinRegistrationModel>>? _realtimeSubscription;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  List<CheckinRegistrationModel> registrations = [];
  bool loading = true;
  bool _exporting = false;

  // ── statistiche calcolate in tempo reale ──────────────────
  int get totaleIscritti => registrations.length;
  int get totalePresenti => registrations.where((r) => r.flPresente).length;
  int get totalePagati => registrations.where((r) => r.flPagato).length;
  int get totaleOmaggi => registrations.where((r) => r.flOmaggio).length;

  /// Importo incassato = n° pagati × quota iscrizione
  double get importoIncassato => totalePagati * widget.quotaIscrizione;

  @override
  void initState() {
    super.initState();
    loadRealtime();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    searchController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  // =========================================================
  // REALTIME
  // =========================================================

  void loadRealtime() {
    _realtimeSubscription = service
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
    required String flag,
  }) async {
    final idx = registrations.indexWhere((r) => r.id == reg.id);
    if (idx < 0) return;

    final updated = switch (flag) {
      'presente' => reg.copyWith(flPresente: !reg.flPresente),
      'pagato' => reg.copyWith(flPagato: !reg.flPagato),
      'omaggio' => reg.copyWith(flOmaggio: !reg.flOmaggio),
      _ => reg,
    };

    setState(() => registrations[idx] = updated);

    try {
      switch (flag) {
        case 'presente':
          await service.togglePresente(
            id: reg.id,
            currentValue: reg.flPresente,
          );
        case 'pagato':
          await service.togglePagato(id: reg.id, currentValue: reg.flPagato);
        case 'omaggio':
          await service.toggleOmaggio(id: reg.id, currentValue: reg.flOmaggio);
      }
    } catch (e) {
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
  // EXPORT PDF
  // =========================================================

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      await CheckinPdfExport.exportAndShare(
        competitionName: widget.competitionName,
        dtGara: DateTime.now(), // sostituisci con c.dtGara se disponibile
        registrations: registrations,
        quotaIscrizione: widget.quotaIscrizione,
        showPresente: widget.flGestionePresenze,
        showPagato: widget.flGestionePagamenti,
        showOmaggio: widget.flGestioneOmaggi,
        l10n: l10n,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore esportazione PDF: $e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
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
        actions: [
          if (!loading)
            _exporting
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: l10n.checkinMessageCustom1, // 'Esporta PDF'
                    icon: const Icon(Icons.picture_as_pdf),
                    onPressed: _exportPdf,
                  ),
        ],
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
                  importoIncassato: importoIncassato,
                  l10n: l10n,
                ),

                // ── ricerca ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: l10n
                          .checkinMessageCustom2, // 'Cerca pettorale, cognome, nome...'
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
                _CheckinLegend(
                  showPresente: widget.flGestionePresenze,
                  showPagato: widget.flGestionePagamenti,
                  showOmaggio: widget.flGestioneOmaggi,
                ),
                // ── lista ─────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            l10n.checkinMessageCustom3, // 'Nessuna iscrizione trovata'
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            const minContentWidth = 720.0;
                            final contentWidth =
                                constraints.maxWidth > minContentWidth
                                ? constraints.maxWidth
                                : minContentWidth;

                            return Scrollbar(
                              controller: _horizontalController,
                              thumbVisibility: true,
                              notificationPredicate: (notif) =>
                                  notif.metrics.axis == Axis.horizontal,
                              child: SingleChildScrollView(
                                controller: _horizontalController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: contentWidth,
                                  height: constraints.maxHeight,
                                  child: ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (_, i) => _RegistrationTile(
                                      registration: filtered[i],
                                      onToggle: _toggleFlag,
                                      enablePresente: widget.flGestionePresenze,
                                      enablePagato: widget.flGestionePagamenti,
                                      enableOmaggio: widget.flGestioneOmaggi,
                                      l10n: l10n,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
  final double importoIncassato;
  final AppLocalizations l10n;

  const _StatsBar({
    required this.totale,
    required this.presenti,
    required this.pagati,
    required this.omaggi,
    required this.importoIncassato,
    required this.l10n,
  });

  /// Formatta il doppio come valuta italiana: € 1.250,00
  String _formatEuro(double value) {
    // Separiamo interi e decimali manualmente per non richiedere intl.
    final intPart = value.truncate();
    final decPart = ((value - intPart) * 100).round().abs();
    final intStr = intPart.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '€ $intStr,${decPart.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: l10n.checkinMessageCustom4, // 'Iscritti'
              value: totale,
              color: Colors.blue.shade700,
              icon: Icons.people,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(
              label: l10n.checkinMessageCustom5, // 'Presenti'
              value: presenti,
              color: Colors.green.shade700,
              icon: Icons.person_pin,
              suffix: totale > 0
                  ? '${(presenti / totale * 100).toStringAsFixed(0)}%'
                  : '0%',
            ),
          ),
          _VerticalDivider(),
          // ── Pagati + importo incassato ───────────────────
          Expanded(
            child: _StatItem(
              label: l10n.checkinMessageCustom6, // 'Pagati'
              value: pagati,
              color: Colors.teal.shade700,
              icon: Icons.payments,
              suffix: importoIncassato > 0
                  ? _formatEuro(importoIncassato)
                  : null,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(
              label: l10n.checkinMessageCustom7, // 'Omaggi'
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
        Text(
          '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (suffix != null)
          Text(
            suffix!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
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
// LEGENDA — mostra solo le icone abilitate dalla competition
// ──────────────────────────────────────────────────────────────

class _CheckinLegend extends StatelessWidget {
  final bool showPresente;
  final bool showPagato;
  final bool showOmaggio;

  const _CheckinLegend({
    required this.showPresente,
    required this.showPagato,
    required this.showOmaggio,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasAny = showPresente || showPagato || showOmaggio;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            hasAny
                ? l10n
                      .checkinMessageCustom8 // 'Tocca le icone per aggiornare: '
                : l10n.checkinMessageCustom9, // 'Gestione check-in disabilitata per questa gara'
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (showPresente) ...[
            const SizedBox(width: 8),
            _LegendDot(
              color: Colors.green.shade600,
              label: l10n.registrationMessageCustom37,
            ), // 'Presente'
          ],
          if (showPagato) ...[
            const SizedBox(width: 8),
            _LegendDot(
              color: Colors.teal.shade600,
              label: l10n.registrationMessageCustom38,
            ), // 'Pagato'
          ],
          if (showOmaggio) ...[
            const SizedBox(width: 8),
            _LegendDot(
              color: Colors.orange.shade600,
              label: l10n.registrationMessageCustom39,
            ), // 'Omaggio'
          ],
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
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
  })
  onToggle;

  // ── flag abilitazione dalla competition ───────────────────
  final bool enablePresente;
  final bool enablePagato;
  final bool enableOmaggio;
  final AppLocalizations l10n;

  const _RegistrationTile({
    required this.registration,
    required this.onToggle,
    required this.enablePresente,
    required this.enablePagato,
    required this.enableOmaggio,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final r = registration;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: r.flPresente ? Colors.green.shade200 : const Color(0xFFE5E7EB),
          width: r.flPresente ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── pettorale ─────────────────────────────────
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

            // ── dati atleta ───────────────────────────────
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── toggle presenze ───────────────────────────
            _CheckinToggle(
              value: r.flPresente,
              enabled: enablePresente,
              activeIcon: Icons.person_pin,
              inactiveIcon: Icons.person_pin_outlined,
              activeColor: Colors.green,
              tooltip: enablePresente
                  ? (r.flPresente
                        ? l10n.checkinMessageCustom10
                        : l10n.checkinMessageCustom11) // 'Rimuovi presenza' / 'Segna presente'
                  : l10n.checkinMessageCustom12, // 'Gestione presenze non abilitata'
              onTap: enablePresente
                  ? () => onToggle(reg: r, flag: 'presente')
                  : null,
            ),

            const SizedBox(width: 4),

            _CheckinToggle(
              value: r.flPagato,
              enabled: enablePagato,
              activeIcon: Icons.payments,
              inactiveIcon: Icons.payments_outlined,
              activeColor: Colors.teal,
              tooltip: enablePagato
                  ? (r.flPagato
                        ? l10n.checkinMessageCustom13
                        : l10n.checkinMessageCustom14) // 'Annulla pagamento' / 'Segna pagato'
                  : l10n.checkinMessageCustom15, // 'Gestione pagamenti non abilitata'
              onTap: enablePagato
                  ? () => onToggle(reg: r, flag: 'pagato')
                  : null,
            ),

            const SizedBox(width: 4),

            _CheckinToggle(
              value: r.flOmaggio,
              enabled: enableOmaggio,
              activeIcon: Icons.card_giftcard,
              inactiveIcon: Icons.card_giftcard_outlined,
              activeColor: Colors.orange,
              tooltip: enableOmaggio
                  ? (r.flOmaggio
                        ? l10n.checkinMessageCustom16
                        : l10n.checkinMessageCustom17) // 'Annulla omaggio' / 'Segna omaggio'
                  : l10n.checkinMessageCustom18, // 'Gestione omaggi non abilitata'
              onTap: enableOmaggio
                  ? () => onToggle(reg: r, flag: 'omaggio')
                  : null,
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
  final bool enabled; // ← nuovo: false = sola lettura
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final String tooltip;
  final VoidCallback? onTap; // ← nullable: null se disabilitato

  const _CheckinToggle({
    required this.value,
    required this.enabled,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colori dimmerizzati quando disabilitato
    final effectiveColor = enabled ? activeColor : Colors.grey.shade400;
    final effectiveBg = enabled
        ? (value ? activeColor.withValues(alpha: 0.12) : Colors.grey.shade50)
        : Colors.grey.shade100;
    final effectiveBorder = enabled
        ? (value ? activeColor.withValues(alpha: 0.5) : Colors.grey.shade300)
        : Colors.grey.shade200;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap, // null disabilita automaticamente InkWell
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: effectiveBorder),
          ),
          child: Icon(
            value ? activeIcon : inactiveIcon,
            size: 22,
            color: value && enabled ? effectiveColor : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
