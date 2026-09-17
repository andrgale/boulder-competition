import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/athlete_statistics_item_model.dart';
import '../data/athlete_statistics_service.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class AthleteStatisticsPage extends StatefulWidget {
  const AthleteStatisticsPage({
    super.key,
  });

  @override
  State<AthleteStatisticsPage> createState() => _AthleteStatisticsPageState();
}

class _AthleteStatisticsPageState extends State<AthleteStatisticsPage> {
  final service = AthleteStatisticsService();
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool loading = true;
  List<AthleteStatisticsItemModel> items = [];

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
      final data = await service.loadStatistics();

      if (!mounted) return;

      setState(() {
        items = data;
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
        title: Text(l10n.athleteMessageCustom111), // 'Le mie gare'
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
        child: items.isEmpty
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.athleteMessageCustom112, // 'Nessuna gara trovata'
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final competition = item.competition;

                  final progress = item.totalBoulders == 0
                      ? 0.0
                      : item.completedBoulders / item.totalBoulders;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
 
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  competition.descrizione,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.athleteMessageCustom116, // 'Dettaglio statistiche'
                                icon: const Icon(Icons.bar_chart),
                                onPressed: () {
                                  context.push(
                                    '/athlete-statistics-detail',
                                    extra: {
                                      'competitionId': competition.id,
                                      'registrationId': item.registrationId,
                                      'descrizione': competition.descrizione,
                                    },
                                  );
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: competition.flGaraChiusa
                                      ? Colors.grey.shade300
                                      : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  competition.flGaraChiusa
                                      ? l10n.athleteMessageCustom114 // 'Gara chiusa'
                                      : l10n.athleteMessageCustom113, // 'Gara aperta'
                                  style: TextStyle(
                                    color: competition.flGaraChiusa
                                        ? Colors.grey.shade800
                                        : Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 6),
                              Text(_formatDate(competition.dataGara)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.athleteMessageCustom115(
                              item.completedBoulders,
                              item.totalBoulders,
                            ), // '{completed}/{total} boulder completati'
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}