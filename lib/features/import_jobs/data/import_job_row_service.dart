import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/import_job_row_model.dart';

class ImportJobRowService {
  final _db = Supabase.instance.client.from(
    'import_job_rows',
  );

  // =====================================================
  // STREAM REALTIME
  // =====================================================

  Stream<List<ImportJobRowModel>>
      watchImportJobRows(
    String importJobId,
  ) {
    return Supabase.instance.client
        .from('import_job_rows')
        .stream(primaryKey: ['id'])
        .map((data) {
      final filtered = data
          .where(
            (e) =>
                e['import_job_id'] ==
                importJobId,
          )
          .toList();

      filtered.sort((a, b) =>
          (a['row_number'] as int)
              .compareTo(
            b['row_number'] as int,
          ));

      return filtered
          .map(
            (e) =>
                ImportJobRowModel
                    .fromJson(e),
          )
          .toList();
    });
  }

  // =====================================================
  // GET ROWS BY IMPORT JOB
  // =====================================================

  Future<List<ImportJobRowModel>>
      getImportJobRows(
    String importJobId,
  ) async {
    final data = await _db
        .select()
        .eq(
          'import_job_id',
          importJobId,
        )
        .order(
          'row_number',
          ascending: true,
        );

    return (data as List)
        .map(
          (e) =>
              ImportJobRowModel
                  .fromJson(e),
        )
        .toList();
  }

  // =====================================================
  // GET ONLY DISCARDED ROWS
  // =====================================================

  Future<List<ImportJobRowModel>>
      getDiscardedRows(
    String importJobId,
  ) async {
    final data = await _db
        .select()
        .eq(
          'import_job_id',
          importJobId,
        )
        .eq(
          'status',
          'DISCARDED',
        )
        .order(
          'row_number',
          ascending: true,
        );

    return (data as List)
        .map(
          (e) =>
              ImportJobRowModel
                  .fromJson(e),
        )
        .toList();
  }

  // =====================================================
  // GET SINGLE ROW
  // =====================================================

  Future<ImportJobRowModel?>
      getImportJobRow(
    String id,
  ) async {
    final data = await _db
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return ImportJobRowModel.fromJson(
      data,
    );
  }
}