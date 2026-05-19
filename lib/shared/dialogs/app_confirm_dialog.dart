import 'package:flutter/material.dart';

class AppConfirmDialog {
  // =======================================================
  // DELETE DIALOG
  // =======================================================

  static Future<bool> showDelete({
    required BuildContext context,

    required String title,

    required String message,

    String confirmText = 'Elimina',

    String cancelText = 'Annulla',
  }) async {
    final result = await showDialog<bool>(
      context: context,

      barrierDismissible: false,

      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          titlePadding:
              const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            0,
          ),

          contentPadding:
              const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            0,
          ),

          actionsPadding:
              const EdgeInsets.all(16),

          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,

                color:
                    Theme.of(context)
                        .colorScheme
                        .error,

                size: 32,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: Text(
            message,

            style: TextStyle(
              fontSize: 16,

              color:
                  Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: Text(cancelText),
            ),

            FilledButton.icon(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context)
                        .colorScheme
                        .error,

                foregroundColor:
                    Theme.of(context)
                        .colorScheme
                        .onError,
              ),

              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              icon: const Icon(Icons.delete),

              label: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // =======================================================
  // GENERIC CONFIRM
  // =======================================================

  static Future<bool> showConfirm({
    required BuildContext context,

    required String title,

    required String message,

    String confirmText = 'Conferma',

    String cancelText = 'Annulla',

    IconData icon = Icons.help_outline,
  }) async {
    final result = await showDialog<bool>(
      context: context,

      barrierDismissible: false,

      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              Icon(icon),

              const SizedBox(width: 16),

              Expanded(
                child: Text(title),
              ),
            ],
          ),

          content: Text(message),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: Text(cancelText),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // =======================================================
  // INFO
  // =======================================================

  static Future<void> showInfo({
    required BuildContext context,

    required String title,

    required String message,
  }) async {
    await showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Text(title),

          content: Text(message),

          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}