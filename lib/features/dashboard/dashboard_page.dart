
// import 'package:flutter/material.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           const Text(
//             'Dashboard',
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 24),

//           Wrap(
//             spacing: 16,
//             runSpacing: 16,

//             children: [
//               _statCard(
//                 title: 'Gare',
//                 value: '12',
//                 icon: Icons.emoji_events,
//               ),

//               _statCard(
//                 title: 'Iscritti',
//                 value: '248',
//                 icon: Icons.groups,
//               ),

//               _statCard(
//                 title: 'Boulder',
//                 value: '96',
//                 icon: Icons.terrain,
//               ),

//               _statCard(
//                 title: 'Classifiche',
//                 value: '8',
//                 icon: Icons.leaderboard,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statCard({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Container(
//       width: 240,
//       padding: const EdgeInsets.all(24),

//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),

//         boxShadow: [
//           BoxShadow(
//             blurRadius: 10,
//             color: Colors.black.withOpacity(0.05),
//           ),
//         ],
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           Icon(icon, size: 40),

//           const SizedBox(height: 16),

//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 36,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../shared/widgets/base_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Dashboard',

      subtitle:
          'Panoramica generale competizione',

      actions: [
        FilledButton.icon(
          onPressed: () {},

          icon: const Icon(Icons.add),

          label: const Text('Nuova Gara'),
        ),
      ],

      child: GridView.count(
        crossAxisCount: 4,

        crossAxisSpacing: 16,

        mainAxisSpacing: 16,

        children: const [
          _DashboardCard(
            title: 'Competizioni',
            value: '12',
            icon: Icons.emoji_events,
          ),

          _DashboardCard(
            title: 'Atleti',
            value: '248',
            icon: Icons.groups,
          ),

          _DashboardCard(
            title: 'Boulder',
            value: '32',
            icon: Icons.terrain,
          ),

          _DashboardCard(
            title: 'Ascents',
            value: '1.245',
            icon: Icons.sports_score,
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;

  final String value;

  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

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
                color:
                    Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}