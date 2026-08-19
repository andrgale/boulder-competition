import 'package:flutter/material.dart';

import '../data/competition_service.dart';

import 'competition_form_page.dart';

import 'package:boulder_competition/l10n/app_localizations.dart';


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
  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
          // Assicurati di avere `l10n` disponibile in questo scope, per esempio:
          // final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            body: Center(
              child: Text(
                l10n.competitionMessageCustom38, // 'Competizione non trovata'
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