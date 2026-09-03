import 'package:boulder_competition/features/categories/models/category_template_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


/// Accesso ai dati delle categorie contenute in un template.
class CategoryTemplateItemsService {
  CategoryTemplateItemsService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<CategoryTemplateItemModel>> listForTemplate(
    String templateId,
  ) async {
    final rows = await _client
        .from('category_template_items')
        .select()
        .eq('template_id', templateId)
        .order('ordine')
        .order('nome');

    return (rows as List)
        .map(
          (row) => CategoryTemplateItemModel.fromJson(
            row as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Stream<List<CategoryTemplateItemModel>> watchForTemplate(String templateId) {
    return _client
        .from('category_template_items')
        .stream(primaryKey: ['id'])
        .eq('template_id', templateId)
        .order('ordine')
        .order('nome')
        .map(
          (rows) => rows
              .map(CategoryTemplateItemModel.fromJson)
              .toList(),
        );
  }

  Future<void> delete(String id) async {
    await _client.from('category_template_items').delete().eq('id', id);
  }


  Future<CategoryTemplateItemModel> createItem({
    required String templateId,
    required String nome,
    String? sesso,
    int? etaMin,
    int? etaMax,
    required int ordine,
  }) async {
    final row = await _client.from('category_template_items').insert({
      'template_id': templateId,
      'nome': nome,
      'sesso': sesso,
      'eta_min': etaMin,
      'eta_max': etaMax,
      'ordine': ordine,
    }).select().single();

    return CategoryTemplateItemModel.fromJson(row);
  }

  Future<CategoryTemplateItemModel> updateItem({
    required String id,
    required String nome,
    String? sesso,
    int? etaMin,
    int? etaMax,
    required int ordine,
  }) async {
    final row = await _client
        .from('category_template_items')
        .update({
          'nome': nome,
          'sesso': sesso,
          'eta_min': etaMin,
          'eta_max': etaMax,
          'ordine': ordine,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return CategoryTemplateItemModel.fromJson(row);
  }

}
