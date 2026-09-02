import 'package:boulder_competition/features/rankings/models/ranking_sex_model_l10n.dart';
import 'package:flutter/material.dart';

import '../data/ranking_qualification_service.dart';
import '../models/ranking_qualification_model.dart';
import 'ranking_qualification_export_pdf.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import '../models/ranking_category_model.dart';

enum _RankingFilter { maschile, femminile, generale }

class RankingQualificationPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;
  final int nrFinalisti;

  const RankingQualificationPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
    this.nrFinalisti = 0,
  });

  @override
  State<RankingQualificationPage> createState() =>
      _RankingQualificazionePageState();
}

class _RankingQualificazionePageState
    extends State<RankingQualificationPage> {
  final service = RankingQualificazioneService();
  final searchController = TextEditingController();
  final _horizontalController = ScrollController();

  List<RankingQualificationModel> rankings = [];
  bool loading = true;
  bool _exporting = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // ── filtro classifica: parte da Maschile come richiesto ────
  _RankingFilter _filter = _RankingFilter.maschile;

  // ── NUOVO: true se almeno un atleta ha una categoria ───────
  bool get hasCategories => rankings.any((r) => r.categoryId != null);

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
        SnackBar(content: Text(l10n.rankingMessageCustom10(e.toString()))), // 'Errore caricamento classifica: {error}'
      );
    }
  }

  // =========================================================
  // FILTER (sesso + ricerca testuale combinati)
  // =========================================================

  List<RankingQualificationModel> get filtered {
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
      // ── NUOVO: recupera anche le classifiche di categoria ──
      final categoryRankings = hasCategories
          ? await service.getCategoryRankings(widget.competitionId)
          : <RankingCategoryModel>[];

      await RankingQualificazioneExportPdf.exportAndShare(
        competitionName: widget.competitionName,
        dtGara: DateTime.now(),
        rankings: rankings,
        nrFinalisti: widget.nrFinalisti,
        l10n: l10n,
        categoryRankings: categoryRankings, // NUOVO
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rankingMessageCustom11(e.toString()))),
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
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.rankingMessageCustom31(widget.competitionName)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tabCount = hasCategories ? 2 : 1;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.rankingMessageCustom31(widget.competitionName), // 'Classifica qualificazioni - {competition}'
          ),
          actions: [
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
          bottom: hasCategories
              ? TabBar(
                  tabs: [
                    Tab(text: l10n.rankingMessageCustom59), // 'Generale'
                    Tab(text: l10n.rankingMessageCustom60), // 'Categorie'
                  ],
                )
              : null,
        ),
        body: hasCategories
            ? TabBarView(
                children: [
                  _buildGeneralTab(),
                  _CategoryRankingsTab(
                    competitionId: widget.competitionId,
                    service: service,
                  ),
                ],
              )
            : _buildGeneralTab(),
      ),
    );
  }

  // ── Tab "Generale" (stesso contenuto del body originale) ──
  Widget _buildGeneralTab() {
    return Column(
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
                            itemBuilder: (_, i) => _RankingTile(
                              ranking: filtered[i],
                              position: i + 1,
                              isFinalist: _isFinalist(filtered[i]),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // =========================================================
  // FINALISTI — basato sulla posizione nell'elenco FILTRATO
  // corrente (es. se è attivo "Maschile", i finalisti sono i
  // primi N uomini; se "Generale", i primi N assoluti).
  // =========================================================

  bool _isFinalist(RankingQualificationModel ranking) {
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

class _RankingTile extends StatelessWidget {
  final RankingQualificationModel ranking;
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
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.rankingMessageCustom32, // 'Top'
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
                  Text(
                    l10n.rankingMessageCustom33, // 'punti'
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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
// ──────────────────────────────────────────────────────────────
// CATEGORY RANKINGS TAB
// ──────────────────────────────────────────────────────────────

class _CategoryRankingsTab extends StatefulWidget {
  final String competitionId;
  final RankingQualificazioneService service;

  const _CategoryRankingsTab({
    required this.competitionId,
    required this.service,
  });

  @override
  State<_CategoryRankingsTab> createState() => _CategoryRankingsTabState();
}

class _CategoryRankingsTabState extends State<_CategoryRankingsTab> {
  List<RankingCategoryModel> _rankings = [];
  bool _loading = true;
  String? _error;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.service.getCategoryRankings(
        widget.competitionId,
      );
      if (!mounted) return;
      setState(() {
        _rankings = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(l10n.rankingMessageCustom10(_error!)),
      );
    }
    if (_rankings.isEmpty) {
      return Center(child: Text(l10n.rankingMessageCustom4));
    }

    final groups = <String, List<RankingCategoryModel>>{};
    final order = <String>[];
    for (final r in _rankings) {
      if (!groups.containsKey(r.categoryId)) {
        groups[r.categoryId] = [];
        order.add(r.categoryId);
      }
      groups[r.categoryId]!.add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: order.length,
      itemBuilder: (context, i) {
        final catId = order[i];
        final athletes = groups[catId]!;
        final categoryName = athletes.first.categoriaNome;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (i > 0) const SizedBox(height: 20),
            _CategoryHeader(nome: categoryName),
            ...athletes.map((a) => _CategoryRankingTile(ranking: a)),
          ],
        );
      },
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String nome;

  const _CategoryHeader({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Text(
        nome,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.indigo.shade800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _CategoryRankingTile extends StatelessWidget {
  final RankingCategoryModel ranking;

  const _CategoryRankingTile({required this.ranking});

  @override
  Widget build(BuildContext context) {
    final r = ranking;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${r.posizione}°',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,
              child: Text(
                r.pettorale?.toString() ?? '—',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                  if (r.societa != null && r.societa!.isNotEmpty)
                    Text(
                      r.societa!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                  l10n.rankingMessageCustom32,
                  style: TextStyle(fontSize: 10, color: Colors.teal.shade700),
                ),
              ],
            ),
            const SizedBox(width: 16),
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
                  Text(
                    l10n.rankingMessageCustom33,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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