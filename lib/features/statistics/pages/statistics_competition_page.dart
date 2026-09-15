import 'package:flutter/material.dart';

import '../data/statistic_competition_registration_service.dart';
import '../data/statistic_competition_registration_owner_service.dart';
import '../data/statistic_competition_boulder_service.dart';
import '../data/statistic_competition_boulder_detail_service.dart';
import '../data/statistic_competition_category_service.dart';
import '../models/statistic_competition_registration_model.dart';
import '../models/statistic_competition_registration_owner_model.dart';
import '../models/statistic_competition_boulder_model.dart';
import '../models/statistic_competition_boulder_detail_model.dart';
import '../models/statistic_competition_category_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class StatisticsCompetitionPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const StatisticsCompetitionPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  State<StatisticsCompetitionPage> createState() =>
      _StatisticsCompetitionPageState();
}

class _StatisticsCompetitionPageState
    extends State<StatisticsCompetitionPage> {
  final _statsService = StatisticCompetitionRegistrationService();
  final _ownerService = StatisticCompetitionRegistrationOwnerService();
  final _boulderService = StatisticCompetitionBoulderService();
  final _boulderDetailService = StatisticCompetitionBoulderDetailService();
  final _categoryService = StatisticCompetitionCategoryService();

  StatisticCompetitionRegistrationModel? _stats;
  List<StatisticCompetitionRegistrationOwnerModel> _ownerStats = [];

  StatisticCompetitionBoulderModel? _boulderStats;
  List<StatisticCompetitionBoulderDetailModel> _boulderDetails = [];

  List<StatisticCompetitionCategoryModel> _categoryStats = [];

  bool _loading = true;
  String? _error;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _statsService.getCompetitionStatistics(widget.competitionId),
        _ownerService.getStatistics(widget.competitionId),
        _boulderService.getStatistics(widget.competitionId),
        _boulderDetailService.getStatistics(widget.competitionId),
        _categoryService.getStatistics(widget.competitionId),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = results[0] as StatisticCompetitionRegistrationModel?;
        _ownerStats =
            results[1] as List<StatisticCompetitionRegistrationOwnerModel>;
        _boulderStats = results[2] as StatisticCompetitionBoulderModel?;
        _boulderDetails =
            results[3] as List<StatisticCompetitionBoulderDetailModel>;
        _categoryStats =
            results[4] as List<StatisticCompetitionCategoryModel>;
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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.statisticsMessageCustom1(widget.competitionName), // 'Statistiche - {competition}'
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.statisticsMessageCustom2), // 'Atleti'
              Tab(text: l10n.statisticsMessageCustom3), // 'Boulder'
              Tab(text: l10n.statisticsMessageCustom4), // 'Categorie'
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAthletesTab(),
            _buildBoulderTab(),
            _buildCategoriesTab(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TAB ATLETI
  // =========================================================

  Widget _buildAthletesTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(l10n.statisticsMessageCustom6(_error!)), // 'Errore caricamento statistiche: {error}'
      );
    }

    final stats = _stats;
    if (stats == null) {
      return Center(
        child: Text(l10n.statisticsMessageCustom27), // 'Nessuna statistica disponibile per questa gara'
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── overview ────────────────────────────────────
          _SectionTitle(title: l10n.statisticsMessageCustom7), // 'Iscrizioni'
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.statisticsMessageCustom8, // 'Totale iscritti'
                  value: stats.nrAtletiIscritti,
                  icon: Icons.how_to_reg,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: l10n.statisticsMessageCustom9, // 'Totale partecipanti'
                  value: stats.nrAtletiPartecipanti,
                  icon: Icons.emoji_events,
                  color: Colors.teal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── per sesso ───────────────────────────────────
          _GenderStatTable(
            iscrittiLabel: l10n.statisticsMessageCustom10, // 'Maschi iscritti'
            iscritteLabel: l10n.statisticsMessageCustom11, // 'Femmine iscritte'
            partecipantiLabel: l10n.statisticsMessageCustom12, // 'Maschi partecipanti'
            partecipantiFLabel: l10n.statisticsMessageCustom13, // 'Femmine partecipanti'
            maschiIscritti: stats.nrAtletiMaschiIscritti,
            femmineIscritte: stats.nrAtleteFemmineIscritte,
            maschiPartecipanti: stats.nrAtletiMaschiPartecipanti,
            femminePartecipanti: stats.nrAtleteFemminePartecipanti,
          ),

          const SizedBox(height: 20),

          // ── provenienza iscrizioni ────────────────────────
          if (_ownerStats.isNotEmpty) ...[
            _SectionTitle(title: l10n.statisticsMessageCustom14), // 'Provenienza iscrizioni'
            _OwnerStatsCard(
              ownerStats: _ownerStats,
              totale: stats.nrAtletiIscritti,
              labelFor: _ownerLabel,
            ),
            const SizedBox(height: 20),
          ],

          // ── record anagrafici ─────────────────────────────
          _SectionTitle(title: l10n.statisticsMessageCustom18), // 'Record anagrafici'
          _AthleteExtremeTile(
            title: l10n.statisticsMessageCustom19, // 'Atleta più giovane (M)'
            athlete: stats.atletaMaschioPartecipantePiuGiovane,
            icon: Icons.male,
            color: Colors.blue,
          ),
          _AthleteExtremeTile(
            title: l10n.statisticsMessageCustom20, // 'Atleta più giovane (F)'
            athlete: stats.atletaFemminaPartecipantePiuGiovane,
            icon: Icons.female,
            color: Colors.pink,
          ),
          _AthleteExtremeTile(
            title: l10n.statisticsMessageCustom21, // 'Atleta più anziano (M)'
            athlete: stats.atletaMaschioPartecipantePiuVecchio,
            icon: Icons.male,
            color: Colors.blue,
          ),
          _AthleteExtremeTile(
            title: l10n.statisticsMessageCustom22, // 'Atleta più anziana (F)'
            athlete: stats.atletaFemminaPartecipantePiuVecchia,
            icon: Icons.female,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }

  String _ownerLabel(String owner) {
    switch (owner) {
      case 'admin':
        return l10n.statisticsMessageCustom15; // 'Amministratore'
      case 'athlete':
        return l10n.statisticsMessageCustom16; // 'Atleta'
      case 'import':
        return l10n.statisticsMessageCustom17; // 'Importazione'
      default:
        return owner;
    }
  }

  // =========================================================
  // TAB BOULDER
  // =========================================================

  Widget _buildBoulderTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(l10n.statisticsMessageCustom42(_error!)), // 'Errore caricamento statistiche boulder: {error}'
      );
    }

    final boulderStats = _boulderStats;
    if (boulderStats == null) {
      return Center(
        child: Text(l10n.statisticsMessageCustom27), // 'Nessuna statistica disponibile per questa gara'
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── overview ────────────────────────────────────
          _SectionTitle(title: l10n.statisticsMessageCustom28), // 'Panoramica boulder'
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.statisticsMessageCustom29, // 'Boulder totali'
                  value: boulderStats.nrBoulder,
                  icon: Icons.terrain,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: l10n.statisticsMessageCustom30, // 'Boulder finale'
                  value: boulderStats.nrBoulderFinale,
                  icon: Icons.military_tech,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── dettaglio boulder ─────────────────────────────
          if (_boulderDetails.isNotEmpty) ...[
            _SectionTitle(title: l10n.statisticsMessageCustom31), // 'Dettaglio boulder'
            ..._boulderDetails.map(
              (b) => _BoulderTile(boulder: b),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // TAB CATEGORIE
  // =========================================================

  Widget _buildCategoriesTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(l10n.statisticsMessageCustom51(_error!)), // 'Errore caricamento statistiche categorie: {error}'
      );
    }

    if (_categoryStats.isEmpty) {
      return Center(
        child: Text(l10n.statisticsMessageCustom27), // 'Nessuna statistica disponibile per questa gara'
      );
    }

    final totaleCategorie = _categoryStats.length;
    final totaleIscritti =
        _categoryStats.fold<int>(0, (sum, c) => sum + c.nrAtletiIscritti);
    final totalePartecipanti = _categoryStats.fold<int>(
      0,
      (sum, c) => sum + c.nrAtletiPartecipanti,
    );

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── overview ────────────────────────────────────
          _SectionTitle(title: l10n.statisticsMessageCustom43), // 'Panoramica categorie'
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.statisticsMessageCustom44, // 'Categorie totali'
                  value: totaleCategorie,
                  icon: Icons.category,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: l10n.statisticsMessageCustom45, // 'Iscritti totali'
                  value: totaleIscritti,
                  icon: Icons.how_to_reg,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: l10n.statisticsMessageCustom46, // 'Partecipanti totali'
                  value: totalePartecipanti,
                  icon: Icons.emoji_events,
                  color: Colors.teal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── dettaglio categorie ────────────────────────────
          _SectionTitle(title: l10n.statisticsMessageCustom47), // 'Dettaglio categorie'
          ..._categoryStats.map(
            (c) => _CategoryTile(category: c),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// SECTION TITLE
// ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STAT CARD (numero grande + etichetta)
// ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// TABELLA PER SESSO (Maschi / Femmine × Iscritti / Partecipanti)
// ──────────────────────────────────────────────────────────────

class _GenderStatTable extends StatelessWidget {
  final String iscrittiLabel;
  final String iscritteLabel;
  final String partecipantiLabel;
  final String partecipantiFLabel;

  final int maschiIscritti;
  final int femmineIscritte;
  final int maschiPartecipanti;
  final int femminePartecipanti;

  const _GenderStatTable({
    required this.iscrittiLabel,
    required this.iscritteLabel,
    required this.partecipantiLabel,
    required this.partecipantiFLabel,
    required this.maschiIscritti,
    required this.femmineIscritte,
    required this.maschiPartecipanti,
    required this.femminePartecipanti,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GenderStatRow(
                  icon: Icons.male,
                  color: Colors.blue,
                  label: iscrittiLabel,
                  value: maschiIscritti,
                ),
              ),
              Expanded(
                child: _GenderStatRow(
                  icon: Icons.female,
                  color: Colors.pink,
                  label: iscritteLabel,
                  value: femmineIscritte,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _GenderStatRow(
                  icon: Icons.male,
                  color: Colors.blue,
                  label: partecipantiLabel,
                  value: maschiPartecipanti,
                ),
              ),
              Expanded(
                child: _GenderStatRow(
                  icon: Icons.female,
                  color: Colors.pink,
                  label: partecipantiFLabel,
                  value: femminePartecipanti,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderStatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int value;

  const _GenderStatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// PROVENIENZA ISCRIZIONI (owner_registration)
// ──────────────────────────────────────────────────────────────

class _OwnerStatsCard extends StatelessWidget {
  final List<StatisticCompetitionRegistrationOwnerModel> ownerStats;
  final int totale;
  final String Function(String owner) labelFor;

  const _OwnerStatsCard({
    required this.ownerStats,
    required this.totale,
    required this.labelFor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: ownerStats.map((o) {
          final ratio = totale > 0 ? o.nrAtletiIscritti / totale : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      labelFor(o.ownerRegistration),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${o.nrAtletiIscritti}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ATLETA ESTREMO (più giovane / più vecchio)
// ──────────────────────────────────────────────────────────────

class _AthleteExtremeTile extends StatelessWidget {
  final String title;
  final AthleteStatisticModel athlete;
  final IconData icon;
  final Color color;

  const _AthleteExtremeTile({
    required this.title,
    required this.athlete,
    required this.icon,
    required this.color,
  });

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    final gg = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$gg/$mm/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasData = athlete.fullName.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasData
                        ? athlete.fullName
                        : l10n.statisticsMessageCustom26, // 'Nessun dato disponibile'
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasData) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (athlete.pettorale != null)
                          '${l10n.statisticsMessageCustom23} ${athlete.pettorale}', // 'Pettorale'
                        if (athlete.societa != null &&
                            athlete.societa!.isNotEmpty)
                          athlete.societa!, // 'Società'
                        '${l10n.statisticsMessageCustom25} ${_formatDate(athlete.dataNascita)}', // 'Data di nascita'
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
// BOULDER TILE
// ──────────────────────────────────────────────────────────────

class _BoulderTile extends StatelessWidget {
  final StatisticCompetitionBoulderDetailModel boulder;

  const _BoulderTile({required this.boulder});

  // ── mappa nome colore (dato, non localizzato) → Color ─────
  Color _swatchColor(String? nome) {
    switch (nome?.toLowerCase()) {
      case 'verde':
        return Colors.green;
      case 'nero':
        return Colors.black87;
      case 'giallo':
        return Colors.amber;
      case 'rosso':
        return Colors.red;
      case 'blu':
        return Colors.blue;
      case 'bianco':
        return Colors.grey.shade300;
      case 'arancione':
        return Colors.orange;
      case 'viola':
        return Colors.purple;
      case 'grigio':
        return Colors.grey;
      case 'rosa':
        return Colors.pink;
      case 'marrone':
        return Colors.brown;
      case 'azzurro':
        return Colors.lightBlue;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final b = boulder;
    final swatch = _swatchColor(b.colore);
    final ratio =
        b.valoreTeorico > 0 ? (b.valoreAttuale / b.valoreTeorico).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── intestazione: numero, colore, chip finale/qualifica ──
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: swatch,
                  child: Text(
                    '${b.numero}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: swatch.computeLuminance() > 0.5
                          ? Colors.black87
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.statisticsMessageCustom32(b.numero), // 'Boulder n. {numero}'
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (b.isFinale ? Colors.purple : Colors.indigo)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    b.isFinale
                        ? l10n.statisticsMessageCustom33 // 'Finale'
                        : l10n.statisticsMessageCustom34, // 'Qualifica'
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: b.isFinale ? Colors.purple : Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── difficoltà e colore ─────────────────────────
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _InlineInfo(
                  label: l10n.statisticsMessageCustom35, // 'Difficoltà'
                  value: b.difficolta?.toString() ?? '—',
                ),
                _InlineInfo(
                  label: l10n.statisticsMessageCustom36, // 'Colore'
                  value: b.colore ?? '—',
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── salite ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _InlineInfo(
                    label: l10n.statisticsMessageCustom37, // 'Salite totali'
                    value: '${b.nrSalite}',
                    big: true,
                  ),
                ),
                Expanded(
                  child: _InlineInfo(
                    label: l10n.statisticsMessageCustom38, // 'Salite maschili'
                    value: '${b.nrSaliteMaschili}',
                    big: true,
                  ),
                ),
                Expanded(
                  child: _InlineInfo(
                    label: l10n.statisticsMessageCustom39, // 'Salite femminili'
                    value: '${b.nrSaliteFemminili}',
                    big: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── valore teorico / attuale ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.statisticsMessageCustom40}: ${b.valoreTeorico.toStringAsFixed(2)}', // 'Valore teorico'
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  '${l10n.statisticsMessageCustom41}: ${b.valoreAttuale.toStringAsFixed(2)}', // 'Valore attuale'
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(swatch),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool big;

  const _InlineInfo({
    required this.label,
    required this.value,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: big ? 16 : 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// CATEGORY TILE
// ──────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final StatisticCompetitionCategoryModel category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = category;
    final isEmpty = c.nrAtletiIscritti == 0;
    final ratio = c.nrAtletiIscritti > 0
        ? (c.nrAtletiPartecipanti / c.nrAtletiIscritti).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.statisticsMessageCustom50, // 'Vuota'
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _InlineInfo(
                    label: l10n.statisticsMessageCustom48, // 'Iscritti'
                    value: '${c.nrAtletiIscritti}',
                    big: true,
                  ),
                ),
                Expanded(
                  child: _InlineInfo(
                    label: l10n.statisticsMessageCustom49, // 'Partecipanti'
                    value: '${c.nrAtletiPartecipanti}',
                    big: true,
                  ),
                ),
              ],
            ),

            if (!isEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.indigo,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}