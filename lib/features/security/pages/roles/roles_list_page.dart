import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/role_service.dart';
import '../../models/role_model.dart';

class RolesListPage extends StatefulWidget {
  const RolesListPage({super.key});

  @override
  State<RolesListPage> createState() => _RolesListPageState();
}

class _RolesListPageState extends State<RolesListPage> {
  final service = RoleService();

  List<RoleModel> roles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRoles();
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
      AppSnackbar.error(context, 'Errore caricamento ruoli: $e');
    }
  }

  Future<void> deleteRole(RoleModel role) async {
    final confirm = await AppConfirmDialog.showDelete(
      context: context,
      title: 'Elimina ruolo',
      message: 'Vuoi eliminare il ruolo "${role.name}"?\n'
          'Tutti gli utenti e i menu associati perderanno questo ruolo.',
    );

    if (!confirm || !mounted) return;

    try {
      await service.deleteRole(role.id);
      AppSnackbar.success(context, 'Ruolo eliminato');
      await loadRoles();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Errore eliminazione: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Ruoli',
      subtitle: 'Gestione ruoli applicativi',
      loading: loading,
      empty: !loading && roles.isEmpty,
      emptyMessage: 'Nessun ruolo configurato',
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push('/security/roles/new');
            await loadRoles();
          },
          icon: const Icon(Icons.add),
          label: const Text('Nuovo Ruolo'),
        ),
      ],
      child: _buildTable(),
    );
  }

  Widget _buildTable() {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return ListView.separated(
        itemCount: roles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _RoleMobileCard(
          role: roles[i],
          onEdit: () async {
            await context.push('/security/roles/edit', extra: roles[i]);
            await loadRoles();
          },
          onDelete: () => deleteRole(roles[i]),
          onManage: () async {
            await context.push('/security/roles/manage', extra: roles[i]);
            await loadRoles();
          },
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        columnSpacing: 48,
        horizontalMargin: 32,
        dataRowMinHeight: 64,
        dataRowMaxHeight: 64,
        headingRowHeight: 56,
        columns: const [
          DataColumn(label: Text('Codice')),
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('Azioni')),
        ],
        rows: roles.map((role) {
          return DataRow(cells: [
            DataCell(Text(role.code,
                style: const TextStyle(fontFamily: 'monospace'))),
            DataCell(Text(role.name)),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Menu & Permessi',
                  icon: const Icon(Icons.tune),
                  onPressed: () async {
                    await context.push('/security/roles/manage',
                        extra: role);
                    await loadRoles();
                  },
                ),
                IconButton(
                  tooltip: 'Modifica',
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await context.push('/security/roles/edit', extra: role);
                    await loadRoles();
                  },
                ),
                IconButton(
                  tooltip: 'Elimina',
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteRole(role),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}

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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(role.code,
                style: const TextStyle(
                    fontFamily: 'monospace', color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                    tooltip: 'Menu & Permessi',
                    icon: const Icon(Icons.tune),
                    onPressed: onManage),
                IconButton(
                    tooltip: 'Modifica',
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit),
                IconButton(
                    tooltip: 'Elimina',
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
