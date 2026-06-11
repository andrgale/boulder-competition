// import 'package:flutter/material.dart';

// import '../../shared/widgets/base_page.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BasePage(
//       title: 'Dashboard',

//       subtitle:
//           'Panoramica generale competizione',

//       actions: [
//         FilledButton.icon(
//           onPressed: () {},

//           icon: const Icon(Icons.add),

//           label: const Text('Nuova Gara'),
//         ),
//       ],

//       child: GridView.count(
//         crossAxisCount: 4,

//         crossAxisSpacing: 16,

//         mainAxisSpacing: 16,

//         children: const [
//           _DashboardCard(
//             title: 'Competizioni',
//             value: '12',
//             icon: Icons.emoji_events,
//           ),

//           _DashboardCard(
//             title: 'Atleti',
//             value: '248',
//             icon: Icons.groups,
//           ),

//           _DashboardCard(
//             title: 'Boulder',
//             value: '32',
//             icon: Icons.terrain,
//           ),

//           _DashboardCard(
//             title: 'Ascents',
//             value: '1.245',
//             icon: Icons.sports_score,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DashboardCard extends StatelessWidget {
//   final String title;

//   final String value;

//   final IconData icon;

//   const _DashboardCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,

//       child: Padding(
//         padding: const EdgeInsets.all(24),

//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,

//           children: [
//             Icon(icon, size: 40),

//             const Spacer(),

//             Text(
//               value,

//               style: const TextStyle(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               title,

//               style: TextStyle(
//                 color:
//                     Theme.of(context)
//                         .colorScheme
//                         .onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../shared/widgets/base_page.dart';
import '../dashboard/models/dashboard_model.dart';
import '../dashboard/data/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _service = DashboardService();

  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _service.fetchStats();
  }

  void _refresh() => setState(() {
        _statsFuture = _service.fetchStats();
      });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Dashboard',
      subtitle: 'Panoramica generale competizione',
      actions: [
        IconButton(
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
          tooltip: 'Aggiorna',
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Nuova Gara'),
        ),
      ],
      child: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Errore nel caricamento dei dati',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data ?? DashboardStats.empty();

          return GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              DashboardCard(
                title: 'Competizioni',
                value: stats.competitions.toString(),
                icon: Icons.emoji_events,
              ),
              DashboardCard(
                title: 'Atleti',
                value: stats.athletes.toString(),
                icon: Icons.groups,
              ),
              DashboardCard(
                title: 'Boulder',
                value: stats.boulders.toString(),
                icon: Icons.terrain,
              ),
              DashboardCard(
                title: 'Ascents',
                value: stats.ascents.toString(),
                icon: Icons.sports_score,
              ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widget card — invariato nel layout, ora accetta solo String per il valore
// -----------------------------------------------------------------------------

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
