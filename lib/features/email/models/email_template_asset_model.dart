class EmailTemplateAssetModel {
  final String id;
  final String templateId;
  final String bucketId;
  final String storagePath;
  final String originalFilename;
  final String mimeType;
  final int? sizeBytes;
  final String? altText;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  EmailTemplateAssetModel({
    required this.id,
    required this.templateId,
    required this.bucketId,
    required this.storagePath,
    required this.originalFilename,
    required this.mimeType,
    this.sizeBytes,
    this.altText,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory EmailTemplateAssetModel.fromMap(Map<String, dynamic> map) {
    return EmailTemplateAssetModel(
      id: map['id'] as String,
      templateId: map['template_id'] as String,
      bucketId: map['bucket_id'] as String,
      storagePath: map['storage_path'] as String,
      originalFilename: map['original_filename'] as String,
      mimeType: map['mime_type'] as String,
      sizeBytes: map['size_bytes'] as int?,
      altText: map['alt_text'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      createdBy: map['created_by'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'template_id': templateId,
      'bucket_id': bucketId,
      'storage_path': storagePath,
      'original_filename': originalFilename,
      'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (altText != null) 'alt_text': altText,
      'status': status,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'bucket_id': bucketId,
      'storage_path': storagePath,
      'original_filename': originalFilename,
      'mime_type': mimeType,
      'size_bytes': sizeBytes,
      'alt_text': altText,
      'status': status,
    };
  }
}