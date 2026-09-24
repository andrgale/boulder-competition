import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/permission_service.dart';
import '../../models/permission_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class PermissionsListPage extends StatefulWidget {
  const PermissionsListPage({super.key});

  @override
  State<PermissionsListPage> createState() => _PermissionsListPageState();
}

class _PermissionsListPageState extends State<PermissionsListPage> {
  final service = PermissionService();
  final searchController = TextEditingController();
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // controller condiviso tra Scrollbar e SingleChildScrollView
  final _verticalScrollController = ScrollController();

  List<PermissionModel> all = [];
  List<PermissionModel> filtered = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPermissions();
  }

  @override
  void dispose() {
    searchController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> loadPermissions() async {
    try {
      final data = await service.getPermissions();
      if (!mounted) return;
      setState(() {
        all = data;
        filtered = List.from(data);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      AppSnackbar.error(
        context,
        AppLocalizations.of(context)!.administrationMessaggeCustom27(e.toString()), // 'Errore: $e'
      );
    }
  }

  void applyFilter() {
    final q = searchController.text.trim().toLowerCase();
    setState(() {
      filtered = all.where((p) {
        return p.permissionCode.toLowerCase().contains(q) ||
            p.activity.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> deletePermission(PermissionModel p) async {
    final confirm = await AppConfirmDialog.showDelete(
      context: context,
      title: l10n.administrationMessaggeCustom74, // 'Elimina permesso'
      message: l10n.administrationMessaggeCustom83(p.permissionCode), // 'Vuoi eliminare "{code}"?'
    );
    if (!confirm || !mounted) return;

    try {
      await service.deletePermission(p.id);
      AppSnackbar.success(context, l10n.administrationMessaggeCustom84); // 'Permesso eliminato'
      await loadPermissions();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, l10n.administrationMessaggeCustom27(e.toString())); // 'Errore: $e'
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showBackButton: true,
      backRoute: '/security',
      title: l10n.administrationMessaggeCustom76, // 'Permessi'
      subtitle: l10n.administrationMessaggeCustom77, // 'Codici permesso e attività associate'
      loading: loading,
      empty: !loading && filtered.isEmpty,
      emptyMessage: l10n.administrationMessaggeCustom78, // 'Nessun permesso trovato'
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push('/security/permissions/new');
            await loadPermissions();
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.administrationMessaggeCustom75), // 'Nuovo Permesso'
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ricerca ─────────────────────────────────────
          SizedBox(
            width: 360,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: l10n.administrationMessaggeCustom79, // 'Cerca codice o attività'
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => applyFilter(),
            ),
          ),

          const SizedBox(height: 24),

          // ── tabella ──────────────────────────────────────
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: _verticalScrollController,
        thumbVisibility: true, // barra sempre visibile
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            // scroll orizzontale per code lunghi
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 360,
              ),
              child: DataTable(
                columnSpacing: 48,
                horizontalMargin: 32,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                headingRowHeight: 56,
                columns: [
                  DataColumn(label: Text(l10n.administrationMessaggeCustom80)), // 'Codice Permesso'
                  DataColumn(label: Text(l10n.administrationMessaggeCustom81)), // 'Attività'
                  DataColumn(label: Text(l10n.administrationMessaggeCustom82)), // 'Azioni'
                ],
                rows: filtered.map((p) => _buildRow(p)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(PermissionModel p) {
    return DataRow(
      cells: [
        // ── codice ──────────────────────────────────────
        DataCell(
          Text(
            p.permissionCode,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),

        // ── attività ────────────────────────────────────
        DataCell(
          SizedBox(
            width: 460,
            child: Text(
              p.activity,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // ── azioni ──────────────────────────────────────
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l10n.administrationMessaggeCustom31, // 'Modifica'
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await context.push(
                    '/security/permissions/edit',
                    extra: p,
                  );
                  await loadPermissions();
                },
              ),
              IconButton(
                tooltip: l10n.administrationMessaggeCustom32, // 'Elimina'
                icon: const Icon(Icons.delete),
                onPressed: () => deletePermission(p),
              ),
            ],
          ),
        ),
      ],
    );
  }
}