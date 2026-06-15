import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/boulder_model.dart';

class BoulderService {
  final _db =
      Supabase.instance.client.from(
    'boulders',
  );

  // =====================================================
  // REALTIME STREAM
  // =====================================================

  Stream<List<BoulderModel>> watchBoulders(
    String competitionId,
  ) {
    return Supabase.instance.client
        .from('boulders')
        .stream(primaryKey: ['id'])
        .handleError((error) {
          // Connessione Realtime persa temporaneamente, verrà riconnessa automaticamente
          debugPrint('Realtime stream error (ignorato): $error');
        })
        .map((data) {
      final filtered = data
          .where(
            (e) =>
                e['competition_id'] ==
                competitionId,
          )
          .toList();

      filtered.sort(
        (a, b) => (a['numero'] as int)
            .compareTo(
          b['numero'] as int,
        ),
      );

      return filtered
          .map(
            (e) => BoulderModel.fromJson(e),
          )
          .toList();
    });
  }

  // =====================================================
  // GET
  // =====================================================

  Future<List<BoulderModel>> getBoulders(
    String competitionId,
  ) async {
    final data = await _db
        .select()
        .eq(
          'competition_id',
          competitionId,
        )
        .order('numero',ascending: true);

    return (data as List)
        .map(
          (e) => BoulderModel.fromJson(e),
        )
        .toList();
  }

  // =====================================================
  // CREATE
  // =====================================================

  Future<void> createBoulder({
    required String competitionId,
    required int numero,
    required int difficolta,
    String? colore,
    required double valoreTeorico,
    required bool isfinale
  }) async {
    await _db.insert({
      'competition_id': competitionId,
      'numero': numero,
      'difficolta': difficolta,
      'colore': colore,
      'valore_teorico': valoreTeorico,
        'is_finale': isfinale, 
    });
  }

  // =====================================================
  // UPDATE
  // =====================================================

  Future<void> updateBoulder({
    required String id,
    required int numero,
    required int difficolta,
    String? colore,
    required double valoreTeorico,
    required bool isfinale
  }) async {
    await _db
        .update({
          'numero': numero,
          'difficolta': difficolta,
          'colore': colore,
          'valore_teorico':
              valoreTeorico,
          'updated_at': DateTime.now()
              .toIso8601String(),
          'is_finale': isfinale,    
        })
        .eq('id', id);
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<void> deleteBoulder(
    String id,
  ) async {
    await _db.delete().eq('id', id);
  }


  Future<int> getNextNumero(String competitionId) async {
    final data = await _db
        .select('numero')
        .eq('competition_id', competitionId)
        .order('numero', ascending: false)
        .limit(1);

    if ((data as List).isEmpty) {
      return 1;
    }

    final maxNumero = data.first['numero'] as int;

    return maxNumero + 1;
  }
}