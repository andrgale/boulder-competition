import 'package:flutter/material.dart';

import '../../../../shared/app_snackbar.dart';
import '../../data/role_service.dart';
import '../../data/permission_service.dart' as admin_ps;
import '../../data/menu_service_admin.dart';
import '../../models/role_model.dart';
import '../../models/permission_model.dart';
import '../../models/menu_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class RoleManagePage extends StatefulWidget {
  final RoleModel role;

  const RoleManagePage({super.key, required this.role});

  @override
  State<RoleManagePage> createState() => _RoleManagePageState();
}

class _RoleManagePageState extends State<RoleManagePage>
    with SingleTickerProviderStateMixin {
  final roleService = RoleService();
  final permService = admin_ps.PermissionService();
  final menuService = MenuServiceAdmin();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  late TabController tabController;

  // permissions
  List<PermissionModel> allPermissions = [];
  Set<String> selectedPermIds = {};

  // menus
  List<MenuModel> allMenus = [];
  Set<String> selectedMenuIds = {};

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadAll();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> loadAll() async {
    try {
      final results = await Future.wait([
        permService.getPermissions(),
        menuService.getMenus(),
        roleService.getRolePermissionIds(widget.role.id),
        roleService.getRoleMenuIds(widget.role.id),
      ]);

      if (!mounted) return;

      setState(() {
        allPermissions = results[0] as List<PermissionModel>;
        allMenus = results[1] as List<MenuModel>;
        selectedPermIds =
            Set<String>.from(results[2] as List<String>);
        selectedMenuIds =
            Set<String>.from(results[3] as List<String>);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      AppSnackbar.error(context, l10n.administrationMessageCustom148(e.toString())); // 'Errore caricamento: {error}'
    }
  }

  Future<void> savePermissions() async {
    setState(() => saving = true);
    try {
      await roleService.setRolePermissions(
        roleId: widget.role.id,
        permissionIds: selectedPermIds.toList(),
      );
      if (!mounted) return;
      AppSnackbar.success(context, l10n.administrationMessageCustom149); // 'Permessi salvati'
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, l10n.administrationMessageCustom150(e.toString())); // 'Errore salvataggio permessi: {error}'
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> saveMenus() async {
    setState(() => saving = true);
    try {
      await roleService.setRoleMenus(
        roleId: widget.role.id,
        menuIds: selectedMenuIds.toList(),
      );
      if (!mounted) return;
      AppSnackbar.success(context, l10n.administrationMessageCustom151); // 'Menu salvati'
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, l10n.administrationMessageCustom152(e.toString())); // 'Errore salvataggio menu: {error}'
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.administrationMessageCustom144(widget.role.name), // 'Gestione ruolo: ${widget.role.name}'
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.administrationMessageCustom145(widget.role.code), // 'Codice: ${widget.role.code}'
                        style: const TextStyle(
                            fontFamily: 'monospace', color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (saving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
          ),
          // ─── tabs ─────────────────────────────────────────
          const SizedBox(height: 16),
          TabBar(
            controller: tabController,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            tabs: [
              Tab(icon: const Icon(Icons.lock_outline), text: l10n.administrationMessageCustom146), // 'Permessi'
              Tab(icon: const Icon(Icons.menu_book_outlined), text: l10n.administrationMessageCustom147), // 'Menu'
            ],
          ),
          const Divider(height: 1),
          // ─── content ──────────────────────────────────────
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: tabController,
                    children: [
                      _PermissionsTab(
                        permissions: allPermissions,
                        selected: selectedPermIds,
                        onToggle: (id, val) {
                          setState(() {
                            val
                                ? selectedPermIds.add(id)
                                : selectedPermIds.remove(id);
                          });
                        },
                        onSave: saving ? null : savePermissions,
                      ),
                      _MenusTab(
                        menus: allMenus,
                        selected: selectedMenuIds,
                        onToggle: (id, val) {
                          setState(() {
                            val
                                ? selectedMenuIds.add(id)
                                : selectedMenuIds.remove(id);
                          });
                        },
                        onSave: saving ? null : saveMenus,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// PERMISSIONS TAB
// ──────────────────────────────────────────────────────────

class _PermissionsTab extends StatelessWidget {
  final List<PermissionModel> permissions;
  final Set<String> selected;
  final void Function(String id, bool val) onToggle;
  final VoidCallback? onSave;

  const _PermissionsTab({
    required this.permissions,
    required this.selected,
    required this.onToggle,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
    // raggruppa per prefisso (parte prima del '.')
    final Map<String, List<PermissionModel>> groups = {};
    for (final p in permissions) {
      final prefix = p.permissionCode.contains('.')
          ? p.permissionCode.split('.').first
          : 'other';
      groups.putIfAbsent(prefix, () => []).add(p);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: groups.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                          letterSpacing: 1.2),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: entry.value.map((p) {
                        final isSelected = selected.contains(p.id);
                        return CheckboxListTile(
                          title: Text(p.permissionCode,
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(p.activity),
                          value: isSelected,
                          onChanged: (val) =>
                              onToggle(p.id, val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
        ),
        _SaveBar(onSave: onSave, label: l10n.administrationMessageCustom153), // 'Salva Permessi'
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
// MENUS TAB
// ──────────────────────────────────────────────────────────

class _MenusTab extends StatelessWidget {
  final List<MenuModel> menus;
  final Set<String> selected;
  final void Function(String id, bool val) onToggle;
  final VoidCallback? onSave;

  const _MenusTab({
    required this.menus,
    required this.selected,
    required this.onToggle,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // radici (parent_id null)
    final roots = menus.where((m) => m.parentId == null).toList();
    final children = menus.where((m) => m.parentId != null).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: roots.map((root) {
              final kids =
                  children.where((c) => c.parentId == root.id).toList();

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: Row(
                        children: [
                          Icon(_iconFromName(root.icon),
                              size: 20, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Text(root.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text(root.route,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: 'monospace')),
                        ],
                      ),
                      value: selected.contains(root.id),
                      onChanged: (val) => onToggle(root.id, val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (kids.isNotEmpty) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ...kids.map((kid) => CheckboxListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 48, right: 16),
                            title: Row(
                              children: [
                                Icon(_iconFromName(kid.icon),
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(kid.label),
                                const SizedBox(width: 8),
                                Text(kid.route,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontFamily: 'monospace')),
                              ],
                            ),
                            value: selected.contains(kid.id),
                            onChanged: (val) =>
                                onToggle(kid.id, val ?? false),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                          )),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        _SaveBar(onSave: onSave, label: l10n.administrationMessageCustom154), // 'Salva Menu'
      ],
    );
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'dashboard':
        return Icons.dashboard;
      case 'groups':
        return Icons.groups;
      case 'terrain':
        return Icons.terrain;
      case 'leaderboard':
        return Icons.leaderboard;
      case 'sports_score':
        return Icons.sports_score;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'category':
        return Icons.category;
      case 'person':
        return Icons.person;
      default:
        return Icons.circle_outlined;
    }
  }
}

// ──────────────────────────────────────────────────────────
// SAVE BAR
// ──────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final VoidCallback? onSave;
  final String label;

  const _SaveBar({required this.onSave, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            label: Text(label),
          ),
        ],
      ),
    );
  }
}