//import 'dart:io';

import 'package:boulder_competition/core/models/client_config.dart';
import 'package:boulder_competition/core/pages/activation_screen.dart';
import 'package:boulder_competition/core/services/central_config_service.dart';
import 'package:boulder_competition/core/services/client_config_store.dart';
import 'package:boulder_competition/features/notifications/pages/foreground_push_banner.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/locale_override_controller.dart';
import 'core/services/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'config/app_mode.dart';
import 'core/routing/app_router.dart';

// Chiave globale per poter richiamare il reset da qualunque punto dell'app
// (es. da una eventuale pagina impostazioni/admin lato atleta) senza
// passare callback attraverso tutto l'albero.
final bootstrapAppKey = GlobalKey<BootstrapAppState>();
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BootstrapApp(key: bootstrapAppKey));
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => BootstrapAppState();
}

// Nota: non privata (niente underscore) per poterla referenziare
// tramite GlobalKey<BootstrapAppState> da altri file.
class BootstrapAppState extends State<BootstrapApp> {
  bool _loading = true;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final cached = await ClientConfigStore.load();
    if (cached != null) {
      // Credenziali già presenti in locale: salta l'attivazione
      // e si collega direttamente al Supabase del cliente.
      await _initSupabase(cached);
      setState(() {
        _ready = true;
        _loading = false;
      });
    } else {
      // Primo avvio (o dopo un reset): mostra la schermata di attivazione.
      setState(() => _loading = false);
    }
  }


  Future<void> _initSupabase(ClientConfig cfg) async {
    await Supabase.initialize(
      url: cfg.supabaseUrl,
      anonKey: cfg.supabaseAnonKey,
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await PushNotificationService.instance.start();
  }

  Future<void> _onActivate(String clientId, String password) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cfg = await CentralConfigService.authenticate(
        clientId: clientId,
        password: password,
      );
      await ClientConfigStore.save(cfg);
      await _initSupabase(cfg);
      setState(() {
        _ready = true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // usa la stringa localizzata per l'errore
      final l10n = AppLocalizations.of(context);
      setState(() {
        _error = l10n?.athleteMessageCustom1 ?? 'Attivazione fallita: credenziali non valide';
        _loading = false;
      });
    }
  }

  /// Da chiamare per "scollegare" il dispositivo dal cliente corrente
  /// e tornare alla schermata di attivazione. Utile per testare più
  /// clienti sullo stesso dispositivo durante lo sviluppo, o come base
  /// per un'eventuale funzione "cambia palestra" lato atleta.
  Future<void> resetToActivation() async {
    await Supabase.instance.client.auth.signOut().catchError((_) {});
    await ClientConfigStore.clear();
    setState(() {
      _ready = false;
      _loading = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (!_ready) {
      // MaterialApp con delegati di localizzazione così ActivationScreen
      // e i messaggi d'errore possono usare AppLocalizations.
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it'),
          Locale('en'),
        ],
        home: ActivationScreen(onSubmit: _onActivate, error: _error),
      );
    }

    AppConfig.mode = AppMode.athlete;
    AppConfig.mostraCampo = true;
    return const AthleteApp();
  }
}
class AthleteApp extends StatelessWidget {
  const AthleteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeOverrideNotifier,
      builder: (context, overrideLocale, _) {
        return MaterialApp.router(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('it'),
            Locale('en'),
          ],
          locale: overrideLocale,
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          title: 'Athlete Boulder',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.green,
          ),
          builder: (context, child) {
            return ForegroundPushBanner(
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}