import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_translation_model.dart';

class MenuTranslationServiceAdmin {
  final supabase = Supabase.instance.client;

  /// Lingue supportate dall'app: deve restare allineata ai file .arb (l10n)
  static const supportedLocales = ['it', 'en'];

  Future<List<MenuTranslationModel>> getTranslations(String menuId) async {
    final response = await supabase
        .from('menu_translations')
        .select()
        .eq('menu_id', menuId)
        .order('locale');

    return response
        .map<MenuTranslationModel>((row) => MenuTranslationModel.fromMap(row))
        .toList();
  }

  Future<void> createTranslation({
    required String menuId,
    required String locale,
    required String label,
  }) async {
    await supabase.from('menu_translations').insert({
      'menu_id': menuId,
      'locale': locale.trim(),
      'label': label.trim(),
    });
  }

  Future<void> updateTranslation({
    required String id,
    required String locale,
    required String label,
  }) async {
    await supabase.from('menu_translations').update({
      'locale': locale.trim(),
      'label': label.trim(),
    }).eq('id', id);
  }

  Future<void> deleteTranslation(String id) async {
    await supabase.from('menu_translations').delete().eq('id', id);
  }
}