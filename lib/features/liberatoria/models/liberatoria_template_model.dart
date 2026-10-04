class LiberatoriaTemplateModel {
  final String id;
  final String competitionId;
  final int versione;
  final String testo;
  final List<String> logoPaths;
  final DateTime createdAt;

  LiberatoriaTemplateModel({
    required this.id,
    required this.competitionId,
    required this.versione,
    required this.testo,
    this.logoPaths = const [],
    required this.createdAt,
  });

  factory LiberatoriaTemplateModel.fromMap(Map<String, dynamic> map) {
    return LiberatoriaTemplateModel(
      id: map['id'] as String,
      competitionId: map['competition_id'] as String,
      versione: map['versione'] as int,
      testo: map['testo'] as String,
      logoPaths: ((map['logo_paths'] as List?) ?? const [])
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}