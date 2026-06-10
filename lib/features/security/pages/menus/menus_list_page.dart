import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/menu_service_admin.dart';
import '../../models/menu_model.dart';

class MenusListPage extends StatefulWidget {
  const MenusListPage({super.key});

  @override
  State<MenusListPage> createState() => _MenusListPageState();
}

class _MenusListPageState extends State<MenusListPage> {
  final service = MenuServiceAdmin();

  List<MenuModel> menus = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMenus();
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
      AppSnackbar.error(context, 'Errore: $e');
    }
  }

  Future<void> deleteMenu(MenuModel m) async {
    final confirm = await AppConfirmDialog.showDelete(
      context: context,
      title: 'Elimina voce menu',
      message: 'Vuoi eliminare "${m.label}"?\n'
          'I sottomenu figli verranno eliminati a cascata.',
    );
    if (!confirm || !mounted) return;

    try {
      await service.deleteMenu(m.id);
      AppSnackbar.success(context, 'Voce eliminata');
      await loadMenus();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Errore: $e');
    }
  }

  List<MenuModel> get roots =>
      menus.where((m) => m.parentId == null).toList();

  List<MenuModel> childrenOf(String parentId) =>
      menus.where((m) => m.parentId == parentId).toList();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Menu',
      subtitle: 'Struttura di navigazione',
      loading: loading,
      empty: !loading && menus.isEmpty,
      emptyMessage: 'Nessuna voce menu configurata',
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push('/security/menus/new');
            await loadMenus();
          },
          icon: const Icon(Icons.add),
          label: const Text('Nuova Voce'),
        ),
      ],
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView(
          children: roots.expand((root) {
            final kids = childrenOf(root.id);
            return [
              _MenuTile(
                menu: root,
                isRoot: true,
                onEdit: () async {
                  await context.push('/security/menus/edit', extra: root);
                  await loadMenus();
                },
                onDelete: () => deleteMenu(root),
                onAddChild: () async {
                  // passa il parentId come extra
                  await context.push('/security/menus/new',
                      extra: root.id);
                  await loadMenus();
                },
              ),
              ...kids.map((kid) => _MenuTile(
                    menu: kid,
                    isRoot: false,
                    onEdit: () async {
                      await context.push('/security/menus/edit',
                          extra: kid);
                      await loadMenus();
                    },
                    onDelete: () => deleteMenu(kid),
                    onAddChild: null,
                  )),
            ];
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final MenuModel menu;
  final bool isRoot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddChild;

  const _MenuTile({
    required this.menu,
    required this.isRoot,
    required this.onEdit,
    required this.onDelete,
    this.onAddChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
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
            fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          menu.route,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // badge visibilità
            _VisibilityBadge(visible: menu.visible, mobile: menu.mobile, desktop: menu.desktop),
            const SizedBox(width: 8),
            // ordine
            Chip(
              label: Text('${menu.displayOrder}'),
              visualDensity: VisualDensity.compact,
            ),
            if (onAddChild != null)
              IconButton(
                tooltip: 'Aggiungi figlio',
                icon: const Icon(Icons.add),
                onPressed: onAddChild,
              ),
            IconButton(
              tooltip: 'Modifica',
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Elimina',
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

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
        Icon(visible ? Icons.visibility : Icons.visibility_off,
            size: 16,
            color: visible ? Colors.green : Colors.grey),
        const SizedBox(width: 4),
        Icon(Icons.smartphone,
            size: 16, color: mobile ? Colors.blue : Colors.grey.shade300),
        const SizedBox(width: 2),
        Icon(Icons.desktop_windows,
            size: 16,
            color: desktop ? Colors.blue : Colors.grey.shade300),
      ],
    );
  }
}
