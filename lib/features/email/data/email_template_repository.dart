import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/email_template_asset_model.dart';
import '../models/email_template_model.dart';
import '../models/email_template_variable_model.dart';

/// Accesso dati del pannello amministrativo. Tutte le operazioni sono soggette
/// alle policy RLS gia' definite nel progetto Supabase.
class EmailTemplateRepository {
  EmailTemplateRepository([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<EmailTemplateModel>> listTemplates() async {
    final rows = await _client
        .from('email_templates')
        .select()
        .order('template_code')
        .order('language')
        .order('version', ascending: false);
    return (rows as List)
        .map((row) => EmailTemplateModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<EmailTemplateVariableModel>> variablesFor(
    String templateId,
  ) async {
    final rows = await _client
        .from('email_template_variables')
        .select()
        .eq('template_id', templateId)
        .order('variable_code');
    return (rows as List)
        .map(
          (row) =>
              EmailTemplateVariableModel.fromMap(row as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<EmailTemplateAssetModel>> assetsFor(String templateId) async {
    final rows = await _client
        .from('email_template_assets')
        .select()
        .eq('template_id', templateId)
        .eq('status', 'ready')
        .order('created_at', ascending: false);
    return (rows as List)
        .map(
          (row) => EmailTemplateAssetModel.fromMap(row as Map<String, dynamic>),
        )
        .toList();
  }

  /// Crea una bozza con versione progressiva. In caso di salvataggi concorrenti
  /// il vincolo SQL (codice, lingua, versione) resta la protezione definitiva.
  Future<EmailTemplateModel> createDraft({
    required String templateCode,
    required String language,
    required String subject,
    required String htmlBody,
    String? description,
  }) async {
    final last = await _client
        .from('email_templates')
        .select('version')
        .eq('template_code', templateCode)
        .eq('language', language)
        .order('version', ascending: false)
        .limit(1)
        .maybeSingle();
    final nextVersion = ((last?['version'] as int?) ?? 0) + 1;

    final row = await _client
        .from('email_templates')
        .insert({
          'template_code': templateCode,
          'language': language,
          'version': nextVersion,
          'status': 'draft',
          'subject': subject,
          'html_body': htmlBody,
          'description': description,
          'is_default': false,
        })
        .select()
        .single();
    return EmailTemplateModel.fromMap(row);
  }

  Future<EmailTemplateModel> updateDraft({
    required String id,
    required String subject,
    required String htmlBody,
    String? description,
  }) async {
    final row = await _client
        .from('email_templates')
        .update({
          'subject': subject,
          'html_body': htmlBody,
          'description': description,
        })
        .eq('id', id)
        .eq('status', 'draft')
        .select()
        .single();
    return EmailTemplateModel.fromMap(row);
  }

  Future<void> replaceVariables(
    String templateId,
    List<EmailTemplateVariableModel> variables,
  ) async {
    await _client
        .from('email_template_variables')
        .delete()
        .eq('template_id', templateId);

    if (variables.isEmpty) return;
    await _client
        .from('email_template_variables')
        .insert(
          variables
              .map(
                (variable) => {
                  ...variable.toInsertMap(),
                  'template_id': templateId,
                },
              )
              .toList(),
        );
  }

  Future<EmailTemplateModel> getTemplate(String id) async {
    final row = await _client
        .from('email_templates')
        .select()
        .eq('id', id)
        .single();

    return EmailTemplateModel.fromMap(row);
  }

  Future<void> publish(String templateId, {required bool isDefault}) {
    return _client.rpc(
      'publish_email_template_version',
      params: {'p_template_id': templateId, 'p_is_default': isDefault},
    );
  }
}
