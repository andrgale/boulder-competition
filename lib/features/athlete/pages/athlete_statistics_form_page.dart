import 'package:boulder_competition/features/statistics/data/statistic_registration_boulder_color_difficulty_service.dart';
import 'package:boulder_competition/features/statistics/data/statistic_registration_service.dart';
import 'package:boulder_competition/features/statistics/models/statistic_registration_boulder_color_difficulty_model.dart';
import 'package:boulder_competition/features/statistics/models/statistic_registration_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class AthleteStatisticsFormPage extends StatefulWidget {
  final String competitionId;
  final String registrationId;
  final String? descrizione;

  const AthleteStatisticsFormPage({
    super.key,
    required this.competitionId,
    required this.registrationId,
    this.descrizione,
  });

  @override
  State<AthleteStatisticsFormPage> createState() =>
      _AthleteStatisticsFormPageState();
}

class _AthleteStatisticsFormPageState
    extends State<AthleteStatisticsFormPage> {
  final registrationService = StatisticRegistrationService();
  final boulderStatsService =
      StatisticRegistrationBoulderColorDifficultyService();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool loading = true;
  StatisticRegistrationModel? registrationStats;
  List<StatisticRegistrationBoulderColorDifficultyModel> boulderStats = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });

    try {
      final results = await Future.wait([
        registrationService.getStatistics(
          widget.competitionId,
          widget.registrationId,
        ),
        boulderStatsService.getStatistics(
          widget.competitionId,
          widget.registrationId,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        registrationStats = results[0] as StatisticRegistrationModel?;
        boulderStats = results[1]
            as List<StatisticRegistrationBoulderColorDifficultyModel>;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.athleteMessageCustom56(e.toString())),
        ),
      );

      setState(() {
        loading = false;
      });
    }
  }

  Color _parseColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'rosso':
        return Colors.red;
      case 'blu':
        return Colors.blue;
      case 'verde':
        return Colors.green;
      case 'giallo':
        return Colors.yellow;
      case 'nero':
        return Colors.black;
      case 'bianco':
        return Colors.white;
      case 'arancione':
        return Colors.orange;
      case 'viola':
        return Colors.purple;
      case 'rosa':
        return Colors.pink;
      case 'grigio':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _positionCard({
    required IconData icon,
    required String label,
    required int position,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue.shade700, size: 28),
            const SizedBox(height: 8),
            Text(
              position > 0 ? '$position°' : '-',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.descrizione ?? l10n.athleteMessageCustom117, // 'Dettaglio statistiche'
        ),
        actions: [
          IconButton(
            tooltip: l10n.athleteMessageCustom59, // 'Torna alla home'
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/athlete-home'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (registrationStats == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.athleteMessageCustom118, // 'Statistiche non disponibili'
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Row(
                children: [
                  _positionCard(
                    icon: Icons.emoji_events,
                    label: l10n.athleteMessageCustom119, // 'Classifica generale'
                    position: registrationStats!.posizioneGenerale,
                  ),
                  _positionCard(
                    icon: Icons.wc,
                    label: l10n.athleteMessageCustom120, // 'Classifica sesso'
                    position: registrationStats!.posizioneSesso,
                  ),
                  _positionCard(
                    icon: Icons.category,
                    label: l10n.athleteMessageCustom121, // 'Classifica categoria'
                    position: registrationStats!.posizioneCategoria,
                  ),
                ],
              ),

            const SizedBox(height: 24),

            Text(
              l10n.athleteMessageCustom122, // 'Boulder saliti'
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (boulderStats.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.athleteMessageCustom123, // 'Nessun boulder salito'
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              ...boulderStats.map((stat) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.terrain,
                          size: 28,
                          color: _parseColor(stat.colore),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.athleteMessageCustom90(
                                  stat.difficolta ?? 0,
                                ), // riutilizza 'Difficoltà {value}'
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(stat.colore ?? '-'),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.athleteMessageCustom124(
                              stat.nrBoulderSaliti,
                            ), // '{count} saliti'
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}