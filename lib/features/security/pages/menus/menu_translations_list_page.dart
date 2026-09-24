import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/menu_translation_service_admin.dart';
import '../../models/menu_model.dart';
import '../../models/menu_translation_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class MenuTranslationsListPage extends StatefulWidget {
  final MenuModel menu;

  const MenuTranslationsListPage({super.key, required this.menu});

  @override
  State<MenuTranslationsListPage> createState() =>
      _MenuTranslationsListPageState();
}

class _MenuTranslationsListPageState extends State<MenuTranslationsListPage> {
  final service = MenuTranslationServiceAdmin();

  List<MenuTranslationModel> translations = [];
  bool loading = true;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    loadTranslations();
  }

  Future<void> loadTranslations() async {
    try {
      final data = await service.getTranslations(widget.menu.id);
      if (!mounted) return;
      setState(() {
        translations = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      AppSnackbar.error(context, AppLocalizations.of(context)!.administrationMessaggeCustom27(e.toString())); // 'Errore: $e'
    }
  }

  Future<void> deleteTranslation(MenuTranslationModel t) async {
    final confirm = await AppConfirmDialog.showDelete(
      context: context,
      title: l10n.administrationMessaggeCustom68, // 'Elimina traduzione'
      message: l10n.administrationMessaggeCustom69(t.locale, t.label), // 'Vuoi eliminare la traduzione "{locale}" ("{label}")?'
    );
    if (!confirm || !mounted) return;

    try {
      await service.deleteTranslation(t.id);
      AppSnackbar.success(context, l10n.administrationMessaggeCustom70); // 'Traduzione eliminata'
      await loadTranslations();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, l10n.administrationMessaggeCustom27(e.toString())); // 'Errore: $e'
    }
  }

  // lingue non ancora tradotte, per abilitare/disabilitare "Nuova traduzione"
  List<String> get _availableLocales {
    final used = translations.map((t) => t.locale).toSet();
    return MenuTranslationServiceAdmin.supportedLocales
        .where((l) => !used.contains(l))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _availableLocales.isNotEmpty;

    return BasePage(
      showBackButton: true,
      title: l10n.administrationMessaggeCustom71, // 'Traduzioni'
      subtitle: l10n.administrationMessaggeCustom63(widget.menu.label, widget.menu.route), // '"${widget.menu.label}" — ${widget.menu.route}'
      loading: loading,
      empty: !loading && translations.isEmpty,
      emptyMessage: l10n.administrationMessaggeCustom72, // 'Nessuna traduzione configurata (viene usata la label predefinita)'
      actions: [
        FilledButton.icon(
          onPressed: canAdd
              ? () async {
                  await context.push(
                    '/security/menus/translations/new',
                    extra: widget.menu,
                  );
                  await loadTranslations();
                }
              : null,
          icon: const Icon(Icons.add),
          label: Text(l10n.administrationMessaggeCustom62), // 'Nuova Traduzione'
        ),
      ],
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // riga informativa con la label di default (fallback)
            Container(
              width: double.infinity,
              color: const Color(0xFFF6F8FB),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.administrationMessaggeCustom73(widget.menu.label), // 'Label predefinita (fallback): "${widget.menu.label}"'
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...translations.map(
              (t) => _TranslationTile(
                translation: t,
                onEdit: () async {
                  await context.push(
                    '/security/menus/translations/edit',
                    extra: {'menu': widget.menu, 'translation': t},
                  );
                  await loadTranslations();
                },
                onDelete: () => deleteTranslation(t),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslationTile extends StatelessWidget {
  final MenuTranslationModel translation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TranslationTile({
    required this.translation,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue.shade50,
          child: Text(
            translation.locale.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        title: Text(translation.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.administrationMessaggeCustom31, // 'Modifica'
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: l10n.administrationMessaggeCustom32, // 'Elimina'
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}