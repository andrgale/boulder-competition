import 'package:flutter/material.dart';

import '../data/competition_service.dart';

import 'competition_form_page.dart';

class CompetitionFormLoaderPage
    extends StatefulWidget {
  final String competitionId;

  const CompetitionFormLoaderPage({
    super.key,
    required this.competitionId,
  });

  @override
  State<CompetitionFormLoaderPage>
      createState() =>
          _CompetitionFormLoaderPageState();
}

class _CompetitionFormLoaderPageState
    extends State<
        CompetitionFormLoaderPage> {
  final service = CompetitionService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: service.getCompetitionById(
        widget.competitionId,
      ),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        final competition =
            snapshot.data;

        if (competition == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Competizione non trovata',
              ),
            ),
          );
        }

        return CompetitionFormPage(
          competition: competition,
        );
      },
    );
  }
}