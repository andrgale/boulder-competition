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
  final _scrollController = ScrollController();

  List<RoleModel> roles = [];
  bool loading = true;

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
        separatorBuilder: (_, __) => const SizedBox(height: 12),
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

    // ── Desktop: card con scroll verticale e larghezza piena ──
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: ConstrainedBox(
            // Occupa almeno tutta la larghezza disponibile
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: DataTable(
              // Spaziatura generosa per desktop
              columnSpacing: 48,
              horizontalMargin: 32,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 64,
              headingRowHeight: 60,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF374151),
              ),
              dividerThickness: 1,
              columns: const [
                DataColumn(
                  label: Text('Codice'),
                ),
                DataColumn(
                  label: Text('Nome'),
                ),
                DataColumn(
                  label: Text('Azioni'),
                ),
              ],
              rows: roles.map((role) {
                return DataRow(
                  cells: [
                    // ── Codice ─────────────────────────────
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role.code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ),

                    // ── Nome ───────────────────────────────
                    DataCell(
                      Text(
                        role.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // ── Azioni ─────────────────────────────
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            tooltip: 'Menu & Permessi',
                            icon: Icons.tune,
                            color: Colors.blue.shade700,
                            onPressed: () async {
                              await context.push(
                                '/security/roles/manage',
                                extra: role,
                              );
                              await loadRoles();
                            },
                          ),
                          const SizedBox(width: 4),
                          _ActionButton(
                            tooltip: 'Modifica',
                            icon: Icons.edit_outlined,
                            color: Colors.green.shade700,
                            onPressed: () async {
                              await context.push(
                                '/security/roles/edit',
                                extra: role,
                              );
                              await loadRoles();
                            },
                          ),
                          const SizedBox(width: 4),
                          _ActionButton(
                            tooltip: 'Elimina',
                            icon: Icons.delete_outline,
                            color: Colors.red.shade700,
                            onPressed: () => deleteRole(role),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ACTION BUTTON — icona con colore e hover
// ──────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// MOBILE CARD
// ──────────────────────────────────────────────────────────────

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
            Text(
              role.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                role.code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionButton(
                  tooltip: 'Menu & Permessi',
                  icon: Icons.tune,
                  color: Colors.blue.shade700,
                  onPressed: onManage,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  tooltip: 'Modifica',
                  icon: Icons.edit_outlined,
                  color: Colors.green.shade700,
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  tooltip: 'Elimina',
                  icon: Icons.delete_outline,
                  color: Colors.red.shade700,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}