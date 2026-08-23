import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/menu_service_admin.dart';
import '../../models/menu_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class MenusListPage extends StatefulWidget {
  const MenusListPage({super.key});

  @override
  State<MenusListPage> createState() => _MenusListPageState();
}

class _MenusListPageState extends State<MenusListPage> {
  final service = MenuServiceAdmin();

  // controller condiviso tra Scrollbar e ListView
  final _scrollController = ScrollController();

  List<MenuModel> menus = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMenus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadMenus() async {
    try {
      final data = await service.getMenus();
      if (!mounted) return;
      setState(() {
        menus = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      AppSnackbar.error(context, AppLocalizations.of(context)!.administrationMessaggeCustom27(e.toString())); // 'Errore: $e'
    }
  }

  Future<void> deleteMenu(MenuModel m) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await AppConfirmDialog.showDelete(
      context: context,
      title: l10n.administrationMessaggeCustom25, // 'Elimina voce menu'
      message: l10n.administrationMessaggeCustom26(m.label), // 'Vuoi eliminare "{label}"?\nI sottomenu figli verranno eliminati a cascata.'
    );
    if (!confirm || !mounted) return;

    try {
      await service.deleteMenu(m.id);
      AppSnackbar.success(context, l10n.administrationMessaggeCustom34); // 'Voce eliminata'
      await loadMenus();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, l10n.administrationMessaggeCustom27(e.toString())); // 'Errore: $e'
    }
  }

  List<MenuModel> get roots =>
      menus.where((m) => m.parentId == null).toList();

  List<MenuModel> childrenOf(String parentId) =>
      menus.where((m) => m.parentId == parentId).toList();

  // costruisce la lista piatta: root + figli indentati
  List<Widget> _buildMenuTiles() {
    return roots.expand((root) {
      final kids = childrenOf(root.id);
      return <Widget>[
        _MenuTile(
          menu: root,
          isRoot: true,
          onEdit: () async {
            await context.push('/security/menus/edit', extra: root);
            await loadMenus();
          },
          onDelete: () => deleteMenu(root),
          onAddChild: () async {
            await context.push('/security/menus/new', extra: root.id);
            await loadMenus();
          },
          onTranslations: () async {
            await context.push('/security/menus/translations', extra: root);
            await loadMenus();
          },
        ),
        ...kids.map(
          (kid) => _MenuTile(
            menu: kid,
            isRoot: false,
            onEdit: () async {
              await context.push('/security/menus/edit', extra: kid);
              await loadMenus();
            },
            onDelete: () => deleteMenu(kid),
            onAddChild: null,
            onTranslations: () async {
              await context.push('/security/menus/translations', extra: kid);
              await loadMenus();
            },
          ),
        ),
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BasePage(
      title: l10n.administrationMessaggeCustom5, // 'Menu'
      subtitle: l10n.administrationMessaggeCustom36, // 'Struttura di navigazione'
      loading: loading,
      empty: !loading && menus.isEmpty,
      emptyMessage: l10n.administrationMessaggeCustom33, // 'Nessuna voce menu configurata'
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push('/security/menus/new');
            await loadMenus();
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.administrationMessaggeCustom28), // 'Nuova Voce'
        ),
      ],
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        // ── Scrollbar avvolge la ListView ────────────────
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView(
            controller: _scrollController,
            children: _buildMenuTiles(),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// MENU TILE
// ──────────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final MenuModel menu;
  final bool isRoot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddChild;
  final VoidCallback onTranslations;

  const _MenuTile({
    required this.menu,
    required this.isRoot,
    required this.onEdit,
    required this.onDelete,
    this.onAddChild,
    required this.onTranslations,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: isRoot ? 20 : 48,
          right: 8,
        ),
        leading: Icon(
          isRoot ? Icons.menu : Icons.subdirectory_arrow_right,
          color: isRoot ? Colors.blue.shade700 : Colors.grey,
        ),
        title: Text(
          menu.label,
          style: TextStyle(
            fontWeight:
                isRoot ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          menu.route,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // badge visibilità / piattaforme
            _VisibilityBadge(
              visible: menu.visible,
              mobile: menu.mobile,
              desktop: menu.desktop,
            ),
            const SizedBox(width: 8),
            // numero ordine
            Chip(
              label: Text('${menu.displayOrder}'),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: l10n.administrationMessaggeCustom29, // 'Traduzioni'
              icon: const Icon(Icons.translate),
              onPressed: onTranslations,
            ),
            if (onAddChild != null)
              IconButton(
                tooltip: l10n.administrationMessaggeCustom30, // 'Aggiungi figlio'
                icon: const Icon(Icons.add),
                onPressed: onAddChild,
              ),
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

// ──────────────────────────────────────────────────────────────
// VISIBILITY BADGE
// ──────────────────────────────────────────────────────────────

class _VisibilityBadge extends StatelessWidget {
  final bool visible;
  final bool mobile;
  final bool desktop;

  const _VisibilityBadge({
    required this.visible,
    required this.mobile,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          visible ? Icons.visibility : Icons.visibility_off,
          size: 16,
          color: visible ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.smartphone,
          size: 16,
          color: mobile ? Colors.blue : Colors.grey.shade300,
        ),
        const SizedBox(width: 2),
        Icon(
          Icons.desktop_windows,
          size: 16,
          color: desktop ? Colors.blue : Colors.grey.shade300,
        ),
      ],
    );
  }
}