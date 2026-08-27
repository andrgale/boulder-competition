import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/category_template_model.dart';

class CategoryService {
  final _db = Supabase.instance.client.from('categories');

  // STREAM realtime
  Stream<List<CategoryModel>> watchCategories(String competitionId) {
    return Supabase.instance.client
        .from('categories')
        .stream(primaryKey: ['id'])
        .handleError((error) {
          // Connessione Realtime persa temporaneamente, verrà riconnessa automaticamente
          debugPrint('Realtime stream error (ignorato): $error');
        })
        .map((data) {
      final filtered = data
          .where((e) => e['competition_id'] == competitionId)
          .toList();

      return filtered
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    });
  }

  // GET
  Future<List<CategoryModel>> getCategories(String competitionId) async {
    final data = await _db
        .select()
        .eq('competition_id', competitionId)
        .order('created_at');

    return (data as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }

  // CREATE
  Future<void> createCategory({
    required String competitionId,
    required String nome,
    String? sesso,
    int? etaMin,
    int? etaMax,
  }) async {
    await _db.insert({
      'competition_id': competitionId,
      'nome': nome,
      'sesso': sesso,
      'eta_min': etaMin,
      'eta_max': etaMax,
    });
  }

  // UPDATE
  Future<void> updateCategory({
    required String id,
    required String nome,
    String? sesso,
    int? etaMin,
    int? etaMax,
  }) async {
    await _db.update({
      'nome': nome,
      'sesso': sesso,
      'eta_min': etaMin,
      'eta_max': etaMax,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // DELETE
  Future<void> deleteCategory(String id) async {
    await _db.delete().eq('id', id);
  }

  // GET CATEGORY TEMPLATES
  Future<List<CategoryTemplateModel>> getCategoryTemplates() async {
    final data = await Supabase.instance.client
        .from('category_templates')
        .select()
        .order('nome');

    return (data as List)
        .map((e) => CategoryTemplateModel.fromJson(e))
        .toList();
  }

  // CREATE CATEGORIES FROM TEMPLATE
  Future<void> createCategoriesFromTemplate({
    required String competitionId,
    required String templateId,
  }) async {
    await Supabase.instance.client.rpc(
      'create_categories_from_template',
      params: {
        'p_competition_id': competitionId,
        'p_template_id': templateId,
      },
    );
  }
}