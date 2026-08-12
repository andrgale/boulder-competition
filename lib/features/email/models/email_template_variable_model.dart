class EmailTemplateVariableModel {
  final String id;
  final String templateId;
  final String variableCode;
  final String label;
  final String? description;
  final String dataType;
  final bool required;
  final String? defaultValue;
  final Map<String, dynamic> validation;
  final String? exampleValue;
  final DateTime createdAt;

  EmailTemplateVariableModel({
    required this.id,
    required this.templateId,
    required this.variableCode,
    required this.label,
    this.description,
    required this.dataType,
    required this.required,
    this.defaultValue,
    required this.validation,
    this.exampleValue,
    required this.createdAt,
  });

  factory EmailTemplateVariableModel.fromMap(Map<String, dynamic> map) {
    return EmailTemplateVariableModel(
      id: map['id'] as String,
      templateId: map['template_id'] as String,
      variableCode: map['variable_code'] as String,
      label: map['label'] as String,
      description: map['description'] as String?,
      dataType: map['data_type'] as String,
      required: map['required'] as bool? ?? false,
      defaultValue: map['default_value'] as String?,
      validation: Map<String, dynamic>.from(
        map['validation'] as Map? ?? {},
      ),
      exampleValue: map['example_value'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'template_id': templateId,
      'variable_code': variableCode,
      'label': label,
      if (description != null) 'description': description,
      'data_type': dataType,
      'required': required,
      if (defaultValue != null) 'default_value': defaultValue,
      'validation': validation,
      if (exampleValue != null) 'example_value': exampleValue,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'variable_code': variableCode,
      'label': label,
      'description': description,
      'data_type': dataType,
      'required': required,
      'default_value': defaultValue,
      'validation': validation,
      'example_value': exampleValue,
    };
  }
}