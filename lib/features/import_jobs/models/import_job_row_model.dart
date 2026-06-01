class ImportJobRowModel {
  final String id;
  final String importJobId;
  final int rowNumber;
  final String rawRow;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;

  ImportJobRowModel({
    required this.id,
    required this.importJobId,
    required this.rowNumber,
    required this.rawRow,
    required this.status,
    this.errorMessage,
    required this.createdAt,
  });

  factory ImportJobRowModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ImportJobRowModel(
      id: json['id'] as String,
      importJobId:
          json['import_job_id'] as String,
      rowNumber:
          json['row_number'] as int,
      rawRow:
          json['raw_row'] as String,
      status:
          json['status'] as String,
      errorMessage:
          json['error_message'] as String?,
      createdAt: DateTime.parse(
        json['created_at'],
      ),
    );
  }

  Map<String, dynamic> toInsert() {
    return {
      'import_job_id': importJobId,
      'row_number': rowNumber,
      'raw_row': rawRow,
      'status': status,
      'error_message': errorMessage,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'row_number': rowNumber,
      'raw_row': rawRow,
      'status': status,
      'error_message': errorMessage,
    };
  }
}