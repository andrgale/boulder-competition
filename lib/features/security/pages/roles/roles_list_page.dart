import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/responsive_table.dart';
import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/app_snackbar.dart';
import '../../../../core/ui/responsive.dart';

import '../../data/role_service.dart';
import '../../models/role_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class RolesListPage extends StatefulWidget {
  const RolesListPage({super.key});

  @override
  State<RolesListPage> createState() => _RolesListPageState();
}

class _RolesListPageState extends State<RolesListPage> {
  final service = RoleService();
  final _scrollController = ScrollController();

  List<RoleModel> roles = [];
  bool loading = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;
  
  @override
  void initState() {
    super.initState();
    loadRoles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadRoles() async {
    try {
      final data = await service.getRoles();
      if (!mounted) return;
      setState(() {
        roles = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      AppSnackbar.error(context, l10n.administrationMessageCustom127(e.toString())); // 'Errore caricamento ruoli: $e'
    }
  }

  Future<void> deleteRole(RoleModel role) async {
    final confirm = await AppConfirmDialog.showDelete(
      context: context,
      title: l10n.administrationMessageCustom128, // 'Elimina ruolo'
      message: l10n.administrationMessageCustom129(role.name), // 'Vuoi eliminare il ruolo "{name}"?\nTutti gli utenti e i menu associati perderanno questo ruolo.'
    );

    if (!confirm || !mounted) return;

    try {
      await service.deleteRole(role.id);
      AppSnackbar.success(context, l10n.administrationMessageCustom130); // 'Ruolo eliminato'
      await loadRoles();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, l10n.administrationMessageCustom131(e.toString())); // 'Errore eliminazione: $e'
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showBackButton: true,
      backRoute: '/security',
      title: l10n.administrationMessageCustom123, // 'Ruoli'
      subtitle: l10n.administrationMessageCustom124, // 'Gestione ruoli applicativi'
      loading: loading,
      empty: !loading && roles.isEmpty,
      emptyMessage: l10n.administrationMessageCustom125, // 'Nessun ruolo configurato'
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push('/security/roles/new');
            await loadRoles();
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.administrationMessageCustom126), // 'Nuovo Ruolo'
        ),
      ],
      child: _RolesContent(
        roles: roles,
        onDelete: deleteRole,
        onReload: loadRoles,
        scrollController: _scrollController,
      ),
    );
  }
}

// ✅ ORCHESTRATORE RESPONSIVE

class _RolesContent extends StatelessWidget {
  final List<RoleModel> roles;
  final Future<void> Function(RoleModel) onDelete;
  final Future<void> Function() onReload;
  final ScrollController scrollController;

  const _RolesContent({
    required this.roles,
    required this.onDelete,
    required this.onReload,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final screen = context.responsive;

    switch (screen.screenSize) {
      case ScreenSize.mobile:
        return _RolesMobileView(
          roles: roles,
          onDelete: onDelete,
          onReload: onReload,
        );

      case ScreenSize.tablet:
        return _RolesTabletView(
          roles: roles,
          scrollController: scrollController,
          onDelete: onDelete,
          onReload: onReload,
        );

      case ScreenSize.desktop:
        return _RolesDesktopView(
          roles: roles,
          scrollController: scrollController,
          onDelete: onDelete,
          onReload: onReload,
        );
    }
  }
}

// ✅ MOBILE

class _RolesMobileView extends StatelessWidget {
  final List<RoleModel> roles;
  final Future<void> Function(RoleModel) onDelete;
  final Future<void> Function() onReload;

  const _RolesMobileView({
    required this.roles,
    required this.onDelete,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: roles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final role = roles[i];

        return _RoleMobileCard(
          role: role,
          onEdit: () async {
            await context.push('/security/roles/edit', extra: role);
            await onReload();
          },
          onDelete: () => onDelete(role),
          onManage: () async {
            await context.push('/security/roles/manage', extra: role);
            await onReload();
          },
        );
      },
    );
  }
}

// ✅ TABLET

class _RolesTabletView extends StatelessWidget {
  final List<RoleModel> roles;
  final ScrollController scrollController;
  final Future<void> Function(RoleModel) onDelete;
  final Future<void> Function() onReload;

  const _RolesTabletView({
    required this.roles,
    required this.scrollController,
    required this.onDelete,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveTable(
      controller: scrollController,
      columns: [
        DataColumn(label: Text(l10n.administrationMessageCustom132)), // 'Codice'
        DataColumn(label: Text(l10n.administrationMessageCustom133)), // 'Nome'
        DataColumn(label: Text(l10n.administrationMessageCustom134)), // 'Azioni'
      ],
      rows: roles.map((role) {
        return DataRow(
          cells: [
            DataCell(Text(role.code)),
            DataCell(Text(role.name)),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () async {
                      await context.push('/security/roles/manage',
                          extra: role);
                      await onReload();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await context.push('/security/roles/edit',
                          extra: role);
                      await onReload();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(role),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ✅ DESKTOP
class _RolesDesktopView extends StatelessWidget {
  final List<RoleModel> roles;
  final ScrollController scrollController;
  final Future<void> Function(RoleModel) onDelete;
  final Future<void> Function() onReload;

  const _RolesDesktopView({
    required this.roles,
    required this.scrollController,
    required this.onDelete,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveTable(
      controller: scrollController,
      columns: [
        DataColumn(label: Text(l10n.administrationMessageCustom132)), // 'Codice'
        DataColumn(label: Text(l10n.administrationMessageCustom133)), // 'Nome'
        DataColumn(label: Text(l10n.administrationMessageCustom134)), // 'Azioni'
      ],
      rows: roles.map((role) {
        return DataRow(
          cells: [
            DataCell(Text(role.code)),
            DataCell(Text(role.name)),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () async {
                      await context.push('/security/roles/manage',
                          extra: role);
                      await onReload();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await context.push('/security/roles/edit',
                          extra: role);
                      await onReload();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(role),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ✅ MOBILE CARD (UNCHANGED CLEAN)

class _RoleMobileCard extends StatelessWidget {
  final RoleModel role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManage;

  const _RoleMobileCard({
    required this.role,
    required this.onEdit,
    required this.onDelete,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(role.code),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.tune), onPressed: onManage),
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
              ],
            )
          ],
        ),
      ),
    );
  }
}