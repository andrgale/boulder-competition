class ImportJobModel {
  final String id;
  final String competitionId;
  final String fileName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status;
  final int totalRows;
  final int insertedRows;
  final int discardedRows;
  final String? createdBy;
  final DateTime createdAt;
  final String? competitionDescription;

  ImportJobModel({
    required this.id,
    required this.competitionId,
    required this.fileName,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.totalRows,
    required this.insertedRows,
    required this.discardedRows,
    this.createdBy,
    required this.createdAt,
    this.competitionDescription,
  });

  factory ImportJobModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ImportJobModel(
      id: json['id'] as String,
      competitionId:
          json['competition_id'] as String,
      fileName:
          json['file_name'] as String,
      startedAt: DateTime.parse(
        json['started_at'],
      ),
      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(
                  json['completed_at'],
                )
              : null,
      status:
          json['status'] as String,
      totalRows:
          json['total_rows'] as int,
      insertedRows:
          json['inserted_rows'] as int,
      discardedRows:
          json['discarded_rows'] as int,
      createdBy:
          json['created_by'] as String?,
      createdAt: DateTime.parse(
        json['created_at'],  
      ),
      competitionDescription:
        json['competitions']?['descrizione'] ?? '',   
    );
  }

  Map<String, dynamic> toInsert() {
    return {
      'competition_id': competitionId,
      'file_name': fileName,
      'started_at':
          startedAt.toIso8601String(),
      'completed_at':
          completedAt?.toIso8601String(),
      'status': status,
      'total_rows': totalRows,
      'inserted_rows': insertedRows,
      'discarded_rows': discardedRows,
      'created_by': createdBy,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'completed_at':
          completedAt?.toIso8601String(),
      'status': status,
      'total_rows': totalRows,
      'inserted_rows': insertedRows,
      'discarded_rows': discardedRows,
    };
  }
}