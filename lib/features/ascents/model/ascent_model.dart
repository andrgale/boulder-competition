class AscentModel {
  final String registrationId;
  final String boulderId;

  final bool top;
  final bool zone;

  final int tentativiTop;
  final int tentativiZone;

  final DateTime createdAt;
  final DateTime updatedAt;

  AscentModel({
    required this.registrationId,
    required this.boulderId,
    required this.top,
    required this.zone,
    required this.tentativiTop,
    required this.tentativiZone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AscentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AscentModel(
      registrationId:
          json['registration_id'] as String,

      boulderId:
          json['boulder_id'] as String,

      top:
          json['top'] as bool? ?? false,

      zone:
          json['zone'] as bool? ?? false,

      tentativiTop:
          json['tentativi_top'] as int? ?? 0,

      tentativiZone:
          json['tentativi_zone'] as int? ?? 0,

      createdAt: DateTime.parse(
        json['created_at'],
      ),

      updatedAt: DateTime.parse(
        json['updated_at'],
      ),
    );
  }

  // =====================================================
  // INSERT
  // =====================================================

  Map<String, dynamic> toInsert() {
    return {
      'registration_id': registrationId,
      'boulder_id': boulderId,
      'top': top,
      'zone': zone,
      'tentativi_top': tentativiTop,
      'tentativi_zone': tentativiZone,
    };
  }

  // =====================================================
  // UPDATE
  // =====================================================

  Map<String, dynamic> toUpdate() {
    return {
      'top': top,
      'zone': zone,
      'tentativi_top': tentativiTop,
      'tentativi_zone': tentativiZone,
      'updated_at':
          DateTime.now().toIso8601String(),
    };
  }
}