import 'package:flutter/material.dart';

import '../data/ranking_qualificazione_service.dart';
import '../models/ranking_qualificazione_model.dart';
import 'ranking_qualificazione_export_pdf.dart';

enum _RankingFilter { maschile, femminile, generale }

class RankingQualificazionePage extends StatefulWidget {
  final String competitionId;
  final String competitionName;
  final int nrFinalisti;

  const RankingQualificazionePage({
    super.key,
    required this.competitionId,
    required this.competitionName,
    this.nrFinalisti = 0,
  });

  @override
  State<RankingQualificazionePage> createState() =>
      _RankingQualificazionePageState();
}

class _RankingQualificazionePageState
    extends State<RankingQualificazionePage> {
  final service = RankingQualificazioneService();
  final searchController = TextEditingController();

  List<RankingQualificazioneModel> rankings = [];
  bool loading = true;
  bool _exporting = false;

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
        SnackBar(content: Text('Errore caricamento classifica: $e')),
      );
    }
  }

  // =========================================================
  // FILTER (sesso + ricerca testuale combinati)
  // =========================================================

  List<RankingQualificazioneModel> get filtered {
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
  // EXPORT PDF — implementazione nel prossimo step
  // =========================================================

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      await RankingQualificazioneExportPdf.exportAndShare(
        competitionName: widget.competitionName,
        dtGara: DateTime.now(), // sostituisci con la data gara reale se disponibile
        rankings: rankings, // usa la lista completa, non filtered
        nrFinalisti: widget.nrFinalisti,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore esportazione PDF: $e')),
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
          'Classifica qualificazioni - ${widget.competitionName}',
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
                    tooltip: 'Esporta PDF',
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
                      hintText: 'Cerca pettorale, cognome, nome...',
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
                      ? const Center(
                          child: Text('Nessun atleta in classifica'),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _RankingTile(
                            ranking: filtered[i],
                            // La posizione qui rispecchia l'ordine
                            // dell'elenco FILTRATO, ma il colore finalisti
                            // si basa sull'ordine GENERALE per coerenza
                            // con la classifica reale, non con il filtro
                            // sesso applicato. Vedi nota sotto.
                            position: i + 1,
                            isFinalist: _isFinalist(filtered[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // =========================================================
  // FINALISTI — basato sulla posizione nell'elenco FILTRATO
  // corrente (es. se è attivo "Maschile", i finalisti sono i
  // primi N uomini; se "Generale", i primi N assoluti).
  // =========================================================

  bool _isFinalist(RankingQualificazioneModel ranking) {
    if (widget.nrFinalisti <= 0) return false;
    final list = filtered;
    final idx = list.indexOf(ranking);
    return idx >= 0 && idx < widget.nrFinalisti;
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _FilterChip(
            label: 'Classifica Maschile',
            icon: Icons.male,
            selected: current == _RankingFilter.maschile,
            color: Colors.blue,
            onTap: () => onChanged(_RankingFilter.maschile),
          ),
          _FilterChip(
            label: 'Classifica Femminile',
            icon: Icons.female,
            selected: current == _RankingFilter.femminile,
            color: Colors.pink,
            onTap: () => onChanged(_RankingFilter.femminile),
          ),
          _FilterChip(
            label: 'Classifica Generale',
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

class _RankingTile extends StatelessWidget {
  final RankingQualificazioneModel ranking;
  final int position;
  final bool isFinalist;

  const _RankingTile({
    required this.ranking,
    required this.position,
    required this.isFinalist,
  });

  @override
  Widget build(BuildContext context) {
    final r = ranking;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isFinalist
              ? Colors.green.shade300
              : const Color(0xFFE5E7EB),
          width: isFinalist ? 1.5 : 1,
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

            // ── pettorale — verde se finalista ─────────────
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  isFinalist ? Colors.green.shade400 : Colors.grey.shade100,
              child: Text(
                r.pettorale?.toString() ?? '—',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isFinalist ? Colors.white : Colors.grey.shade700,
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
                      r.sessoLabel,
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

            // ── nr top ────────────────────────────────────
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
                  'Top',
                  style: TextStyle(fontSize: 10, color: Colors.teal.shade700),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // ── punteggio totale ──────────────────────────
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    r.punteggioTotale.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'punti',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
