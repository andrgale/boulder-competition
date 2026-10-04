class LiberatoriaPlaceholders {
  static const List<String> keys = [
    'cognome',
    'nome',
    'data_nascita',
    'societa',
    'nome_gara',
    'data_gara',
    'data',
    'tutore',
  ];

  static final RegExp _regex = RegExp(r'\{\{\s*(\w+)\s*\}\}');

  /// Sostituisce i segnaposto; quelli sconosciuti restano invariati.
  static String render(String template, Map<String, String> values) {
    return template.replaceAllMapped(
      _regex,
      (m) => values[m.group(1)] ?? m.group(0)!,
    );
  }

  /// Segnaposto presenti nel testo ma non previsti (probabili refusi).
  static Set<String> unknownKeys(String template) {
    return _regex
        .allMatches(template)
        .map((m) => m.group(1)!)
        .where((k) => !keys.contains(k))
        .toSet();
  }
}