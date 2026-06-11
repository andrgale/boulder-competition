import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/import_job_model.dart';

class ImportJobService {
  final _db = Supabase.instance.client.from('import_jobs');

  // =====================================================
  // STREAM REALTIME
  // =====================================================

  Stream<List<ImportJobModel>> watchImportJobs() {
    return Supabase.instance.client
        .from('import_jobs')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .handleError((error) {
          // Connessione Realtime persa temporaneamente, verrà riconnessa automaticamente
          debugPrint('Realtime stream error (ignorato): $error');
        })
        .map((data) {
      return data
          .map((e) => ImportJobModel.fromJson(e))
          .toList();
    });
  }

  // =====================================================
  // GET ALL
  // =====================================================

  Future<List<ImportJobModel>> getImportJobs() async {
    final data = await _db
        .select('''
          *,
          competitions (
            descrizione
          )
        ''')
        .order(
          'created_at',
          ascending: false,
        );

    return (data as List)
        .map(
          (e) => ImportJobModel.fromJson(e),
        )
        .toList();
  }

  // =====================================================
  // GET BY ID
  // =====================================================

  Future<ImportJobModel?> getImportJob(
    String id,
  ) async {
    final data = await _db
        .select('''
          *,
          competitions (
            descrizione
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return ImportJobModel.fromJson(data);
  }
}