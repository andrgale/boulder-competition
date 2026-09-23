import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:boulder_competition/core/routing/app_router.dart';
import 'package:flutter/widgets.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance =
      PushNotificationService._();

  FirebaseMessaging? _messaging;

  final StreamController<RemoteMessage> _foregroundMessagesController =
    StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get foregroundMessages =>
    _foregroundMessagesController.stream;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _notificationOpenedSubscription;

  bool _started = false;

 // static Future<void>? _firebaseInitialization;

  Future<void> start() async {
    if (_started || !_supportsPushPlatform) return;

    // Inizializza Firebase prima di accedere a FirebaseMessaging.
 //   _firebaseInitialization ??= Firebase.initializeApp();
 //   await _firebaseInitialization;

    _messaging ??= FirebaseMessaging.instance;
    
    debugPrint('🔥 Firebase inizializzato');
    debugPrint('🔥 Firebase app: ${Firebase.app().name}');
    
    _started = true;

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    _notificationOpenedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationOpened,
    );

    final initialMessage = await _messaging!.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationOpened(initialMessage);
    }

    await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Su iOS, quando l'app è aperta, usiamo il banner Flutter.
    // Evita di mostrare anche un secondo avviso nativo di sistema.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging!.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }

    _tokenSubscription = _messaging!.onTokenRefresh.listen(_saveToken);

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.initialSession) {
        unawaited(registerCurrentDevice());
      }
    });

    await registerCurrentDevice();
  }

  void _handleForegroundMessage(RemoteMessage message) {
  // debugPrint('🔔 Push ricevuta mentre l’app è aperta');
  // debugPrint('🔔 Titolo: ${message.notification?.title}');
  // debugPrint('🔔 Corpo: ${message.notification?.body}');
  // debugPrint('🔔 Dati: ${message.data}');

  _foregroundMessagesController.add(message);
  }

  void _handleNotificationOpened(RemoteMessage message) {
     debugPrint('🔔 Notifica aperta dall’utente');
     debugPrint('🔔 Dati: ${message.data}');

    if (message.data['type'] != 'competition_open') {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.goNamed('athlete_boulders');
    });
  }

  Future<void> registerCurrentDevice() async {
    if (!_supportsPushPlatform) return;

    final messaging = _messaging;
    if (messaging == null) {
      // debugPrint('🔥 Firebase Messaging non inizializzato');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // debugPrint('🔥 Nessun utente Supabase autenticato');
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await messaging.getAPNSToken();

      // debugPrint('🔥 APNs token: $apnsToken');

      if (apnsToken == null) {
        // debugPrint('🔥 APNs token non ancora disponibile');
        return;
      }
    }

    final token = await messaging.getToken();

    // debugPrint('🔥 FCM token: $token');

    if (token == null || token.isEmpty) {
     // debugPrint('🔥 FCM token non disponibile');
      return;
    }

    await _saveToken(token);

    // debugPrint('🔥 FCM token salvato su Supabase');
  }

  Future<void> _saveToken(String token) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    await Supabase.instance.client.from('user_devices').upsert(
      {
        'auth_user_id': user.id,
        'fcm_token': token,
        'platform':
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'language_code': _languageCode,    
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'fcm_token',
    );
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _authSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _notificationOpenedSubscription?.cancel();

    _tokenSubscription = null;
    _authSubscription = null;
    _foregroundMessageSubscription = null;
    _notificationOpenedSubscription = null;

    _started = false;
    _messaging = null;
  }

  String get _languageCode {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;

    return locale.languageCode.toLowerCase() == 'it' ? 'IT' : 'EN';
  }

  bool get _supportsPushPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}