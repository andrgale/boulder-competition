import 'dart:async';

import 'package:boulder_competition/core/routing/app_router.dart';
import 'package:boulder_competition/core/services/push_notification_service.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ForegroundPushBanner extends StatefulWidget {
  const ForegroundPushBanner({
    required this.scaffoldMessengerKey,
    required this.child,
    super.key,
  });

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Widget child;

  @override
  State<ForegroundPushBanner> createState() => _ForegroundPushBannerState();
}

class _ForegroundPushBannerState extends State<ForegroundPushBanner> {
  StreamSubscription<RemoteMessage>? _subscription;
 AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();

    _subscription =
        PushNotificationService.instance.foregroundMessages.listen(
      _showForegroundBanner,
    );
  }

  void _showForegroundBanner(RemoteMessage message) {
    final type = message.data['type'];
  //  final localizations = AppLocalizations.of(context);
    final messenger = widget.scaffoldMessengerKey.currentState;

    if (messenger == null) {
      return;
    }

    messenger.hideCurrentMaterialBanner();

    if (type == 'competition_closed') {
      messenger.showMaterialBanner(
        MaterialBanner(
          backgroundColor: Colors.red.shade50,
          leading: const Icon(
            Icons.sports_score_outlined,
            color: Colors.red,
          ),
          content: Text(
            '${l10n.notificationMessageCustom1}\n' //Gara conclusa
            '${l10n.notificationMessageCustom2}',  // La gara è terminata. Non è più possibile registrare boulder. 
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: Text(l10n.notificationMessageCustom3), // Ho capito
            ),
          ],
        ),
      );
      return;
    }

    if (type == 'competition_open') {
      messenger.showMaterialBanner(
        MaterialBanner(
          backgroundColor: Colors.green.shade50,
          leading: const Icon(
            Icons.emoji_events_outlined,
            color: Colors.green,
          ),
          content: Text(
            '${l10n.notificationMessageCustom4}\n' //Gara aperta
            '${l10n.notificationMessageCustom5}', // La gara è stata aperta. Puoi registrare i boulder.
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
                appRouter.goNamed('athlete_boulders');
              },
              child: Text(l10n.notificationMessageCustom6), // Vai alla gara
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}