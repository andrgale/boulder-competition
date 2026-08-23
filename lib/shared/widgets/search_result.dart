import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum SearchResultType { competition, athlete, boulder, ascent }

class SearchResult {
  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.route,
    this.extra,
  });

  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String route;

  /// Dati aggiuntivi necessari per la navigazione (es. competitionId).
  final Map<String, dynamic>? extra;

  IconData get icon {
    switch (type) {
      case SearchResultType.competition:
        return Icons.emoji_events;
      case SearchResultType.athlete:
        return Icons.person;
      case SearchResultType.boulder:
        return Icons.terrain;
      case SearchResultType.ascent:
        return Icons.sports_score;
    }
  }

  // RETROCOMPATIBLE getter (keeps original text as comment)
  // Prefer using localizedTypeLabel(context) instead.
  String get typeLabel {
    switch (type) {
      case SearchResultType.competition:
        return 'Competizione'; // original: 'Competizione'
      case SearchResultType.athlete:
        return 'Atleta'; // original: 'Atleta'
      case SearchResultType.boulder:
        return 'Boulder'; // original: 'Boulder'
      case SearchResultType.ascent:
        return 'Ascent'; // original: 'Ascent'
    }
  }

  // NEW: localized label using BuildContext / AppLocalizations
  // Call like: group.first.localizedTypeLabel(context)
  String localizedTypeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case SearchResultType.competition:
        return l10n.administrationMessageCustom166; // 'Competizione' / 'Competition'
      case SearchResultType.athlete:
        return l10n.administrationMessageCustom167; // 'Atleta' / 'Athlete'
      case SearchResultType.boulder:
        return l10n.administrationMessageCustom168; // 'Boulder' / 'Boulder'
      case SearchResultType.ascent:
        return l10n.administrationMessageCustom169; // 'Ascent' / 'Ascent'
    }
  }
}