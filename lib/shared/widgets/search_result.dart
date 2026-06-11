import 'package:flutter/material.dart';

enum SearchResultType { competition, athlete, boulder, ascent }

class SearchResult {
  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;

  /// Rotta a cui navigare al tap del risultato.
  final String route;

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

  String get typeLabel {
    switch (type) {
      case SearchResultType.competition:
        return 'Competizione';
      case SearchResultType.athlete:
        return 'Atleta';
      case SearchResultType.boulder:
        return 'Boulder';
      case SearchResultType.ascent:
        return 'Ascent';
    }
  }
}
