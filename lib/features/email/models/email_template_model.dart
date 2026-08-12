class EmailTemplateModel {
  final String id;
  final String templateCode;
  final String language;
  final int version;
  final String status;
  final bool active;
  final String subject;
  final String htmlBody;
  final String? description;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  EmailTemplateModel({
    required this.id,
    required this.templateCode,
    required this.language,
    required this.version,
    required this.status,
    required this.active,
    required this.subject,
    required this.htmlBody,
    this.description,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory EmailTemplateModel.fromMap(Map<String, dynamic> map) {
    return EmailTemplateModel(
      id: map['id'] as String,
      templateCode: map['template_code'] as String,
      language: map['language'] as String? ?? 'it',
      version: map['version'] as int? ?? 1,
      status: map['status'] as String,
      active: map['active'] as bool? ?? false,
      subject: map['subject'] as String,
      htmlBody: map['html_body'] as String,
      description: map['description'] as String?,
      isDefault: map['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      createdBy: map['created_by'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'template_code': templateCode,
      'language': language,
      'version': version,
      'status': status,
      'subject': subject,
      'html_body': htmlBody,
      if (description != null) 'description': description,
      'is_default': isDefault,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'template_code': templateCode,
      'language': language,
      'version': version,
      'status': status,
      'subject': subject,
      'html_body': htmlBody,
      'description': description,
      'is_default': isDefault,
    };
  }
}