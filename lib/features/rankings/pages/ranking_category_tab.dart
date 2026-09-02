import 'package:boulder_competition/features/rankings/data/ranking_qualification_service.dart';
import 'package:boulder_competition/features/rankings/models/ranking_category_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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

    // ── raggruppa mantenendo l'ordine già dato dalla query ──
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
            if (i > 0) const SizedBox(height: 20), // riga vuota tra categorie
            _CategoryHeader(nome: categoryName),
            ...athletes.map(
              (a) => _CategoryRankingTile(ranking: a),
            ),
          ],
        );
      },
    );
  }
}

// ── intestazione categoria evidenziata ──────────────────────
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

// ── tile atleta per la classifica di categoria ──────────────
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