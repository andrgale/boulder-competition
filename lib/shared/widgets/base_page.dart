import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final String title;

  final String? subtitle;

  final Widget child;

  final List<Widget>? actions;

  final bool loading;

  final bool empty;

  final String emptyMessage;

  final Widget? floatingActionButton;

  const BasePage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.loading = false,
    this.empty = false,
    this.emptyMessage =
        'Nessun dato disponibile',
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          floatingActionButton,

      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,

      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // =================================================
          // HEADER
          // =================================================

          _PageHeader(
            title: title,
            subtitle: subtitle,
            actions: actions,
          ),

          // =================================================
          // CONTENT
          // =================================================

          Expanded(
            child: Builder(
              builder: (_) {
                // ===========================================
                // LOADING
                // ===========================================

                if (loading) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                // ===========================================
                // EMPTY STATE
                // ===========================================

                if (empty) {
                  return _EmptyState(
                    message: emptyMessage,
                  );
                }

                // ===========================================
                // CONTENT
                // ===========================================

                return child;
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// PAGE HEADER
// =========================================================

class _PageHeader extends StatelessWidget {
  final String title;

  final String? subtitle;

  final List<Widget>? actions;

  const _PageHeader({
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 24,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ===============================================
          // TITLES
          // ===============================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 8),

                  Text(
                    subtitle!,

                    style: TextStyle(
                      fontSize: 16,

                      color:
                          Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ===============================================
          // ACTIONS
          // ===============================================

          if (actions != null)
            Wrap(
              spacing: 12,
              children: actions!,
            ),
        ],
      ),
    );
  }
}

// =========================================================
// EMPTY STATE
// =========================================================

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.inbox_outlined,

            size: 72,

            color:
                Theme.of(context)
                    .colorScheme
                    .outline,
          ),

          const SizedBox(height: 24),

          Text(
            message,

            style: TextStyle(
              fontSize: 18,

              color:
                  Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}