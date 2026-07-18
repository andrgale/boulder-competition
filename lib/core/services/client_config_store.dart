import 'package:boulder_competition/core/models/client_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientConfigStore {
  static const _kClientId = 'client_id';
  static const _kDescription = 'client_description';
  static const _kUrl = 'supabase_url';
  static const _kKey = 'supabase_anon_key';

  static Future<ClientConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_kUrl);
    final key = prefs.getString(_kKey);
    final id = prefs.getString(_kClientId);
    if (url == null || key == null || id == null) return null;

    return ClientConfig(
      clientId: id,
      description: prefs.getString(_kDescription) ?? '',
      supabaseUrl: url,
      supabaseAnonKey: key,
    );
  }

  static Future<void> save(ClientConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kClientId, cfg.clientId);
    await prefs.setString(_kDescription, cfg.description);
    await prefs.setString(_kUrl, cfg.supabaseUrl);
    await prefs.setString(_kKey, cfg.supabaseAnonKey);
  }

  /// Utile se vuoi permettere di "riattivare" il device su un altro cliente
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kClientId);
    await prefs.remove(_kDescription);
    await prefs.remove(_kUrl);
    await prefs.remove(_kKey);
  }
}