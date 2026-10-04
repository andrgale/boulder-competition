class LiberatoriaAtletaModel {
  final String id;
  final String registrationId;
  final String templateId;
  final String modalita; // 'cartacea' | 'digitale'
  final String stato; // 'stampata' | 'consegnata' | 'firmata'
  final String? pdfPath;

  LiberatoriaAtletaModel({
    required this.id,
    required this.registrationId,
    required this.templateId,
    required this.modalita,
    required this.stato,
    this.pdfPath,
  });

  bool get isDone => stato == 'consegnata' || stato == 'firmata';

  factory LiberatoriaAtletaModel.fromMap(Map<String, dynamic> m) {
    return LiberatoriaAtletaModel(
      id: m['id'] as String,
      registrationId: m['registration_id'] as String,
      templateId: m['template_id'] as String,
      modalita: m['modalita'] as String,
      stato: m['stato'] as String,
      pdfPath: m['pdf_path'] as String?,
    );
  }
}