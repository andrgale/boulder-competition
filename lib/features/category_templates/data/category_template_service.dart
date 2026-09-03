import 'package:boulder_competition/features/categories/models/category_template_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Accesso ai dati dei template delle categorie.
/// Le operazioni sono soggette alle policy RLS definite su Supabase.
class CategoryTemplateService {
  CategoryTemplateService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<CategoryTemplateModel>> listTemplates() async {
    final rows = await _client.from('category_templates').select().order('nome');
    return (rows as List)
        .map((row) => CategoryTemplateModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryTemplateModel> create({required String nome}) async {
    final row = await _client
        .from('category_templates')
        .insert({'nome': nome})
        .select()
        .single();
    return CategoryTemplateModel.fromJson(row);
  }

  Future<CategoryTemplateModel> update({
    required String id,
    required String nome,
  }) async {
    final row = await _client
        .from('category_templates')
        .update({
          'nome': nome,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return CategoryTemplateModel.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from('category_templates').delete().eq('id', id);
  }

  /// Duplica un template chiamando la function Postgres:
  /// duplica_template_category(p_template_id uuid, p_nuovo_nome_template text)
  /// Nota: la function ritorna l'UUID del nuovo template; qui invochiamo la RPC.
  Future<void> duplicate({
    required String id,
    required String nuovoNome,
  }) async {
    await _client.rpc('duplica_template_category', params: {
      'p_template_id': id,
      'p_nuovo_nome_template': nuovoNome,
    });
  }
}