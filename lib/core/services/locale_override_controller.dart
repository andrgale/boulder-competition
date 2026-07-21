import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier globale che tiene la lingua forzata per il testing.
/// null = nessun override, usa la lingua di sistema/normale risoluzione l10n.
final ValueNotifier<Locale?> localeOverrideNotifier = ValueNotifier(null);

const _prefsKey = 'debug_locale_override';

class LocaleOverrideController {
  /// Da chiamare in main() prima di runApp, per ripristinare
  /// l'eventuale override scelto in una sessione precedente.
  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      localeOverrideNotifier.value = Locale(code);
    }
  }

  /// Imposta (o rimuove, passando null) l'override e lo persiste.
  static Future<void> set(Locale? locale) async {
    localeOverrideNotifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}