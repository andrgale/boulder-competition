import 'package:boulder_competition/features/rankings/models/ranking_sex_model_l10n.dart';
import 'package:flutter/material.dart';

import '../data/ranking_final_service.dart';
import '../models/ranking_final_model.dart';
import 'ranking_final_export_pdf.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

enum _RankingFilter { maschile, femminile, generale }

class RankingFinalPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const RankingFinalPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  State<RankingFinalPage> createState() => _RankingFinalPageState();
}

class _RankingFinalPageState extends State<RankingFinalPage> {
  final service = RankingFinalService();
  final searchController = TextEditingController();
  final _horizontalController = ScrollController();

  List<RankingFinalModel> rankings = [];
  bool loading = true;
  bool _exporting = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // ── filtro classifica: parte da Maschile come richiesto ────
  _RankingFilter _filter = _RankingFilter.maschile;

  @override
  void initState() {
    super.initState();
    loadRankings();
  }

  @override
  void dispose() {
    searchController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> loadRankings() async {
    try {
      final data = await service.getRankings(widget.competitionId);
      if (!mounted) return;
      setState(() {
        rankings = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.rankingMessageCustom10(e.toString()))), // 'Errore caricamento classifica: {error}'
      );
    }
  }

  // =========================================================
  // FILTER (sesso + ricerca testuale combinati)
  // =========================================================

  List<RankingFinalModel> get filtered {
    final q = searchController.text.trim().toLowerCase();

    return rankings.where((r) {
      // ── filtro sesso ──────────────────────────────────────
      final matchSesso = switch (_filter) {
        _RankingFilter.maschile => r.sesso == 'M',
        _RankingFilter.femminile => r.sesso == 'F',
        _RankingFilter.generale => true,
      };
      if (!matchSesso) return false;

      // ── filtro ricerca testuale ───────────────────────────
      if (q.isEmpty) return true;
      return r.cognome.toLowerCase().contains(q) ||
          r.nome.toLowerCase().contains(q) ||
          (r.pettorale?.toString() ?? '').contains(q);
    }).toList();
  }

  // =========================================================
  // EXPORT PDF
  // =========================================================

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      await RankingFinalExportPdf.exportAndShare(
        competitionName: widget.competitionName,
        dtGara: DateTime.now(), // sostituisci con la data gara reale se disponibile
        rankings: rankings,
        l10n:l10n // usa la lista completa, non filtered
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.rankingMessageCustom11(e.toString()))), // 'Errore esportazione PDF: {error}'
      );
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
        title: Text(
          l10n.rankingMessageCustom1(widget.competitionName), // 'Classifica finale - {competition}'
        ),
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
                    tooltip: l10n.rankingMessageCustom2, // 'Esporta PDF'
                    icon: const Icon(Icons.picture_as_pdf),
                    onPressed: _exportPdf,
                  ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── filtri classifica ──────────────────────
                _RankingFilterBar(
                  current: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                ),

                // ── ricerca ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: l10n.rankingMessageCustom3, // 'Cerca pettorale, cognome, nome...'
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

                // ── lista classifica ───────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(l10n.rankingMessageCustom4), // 'Nessun atleta in classifica'
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            const minContentWidth = 780.0;
                            final contentWidth =
                                constraints.maxWidth > minContentWidth
                                    ? constraints.maxWidth
                                    : minContentWidth;

                            return Scrollbar(
                              controller: _horizontalController, // keep consistent variable name
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
                                    itemBuilder: (_, i) => _RankingTile(
                                      ranking: filtered[i],
                                      position: i + 1,
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
// FILTER BAR — Maschile / Femminile / Generale
// ──────────────────────────────────────────────────────────────

class _RankingFilterBar extends StatelessWidget {
  final _RankingFilter current;
  final ValueChanged<_RankingFilter> onChanged;

  const _RankingFilterBar({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _FilterChip(
            label: l10n.rankingMessageCustom5, // 'Classifica Maschile'
            icon: Icons.male,
            selected: current == _RankingFilter.maschile,
            color: Colors.blue,
            onTap: () => onChanged(_RankingFilter.maschile),
          ),
          _FilterChip(
            label: l10n.rankingMessageCustom6, // 'Classifica Femminile'
            icon: Icons.female,
            selected: current == _RankingFilter.femminile,
            color: Colors.pink,
            onTap: () => onChanged(_RankingFilter.femminile),
          ),
          _FilterChip(
            label: l10n.rankingMessageCustom7, // 'Classifica Generale'
            icon: Icons.groups,
            selected: current == _RankingFilter.generale,
            color: Colors.indigo,
            onTap: () => onChanged(_RankingFilter.generale),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// RANKING TILE
// ──────────────────────────────────────────────────────────────

/// Colori podio: oro, argento, bronzo per le prime 3 posizioni.
const _goldColor = Color(0xFFD4AF37);
const _silverColor = Color(0xFFA8A9AD);
const _bronzeColor = Color(0xFFB08D57);

class _RankingTile extends StatelessWidget {
  final RankingFinalModel ranking;
  final int position;

  const _RankingTile({
    required this.ranking,
    required this.position,
  });

  Color? get _podiumColor {
    switch (position) {
      case 1:
        return _goldColor;
      case 2:
        return _silverColor;
      case 3:
        return _bronzeColor;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ranking;
    final podiumColor = _podiumColor;
    final isPodium = podiumColor != null;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPodium ? podiumColor.withValues(alpha: 0.6) : const Color(0xFFE5E7EB),
          width: isPodium ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── posizione ─────────────────────────────────
            SizedBox(
              width: 28,
              child: Text(
                '$position°',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ── pettorale — oro/argento/bronzo per il podio ─
            CircleAvatar(
              radius: 20,
              backgroundColor: isPodium ? podiumColor : Colors.grey.shade100,
              child: Text(
                r.pettorale?.toString() ?? '—',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPodium ? Colors.white : Colors.grey.shade700,
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
                      r.localizedSessoLabel(context),
                      if (r.societa != null && r.societa!.isNotEmpty)
                        r.societa!,
                    ].join(' · '),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── top / tentativi top ─────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${r.nrTop}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                Text(
                  l10n.rankingMessageCustom8(r.tentativiTop.toString()), // 'Top ({attempts})'
                  style: TextStyle(fontSize: 10, color: Colors.teal.shade700),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // ── zone / tentativi zone ────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${r.nrZone}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
                Text(
                  l10n.rankingMessageCustom9(r.tentativiZone.toString()), // 'Zone ({attempts})'
                  style: TextStyle(fontSize: 10, color: Colors.indigo.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}